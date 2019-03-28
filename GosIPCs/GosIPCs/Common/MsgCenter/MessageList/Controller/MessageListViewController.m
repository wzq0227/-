//
//  MessageListViewController.m
//  GosIPCs
//
//  Created by ShenYuanLuo on 2018/12/17.
//  Copyright © 2018年 goscam. All rights reserved.
//

#import "MessageListViewController.h"
#import "MsgListTableViewCell.h"
#import "MsgSettingTableViewCell.h"
#import "PushMsgManager.h"
#import "MsgSettingViewController.h"
#import "APNSManager.h"
#import "GosDevManager.h"
#import "MsgDetailViewController.h"
#import "PushImageManager.h"
#import "GosBottomOperateView.h"

#define MSG_LIST_CELL_HEIGHT 46.0f  // 列表高度
#define OP_PUSH_LIST_TIMEOUT        15  // 推送消息列表操作超时时间（单位：秒）
#define OP_CACHE_PUSH_LIST_TIMEOUT  10   // 推送消息缓存列表操作超时时间（单位：秒）
#define SCROLLING_PUSH_LIST_TIMEOUNT 20  // 滚动后认为不再滚动超时时间（单位：秒）

@interface MessageListViewController () <
                                            UITableViewDataSource,
                                            UITableViewDelegate,
                                            GosBottomOperateViewDelegate
                                        >
{
    BOOL m_isEditing;       // 是否正在编辑
    BOOL m_hasSelectedAll;  // 是否全选
    BOOL m_isDeleting;      // 是否正在删除
    BOOL m_hasCheckedPushStatus;    // 是否已查询推送状态
    BOOL m_isShowingDetailVC; // 是否显示详情页面
    BOOL m_hasSwipeOnDetailVC;  // 详情页面是否左右滑动切换消息
    BOOL m_isScrolling;     // 是否正在滚动列表（停止滚动 'SCROLLING_PUSH_LIST_TIMEOUNT' 秒后认为不查看）
}
@property (weak, nonatomic) IBOutlet UITableView *msgListTableView;
@property (weak, nonatomic) IBOutlet UIImageView *noMsgImgView;
@property (weak, nonatomic) IBOutlet UILabel *noMsgLabel;
/** 推送消息列表 */
@property (nonatomic, readwrite, strong) NSMutableArray<PushMessage*>*pushMsgArray;
/** 推送消息列表操作 锁 */
@property (nonatomic, readwrite, strong) GosReadWriteLock *pushMsgListLock;
@property (nonatomic, readwrite, strong) NSIndexPath *curSelectedPath;
@property (nonatomic, readwrite, strong) NSMutableSet<NSNumber*>*hasSelectedRowSet;
@property (nonatomic, readwrite, strong) NSMutableSet<NSNumber*>*highLightRowSet;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewBottomMargin;
@property (nonatomic, readwrite, strong) dispatch_queue_t cachePushMsgQueue;
/** 需要处理的推送消息列表（编辑模式下接收到的消息） */
@property (nonatomic, readwrite, strong) NSMutableArray<PushMessage*>*needHandleMsgList;
/** 缓存最新消息（编辑模式下）列表操作 锁 */
@property (nonatomic, readwrite, strong) GosReadWriteLock *cacheMsgListLock;

@end

@implementation MessageListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initParam];
    [self configUI];
    [self addSaveSuccessMsgNotify];
    [self addClickMsgUpdateNotify];
    [self addMsgHasReadNotify];
    [self loadPushMsg];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self resetParam];
    [self configBottomViewHidden];
    [self configSelectedAllBtn];
    [self configDeleteBtn];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [SVProgressHUD dismiss];
    [NSObject cancelPreviousPerformRequestsWithTarget:self
                                             selector:@selector(recoverScrollStatus)
                                               object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    GosLog(@"---------- MessageListViewController dealloc ----------");
}

- (void)initParam
{
    m_hasCheckedPushStatus             = NO;
    self.cachePushMsgQueue             = dispatch_queue_create("GosCachePushMsgQueue", DISPATCH_QUEUE_SERIAL);
//    self.pushMsgListLock               = [[GosReadWriteLock alloc] init];
    self.pushMsgListLock.readTimeout   = OP_PUSH_LIST_TIMEOUT;
    self.pushMsgListLock.writeTimeout  = OP_PUSH_LIST_TIMEOUT;
//    self.cacheMsgListLock              = [[GosReadWriteLock alloc] init];
    self.cacheMsgListLock.readTimeout  = OP_CACHE_PUSH_LIST_TIMEOUT;
    self.cacheMsgListLock.writeTimeout = OP_CACHE_PUSH_LIST_TIMEOUT;
}

