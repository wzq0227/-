//
//  TFCRMediaListViewController.m
//  Goscom
//
//  Created by shenyuanluo on 2019/1/2.
//  Copyright © 2019 goscam. All rights reserved.
//

#import "TFCRMediaListViewController.h"
#import "TFCRMediaListTableViewCell.h"
#import "TFCRMediaModel.h"
#import "UIView+GosGradient.h"
#import "iOSConfigSDK.h"
#import "MJRefresh.h"
#import "GosBottomOperateView.h"
#import <MediaPlayer/MediaPlayer.h>
#import "TFPhotoBrowseViewController.h"
#import "TFDownloadManager.h"


#define VIDEO_LOCK_TIMEOUT  20  // 视频列表锁超时时间
#define PHOTO_LOCK_TIMEOUT  20  // 图片列表锁超时时间


@interface TFCRMediaListViewController () <
                                            UITableViewDataSource,
                                            UITableViewDelegate,
                                            iOSConfigSDKDMDelegate,
                                            GosBottomOperateViewDelegate,
                                            TFDownloadManagerDelegate
                                          >
{
    BOOL m_isConfigGradient;
    BOOL m_isRequesting;        // 是否正在请求数据
    BOOL m_isPullDownLoadMore;  // 是否下拉刷新
    BOOL m_isInitList;
    BOOL m_hasInitVideoList;    // 视频列表是否初始加载过
    BOOL m_hasInitPhotoList;    // 图片列表是否初始加载过
    BOOL m_isEditing;           // 是否编辑状态
    BOOL m_isDeleting;          // 是否正在删除
    BOOL m_hasSelectedAll;      // 是否全选
    BOOL m_isQuitCurVC;         // 是否退出当前列表页面
    BOOL m_hasRefreshTB;        // 是否已刷新列表
    BOOL m_isShowingAlert;      // 是否正在显示‘结束下载’警告
}
@property (weak, nonatomic) IBOutlet UIView *navigationView;
@property (weak, nonatomic) IBOutlet UILabel *videoLabel;
@property (weak, nonatomic) IBOutlet EnlargeClickButton *videoBtn;
@property (weak, nonatomic) IBOutlet UIView *videoIndicateView;
@property (weak, nonatomic) IBOutlet UILabel *photoLabel;
@property (weak, nonatomic) IBOutlet EnlargeClickButton *photoBtn;
@property (weak, nonatomic) IBOutlet UIView *photoIndicateView;
@property (weak, nonatomic) IBOutlet UITableView *recordMediaTableview;
@property (weak, nonatomic) IBOutlet UIImageView *noFileImgView;
@property (weak, nonatomic) IBOutlet UILabel *noFileLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewBottomMargin;
@property (nonatomic, readwrite, strong) NSMutableArray<TFCRMediaModel*>*videoList;
@property (nonatomic, readwrite, strong) NSMutableArray<TFCRMediaModel*>*photoList;
@property (nonatomic, readwrite, strong) EnlargeClickButton *rightBarBtn;
/** 当前选择的媒体类型 */
@property (nonatomic, readwrite, assign) TFMediaFileType selectedMediaType;
@property (nonatomic, readwrite, strong) iOSConfigSDK *configSdk;
/** 最新一个视频文件名 */
@property (nonatomic, readwrite, copy) NSString *latestVideoFileName;
/** 最后一个录制文件名 */
@property (nonatomic, readwrite, copy) NSString *lastVideoFileName;
/** 最新一个图片文件名 */
@property (nonatomic, readwrite, copy) NSString *latestPhotoFileName;
/** 最后一个图片文件名 */
@property (nonatomic, readwrite, copy) NSString *lastPhotoFileName;
/** 视频列表数据访问锁 */
@property (nonatomic, readwrite, strong) GosLock *videoListLock;
/** 图片列表数据访问锁 */
@property (nonatomic, readwrite, strong) GosLock *photoListLock;
/** 当前选择 cell */
@property (nonatomic, readwrite, strong) NSIndexPath *curSelectedPath;
/** 已选择 row 集合 */
@property (nonatomic, readwrite, strong) NSMutableSet<NSNumber*>*hasSelectedRowSet;
/** 当前下载中的 cell */
@property (nonatomic, readwrite, strong) NSIndexPath *curDownloadPath;
/** 正在下载的 Cell */
@property (nonatomic, readwrite, strong) TFCRMediaListTableViewCell *curDownloadingCell;
/** 当前下载进度 */
@property (nonatomic, readwrite, assign) float curDownloadProgress;
/** 当前下载文件 */
@property (nonatomic, readwrite, strong) TFCRMediaModel *curDownloadMedia;
/** 正在下载的 video 集合 @{kTFMediaKey : @"***", kRowIndexKey : @(***)} */
@property (nonatomic, readwrite, strong) NSMutableSet<NSDictionary*>*downloadingVideoSet;
/** 正在下载的 photo 集合 @{kTFMediaKey : @"***", kRowIndexKey : @(***)} */
@property (nonatomic, readwrite, strong) NSMutableSet<NSDictionary*>*downloadingPhotoSet;
/** 处理下载结果队列 */
@property (nonatomic, readwrite, strong) dispatch_queue_t handleDownloadResultQueue;
@property (nonatomic, readwrite, strong) UIAlertController *stopDownloadAlert;

@end

@implementation TFCRMediaListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initParam];
    [self configUI];
    [self reqRecList];
    [self addStartDownloadNotify];
    [self addDownloadSuccessNotify];
    [self addDownloadFailureNotify];
    [TFDownloadManager configDeleagate:self];
}

- (void)viewWillLayoutSubviews
{
    if (NO == m_isConfigGradient)
    {
        m_isConfigGradient = YES;
        
        GOS_WEAK_SELF;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            GOS_STRONG_SELF;
            [strongSelf.navigationView gradientStartColor:GOSCOM_THEME_START_COLOR
                                                 endColor:GOSCOM_THEME_END_COLOR
                                             cornerRadius:0
                                                direction:GosGradientLeftToRight];
        });
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self resetParam];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (YES == m_isEditing)
    {
        [self rightBarBtnAction:nil];
    }
    [SVProgressHUD dismiss];
}

- (void)dealloc
{
    [TFDownloadManager stopAllDownload];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    GosLog(@"---------- TFCRMediaListViewController dealloc ----------");
}

- (void)initParam
{
    m_isConfigGradient              = NO;
    m_isPullDownLoadMore            = NO;
    m_isInitList                    = NO;
    m_hasInitVideoList              = YES;
    m_hasInitPhotoList              = NO;
    m_hasRefreshTB                  = NO;
    self.curDownloadProgress        = 0;
    self.selectedMediaType          = TFMediaFile_video;
    self.videoListLock              = [[GosLock alloc] init];
    self.videoListLock.timeout      = VIDEO_LOCK_TIMEOUT;
    self.photoListLock              = [[GosLock alloc] init];
    self.photoListLock.timeout      = PHOTO_LOCK_TIMEOUT;
    dispatch_queue_attr_t bgArrt    = dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL, QOS_CLASS_BACKGROUND, 0);
    self.handleDownloadResultQueue  = dispatch_queue_create("TFDownloadResultHandleQueue", bgArrt);
}

- (void)resetParam
{
    m_isEditing      = NO;
    m_isDeleting     = NO;
    m_isQuitCurVC    = YES;
    m_isShowingAlert = NO;
    [GosBottomOperateView configDelegate:self];
}

#pragma mark -- 设置 UI
- (void)configUI
{
    self.title                = self.recordDateStr;
    self.view.backgroundColor = GOS_VC_BG_COLOR;
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.videoLabel.text      = DPLocalizedString(@"TFCR_Video");
    self.photoLabel.text      = DPLocalizedString(@"TFCR_Photo");
    [self loadRightButtonItem];
    [self configIndicateViewForType:self.selectedMediaType];
    [self configTableView];
}

#pragma mark - 设置列表
- (void)configTableView
{
    self.recordMediaTableview.backgroundColor = GOS_VC_BG_COLOR;
    self.recordMediaTableview.rowHeight       = 50.f;
    self.recordMediaTableview.separatorStyle  = UITableViewCellSeparatorStyleNone;
    self.recordMediaTableview.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.recordMediaTableview.mj_header       = [MJRefreshNormalHeader headerWithRefreshingTarget:self
                                                                                 refreshingAction:@selector(pullDownLoadMore)];
    self.recordMediaTableview.mj_footer       = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self
                                                                                     refreshingAction:@selector(pullUpLoadMore)];
}

#pragma mark -- 设置指示器View
- (void)configIndicateViewForType:(TFMediaFileType)mType
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        switch (mType)
        {
            case TFMediaFile_video:
            {
                self.videoIndicateView.hidden = NO;
                self.photoIndicateView.hidden = YES;
            }
                break;
                
            case TFMediaFile_photo:
            {
                self.videoIndicateView.hidden = YES;
                self.photoIndicateView.hidden = NO;
            }
                break;
                
            default:
                break;
        }
    });
}

