//
//  MsgSettingViewController.m
//  GosIPCs
//
//  Created by shenyuanluo on 2018/12/18.
//  Copyright © 2018 goscam. All rights reserved.
//

#import "MsgSettingViewController.h"
#import "MsgSettingListTableViewCell.h"
#import "GosDevManager.h"
#import "APNSManager.h"
#import "MsgSettingModel.h"
#import "PushStatusMananger.h"

#define MST_SET_LIST_CELL_HEIGHT 46.0f  // 列表高度

@interface MsgSettingViewController () <
                                        UITableViewDataSource,
                                        UITableViewDelegate
                                       >
@property (weak, nonatomic) IBOutlet UITableView *msgSetTableView;
@property (weak, nonatomic) IBOutlet UIImageView *noMsgImgView;
@property (weak, nonatomic) IBOutlet UILabel *noMsgLabel;
@property (nonatomic, readwrite, strong) NSMutableArray<MsgSettingModel*>*pushSettingArray;
@property (nonatomic, readwrite, strong) NSIndexPath *curSelectedPath;
@property (nonatomic, readwrite, strong) NSMutableArray<DevPushStatusModel *>*pushStatusList;

@end

@implementation MsgSettingViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = DPLocalizedString(@"Mine_MessageCenterSetup");
    [self configTableView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self loadPushSetting];
    if (NO == [PushStatusMananger hasChecked])
    {
        [SVProgressHUD showWithStatus:DPLocalizedString(@"SVPLoading")];
        [self addCheckedPushStatusNotify];
    }
    else
    {
        self.pushStatusList = [[PushStatusMananger pushStatusList] mutableCopy];
        [self handleDevPushStatusList:self.pushStatusList];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [SVProgressHUD dismiss];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    GosLog(@"---------- MsgSettingViewController dealloc ----------");
}


- (void)configTableView
{
    self.msgSetTableView.rowHeight       = MST_SET_LIST_CELL_HEIGHT;
    self.msgSetTableView.backgroundColor = GOS_VC_BG_COLOR;
    self.msgSetTableView.separatorStyle  = UITableViewCellSeparatorStyleNone;
    self.msgSetTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.msgSetTableView.bounces         = NO;
}

#pragma mark -- 加载推送设置数据
- (void)loadPushSetting
{
    [self.pushSettingArray removeAllObjects];	// 必需删除，防止左滑手势一半取消未退出页面情况
    if (NO == self.isOnlyShowOnDevMsg) // 显示所有消息
    {
        NSArray<DevDataModel*>*devList = [GosDevManager deviceList];
        for (int i = 0; i < devList.count; i++)
        {
            @autoreleasepool
            {
                MsgSettingModel *msgsModel = [[MsgSettingModel alloc] init];
                msgsModel.devModel         = devList[i];
                [self.pushSettingArray addObject:msgsModel];
            }
        }
    }
    else    // 显示指定设备消息
    {
        MsgSettingModel *msgsModel = [[MsgSettingModel alloc] init];
        msgsModel.devModel         = self.deviceModel;
        [self.pushSettingArray addObject:msgsModel];
    }
    [self checkNoMsgTips];
}

#pragma mark -- 处理推送状态结果
- (void)handleDevPushStatusList:(NSArray<DevPushStatusModel *> *)sList
{
    if (!sList)
    {
        return;
    }
    GOS_WEAK_SELF;
    for (int i = 0; i < self.pushSettingArray.count; i++)
    {
        [sList enumerateObjectsWithOptions:NSEnumerationConcurrent
                                usingBlock:^(DevPushStatusModel * _Nonnull obj,
                                             NSUInteger idx,
                                             BOOL * _Nonnull stop)
         {
             GOS_STRONG_SELF;
             if ([obj.DeviceId isEqualToString:strongSelf.pushSettingArray[i].devModel.DeviceId])
             {
                 GosLog(@"设备（ID = %@）推送状态：%d", obj.DeviceId, obj.PushFlag);
                 strongSelf.pushSettingArray[i].PushFlag = obj.PushFlag;
                 *stop = YES;
             }
         }];
    }
    [self refreshTableView];
}

- (void)addCheckedPushStatusNotify
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(checkedPushStatus:)
                                                 name:kCheckedPushStatusNotify
                                               object:nil];
}

- (void)checkedPushStatus:(NSNotification *)notifyData
{
    [SVProgressHUD dismiss];
    self.pushStatusList = [[PushStatusMananger pushStatusList] mutableCopy];
    [self handleDevPushStatusList:self.pushStatusList];
}

#pragma mark -- 更新列表
- (void)refreshTableView
{
    dispatch_async(dispatch_get_main_queue(), ^{
       
        [self.msgSetTableView reloadData];
    });
}

#pragma mark -- 更新当前选择的 Cell
- (void)updateSelectedCell
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        GOS_WEAK_SELF;
        [UIView performWithoutAnimation:^{  // 防止页面抖动一下
            
            GOS_STRONG_SELF;
            CGPoint loc = strongSelf.msgSetTableView.contentOffset;
            [strongSelf.msgSetTableView reloadRowsAtIndexPaths:@[strongSelf.curSelectedPath]
                                              withRowAnimation:UITableViewRowAnimationNone];
            strongSelf.msgSetTableView.contentOffset = loc;
        }];
    });
}