- (void)resetParam
{
    m_isEditing          = NO;
    m_hasSelectedAll     = NO;
    m_isDeleting         = NO;
    m_isShowingDetailVC  = NO;
    m_hasSwipeOnDetailVC = NO;
    m_isScrolling        = NO;
    [GosBottomOperateView configDelegate:self];
}

#pragma mark - UI 处理
- (void)configUI
{
    self.title = DPLocalizedString(@"Mine_MessageCenter");
    self.view.backgroundColor = GOS_VC_BG_COLOR;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:DPLocalizedString(@"GosComm_Edit")
                                                                              style:UIBarButtonItemStyleDone
                                                                             target:self
                                                                             action:@selector(rightBarBtnAction:)];
    [self configRightBarBtnTitle];
    [self configTableView];
}

#pragma mark -- 设置列表
- (void)configTableView
{
    self.msgListTableView.rowHeight                            = MSG_LIST_CELL_HEIGHT;
    self.msgListTableView.backgroundColor                      = GOS_VC_BG_COLOR;
    self.msgListTableView.separatorStyle                       = UITableViewCellSeparatorStyleNone;
    self.msgListTableView.bounces                              = NO;
    self.msgListTableView.allowsMultipleSelection              = NO;
    self.msgListTableView.allowsSelectionDuringEditing         = NO;
    self.msgListTableView.allowsMultipleSelectionDuringEditing = NO;
}

#pragma mark -- 检查是否需要提示没有消息
- (void)checkNoMsgTips
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self.pushMsgListLock lockRead];
        if (0 == self.pushMsgArray.count)
        {
            self.noMsgImgView.hidden = NO;
            self.noMsgLabel.hidden   = NO;
        }
        else
        {
            self.noMsgImgView.hidden = YES;
            self.noMsgLabel.hidden   = YES;
        }
        [self configRightBarBtnTitle];
        [self configBottomViewHidden];
        [self.pushMsgListLock unLockRead];
    });
}

#pragma mark -- 设置右按钮标题
- (void)configRightBarBtnTitle
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self.pushMsgListLock lockRead];
        NSString *titleStr = nil;
        if (NO == m_isEditing)
        {
            titleStr = DPLocalizedString(@"GosComm_Edit");
        }
        else
        {
            titleStr = DPLocalizedString(@"GosComm_Cancel");
        }
        if (0 == self.pushMsgArray.count)
        {
            titleStr = nil;
        }
        [self.navigationItem.rightBarButtonItem setTitle:titleStr];
        [self.pushMsgListLock unLockRead];
    });
}

#pragma mark -- 设置底部view是否隐藏
- (void)configBottomViewHidden
{
    CGFloat margin = 0;
    if (NO == m_isEditing)
    {
        GosLog(@"隐藏底部操作视图！");
        [GosBottomOperateView dismiss];
        margin = 0.0f;
    }
    else
    {
        GosLog(@"显示底部操作视图！");
        [GosBottomOperateView show];
        margin = 40.0f;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        
        self.tableViewBottomMargin.constant = margin;
    });
}

#pragma mark -- 设置全选按钮
- (void)configSelectedAllBtn
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSString *btnTitle = nil;
        if (NO == m_hasSelectedAll)
        {
            btnTitle = DPLocalizedString(@"GosComm_SelectAll");
        }
        else
        {
            btnTitle = DPLocalizedString(@"GosComm_CancelCheckAll");
        }
        [GosBottomOperateView configLeftTitle:btnTitle
                                     forState:UIControlStateNormal];
    });
}

#pragma mark -- 设置删除按钮
- (void)configDeleteBtn
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        UIColor *titleColr = nil;
        if (0 == self.hasSelectedRowSet.count)
        {
            titleColr = GOS_COLOR_RGBA(255.0f, 36.0f, 36.0f, 0.5f);
        }
        else
        {
            titleColr = GOS_COLOR_RGBA(255.0f, 36.0f, 36.0f, 1.0f);
        }
        [GosBottomOperateView configRightTitleColor:titleColr
                                           forState:UIControlStateNormal];
    });
}