#pragma mark -- 设置没有文件提示
- (void)checkNoFileTips
{
    UIImage *tipImg   = nil;
    NSString *tipsStr = nil;
    BOOL hasVideo     = YES;
    BOOL hasPhoto     = YES;
    switch (self.selectedMediaType)
    {
        case TFMediaFile_video:
        {
            tipImg  = GOS_IMAGE(@"img_blankpage_video");
            tipsStr = DPLocalizedString(@"TFCR_NoVideo");
            if (0 == self.videoList.count)
            {
                hasVideo = NO;
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                
                self.noFileImgView.hidden = hasVideo;
                self.noFileLabel.hidden   = hasVideo;
                self.noFileImgView.image  = tipImg;
                self.noFileLabel.text     = tipsStr;
            });
        }
            break;
            
        case TFMediaFile_photo:
        {
            tipImg  = GOS_IMAGE(@"img_blankpage_photo");
            tipsStr = DPLocalizedString(@"TFCR_NoPhoto");
            if (0 == self.photoList.count)
            {
                hasPhoto = NO;
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                
                self.noFileImgView.hidden = hasPhoto;
                self.noFileLabel.hidden   = hasPhoto;
                self.noFileImgView.image  = tipImg;
                self.noFileLabel.text     = tipsStr;
            });
        }
            break;
            
        default:
            break;
    }
}

#pragma mark -- 设置右按钮标题
- (void)loadRightButtonItem
{
    self.rightBarBtn = [EnlargeClickButton buttonWithType:UIButtonTypeCustom];
    self.rightBarBtn.frame = CGRectMake(30, 0, 100, 40);
    self.rightBarBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    self.rightBarBtn.tintColor = [UIColor whiteColor];
    [self configRightBarBtnTitle];
    [self.rightBarBtn addTarget:self
                         action:@selector(rightBarBtnAction:)
               forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:self.rightBarBtn];
    self.navigationItem.rightBarButtonItem = item;
}

- (void)configRightBarBtnTitle
{
    NSString *titleStr = nil;
    if (NO == m_isEditing)
    {
        titleStr = DPLocalizedString(@"GosComm_Edit");
    }
    else
    {
        titleStr = DPLocalizedString(@"GosComm_Cancel");
    }
    switch (self.selectedMediaType)
    {
        case TFMediaFile_video:
        {
            if (0 == self.videoList.count)
            {
                titleStr = nil;
            }
        }
            break;
            
        case TFMediaFile_photo:
        {
            if (0 == self.photoList.count)
            {
                titleStr = nil;
            }
        }
            break;
            
        default:
            break;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self.rightBarBtn setTitle:titleStr
                          forState:UIControlStateNormal];
    });
}

#pragma mark -- 设置底部视图显示/隐藏
- (void)configBottomViewShowOrHidden
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
        
        self.recordMediaTableview.mj_footer.hidden = m_isEditing;
        self.recordMediaTableview.mj_header.hidden = m_isEditing;
        self.tableViewBottomMargin.constant        = margin;
    });
}

#pragma mark -- 设置全选按钮
- (void)configSelectedAllBtn
{
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
}

#pragma mark -- 设置删除按钮
- (void)configDeleteBtn
{
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
}

#pragma mark -- 日期获取
- (NSDate* )tfcRecordDate
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy/MM/dd"];
    NSDate *reqDate = [formatter dateFromString:self.recordDateStr];
    return reqDate;
}

#pragma mark -- 初始加载列（调用一次）
- (void)reqRecList
{
    if (YES == m_isRequesting || YES == m_isEditing)
    {
        GosLog(@"正在请求数据 or 编辑中，请稍后。。。");
        return;
    }
    GosLog(@"准备初始设备（ID = %@）加载 TF 卡录制文件。。。", self.devModel.DeviceId);
    m_isRequesting       = YES;
    m_isPullDownLoadMore = NO;
    m_isInitList         = YES;
    switch (self.selectedMediaType)
    {
        case TFMediaFile_video: m_hasInitVideoList = YES;  break;
        case TFMediaFile_photo: m_hasInitPhotoList = YES;  break;
        default: break;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [SVProgressHUD showWithStatus:DPLocalizedString(@"SVPLoading")];
    });
    [self.configSdk reqDayRecListWithdDevId:self.devModel.DeviceId
                                      onDay:[self tfcRecordDate]
                                   fileType:self.selectedMediaType];
}

#pragma mark -- 下拉刷新（加载最新）
- (void)pullDownLoadMore
{
    if (YES == m_isRequesting || YES == m_isEditing)
    {
        GosLog(@"正在请求数据 or 编辑中，请稍后。。。");
        return;
    }
    if ((NO == m_hasInitVideoList && TFMediaFile_video == self.selectedMediaType)
        || (NO == m_hasInitPhotoList && TFMediaFile_photo == self.selectedMediaType)) // 全选删除情况
    {
        [self reqRecList];
        m_isPullDownLoadMore = YES;
        return;
    }
    GosLog(@"准备加载设备（ID = %@）最新 TF 卡录制文件。。。", self.devModel.DeviceId);
    m_isInitList         = NO;
    m_isRequesting       = YES;
    m_isPullDownLoadMore = YES;
    NSString *startFile  = nil;
    switch (self.selectedMediaType)
    {
        case TFMediaFile_video: startFile = self.latestVideoFileName; break;
        case TFMediaFile_photo:   startFile = self.latestPhotoFileName; break;
        default:            startFile = self.latestVideoFileName; break;
    }
    [self.configSdk loadMoreRecListWithDevId:self.devModel.DeviceId
                                       onDay:[self tfcRecordDate]
                                    fileType:self.selectedMediaType
                                   startFile:startFile
                               turnDirection:RecListPageTurn_forward];
}

#pragma mark -- 上拉刷新（加载历史）
- (void)pullUpLoadMore
{
    if (YES == m_isRequesting || YES == m_isEditing)
    {
        GosLog(@"正在请求数据 or 编辑中，请稍后。。。");
        return;
    }
    GosLog(@"准备加载设备（ID = %@）历史 TF 卡录制文件。。。", self.devModel.DeviceId);
    m_isInitList         = NO;
    m_isRequesting       = YES;
    m_isPullDownLoadMore = NO;
    NSString *startFile  = nil;
    switch (self.selectedMediaType)
    {
        case TFMediaFile_video: startFile = self.lastVideoFileName; break;
        case TFMediaFile_photo:   startFile = self.lastPhotoFileName; break;
        default:            startFile = self.lastVideoFileName; break;
    }
    [self.configSdk loadMoreRecListWithDevId:self.devModel.DeviceId
                                       onDay:[self tfcRecordDate]
                                    fileType:self.selectedMediaType
                                   startFile:startFile
                               turnDirection:RecListPageTurn_backward];
}

#pragma mark -- 停止'下拉刷新'（请求超时时）
- (void)stopPullDownLoadMore
{
    GOS_WEAK_SELF;
    dispatch_async(dispatch_get_main_queue(), ^{
        
        GOS_STRONG_SELF;
        [strongSelf.recordMediaTableview.mj_header endRefreshing];
    });
}

#pragma mark -- 停止'上拉刷新'（请求超时时）
- (void)stopPullUpLoadMore:(BOOL)isNoMoreFile
{
    GOS_WEAK_SELF;
    dispatch_async(dispatch_get_main_queue(), ^{
        
        GOS_STRONG_SELF;
        if (NO == isNoMoreFile)
        {
            [strongSelf.recordMediaTableview.mj_footer endRefreshing];
        }
        else    // 没有更多文件了
        {
            [strongSelf.recordMediaTableview.mj_footer endRefreshingWithNoMoreData];
        }
    });
}

#pragma mark -- 刷新列表
- (void)refreshTableView
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self.recordMediaTableview reloadData];
        m_hasRefreshTB = YES;
        if (0 < self.curDownloadProgress)
        {
            GosLog(@"TF 卡媒体文件下载进度马上更新！");
            [self coverCurDownloadProgress];
        }
    });
}