#pragma mark -- 按钮事件
- (void)switchAction:(BOOL)isOn
         onIndexPath:(NSIndexPath *)indexPath
{
    NSInteger rowIndex = indexPath.row;
    if (rowIndex >= self.pushSettingArray.count)
    {
        return;
    }
    self.curSelectedPath = indexPath;
    [SVProgressHUD showWithStatus:DPLocalizedString(@"SVPLoading")];
    NSString *devId = self.pushSettingArray[rowIndex].devModel.DeviceId;
    GOS_WEAK_SELF;
    if (NO == isOn) // 关闭推送
    {
        [APNSManager closePushWithDevId:devId
                                 result:^(BOOL isSuccess)
         {
             [SVProgressHUD dismiss];
             GOS_STRONG_SELF;
             if (NO == isSuccess)
             {
                 GosLog(@"关闭设备（ID = %@）推送失败！", devId);
                 [SVProgressHUD showErrorWithStatus:DPLocalizedString(@"GosComm_Set_Failed")];
                 [strongSelf updateSelectedCell];
             }
             else
             {
                 GosLog(@"关闭设备（ID = %@）推送成功！", devId);
                 __block DevPushStatusModel *retModel = nil;
                 __block BOOL isExist = NO;
                 [self.pushStatusList enumerateObjectsWithOptions:NSEnumerationConcurrent
                                                       usingBlock:^(DevPushStatusModel * _Nonnull obj,
                                                                    NSUInteger idx,
                                                                    BOOL * _Nonnull stop)
                  {
                      if ([obj.DeviceId isEqualToString:devId])
                      {
                          retModel          = [obj copy];
                          retModel.PushFlag = NO;
                          isExist           = YES;
                          *stop             = YES;
                      }
                  }];
                 [PushStatusMananger updatePushStatus:retModel];
             }
         }];
    }
    else    // 打开推送
    {
        [APNSManager openPushWithDevId:devId
                                result:^(BOOL isSuccess)
         {
             [SVProgressHUD dismiss];
             GOS_STRONG_SELF;
             if (NO == isSuccess)
             {
                 GosLog(@"打开设备（ID = %@）推送失败！", devId);
                 [SVProgressHUD showErrorWithStatus:DPLocalizedString(@"GosComm_Set_Failed")];
                 [strongSelf updateSelectedCell];
             }
             else
             {
                 GosLog(@"打开设备（ID = %@）推送成功！", devId);
                 __block DevPushStatusModel *retModel = nil;
                 __block BOOL isExist = NO;
                 [self.pushStatusList enumerateObjectsWithOptions:NSEnumerationConcurrent
                                                       usingBlock:^(DevPushStatusModel * _Nonnull obj,
                                                                    NSUInteger idx,
                                                                    BOOL * _Nonnull stop)
                  {
                      if ([obj.DeviceId isEqualToString:devId])
                      {
                          retModel          = [obj copy];
                          retModel.PushFlag = YES;
                          isExist           = YES;
                          *stop             = YES;
                      }
                  }];
                 [PushStatusMananger updatePushStatus:retModel];
             }
         }];
    }
}

#pragma mark -- 检查是否需要提示没有消息
- (void)checkNoMsgTips
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (0 == self.pushSettingArray.count)
        {
            self.noMsgImgView.hidden = NO;
            self.noMsgLabel.hidden   = NO;
        }
        else
        {
            self.noMsgImgView.hidden = YES;
            self.noMsgLabel.hidden   = YES;
        }
    });
}

#pragma mark - 懒加载
- (NSMutableArray<MsgSettingModel *> *)pushSettingArray
{
    if (!_pushSettingArray)
    {
        _pushSettingArray = [NSMutableArray arrayWithCapacity:0];
    }
    return _pushSettingArray;
}

- (NSMutableArray<DevPushStatusModel *> *)pushStatusList
{
    if (!_pushStatusList)
    {
        _pushStatusList = [NSMutableArray arrayWithCapacity:0];
    }
    return _pushStatusList;
}

#pragma mark - TableView DataSource & Delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.pushSettingArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger rowIndex     = indexPath.row;
    static NSString * const kMsgSettingListCellId = @"PushSettingListCeeId";
    if (rowIndex >= self.pushSettingArray.count)
    {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                       reuseIdentifier:@"MsgSettingListDefaultCellId"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    MsgSettingModel *pushSetData = self.pushSettingArray[rowIndex];
    MsgSettingListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kMsgSettingListCellId];
    if (!cell)
    {
        cell = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([MsgSettingListTableViewCell class])
                                             owner:self
                                           options:nil][0];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    cell.msgSettingListCellData = pushSetData;
    if (rowIndex == self.pushSettingArray.count - 1)
    {
        cell.isHiddenSeperateLine = YES;
    }
    else
    {
        cell.isHiddenSeperateLine = NO;
    }
    GOS_WEAK_SELF;
    cell.switchAction = ^(BOOL isOn) {
        
        GOS_STRONG_SELF;
        [strongSelf switchAction:isOn
                     onIndexPath:indexPath];
    };
    return cell;
}

@end