#pragma mark - 刷新
#pragma mark -- 刷新列表
- (void)refreshTableView
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self.msgListTableView reloadData];
    });
}

#pragma mark -- 更新当前选择的 Cell
- (void)updateSelectedCell
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        GOS_WEAK_SELF;
        [UIView performWithoutAnimation:^{  // 防止页面抖动一下
            
            GOS_STRONG_SELF;
            CGPoint loc = strongSelf.msgListTableView.contentOffset;
            [strongSelf.msgListTableView reloadRowsAtIndexPaths:@[strongSelf.curSelectedPath]
                                               withRowAnimation:UITableViewRowAnimationNone];
            strongSelf.msgListTableView.contentOffset = loc;
        }];
    });
}

#pragma mark -- 滚动到当前选择 cell （由详情页面返回时）
- (void)scrollToIndexPath:(NSIndexPath *)indexPath
{
    if (!indexPath)
    {
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self.msgListTableView scrollToRowAtIndexPath:indexPath
                                     atScrollPosition:UITableViewScrollPositionMiddle
                                             animated:YES];
    });
}

#pragma mark -- 高亮显示指定 Cell
- (void)highLightIndicateCell:(NSUInteger)rowIndex
{
    [self.pushMsgListLock lockRead];
    if (self.pushMsgArray.count <= rowIndex)
    {
        [self.pushMsgListLock unLockRead];
        return;
    }
    GOS_WEAK_SELF;
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [UIView performWithoutAnimation:^{  // 防止页面抖动一下
            
            GOS_STRONG_SELF;
            CGPoint loc = strongSelf.msgListTableView.contentOffset;
            [strongSelf.highLightRowSet addObject:@(rowIndex)];
            
            GosLog(@"推送消息列表，高亮显示 cell， row = %ld", rowIndex);
            NSIndexPath *tempPath = [NSIndexPath indexPathForRow:rowIndex
                                                       inSection:1];
            [strongSelf.msgListTableView reloadRowsAtIndexPaths:@[tempPath]
                                               withRowAnimation:UITableViewRowAnimationNone];
            strongSelf.msgListTableView.contentOffset = loc;
        }];
    });
    // 恢复高亮显示
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        GOS_STRONG_SELF;
        [strongSelf recoverIndicateCell:rowIndex];
    });
}

#pragma mark -- 恢复（高亮显示）指定 Cell
- (void)recoverIndicateCell:(NSUInteger)rowIndex
{
    [self.pushMsgListLock lockRead];
    if (self.pushMsgArray.count <= rowIndex)
    {
        [self.pushMsgListLock unLockRead];
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        
        GOS_WEAK_SELF;
        [UIView performWithoutAnimation:^{  // 防止页面抖动一下
            
            GOS_STRONG_SELF;
            CGPoint loc = strongSelf.msgListTableView.contentOffset;
            NSIndexPath *tempPath = [NSIndexPath indexPathForRow:rowIndex
                                                       inSection:1];
            GosLog(@"推送消息列表，恢复（高亮显示）cell，row = %ld", rowIndex);
            [strongSelf.highLightRowSet removeObject:@(rowIndex)];
            [strongSelf.msgListTableView reloadRowsAtIndexPaths:@[tempPath]
                                               withRowAnimation:UITableViewRowAnimationNone];
            strongSelf.msgListTableView.contentOffset = loc;
        }];
    });
}

#pragma makr -- 恢复滚动状态
- (void)recoverScrollStatus
{
    m_isScrolling = NO;
    GosLog(@"距离上次已经有 %d 秒没有滚动列表啦！", SCROLLING_PUSH_LIST_TIMEOUNT);
}

#pragma mark - 数据处理
#pragma mark -- 加载推送消息数据
- (void)loadPushMsg
{
    NSArray<PushMessage*>*tempArray = nil;
    
    if (NO == self.isOnlyShowOnDevMsg) // 显示所有消息
    {
        tempArray = [PushMsgManager pushMsgList];
    }
    else    // 显示指定设备消息
    {
        tempArray = [PushMsgManager pushMsgListOfDevice:self.deviceModel.DeviceId];
    }
    [self.pushMsgListLock lockWrite];
    self.pushMsgArray = [tempArray mutableCopy];
    [self.pushMsgListLock unLockWrite];
    [self checkNoMsgTips];
    [self configRightBarBtnTitle];
}