#pragma mark -- 恢复当前下载进（刷新列表之后）
- (void)coverCurDownloadProgress
{
    NSMutableArray<TFCRMediaModel*>*tempArray = nil;
    GosLock *tempLock                         = nil;
    switch (self.selectedMediaType)
    {
        case TFMediaFile_video:
        {
            tempArray = self.videoList;
            tempLock  = self.videoListLock;
        }
            break;
            
        case TFMediaFile_photo:
        {
            tempArray = self.photoList;
            tempLock  = self.photoListLock;
        }
            break;
            
        default:
            break;
    }
    __block BOOL isExist        = NO;
    __block NSUInteger rowIndex = 0;
    [tempLock lock];
    [tempArray enumerateObjectsWithOptions:NSEnumerationConcurrent
                                usingBlock:^(TFCRMediaModel * _Nonnull obj,
                                             NSUInteger idx,
                                             BOOL * _Nonnull stop)
    {
        if ([obj isEqual:self.curDownloadMedia])
        {
            isExist  = YES;
            rowIndex = idx;
            *stop    = YES;
        }
    }];
    if (YES == isExist)
    {
        GosLog(@"TF 卡媒体列表刷新了，恢复下载(%f)进度显示！", self.curDownloadProgress);
        self.curDownloadPath = [NSIndexPath indexPathForRow:rowIndex
                                                  inSection:0];
        self.curDownloadingCell = [self.recordMediaTableview cellForRowAtIndexPath:self.curDownloadPath];
        [self.curDownloadingCell downloading:self.curDownloadProgress];
    }
    [tempLock unLock];
}

#pragma mark -- 更新当前选择的 Cell
- (void)updateSelectedCell
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        GOS_WEAK_SELF;
        [UIView performWithoutAnimation:^{  // 防止页面抖动一下
            
            GOS_STRONG_SELF;
            CGPoint loc = strongSelf.recordMediaTableview.contentOffset;
            [strongSelf.recordMediaTableview reloadRowsAtIndexPaths:@[strongSelf.curSelectedPath]
                                                   withRowAnimation:UITableViewRowAnimationNone];
            strongSelf.recordMediaTableview.contentOffset = loc;
        }];
    });
}

#pragma mark - 按钮事件中心
#pragma mark -- ’视频列表‘按钮事件
- (IBAction)videoBtnAction:(id)sender
{
    
    if (YES == m_isRequesting)
    {
        GosLog(@"正在请求数据，请稍后。。。");
        return;
    }
    if (TFMediaFile_video == self.selectedMediaType)
    {
        return;
    }
    m_hasRefreshTB         = NO;
    m_hasSelectedAll       = NO;
    [self configSelectedAllBtn];
    self.selectedMediaType = TFMediaFile_video;
    [self configIndicateViewForType:self.selectedMediaType];
    if (YES == m_isEditing)
    {
        m_isEditing = NO;
        [self configRightBarBtnTitle];
        [self configBottomViewShowOrHidden];
    }
    [self checkNoFileTips];
    //    [self refreshTableView];
    [self cancelSelectAllCell];
    
    if (0 < self.downloadingVideoSet.count) // 优先下载 视频
    {
        [TFDownloadManager priorityDownloadType:TFMediaFile_video];
    }
}

#pragma mark -- ’图片列表‘按钮事件
- (IBAction)photoBtnAction:(id)sender
{
    
    if (YES == m_isRequesting)
    {
        GosLog(@"正在请求数据，请稍后。。。");
        return;
    }
    if (TFMediaFile_photo == self.selectedMediaType)
    {
        return;
    }
    m_hasRefreshTB         = NO;
    m_hasSelectedAll       = NO;
    [self configSelectedAllBtn];
    
    self.selectedMediaType = TFMediaFile_photo;
    [self configIndicateViewForType:self.selectedMediaType];
    if (YES == m_isEditing)
    {
        m_isEditing = NO;
        [self configRightBarBtnTitle];
        [self configBottomViewShowOrHidden];
    }
    if (NO == m_hasInitPhotoList)
    {
        [self reqRecList];
    }
    [self checkNoFileTips];
    //    [self refreshTableView];
    [self cancelSelectAllCell];
    
    if (0 < self.downloadingPhotoSet.count) // 优先下载 图片
    {
        [TFDownloadManager priorityDownloadType:TFMediaFile_photo];
    }
}

#pragma mark - 将全选置位no
- (void)cancelSelectAllCell{
    [self.hasSelectedRowSet removeAllObjects];
    [self refreshTableView];
}
#pragma mark -- ‘编辑'/'取消'按钮事件
- (void)rightBarBtnAction:(id)sender
{
    if (YES == m_isDeleting)
    {
        GosLog(@"正在删除已选中推送消息，请稍后。。。");
        return;
    }
    m_isEditing = !m_isEditing;
    [self configRightBarBtnTitle];
    [self configBottomViewShowOrHidden];
    [self refreshTableView];
    if (NO == m_isEditing)  // 普通模式
    {
        [self.hasSelectedRowSet removeAllObjects];
    }
    else    // 编辑模式
    {
        
    }
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
    if ((TFMediaFile_video == self.selectedMediaType && rowIndex >= self.videoList.count)
        || (TFMediaFile_photo == self.selectedMediaType && rowIndex >= self.photoList.count))
    {
        GosLog(@"越界了！");
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
    switch (self.selectedMediaType)
    {
        case TFMediaFile_video:
        {
            if (self.hasSelectedRowSet.count == self.videoList.count)
            {
                m_hasSelectedAll = YES;
            }
            else
            {
                m_hasSelectedAll = NO;
            }
        }
            break;
            
        case TFMediaFile_photo:
        {
            if (self.hasSelectedRowSet.count == self.photoList.count)
            {
                m_hasSelectedAll = YES;
            }
            else
            {
                m_hasSelectedAll = NO;
            }
        }
            break;
            
        default:
            break;
    }
    [self configSelectedAllBtn];
    [self configDeleteBtn];
}

#pragma mark -- 开始删除
#pragma mark -- 开始执行删除操作
- (void)startDeleteAction
{
    m_isDeleting = YES;
    [SVProgressHUD showWithStatus:DPLocalizedString(@"Deleting")];
    GOS_WEAK_SELF;
    __block NSMutableArray<NSString*>*tempArray              = [NSMutableArray arrayWithCapacity:0];
    NSFileManager *manager                                    = [NSFileManager defaultManager];
    __block NSMutableArray<TFCRMediaModel*>*stopDownloadArray = [NSMutableArray arrayWithCapacity:0];
    switch (self.selectedMediaType)
    {
        case TFMediaFile_video:
        {
            [self.videoListLock lock];
            [self.hasSelectedRowSet enumerateObjectsWithOptions:NSEnumerationConcurrent
                                                     usingBlock:^(NSNumber * _Nonnull obj,
                                                                  BOOL * _Nonnull stop)
             {
                 GOS_STRONG_SELF;
                 NSInteger rowIndex        = [obj integerValue];
                 TFCRMediaModel *tempMedia = strongSelf.videoList[rowIndex];
                 BOOL isDownloading = [strongSelf isDownloadingForRow:rowIndex
                                                               ofType:TFMediaFile_video];
                 if (YES == isDownloading)
                 {
                     [stopDownloadArray addObject:tempMedia];
                 }
                 BOOL isDir                = NO;
                 BOOL isExist              = NO;
                 NSError *error            = nil;
                 if (YES == tempMedia.hasDownload)
                 {
                     isExist = [manager fileExistsAtPath:tempMedia.mediaFilePath isDirectory:&isDir];
                     if (YES == isExist && NO == isDir)
                     {
                         [manager removeItemAtPath:tempMedia.mediaFilePath error:&error];
                         if (error)
                         {
                             GosLog(@"删除已下载的 TF 卡视频文件(%@)失败！", tempMedia.mediaFilePath);
                         }
                         else
                         {
                             GosLog(@"删除已下载的 TF 卡视频文件(%@)成功！", tempMedia.mediaFilePath);
                         }
                     }
                 }
                 [tempArray addObject:strongSelf.videoList[rowIndex].tfmFile.fileName];
             }];
            [self.videoListLock unLock];
        }
            break;
            
        case TFMediaFile_photo:
        {
            [self.photoListLock lock];
            [self.hasSelectedRowSet enumerateObjectsWithOptions:NSEnumerationConcurrent
                                                     usingBlock:^(NSNumber * _Nonnull obj,
                                                                  BOOL * _Nonnull stop)
             {
                 GOS_STRONG_SELF;
                 NSInteger rowIndex = [obj integerValue];
                 TFCRMediaModel *tempMedia = strongSelf.photoList[rowIndex];
                 BOOL isDownloading = [strongSelf isDownloadingForRow:rowIndex
                                                               ofType:TFMediaFile_photo];
                 if (YES == isDownloading)
                 {
                     [stopDownloadArray addObject:tempMedia];
                 }
                 BOOL isDir                = NO;
                 BOOL isExist              = NO;
                 NSError *error            = nil;
                 if (YES == tempMedia.hasDownload)
                 {
                     isExist = [manager fileExistsAtPath:tempMedia.mediaFilePath isDirectory:&isDir];
                     if (YES == isExist && NO == isDir)
                     {
                         [manager removeItemAtPath:tempMedia.mediaFilePath error:&error];
                         if (error)
                         {
                             GosLog(@"删除已下载的 TF 卡图片文件(%@)失败！", tempMedia.mediaFilePath);
                         }
                         else
                         {
                             GosLog(@"删除已下载的 TF 卡图片文件(%@)成功！", tempMedia.mediaFilePath);
                         }
                     }
                 }
                 [tempArray addObject:strongSelf.photoList[rowIndex].tfmFile.fileName];
             }];
            [self.photoListLock unLock];
        }
            break;
            
        default:
            break;
    }
    [TFDownloadManager stopDownloadMediaList:stopDownloadArray];
    [self.configSdk delTFRecList:tempArray
                         ofDevId:self.devModel.DeviceId];
    m_hasSelectedAll = NO;
    [self configSelectedAllBtn];
}

#pragma mark -- 检查指定 Row 是否正在下载中，是则移除（执行删除列表操作是）
- (BOOL)isDownloadingForRow:(NSUInteger)rowIndex
                     ofType:(TFMediaFileType)mfType
{
    __block BOOL isExist              = NO;
    __block NSDictionary *delDict     = nil;
    BOOL isDownloading                = NO;
    NSMutableSet *tempSet             = nil;
    switch (mfType)
    {
        case TFMediaFile_video:
        {
            tempSet = self.downloadingVideoSet;
        }
            break;
            
        case TFMediaFile_photo:
        {
            tempSet = self.downloadingPhotoSet;
        }
            break;
            
        default:
            break;
    }
    [tempSet enumerateObjectsWithOptions:NSEnumerationConcurrent
                              usingBlock:^(NSDictionary * _Nonnull obj,
                                           BOOL * _Nonnull stop)
     {
         if ([[obj allKeys] containsObject:kTFMediaKey]
             && [[obj allKeys] containsObject:kRowIndexKey]
             && rowIndex == [obj[kRowIndexKey] unsignedIntegerValue])
         {
             delDict   = obj;
             isExist   = YES;
             *stop     = YES;
         }
     }];
    if (YES == isExist && delDict)
    {
        isDownloading = YES;
        [self.downloadingVideoSet removeObject:delDict];
    }
    return isDownloading;
}

#pragma mark -- 更新正在下载的 rowIndex（下载中执行删除操作时）
- (void)updateDownloadingRowSet
{
    NSMutableSet<NSDictionary*>*tempSet      = nil;
    NSMutableArray<TFCRMediaModel*>*tempList = nil;
    switch (self.selectedMediaType)
    {
        case TFMediaFile_video:
        {
            tempSet  = self.downloadingVideoSet;
            tempList = self.videoList;
        }
            break;
            
        case TFMediaFile_photo:
        {
            tempSet  = self.downloadingPhotoSet;
            tempList = self.photoList;
        }
            break;
            
        default:
            break;
    }
    __block NSMutableSet<NSDictionary*>*replaceSet = [NSMutableSet setWithCapacity:0];
    [tempSet enumerateObjectsWithOptions:NSEnumerationConcurrent
                              usingBlock:^(NSDictionary * _Nonnull obj,
                                           BOOL * _Nonnull stop)
    {
        if ([[obj allKeys] containsObject:kTFMediaKey]
            && [[obj allKeys] containsObject:kRowIndexKey])
        {
            for (int i = 0; i < tempList.count; i++)
            {
                if ([obj[kTFMediaKey] isEqual:tempList[i]])
                {
                    NSDictionary *dict  = @{kTFMediaKey : obj[kTFMediaKey],
                                            kRowIndexKey : @(i)};
                    [replaceSet addObject:dict];
                    break;
                }
            }
        }
    }];
    switch (self.selectedMediaType)
    {
        case TFMediaFile_video:
        {
            self.downloadingVideoSet = replaceSet;
        }
            break;
            
        case TFMediaFile_photo:
        {
            self.downloadingPhotoSet = replaceSet;
        }
            break;
            
        default:
            break;
    }
}

#pragma mark -- 删除指定文件
- (void)deleteFileAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger rowIndex      = indexPath.row;
    NSString *fileName       = nil;
    NSFileManager *manager   = [NSFileManager defaultManager];
    TFCRMediaModel *delMedia = nil;
    switch (self.selectedMediaType)
    {
        case TFMediaFile_video:
        {
            if (self.videoList.count <= rowIndex)
            {
                GosLog(@"数据越界，无法删除 TF 录制视频文件！");
                return;
            }
            delMedia = self.videoList[rowIndex];
            fileName = delMedia.tfmFile.fileName;
        }
            break;
            
        case TFMediaFile_photo:
        {
            if (self.photoList.count <= rowIndex)
            {
                GosLog(@"数据越界，无法删除 TF 录制图片文件！");
                return;
            }
            delMedia = self.photoList[rowIndex];
            fileName = delMedia.tfmFile.fileName;
        }
            break;
            
        default:
            break;
    }
    m_isDeleting              = YES;
    BOOL isDir                = NO;
    BOOL isExist              = NO;
    NSError *error            = nil;
    if (YES == delMedia.hasDownload)
    {
        isExist = [manager fileExistsAtPath:delMedia.mediaFilePath isDirectory:&isDir];
        if (YES == isExist && NO == isDir)
        {
            [manager removeItemAtPath:delMedia.mediaFilePath error:&error];
            if (error)
            {
                GosLog(@"删除已下载的 TF 卡视频文件(%@)失败！", delMedia.mediaFilePath);
            }
            else
            {
                GosLog(@"删除已下载的 TF 卡视频文件(%@)成功！", delMedia.mediaFilePath);
            }
        }
    }
    BOOL isDownloading = [self isDownloadingForRow:rowIndex
                                            ofType:delMedia.tfmFile.fileType];
    [SVProgressHUD showWithStatus:DPLocalizedString(@"Deleting")];
    if (YES == isDownloading)
    {
        [TFDownloadManager stopDownloadMedia:delMedia];
    }
    [self.hasSelectedRowSet addObject:@(rowIndex)];
    [self.configSdk delTFRecList:@[fileName]
                         ofDevId:self.devModel.DeviceId];
}

#pragma mark -- 取消下载提示
- (void)configStopDownloadAlert:(BOOL)isShow
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        m_isShowingAlert = isShow;
        if (NO == isShow)
        {
            [self dismissViewControllerAnimated:self.stopDownloadAlert
                                     completion:nil];
        }
        else
        {
            [self presentViewController:self.stopDownloadAlert
                               animated:YES
                             completion:nil];
        }
    });
}

#pragma mark -- 处理删除成功结果
- (void)handleDeleteSuccess
{
    GOS_WEAK_SELF;
    __block NSMutableIndexSet *indexSet = [[NSMutableIndexSet alloc] init];
    switch (self.selectedMediaType)
    {
        case TFMediaFile_video:
        {
            [self.videoListLock lock];
            [self.hasSelectedRowSet enumerateObjectsWithOptions:NSEnumerationConcurrent
                                                     usingBlock:^(NSNumber * _Nonnull obj,
                                                                  BOOL * _Nonnull stop)
             {
                 GOS_STRONG_SELF;
                 NSInteger rowIndex = [obj integerValue];
                 [indexSet addIndex:rowIndex];
             }];
            [self.videoList removeObjectsAtIndexes:indexSet];
            [self.hasSelectedRowSet removeAllObjects];
            if (0 == self.videoList.count && YES == m_isEditing)
            {
                m_isEditing = NO;
                [self configRightBarBtnTitle];
                [self configBottomViewShowOrHidden];
            }
            [self.videoListLock unLock];
            m_hasInitVideoList = NO;
        }
            break;
            
        case TFMediaFile_photo:
        {
            [self.photoListLock lock];
            [self.hasSelectedRowSet enumerateObjectsWithOptions:NSEnumerationConcurrent
                                                     usingBlock:^(NSNumber * _Nonnull obj,
                                                                  BOOL * _Nonnull stop)
             {
                 GOS_STRONG_SELF;
                 NSInteger rowIndex = [obj integerValue];
                 [indexSet addIndex:rowIndex];
             }];
            [self.photoList removeObjectsAtIndexes:indexSet];
            [self.hasSelectedRowSet removeAllObjects];
            if (0 == self.photoList.count && YES == m_isEditing)
            {
                m_isEditing = NO;
                [self configRightBarBtnTitle];
                [self configBottomViewShowOrHidden];
            }
            [self.photoListLock unLock];
            m_hasInitPhotoList = NO;
        }
            break;
            
        default:
            break;
    }
    [self refreshTableView];
    [self configDeleteBtn];
    [self checkNoFileTips];
    [self configBottomViewShowOrHidden];
    [self updateDownloadingRowSet];
    m_isDeleting = NO;
}