#pragma mark -- 添加推送消息解析并成功保存至数据库通知
- (void)addSaveSuccessMsgNotify
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(successSaveMsg:)
                                                 name:kPushMsgSaveSuccessNotify
                                               object:nil];
}

#pragma mark -- 添加推送消息解析并成功保存至数据库b并同步更新列表通知
- (void)addClickMsgUpdateNotify
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(successSaveMsg:)
                                                 name:kClickPushMsgToUpdateListNotify
                                               object:nil];
}

- (void)successSaveMsg:(NSNotification *)notifyData
{
    PushMessage *savedMsg = (PushMessage *)notifyData.object;
    if (!savedMsg)
    {
        return;
    }
    if (YES == self.isOnlyShowOnDevMsg
        && NO == [savedMsg.deviceId isEqualToString:self.deviceModel.DeviceId])
    {
        GosLog(@"最新推送不是当前设备推送，不处理！");
        return;
    }
    if (YES == m_isEditing)
    {
        GosLog(@"正在编辑模式，最新推送消息暂不处理，先缓存！");
        GOS_WEAK_SELF;
        dispatch_async(self.cachePushMsgQueue, ^{
            
            GOS_STRONG_SELF;
            [strongSelf cacheNewPushMsg:savedMsg];
        });
        return;
    }
    GOS_WEAK_SELF;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        GOS_STRONG_SELF;
        [strongSelf handleCurPushMsg:savedMsg];
    });
    
    NSUInteger highLightRow = self.highLightRowSet.count;
    // 高亮显示
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        GOS_STRONG_SELF;
        [strongSelf highLightIndicateCell:highLightRow];
    });
}

#pragma mark -- 添加推送消息已读通知
- (void)addMsgHasReadNotify
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(PushMsgHasReaded:)
                                                 name:kPushMsgHasReadedNotify
                                               object:nil];
}

- (void)PushMsgHasReaded:(NSNotification *)notifyData
{
    NSDictionary *msgIndexDict = (NSDictionary *)notifyData.object;
    if (!msgIndexDict)
    {
        return;
    }
    if ([[msgIndexDict allKeys] containsObject:@"PushMsgIndex"])
    {
        return;
    }
    NSNumber *indexValue = msgIndexDict[@"PushMsgIndex"];
    NSUInteger rowIndex  = [indexValue unsignedIntegerValue];
    GosLog(@"更新消息列表第 %ld 条消息为已读！", (long)rowIndex);
    [self.pushMsgListLock lockRead];
    self.pushMsgArray[rowIndex].hasReaded = YES;
    [self.pushMsgListLock unLockRead];
    NSIndexPath *updatePath = [NSIndexPath indexPathForRow:rowIndex
                                                 inSection:1];
    self.curSelectedPath = updatePath;
    [self updateSelectedCell];
}

#pragma mark -- 处理当前推送消息
- (void)handleCurPushMsg:(PushMessage *)pmsg
{
    if (!pmsg || IS_EMPTY_STRING(pmsg.deviceId))
    {
        return;
    }
    PushMessage *savedMsgModel = [[PushMessage alloc] init];
    savedMsgModel.account      = pmsg.account;
    savedMsgModel.deviceId     = pmsg.deviceId;
    savedMsgModel.pushUrl      = pmsg.pushUrl;
    savedMsgModel.pushTime     = pmsg.pushTime;
    savedMsgModel.hasReaded    = pmsg.hasReaded;
    savedMsgModel.pmsgType     = pmsg.pmsgType;
    if (NO == self.isOnlyShowOnDevMsg)
    {
        NSArray<DevDataModel*>*tempList = [GosDevManager deviceList];
        __block NSString *devName = nil;
        [tempList enumerateObjectsWithOptions:NSEnumerationConcurrent
                                   usingBlock:^(DevDataModel * _Nonnull obj,
                                                NSUInteger idx,
                                                BOOL * _Nonnull stop)
        {
            if ([obj.DeviceId isEqualToString:pmsg.deviceId])
            {
                devName = [obj.DeviceName copy];
                *stop = YES;
            }
        }];
        savedMsgModel.deviceName = devName;
    }
    else
    {
        savedMsgModel.deviceName = self.deviceModel.DeviceName;
    }
    [self addNewPushMsg:savedMsgModel];
    [self checkNoMsgTips];
}