#pragma mark - 下载
#pragma mark -- 准备下载
- (void)prepareDownloadMedia:(TFCRMediaModel *)media
{
    if (!media)
    {
        return;
    }
    NSUInteger rowIndex = self.curDownloadPath.row;
    NSDictionary *dict  = @{kTFMediaKey : media,
                            kRowIndexKey : @(rowIndex)};
    switch (media.tfmFile.fileType)
    {
        case TFMediaFile_video:
        {
            if (self.videoList.count < rowIndex)
            {
                return;
            }
            [self.downloadingVideoSet addObject:dict];
            self.videoList[rowIndex].isDownloading = YES;
        }
            break;
            
        case TFMediaFile_photo:
        {
            if (self.photoList.count < rowIndex)
            {
                return;
            }
            [self.downloadingPhotoSet addObject:dict];
            self.photoList[rowIndex].isDownloading = YES;
        }
            break;
            
        default:
            break;
    }
    [self startDownloadMedia:media];
}
#pragma mark -- 下载媒体文件
- (void)startDownloadMedia:(TFCRMediaModel *)media
{
    if (!media || IS_EMPTY_STRING(media.tfmFile.fileName)
        || IS_EMPTY_STRING(media.mediaFilePath))
    {
        GosLog(@"无法下载设备（ID = %@）TF 卡录制媒体文件（fileName = %@, mediaFilePath = %@）", self.devModel.DeviceId, media.tfmFile.fileName, media.mediaFilePath);
        return;
    }
    [self.curDownloadingCell startDownload];
    [TFDownloadManager startDownloadMedia:media];
}

#pragma mark -- 取消下载
- (void)cancelDownload
{
    NSUInteger rowIndex           = self.curSelectedPath.row;
    __block BOOL isExist          = NO;
    __block NSDictionary *delDict = nil;
    TFCRMediaModel *stopMedia     = nil;
    switch (self.selectedMediaType)
    {
        case TFMediaFile_video:
        {
            [self.downloadingVideoSet enumerateObjectsWithOptions:NSEnumerationConcurrent
                                                       usingBlock:^(NSDictionary * _Nonnull obj,
                                                                    BOOL * _Nonnull stop)
             {
                 if ([[obj allKeys] containsObject:kTFMediaKey]
                     && [[obj allKeys] containsObject:kRowIndexKey]
                     && rowIndex == [obj[kRowIndexKey] unsignedIntegerValue])
                 {
                     delDict = obj;
                     isExist = YES;
                     *stop   = YES;
                 }
             }];
            if (YES == isExist && delDict)
            {
                [self.downloadingVideoSet removeObject:delDict];
            }
            if (self.videoList.count > rowIndex)
            {
                self.videoList[rowIndex].isDownloading = NO;
                stopMedia = self.videoList[rowIndex];
            }
            [self.videoListLock lock];
            self.curDownloadPath = [NSIndexPath indexPathForRow:rowIndex
                                                      inSection:0];
            self.curDownloadingCell = [self.recordMediaTableview cellForRowAtIndexPath:self.curDownloadPath];
            [self.curDownloadingCell endDownload:StopDowloadReason_cancel];
            [self.videoListLock unLock];
        }
            break;
            
        case TFMediaFile_photo:
        {
            [self.downloadingPhotoSet enumerateObjectsWithOptions:NSEnumerationConcurrent
                                                       usingBlock:^(NSDictionary * _Nonnull obj,
                                                                    BOOL * _Nonnull stop)
             {
                 if ([[obj allKeys] containsObject:kTFMediaKey]
                     && [[obj allKeys] containsObject:kRowIndexKey]
                     && rowIndex == [obj[kRowIndexKey] unsignedIntegerValue])
                 {
                     delDict = obj;
                     isExist = YES;
                     *stop   = YES;
                 }
             }];
            if (YES == isExist && delDict)
            {
                [self.downloadingPhotoSet removeObject:delDict];
            }
            if (self.photoList.count > rowIndex)
            {
                self.photoList[rowIndex].isDownloading = NO;
                stopMedia = self.photoList[rowIndex];
            }
            [self.photoListLock lock];
            self.curDownloadPath = [NSIndexPath indexPathForRow:rowIndex
                                                      inSection:0];
            self.curDownloadingCell = [self.recordMediaTableview cellForRowAtIndexPath:self.curDownloadPath];
            [self.curDownloadingCell endDownload:StopDowloadReason_cancel];
            [self.photoListLock unLock];
        }
            break;
            
        default:
            break;
    }
    [TFDownloadManager stopDownloadMedia:stopMedia];
}

#pragma mark -- 添加开始下载‘图片’通知
- (void)addStartDownloadNotify
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(startDownloadPhoto:)
                                                 name:kStartDownloadTFPhotoNotify
                                               object:nil];
}

- (void)startDownloadPhoto:(NSNotification *)notify
{
    NSDictionary *dict = (NSDictionary *)notify.object;
    if (!dict || NO == [[dict allKeys] containsObject:kDownloadTFPhotoRowKey])
    {
        return;
    }
    NSNumber *rowValue  = dict[kDownloadTFPhotoRowKey];
    NSUInteger rowIndex = [rowValue unsignedIntegerValue];
    if (self.photoList.count < rowIndex)
    {
        GosLog(@"越界，无法下载图片！");
        return;
    }
    self.curDownloadPath = [NSIndexPath indexPathForRow:rowIndex inSection:0];
    self.curDownloadingCell = [self.recordMediaTableview cellForRowAtIndexPath:self.curDownloadPath];
    [self prepareDownloadMedia:self.photoList[rowIndex]];
}

#pragma mark -- 添加下载成功通知
- (void)addDownloadSuccessNotify
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(downloadSuccess:)
                                                 name:kTFMediaDownloadSuccessNotify
                                               object:nil];
}

- (void)downloadSuccess:(NSNotification *)notify
{
    NSDictionary *dict = (NSDictionary *)notify.object;
    if (!dict || NO == [[dict allKeys] containsObject:kTFMediaKey])
    {
        return;
    }
    TFCRMediaModel *media  = dict[kTFMediaKey];
    GOS_WEAK_SELF;
    dispatch_async(self.handleDownloadResultQueue, ^{
        
        GOS_STRONG_SELF;
        [strongSelf handleDownloadResult:YES
                                 ofMedia:media];
    });
}

#pragma mark -- 添加下载失败通知
- (void)addDownloadFailureNotify
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(downloadFailure:)
                                                 name:kTFMediaDownloadFailureNotify
                                               object:nil];
}

- (void)downloadFailure:(NSNotification *)notify
{
    NSDictionary *dict = (NSDictionary *)notify.object;
    if (!dict || NO == [[dict allKeys] containsObject:kTFMediaKey])
    {
        return;
    }
    GOS_WEAK_SELF;
    TFCRMediaModel *media  = dict[kTFMediaKey];
    NSString *tips = [NSString stringWithFormat:@"%@%@", media.tfmFile.showName, DPLocalizedString(@"TFCR_DownloadFalure")];
    if (self.selectedMediaType == media.tfmFile.fileType)
    {
        [SVProgressHUD showErrorWithStatus:tips];
    }
    dispatch_async(self.handleDownloadResultQueue, ^{
        
        GOS_STRONG_SELF;
        [strongSelf handleDownloadResult:NO
                                 ofMedia:media];
    });
}

#pragma mark -- 处理下载结果
- (void)handleDownloadResult:(BOOL)isDownloadSuccess
                     ofMedia:(TFCRMediaModel *)media
{
    if (!media || IS_EMPTY_STRING(media.tfmFile.fileName))
    {
        GosLog(@"无法处理设备（ID = %@）TF 卡媒体文件下载结果！", self.devModel.DeviceId);
        return;
    }
    if (YES == m_isShowingAlert)
    {
        GosLog(@"TF 卡媒体文件下载结束，自动隐藏 AlertVC");
        [self configStopDownloadAlert:NO];
    }
    BOOL isCurShowList                       = NO;
    NSMutableArray<TFCRMediaModel*>*tempList = nil;
    NSMutableSet<NSDictionary *>*tempSet     = nil;
    switch (media.tfmFile.fileType)
    {
        case TFMediaFile_video:
        {
            tempList = self.videoList;
            if (TFMediaFile_video == self.selectedMediaType)    // 在当选择的是 Video 列表
            {
                isCurShowList = YES;
            }
            tempSet = self.downloadingVideoSet;
        }
            break;
            
        case TFMediaFile_photo:
        {
            if (TFMediaFile_photo == self.selectedMediaType)    // 在当选择的是 Video 列表
            {
                isCurShowList = YES;
            }
            tempList = self.photoList;
            tempSet  = self.downloadingPhotoSet;
        }
            break;
            
        default:
            break;
    }
    for (int i = 0; i < tempList.count; i++)
    {
        if (NO == [media isEqual:tempList[i]])
        {
            continue;
        }
        tempList[i].hasDownload   = isDownloadSuccess;
        tempList[i].isDownloading = NO;
        
        if (YES == isCurShowList)    // 在当选择的是 Video 列表
        {
            self.curDownloadPath = [NSIndexPath indexPathForRow:i
                                                      inSection:0];
            self.curDownloadingCell = [self.recordMediaTableview cellForRowAtIndexPath:self.curDownloadPath];
            if (self.curDownloadingCell)
            {
                [self.curDownloadingCell endDownload:NO == isDownloadSuccess ? StopDowloadReason_failure : StopDowloadReason_success];
            }
        }
        break;
    }
    __block BOOL isExist          = NO;
    __block NSDictionary *delDict = nil;
    [tempSet enumerateObjectsWithOptions:NSEnumerationConcurrent
                              usingBlock:^(NSDictionary * _Nonnull obj,
                                           BOOL * _Nonnull stop)
     {
         if ([[obj allKeys] containsObject:kTFMediaKey]
             && [[obj allKeys] containsObject:kRowIndexKey]
             && [media isEqual:obj[kTFMediaKey]])
         {
             isExist = YES;
             delDict = obj;
             *stop   = YES;
         }
     }];
    if (YES == isExist && delDict)
    {
        [tempSet removeObject:delDict];
    }
}