#pragma mark -- 插入最新推送消息
- (void)addNewPushMsg:(PushMessage *)msg
{
    if (!msg)
    {
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSIndexPath *insertPath = [NSIndexPath indexPathForRow:0
                                                     inSection:1];
        if (YES == m_isShowingDetailVC && NO == m_hasSwipeOnDetailVC)
        {
            GosLog(@"当前正在推送消息详情页面，更新推送列表该条消息为已读！");
            msg.hasReaded        = YES;
            self.curSelectedPath = insertPath;
            [PushMsgManager modifyushMsg:msg];
        }
        if (NO == m_isScrolling)
        {
            [self scrollToIndexPath:insertPath];
        }
        [self.pushMsgListLock lockWrite];
        [self.pushMsgArray insertObject:msg atIndex:0];
        [self.msgListTableView beginUpdates];
        
        [self.msgListTableView insertRowsAtIndexPaths:@[insertPath]
                                     withRowAnimation:UITableViewRowAnimationFade];
        [self.msgListTableView endUpdates];
        [self.pushMsgListLock unLockWrite];
    });
}

#pragma mark -- 缓存最新推送消息（正在编辑时。。。）
- (void)cacheNewPushMsg:(PushMessage *)pushMsg
{
    if (!pushMsg)
    {
        GosLog(@"编辑模型下无法缓存z推送消息，pushMsg = nil");
        return;
    }
    [self.cacheMsgListLock lockWrite];
    [self.needHandleMsgList addObject:pushMsg];
    [self.cacheMsgListLock unLockWrite];
}

#pragma mark -- 处理缓存的新消息列表（编辑模式下接收到的）
- (void)handleCacheMsgList
{
    [self.cacheMsgListLock lockWrite];
    NSMutableIndexSet *indexSet = [[NSMutableIndexSet alloc] init];
    for (NSUInteger i = 0; i < self.needHandleMsgList.count; i++)   // 这里需要按序输出，不使用：enumerateObjects...
    {
        if (YES == m_isEditing)
        {
            GosLog(@"又变成编辑模式了，缓存的消息又得延后处理了 ^_^ ");
            break;
        }
        GosLog(@"处理设备（ID = %@）缓存的推送消息（URL = %@）", self.needHandleMsgList[i].deviceId, self.needHandleMsgList[i].pushUrl);
        [self handleCurPushMsg:self.needHandleMsgList[i]];
        [PushMsgManager playInserMsgSound]; // 只有处理缓存消息时才播放
        [indexSet addIndex:i];
    }
    [self.needHandleMsgList removeObjectsAtIndexes:indexSet];
    [self.cacheMsgListLock unLockWrite];
}


#pragma mark - 按钮事件中心
#pragma mark -- ‘编辑'/'取消'按钮事件
- (void)rightBarBtnAction:(id)sender
{
    if (YES == m_isDeleting)
    {
        GosLog(@"正在删除已选中推送消息，请稍后。。。");
        return;
    }
    m_isEditing = !m_isEditing;
    if (NO == m_isEditing)  // 普通模式
    {
        [self.hasSelectedRowSet removeAllObjects];
        // 处理新推送消息（编辑模式下接收到的）
        GOS_WEAK_SELF;
        dispatch_async(self.cachePushMsgQueue, ^{
            
            GOS_STRONG_SELF;
            [strongSelf handleCacheMsgList];
        });
    }
    else    // 编辑模式
    {
        
    }
    GOS_SAVE_OBJ(@(m_isEditing), GOS_PUSHMSG_LIST_IS_EDITING);
    [self refreshTableView];
    [self configBottomViewHidden];
    [self configRightBarBtnTitle];
}