#pragma mark - 播放
#pragma mark -- 播放媒体文件
- (void)startPlayMedia:(TFCRMediaModel *)media
{
    if (!media || NO == media.hasDownload || IS_EMPTY_STRING(media.mediaFilePath))
    {
        GosLog(@"无法播放设备（ID = %@）TF 卡录制媒体文件（hasdownload = %d, mediaFilePath = %@）", self.devModel.DeviceId, media.hasDownload, media.mediaFilePath);
        return;
    }
    switch (media.tfmFile.fileType)
    {
        case TFMediaFile_video:
        {
            NSURL *url = [NSURL fileURLWithPath:media.mediaFilePath];
            MPMoviePlayerViewController *playVideoVC = [[MPMoviePlayerViewController alloc] initWithContentURL:url];
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(videoPlayFinishNotify:)
                                                         name:MPMoviePlayerPlaybackDidFinishNotification
                                                       object:playVideoVC.moviePlayer];
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self presentViewController:playVideoVC
                                   animated:YES
                                 completion:nil];
            });
        }
            break;
            
        case TFMediaFile_photo:
        {
            TFPhotoBrowseViewController *photoVC = [[TFPhotoBrowseViewController alloc] init];
            photoVC.photoList                = [self.photoList mutableCopy];
            photoVC.curPhotoIndex            = self.curSelectedPath.row;
            [self.navigationController pushViewController:photoVC
                                                 animated:YES];
        }
            break;
            
        default:
            break;
    }
}

#pragma mark -- 播放结束通知
-(void)videoPlayFinishNotify:(NSNotification*)notify
{
    [[UIDevice currentDevice] setValue:@(UIInterfaceOrientationPortrait)
                                forKey:@"orientation"];
    MPMoviePlayerController *playVideoVC = [notify object];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:MPMoviePlayerPlaybackDidFinishNotification
                                                  object:playVideoVC];
    [playVideoVC.view removeFromSuperview];
}

#pragma mark - 数据处理
#pragma mark -- 录制视频列表处理
- (void)handleVideoList:(NSArray<TFMediaFileModel*>*)videoList
{
    if (!videoList || 0 == videoList.count)
    {
        return;
    }
    [self.videoListLock lock];
    NSFileManager *manager = [NSFileManager defaultManager];
    for (int i = 0; i < videoList.count; i++)   // 需要默认排序，不使用’enumerateObjectsWithOptions‘
    {
        TFCRMediaModel *media = [[TFCRMediaModel alloc] init];
        media.tfmFile         = videoList[i];
        media.mediaFileSize   = [self formatFileSize:media.tfmFile.fileSize];
        media.isDownloading   = NO;
        media.mediaFilePath   = [MediaManager pathWithDevId:self.devModel.DeviceId
                                                   fileName:media.tfmFile.fileName
                                                  mediaType:GosMediaTFRecVideo
                                                 deviceType:(GosDeviceType)self.devModel.DeviceType
                                                   position:PositionMain];
        BOOL isExist = NO;
        BOOL isDir   = NO;
        isExist = [manager fileExistsAtPath:media.mediaFilePath
                                isDirectory:&isDir];
        if (isExist && NO == isDir)
        {
            media.hasDownload = YES;
        }
        else
        {
            media.hasDownload = NO;
        }
        if (NO == m_isPullDownLoadMore)
        {
            [self.videoList addObject:media];
            if (videoList.count - 1 == i)
            {
                self.lastVideoFileName = videoList[i].fileName;
                GosLog(@"TF 卡录制文件（lastVideoFileName）：%@", self.lastVideoFileName);
            }
        }
        else
        {
            [self.videoList insertObject:media atIndex:i];
            if (0 == i)
            {
                self.latestVideoFileName = videoList[i].fileName;
                GosLog(@"TF 卡录制文件（latestVideoFileName）：%@", self.latestVideoFileName);
            }
        }
    }
    if (YES == m_isPullDownLoadMore)    // rowIndex 变动了
    {
        NSMutableSet<NSDictionary*>*tempSet = [NSMutableSet setWithCapacity:0];
        [self.downloadingVideoSet enumerateObjectsWithOptions:NSEnumerationConcurrent
                                                   usingBlock:^(NSDictionary * _Nonnull obj,
                                                                BOOL * _Nonnull stop)
         {
             if ([[obj allKeys] containsObject:kTFMediaKey]
                 && [[obj allKeys] containsObject:kRowIndexKey])
             {
                 TFCRMediaModel *media = obj[kTFMediaKey];
                 NSUInteger rowIndex = [obj[kRowIndexKey] unsignedIntegerValue];
                 rowIndex += videoList.count;
                 NSDictionary *dict = @{kTFMediaKey  : media,
                                        kRowIndexKey : @(rowIndex)};
                 [tempSet addObject:dict];
             }
         }];
        self.downloadingVideoSet = [NSMutableSet setWithSet:tempSet];
    }
    [self refreshTableView];
    [self.videoListLock unLock];
    
    [self checkNoFileTips];
    [self configRightBarBtnTitle];
}

#pragma mark -- 录制图片列表处理
- (void)handlePhotoList:(NSArray<TFMediaFileModel*>*)photoList
{
    if (!photoList || 0 == photoList.count)
    {
        return;
    }
    [self.photoListLock lock];
    NSFileManager *manager = [NSFileManager defaultManager];
    for (int i = 0; i < photoList.count; i++)   // 需要默认排序，不使用’enumerateObjectsWithOptions‘
    {
        TFCRMediaModel *media = [[TFCRMediaModel alloc] init];
        media.tfmFile         = photoList[i];
        media.mediaFileSize   = [self formatFileSize:media.tfmFile.fileSize];
        media.isDownloading   = NO;
        media.mediaFilePath   = [MediaManager pathWithDevId:self.devModel.DeviceId
                                                   fileName:media.tfmFile.fileName
                                                  mediaType:GosMediaTFRecPhoto
                                                 deviceType:(GosDeviceType)self.devModel.DeviceType
                                                   position:PositionMain];
        BOOL isExist = NO;
        BOOL isDir   = NO;
        isExist = [manager fileExistsAtPath:media.mediaFilePath
                                isDirectory:&isDir];
        if (isExist && NO == isDir)
        {
            media.hasDownload = YES;
        }
        else
        {
            media.hasDownload = NO;
        }
        if (NO == m_isPullDownLoadMore)
        {
            [self.photoList addObject:media];
            if (photoList.count - 1 == i)
            {
                self.lastPhotoFileName = photoList[i].fileName;
                GosLog(@"TF 卡录制文件（lastPhotoFileName）：%@", self.lastPhotoFileName);
            }
        }
        else
        {
            [self.photoList insertObject:media atIndex:i];
            if (0 == i)
            {
                self.latestPhotoFileName = photoList[i].fileName;
                GosLog(@"TF 卡录制文件（latestPhotoFileName）：%@", self.latestPhotoFileName);
            }
        }
    }
    if (YES == m_isPullDownLoadMore)    // rowIndex 变动了
    {
        NSMutableSet<NSDictionary*>*tempSet = [NSMutableSet setWithCapacity:0];
        [self.downloadingPhotoSet enumerateObjectsWithOptions:NSEnumerationConcurrent
                                                   usingBlock:^(NSDictionary * _Nonnull obj,
                                                                BOOL * _Nonnull stop)
         {
             if ([[obj allKeys] containsObject:kTFMediaKey]
                 && [[obj allKeys] containsObject:kRowIndexKey])
             {
                 TFCRMediaModel *media = obj[kTFMediaKey];
                 NSUInteger rowIndex = [obj[kRowIndexKey] unsignedIntegerValue];
                 rowIndex += photoList.count;
                 NSDictionary *dict = @{kTFMediaKey  : media,
                                        kRowIndexKey : @(rowIndex)};
                 [tempSet addObject:dict];
             }
         }];
        self.downloadingPhotoSet = [NSMutableSet setWithSet:tempSet];
    }
    [self refreshTableView];
    [self.photoListLock unLock];
    
    [self checkNoFileTips];
    [self configRightBarBtnTitle];
}