#pragma mark -- '选择'按钮事件
- (void)selectedBtnAction:(BOOL)isSelected
              onIndexPath:(NSIndexPath *)indexPath
{
    if (YES == m_isDeleting)
    {
        GosLog(@"正在删除已选中推送消息，请稍后。。。");
        return;
    }
    NSInteger rowIndex = indexPath.row;
    [self.pushMsgListLock lockRead];
    if (rowIndex >= self.pushMsgArray.count)
    {
        [self.pushMsgListLock unLockRead];
        return;
    }
    self.curSelectedPath = indexPath;
    if (NO == isSelected)   // 取消选择
    {
        GosLog(@"取消了选择第 %ld 行！", rowIndex);
        [self.hasSelectedRowSet removeObject:@(rowIndex)];
    }
    else    // 选择
    {
        GosLog(@"选择了第 %ld 行！", rowIndex);
        [self.hasSelectedRowSet addObject:@(rowIndex)];
    }
    [self updateSelectedCell];
    if (self.hasSelectedRowSet.count == self.pushMsgArray.count)
    {
        m_hasSelectedAll = YES;
    }
    else
    {
        m_hasSelectedAll = NO;
    }
    [self.pushMsgListLock unLockRead];
    [self configSelectedAllBtn];
    [self configDeleteBtn];
}

#pragma mark -- 开始执行删除操作
- (void)startDeleteAction
{
    m_isDeleting = YES;
    [SVProgressHUD showWithStatus:DPLocalizedString(@"Deleting")];
    GOS_WEAK_SELF;
    [self.pushMsgListLock lockWrite];
    __block NSMutableIndexSet *indexSet = [[NSMutableIndexSet alloc] init];
    [self.hasSelectedRowSet enumerateObjectsWithOptions:NSEnumerationConcurrent
                                             usingBlock:^(NSNumber * _Nonnull obj,
                                                          BOOL * _Nonnull stop)
     {
         GOS_STRONG_SELF;
         NSInteger rowIndex = [obj integerValue];
         [PushMsgManager rmvPushMsg:strongSelf.pushMsgArray[rowIndex]];
         [PushImageManager rmvPushImgOfMsg:strongSelf.pushMsgArray[rowIndex]];
         [indexSet addIndex:rowIndex];
     }];
    
    [self.pushMsgArray removeObjectsAtIndexes:indexSet];
    [self.hasSelectedRowSet removeAllObjects];
    if (0 == self.pushMsgArray.count)
    {
        m_isEditing = NO;
    }
    else
    {
        m_isEditing = YES;
    }
    [self.pushMsgListLock unLockWrite];
    [self refreshTableView];
    [self configSelectedAllBtn];
    [self configDeleteBtn];
    [self checkNoMsgTips];
    [SVProgressHUD dismiss];
    m_isDeleting = NO;
}

#pragma mark -- 删除指定消息
- (void)deleteMsgAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger rowIndex     = indexPath.row;
    NSUInteger sectionIndex = indexPath.section;
    if (self.pushMsgArray.count <= rowIndex
        || 1 != sectionIndex)
    {
        GosLog(@"数据越界，无法删除推送消息！");
        return;
    }
    [PushMsgManager rmvPushMsg:self.pushMsgArray[rowIndex]];
    [PushImageManager rmvPushImgOfMsg:self.pushMsgArray[rowIndex]];
    [self.pushMsgListLock lockWrite];
    [self.pushMsgArray removeObjectAtIndex:rowIndex];
    [self.msgListTableView deleteRowsAtIndexPaths:@[indexPath]
                                 withRowAnimation:UITableViewRowAnimationFade];
    [self.pushMsgListLock unLockWrite];
}