#pragma mark -- 提取文件时间
-(NSString *)extractTimeFromStr:(NSString *)dateStr;
{
    if (!dateStr || 14 > dateStr.length)
    {
        return nil;
    }
    NSString *year     = [dateStr substringToIndex:4];
    NSString *month    = [dateStr substringWithRange:NSMakeRange(4, 2)];
    NSString *day      = [dateStr substringWithRange:NSMakeRange(6, 2)];
    NSString *time     = [dateStr substringWithRange:NSMakeRange(8, 2)];
    NSString *minute   = [dateStr substringWithRange:NSMakeRange(10,2)];
    NSString *second   = [dateStr substringWithRange:NSMakeRange(12,2)];
    NSString *dateTime = [NSString stringWithFormat:@"%@/%@/%@ %@:%@:%@",year,month,day,time,minute,second];
    return dateTime;
}

//- (PushMsgType)extractTypeFromeStr:(NSString *)fileName
//{
//
//}

#pragma mark -- 提取文件时间
-(NSString *)formatFileSize:(long long)fileSize;
{
    if (0 > fileSize)
    {
        return nil;
    }
    NSString *measureUnit = nil;
    double measureSize    = 0;
    if (kMeasureSizeGB <= fileSize) // GB
    {
        measureUnit = @"GB";
        measureSize = (double)fileSize/(double)kMeasureSizeGB;
    }
    else if (kMeasureSizeGB > fileSize && kMeasureSizeMB <= fileSize)   // MB
    {
        measureUnit = @"MB";
        measureSize = (double)fileSize/(double)kMeasureSizeMB;
    }
    else if (kMeasureSizeMB > fileSize && kMeasureSizeKB <= fileSize)   // KB
    {
        measureUnit = @"KB";
        measureSize = (double)fileSize/(double)kMeasureSizeKB;
    }
    else
    {
        measureUnit = @"B";
        measureSize = fileSize;
    }
    NSString *sizeStr = [NSString stringWithFormat:@"%.2f%@", measureSize, measureUnit];
    return sizeStr;
}

#pragma mark - 懒加载
- (NSMutableArray<TFCRMediaModel *> *)videoList
{
    if (!_videoList)
    {
        _videoList = [NSMutableArray arrayWithCapacity:0];
    }
    return _videoList;
}

- (NSMutableArray<TFCRMediaModel *> *)photoList
{
    if (!_photoList)
    {
        _photoList = [NSMutableArray arrayWithCapacity:0];
    }
    return _photoList;
}

- (iOSConfigSDK *)configSdk
{
    if (!_configSdk)
    {
        _configSdk = [iOSConfigSDK shareCofigSdk];
        _configSdk.dmDelegate = self;
    }
    return _configSdk;
}


- (NSMutableSet<NSNumber *> *)hasSelectedRowSet
{
    if (!_hasSelectedRowSet)
    {
        _hasSelectedRowSet = [NSMutableSet setWithCapacity:0];
    }
    return _hasSelectedRowSet;
}

- (NSMutableSet<NSDictionary *> *)downloadingVideoSet
{
    if (!_downloadingVideoSet)
    {
        _downloadingVideoSet = [NSMutableSet setWithCapacity:0];
    }
    return _downloadingVideoSet;
}

- (NSMutableSet<NSDictionary *> *)downloadingPhotoSet
{
    if (!_downloadingPhotoSet)
    {
        _downloadingPhotoSet = [NSMutableSet setWithCapacity:0];
    }
    return _downloadingPhotoSet;
}

- (UIAlertController *)stopDownloadAlert
{
    if (!_stopDownloadAlert)
    {
        GOS_WEAK_SELF;
        _stopDownloadAlert = [UIAlertController alertControllerWithTitle:DPLocalizedString(@"TFCR_Tips")
                                                                 message:DPLocalizedString(@"TFCR_IsCancelDownload")
                                                          preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *delAction = [UIAlertAction actionWithTitle:DPLocalizedString(@"TFCR_Stop")
                                                            style:UIAlertActionStyleDestructive
                                                          handler:^(UIAlertAction * _Nonnull action) {
                                                              
                                                              GOS_STRONG_SELF;
                                                              [strongSelf cancelDownload];
                                                              strongSelf->m_isShowingAlert = NO;
                                                          }];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:DPLocalizedString(@"GosComm_Cancel")
                                                               style:UIAlertActionStyleCancel
                                                             handler:^(UIAlertAction * _Nonnull action) {
                                                                 
                                                                 GOS_STRONG_SELF;
                                                                 strongSelf->m_isShowingAlert = NO;
                                                             }];
        [_stopDownloadAlert addAction:delAction];
        [_stopDownloadAlert addAction:cancelAction];
    }
    return _stopDownloadAlert;
}