#pragma mark -- 跳转至推送消息详情页面
- (void)turnToPushDetailVC
{
    NSUInteger rowIndex = self.curSelectedPath.row;
    [self.pushMsgListLock lockRead];
    if (rowIndex >= self.pushMsgArray.count)
    {
        [self.pushMsgListLock unLockRead];
        return;
    }
    m_isShowingDetailVC                  = YES;
    MsgDetailViewController *msgDetailVC = [[MsgDetailViewController alloc] init];
    msgDetailVC.isOnlyShowOnDevMsg       = self.isOnlyShowOnDevMsg;
    msgDetailVC.pushMsg                  = self.pushMsgArray[rowIndex];
     [self.pushMsgListLock unLockRead];
    GOS_WEAK_SELF;
    msgDetailVC.vcDismissBlock = ^(BOOL isDismiss, NSUInteger curMsgIndex) {
        
        GOS_STRONG_SELF;
        if (YES == strongSelf->m_hasSwipeOnDetailVC)
        {
            NSIndexPath *updatePath = [NSIndexPath indexPathForRow:curMsgIndex
                                                         inSection:1];
            strongSelf.curSelectedPath = updatePath;
            [strongSelf scrollToIndexPath:updatePath];
            [strongSelf highLightIndicateCell:curMsgIndex];
        }
        if (YES == isDismiss)
        {
            [strongSelf resetParam];
        }
    };
    msgDetailVC.updateHasRead = ^(NSUInteger index) {
        
        GOS_STRONG_SELF;
        [strongSelf.pushMsgListLock lockWrite];
        if (strongSelf.pushMsgArray.count <= index)
        {
            [strongSelf.pushMsgListLock unLockWrite];
            return;
        }
        GosLog(@"更新消息列表第 %ld 条消息为已读！", (long)index);
        strongSelf.pushMsgArray[index].hasReaded = YES;
        NSIndexPath *updatePath = [NSIndexPath indexPathForRow:index
                                                     inSection:1];
        strongSelf.curSelectedPath = updatePath;
        [strongSelf updateSelectedCell];
        [strongSelf.pushMsgListLock unLockWrite];
    };
    msgDetailVC.hasSwipBlock = ^(BOOL hasSwipe) {
      
        GOS_STRONG_SELF;
        strongSelf->m_hasSwipeOnDetailVC = hasSwipe;
    };
    dispatch_async(dispatch_get_main_queue(), ^{

        [self presentViewController:msgDetailVC
                           animated:YES
                         completion:nil];
    });
}

#pragma mark - 懒加载
- (NSMutableArray<PushMessage *> *)pushMsgArray
{
    if (!_pushMsgArray)
    {
        _pushMsgArray = [NSMutableArray arrayWithCapacity:0];
    }
    return _pushMsgArray;
}

- (NSMutableSet<NSNumber *> *)hasSelectedRowSet
{
    if (!_hasSelectedRowSet)
    {
        _hasSelectedRowSet = [NSMutableSet setWithCapacity:0];
    }
    return _hasSelectedRowSet;
}

- (NSMutableSet<NSNumber *> *)highLightRowSet
{
    if (!_highLightRowSet)
    {
        _highLightRowSet = [NSMutableSet setWithCapacity:0];
    }
    return _highLightRowSet;
}

- (NSMutableArray<PushMessage *> *)needHandleMsgList
{
    if (!_needHandleMsgList)
    {
        _needHandleMsgList = [NSMutableArray arrayWithCapacity:0];
    }
    return _needHandleMsgList;
}