#pragma mark - TableView DataSource & Delegate
- (NSInteger)tableView:(nonnull UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    switch (self.selectedMediaType)
    {
        case TFMediaFile_video:
        {
            return self.videoList.count;
        }
            break;
            
        case TFMediaFile_photo:
        {
            return self.photoList.count;
        }
            break;
            
        default:
            return 0;
            break;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *TFCRMediaListCellId = @"TFCRMediaListCell";
    NSUInteger rowIndex = indexPath.row;
    switch (self.selectedMediaType)
    {
        case TFMediaFile_video:
        {
            if (self.videoList.count <= rowIndex)
            {
                UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                               reuseIdentifier:@"DefaultTFCRMediaListCellId"];
                return cell;
            }
        }
            break;
            
        case TFMediaFile_photo:
        {
            if (self.photoList.count <= rowIndex)
            {
                UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                               reuseIdentifier:@"DefaultTFCRMediaListCellId"];
                return cell;
            }
        }
            break;
            
        default:
            return 0;
            break;
    }
    TFCRMediaListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:TFCRMediaListCellId];
    if (!cell)
    {
        cell = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([TFCRMediaListTableViewCell class])
                                             owner:self
                                           options:nil][0];
        cell.isEditing = m_isEditing;
    }
    switch (self.selectedMediaType)
    {
        case TFMediaFile_video:
        {
            cell.mediaData = self.videoList[rowIndex];
        }
            break;
            
        case TFMediaFile_photo:
        {
            cell.mediaData = self.photoList[rowIndex];
        }
            break;
            
        default:
            break;
    }
    cell.isEditing = m_isEditing;
    cell.hasSelected = [self.hasSelectedRowSet containsObject:@(rowIndex)];
    GOS_WEAK_SELF;
    cell.selectedBtnActionBlock = ^(BOOL isSeleted) {
        
        GOS_STRONG_SELF;
        [strongSelf selectedBtnAction:isSeleted
                          onIndexPath:indexPath];
    };
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (YES == m_isDeleting)
    {
        GosLog(@"正在删除已选中推送消息，请稍后。。。");
        return;
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSInteger rowIndex         = indexPath.row;
    self.curSelectedPath       = indexPath;
    TFCRMediaModel *media      = nil;
    __block BOOL isDownloading = NO;
    switch (self.selectedMediaType)
    {
        case TFMediaFile_video:
        {
            if (self.videoList.count <= rowIndex)
            {
                return;
            }
            media = self.videoList[rowIndex];
            [self.downloadingVideoSet enumerateObjectsWithOptions:NSEnumerationConcurrent
                                                       usingBlock:^(NSDictionary * _Nonnull obj,
                                                                    BOOL * _Nonnull stop)
             {
                 if ([[obj allKeys] containsObject:kTFMediaKey]
                     && [[obj allKeys] containsObject:kRowIndexKey]
                     && [media isEqual:obj[kTFMediaKey]])
                 {
                     isDownloading = YES;
                     *stop         = YES;
                 }
             }];
        }
            break;
			
        case TFMediaFile_photo:
        {
            if (self.photoList.count <= rowIndex)
            {
                return;
            }
            media = self.photoList[rowIndex];
            [self.downloadingPhotoSet enumerateObjectsWithOptions:NSEnumerationConcurrent
                                                       usingBlock:^(NSDictionary * _Nonnull obj,
                                                                    BOOL * _Nonnull stop)
             {
                 if ([[obj allKeys] containsObject:kTFMediaKey]
                     && [[obj allKeys] containsObject:kRowIndexKey]
                     && [media isEqual:obj[kTFMediaKey]])
                 {
                     isDownloading = YES;
                     *stop         = YES;
                 }
             }];
        }
            break;
            
        default:
            break;
    }
    if (NO == m_isEditing)  // 普通模式
    {
        if (NO == media.hasDownload)    // 还未下载
        {
            if (NO == isDownloading)
            {
                self.curDownloadPath    = indexPath;
                self.curDownloadingCell = [tableView cellForRowAtIndexPath:indexPath];
                [self prepareDownloadMedia:media];
            }
            else    // 已在下载队列
            {
                [self configStopDownloadAlert:YES];
            }
        }
        else    // 已下载，开始播放
        {
            m_isQuitCurVC = NO;
            [self startPlayMedia:media];
        }
    }
    else    // 选择模式
    {
        [self selectedBtnAction:![self.hasSelectedRowSet containsObject:@(rowIndex)]
                    onIndexPath:indexPath];
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView
           editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger rowIndex = indexPath.row;
    if (UITableViewCellEditingStyleDelete == editingStyle)
    {
        switch (self.selectedMediaType)
        {
            case TFMediaFile_video:
            {
                if (self.videoList.count <= rowIndex)
                {
                    return;
                }
            }
                break;
                
            case TFMediaFile_photo:
            {
                if (self.photoList.count <= rowIndex)
                {
                    return;
                }
            }
                break;
                
            default:
                break;
        }
        [self deleteFileAtIndexPath:indexPath];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return DPLocalizedString(@"GosComm_Delete");
}


#pragma mark - iOSConfigSDKDMDelegate
- (void)reqDay:(BOOL)isSuccess
    recordList:(NSArray <TFMediaFileModel*>*)fileList
         count:(NSInteger)pCount
      isNoFile:(BOOL)isNoFile
{
    [SVProgressHUD dismiss];
    m_isRequesting = NO;
    if (NO == isSuccess)
    {
        GosLog(@"请求设备（ID = %@）TF 卡录制文件（类型：%ld)列表失败！", self.devModel.DeviceId, (long)self.selectedMediaType);
        [SVProgressHUD showErrorWithStatus:DPLocalizedString(@"GosComm_getData_fail")];
        switch (self.selectedMediaType)
        {
            case TFMediaFile_video:
            {
                if (YES == m_isInitList && YES == m_hasInitVideoList)
                {
                    m_hasInitVideoList = NO;
                }
            }
                break;
                
            case TFMediaFile_photo:
            {
                if (YES == m_isInitList && YES == m_hasInitPhotoList)
                {
                    m_hasInitPhotoList = NO;
                }
            }
                break;
                
            default:
                break;
        }
    }
    else
    {
        GosLog(@"请求设备（ID = %@）TF 卡录制文件（类型：%ld)列表成功：count = %ld", self.devModel.DeviceId, (long)self.selectedMediaType, (long)fileList.count);
        if (NO == isNoFile)
        {
            GOS_WEAK_SELF;
            switch (self.selectedMediaType)
            {
                case TFMediaFile_video:
                {
                    dispatch_async([QueueManager bgQueue], ^{
                        
                        GOS_STRONG_SELF;
                        [strongSelf handleVideoList:[fileList mutableCopy]];
                        if (NO == strongSelf->m_isPullDownLoadMore)
                        {
                            [strongSelf stopPullUpLoadMore:NO];
                        }
                        else
                        {
                            [strongSelf stopPullDownLoadMore];
                        }
                    });
                }
                    break;
                    
                case TFMediaFile_photo:
                {
                    dispatch_async([QueueManager bgQueue], ^{
                        
                        GOS_STRONG_SELF;
                        [strongSelf handlePhotoList:[fileList mutableCopy]];
                        if (NO == strongSelf->m_isPullDownLoadMore)
                        {
                            [strongSelf stopPullUpLoadMore:NO];
                        }
                        else
                        {
                            [strongSelf stopPullDownLoadMore];
                        }
                    });
                }
                    break;
                    
                default:
                    break;
            }
        }
        else
        {
            if (NO == m_isPullDownLoadMore)
            {
                [self stopPullUpLoadMore:YES];
                [SVProgressHUD showInfoWithStatus:DPLocalizedString(@"TFCR_NoLastFile")
                                      forDuration:1.5];
            }
            else
            {
                [self stopPullDownLoadMore];
                [SVProgressHUD showInfoWithStatus:DPLocalizedString(@"TFCR_NoLatestFile")
                                      forDuration:1.5];
            }
        }
    }
}

- (void)delTFRecList:(BOOL)isSuccess
            deviceId:(NSString *)devId
           errorCode:(int)eCode
{
    [SVProgressHUD dismiss];
    if (NO == isSuccess)
    {
        GosLog(@"删除设备（ID = %@）TF 卡录制文件失败：%d", devId, eCode);
        [SVProgressHUD showErrorWithStatus:DPLocalizedString(@"GosComm_DeleteFailure")];
        m_isDeleting = NO;
    }
    else
    {
        GosLog(@"删除设备（ID = %@）TF 卡录制文件成功！", devId);
        GOS_WEAK_SELF;
        dispatch_async([QueueManager bgQueue], ^{
            
            GOS_STRONG_SELF;
            [strongSelf handleDeleteSuccess];
        });
    }
}


#pragma mark - GosBottomOperateViewDelegate
#pragma mark -- ‘全选’按钮事件
- (void)leftButtonAction
{
    if (YES == m_isDeleting)
    {
        GosLog(@"正在删除已选中录制文件，请稍后。。。");
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
        switch (self.selectedMediaType)
        {
            case TFMediaFile_video:
            {
                [self.videoListLock lock];
                for (int i = 0; i < self.videoList.count; i++)
                {
                    [self.hasSelectedRowSet addObject:@(i)];
                }
                [self.videoListLock unLock];
            }
                break;
                
            case TFMediaFile_photo:
            {
                [self.photoListLock lock];
                for (int i = 0; i < self.photoList.count; i++)
                {
                    [self.hasSelectedRowSet addObject:@(i)];
                }
                [self.photoListLock unLock];
            }
                break;
                
            default:
                break;
        }
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
        GosLog(@"正在删除已选中录制文件，请稍后。。。");
        return;
    }
    GosLog(@"准备删除已选中的录制文件...");
    GOS_WEAK_SELF;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        GOS_STRONG_SELF;
        [strongSelf startDeleteAction];
    });
}


#pragma mark - TFDownloadManagerDelegate
- (void)downloadMedia:(TFCRMediaModel *)media
             progress:(float)progress
{
    if (!media || IS_EMPTY_STRING(media.tfmFile.fileName))
    {
        GosLog(@"无法处理设备（ID = %@）TF 卡媒体文件下载进度！", self.devModel.DeviceId);
        return;
    }
    self.curDownloadProgress = progress;
    self.curDownloadMedia    = [media copy];
    if (NO == m_hasRefreshTB)
    {
        GosLog(@"TF 卡媒体文件列表还未刷新，无法刷新下载进度！");
        return;
    }
    __block BOOL isExist        = NO;
    __block NSUInteger rowIndex = 0;
    switch (media.tfmFile.fileType)
    {
        case TFMediaFile_video:
        {
            [self.downloadingVideoSet enumerateObjectsWithOptions:NSEnumerationConcurrent
                                                       usingBlock:^(NSDictionary * _Nonnull obj,
                                                                    BOOL * _Nonnull stop)
            {
                if ([[obj allKeys] containsObject:kTFMediaKey]
                    && [[obj allKeys] containsObject:kRowIndexKey]
                    && [media isEqual:obj[kTFMediaKey]])
                {
                    isExist  = YES;
                    rowIndex = [obj[kRowIndexKey] unsignedIntegerValue];
                    *stop    = YES;
                }
            }];
            if (YES == isExist && media.tfmFile.fileType == self.selectedMediaType
                && self.videoList.count > rowIndex)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [self.videoListLock lock];
                    self.curDownloadPath = [NSIndexPath indexPathForRow:rowIndex
                                                              inSection:0];
                    self.curDownloadingCell = [self.recordMediaTableview cellForRowAtIndexPath:self.curDownloadPath];
                    [self.curDownloadingCell downloading:progress];
                    [self.videoListLock unLock];
                });
            }
        }
            break;
            
        case TFMediaFile_photo:
        {
            [self.downloadingPhotoSet enumerateObjectsWithOptions:NSEnumerationConcurrent
                                                       usingBlock:^(NSDictionary * _Nonnull obj,
                                                                    BOOL * _Nonnull stop)
             {
                 if ([[obj allKeys] containsObject:kTFMediaKey]
                     && [[obj allKeys] containsObject:kRowIndexKey]
                     && [media isEqual:obj[kTFMediaKey]])
                 {
                     isExist  = YES;
                     rowIndex = [obj[kRowIndexKey] unsignedIntegerValue];
                     *stop    = YES;
                 }
             }];
            if (YES == isExist && media.tfmFile.fileType == self.selectedMediaType
                && self.photoList.count > rowIndex)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [self.photoListLock lock];
                    self.curDownloadPath = [NSIndexPath indexPathForRow:rowIndex
                                                              inSection:0];
                    self.curDownloadingCell = [self.recordMediaTableview cellForRowAtIndexPath:self.curDownloadPath];
                    [self.curDownloadingCell downloading:progress];
                    [self.photoListLock unLock];
                });
            }
        }
            break;
            
        default:
            break;
    }
}

@end