#pragma mark - TableView DataSource & Delegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (0 == section)
    {
        return 10.0f;
    }
    else
    {
        return CGFLOAT_MIN;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (0 == section)
    {
        return 1;
    }
    else
    {
        return self.pushMsgArray.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger sectionIndex = indexPath.section;
    NSInteger rowIndex     = indexPath.row;
    static NSString * const kMsgListCellId = @"PushMsgListCeeId";
    if (0 == sectionIndex)
    {
        MsgSettingTableViewCell *cell = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([MsgSettingTableViewCell class])
                                                                      owner:self
                                                                    options:nil][0];
        return cell;
    }
    else
    {
        if (rowIndex >= self.pushMsgArray.count)
        {
            UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                           reuseIdentifier:@"MsgListDefaultCellId"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        }
        PushMessage *pushData = self.pushMsgArray[rowIndex];
        MsgListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kMsgListCellId];
        if (!cell)
        {
            cell = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([MsgListTableViewCell class])
                                                 owner:self
                                               options:nil][0];
            cell.isEditing = m_isEditing;
        }
        cell.msgListCellData     = pushData;
        cell.isEditing           = m_isEditing;
        cell.hasSelected         = [self.hasSelectedRowSet containsObject:@(rowIndex)];
        cell.isShowIndicatorView = [self.highLightRowSet containsObject:@(rowIndex)];
        if (rowIndex == self.pushMsgArray.count - 1)
        {
            cell.hiddenSeperateLine = YES;
        }
        else
        {
            cell.hiddenSeperateLine = NO;
        }
        GOS_WEAK_SELF;
        cell.selectedBtnAction = ^(BOOL isSeleted) {
            
            GOS_STRONG_SELF;
            [strongSelf selectedBtnAction:isSeleted
                              onIndexPath:indexPath];
        };
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (YES == m_isDeleting)
    {
        GosLog(@"正在删除已选中推送消息，请稍后。。。");
        return;
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSInteger sectionIndex = indexPath.section;
    NSInteger rowIndex     = indexPath.row;
    self.curSelectedPath   = indexPath;
    if (0 == sectionIndex)
    {
        MsgSettingViewController *settingVC = [[MsgSettingViewController alloc] init];
        settingVC.isOnlyShowOnDevMsg        = self.isOnlyShowOnDevMsg;
        settingVC.deviceModel               = self.deviceModel;
        [self.navigationController pushViewController:settingVC
                                             animated:YES];
        m_isEditing = NO;
        [self configBottomViewHidden];
        [self configRightBarBtnTitle];
        [self refreshTableView];
    }
    else
    {
        if (rowIndex >= self.pushMsgArray.count)
        {
            return;
        }
        if (NO == m_isEditing)  // 普通模式
        {
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            [self turnToPushDetailVC];
            if (NO == self.pushMsgArray[rowIndex].hasReaded)    // 未读修改为已读
            {
                GosLog(@"该推送消息还未读过，需更新已读标志！");
                [self.pushMsgListLock lockWrite];
                self.pushMsgArray[rowIndex].hasReaded = YES;
                 [self.pushMsgListLock unLockWrite];
                [self updateSelectedCell];
                GOS_WEAK_SELF;
                dispatch_async(dispatch_get_global_queue(0, 0), ^{
                    
                    GOS_STRONG_SELF;
                    // 同步更新数据库
                    [strongSelf.pushMsgListLock lockRead];
                    [PushMsgManager modifyushMsg:strongSelf.pushMsgArray[rowIndex]];
                    [strongSelf.pushMsgListLock unLockRead];
                });
            }
            else
            {
                GosLog(@"该推送消息已经读过，无需更新已读标识！");
            }
        }
        else    // 选择模式
        {
            [self selectedBtnAction:![self.hasSelectedRowSet containsObject:@(rowIndex)]
                        onIndexPath:indexPath];
        }
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView
           editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger section = indexPath.section;
    if (0 == section)
    {
        return UITableViewCellEditingStyleNone;
    }
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger rowIndex = indexPath.row;
    if (UITableViewCellEditingStyleDelete == editingStyle)
    {
        if (self.pushMsgArray.count <= rowIndex)
        {
            return;
        }
        [self deleteMsgAtIndexPath:indexPath];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return DPLocalizedString(@"GosComm_Delete");
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    GosLog(@"推送消息列表准备开始滚动，取消滚动状态超时设置！");
    m_isScrolling = YES;
    [NSObject cancelPreviousPerformRequestsWithTarget:self
                                             selector:@selector(recoverScrollStatus)
                                               object:nil];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    GosLog(@"推送消息列表滚动结束！");
    [self performSelector:@selector(recoverScrollStatus)
                   withObject:nil
                   afterDelay:SCROLLING_PUSH_LIST_TIMEOUNT];
}


#pragma mark - GosBottomOperateViewDelegate
#pragma mark -- ‘全选’按钮事件
- (void)leftButtonAction
{
    if (YES == m_isDeleting)
    {
        GosLog(@"正在删除已选中推送消息，请稍后。。。");
        return;
    }
    m_hasSelectedAll = !m_hasSelectedAll;
    if (NO == m_hasSelectedAll) // 取消全选
    {
        [self.hasSelectedRowSet removeAllObjects];
        [self refreshTableView];
    }
    else    // 全选
    {
        [self.pushMsgListLock lockRead];
        for (int i = 0; i < self.pushMsgArray.count; i++)
        {
            [self.hasSelectedRowSet addObject:@(i)];
        }
        [self.pushMsgListLock unLockRead];
        [self refreshTableView];
    }
    [self configSelectedAllBtn];
    [self configDeleteBtn];
}

#pragma mark -- ‘删除’按钮事件
- (void)rightButtonAction
{
    if (0 == self.hasSelectedRowSet.count)
    {
        return;
    }
    if (YES == m_isDeleting)
    {
        GosLog(@"正在删除已选中推送消息，请稍后。。。");
        return;
    }
    GosLog(@"准备删除已选中的推送消息...");
    GOS_WEAK_SELF;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        GOS_STRONG_SELF;
        [strongSelf startDeleteAction];
    });
}


@end
