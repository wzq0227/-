//
//  DeviceListViewController.m
//  Goscom
//
//  Created by shenyuanluo on 2018/11/10.
//  Copyright © 2018 shenyuanluo. All rights reserved.
//

#import "DeviceListViewController.h"
#import "iOSConfigSDK.h"
#import "iOSDevSDK.h"
#import "IpcDevListTableViewCell.h"
#import "NVRDevListTableViewCell.h"
#import "Panoramic360DevListCell.h"
#import "UITableViewCell+DeviceListENUM.h"
#import "MJRefresh.h"
#import "MainSettingViewController.h"
#import "GosDevManager.h"
#import "AppDelegate+GosAutoLogin.h"
#import "DeviceListViewController+AutoLogin.h"
#import "IPCPlayViewController.h"
#import "GosThreadTimer.h"
#import "DevAbilityManager.h"
#import "APNSManager.h"
#import "MessageListViewController.h"
#import "PushStatusMananger.h"
#import "AddDeviceFirstViewController.h"
#import "ScanQRCodeManager.h"
#import "NSObject+CurrentVC.h"
#import "TFCRDateListViewController.h"
#import "CloudPlaybackViewController.h"
#import "SetDevNameAlertManager.h"
#import "MonitorNetwork.h"
#import "VRPlayViewController.h"
#import "UIScrollView+EmptyDataSet.h"
#import "TFCardPlayViewController.h"

#define CELL_BOTTOM_VIEW_HEIGHT     40.0f
#define GOS_REQ_DEV_LIST_TIMEOUT    10  // 请求设备列表超时时间（单位：秒）
#define AUTO_CONN_INTERVALE         5   // 自动连接时间间隔（单位：秒）
#define OP_DEV_LIST_TIMEOUT         20  // 操作设备列表超时时间（单位：秒）
#define OP_ABILITY_SET_TIMEOUT      10   // 操作需要获取设备能力集集合超时时间（单位：秒）


/* 导航栏状态类型 */
typedef NS_ENUM(NSInteger, NaviTitleStatus) {
    NaviTitle_normal                = 0,    // 普通状态：设备列表
    NaviTitle_connecting            = 1,    // 正在连接：设备列表（正在连接。。。）
    NaviTitle_noNetwork             = 2,    // 没有网络：设备列表（未连接）
};

@interface DeviceListViewController () <
                                        UITableViewDataSource,
                                        UITableViewDelegate,
                                        iOSConfigSDKDMDelegate,
                                        iOSDevConnDelegate,
                                        iOSConfigSDKABDelegate,
                                        DZNEmptyDataSetSource,
                                        DZNEmptyDataSetDelegate
                                       >
{
    BOOL m_isConnecting;        // 是否正在连接中（自动登录时）
    BOOL m_isRequestingDevList; // 是否正在请求设备列表
    BOOL m_isFirstAutoConn;     // 是否第一次启动自动连接
    BOOL m_hasTurnToOtherVC;    // 是否已经跳转至其他页面
    BOOL m_isPauseAutoTimer;    // 是否暂停自动连接管理定时器
    BOOL m_isCheckingPushStatus;    // 是否正在请求所有设备推送状态
    BOOL m_hasCheckedPushStatus;    // 是否已经查询所有设备推送状态
    dispatch_queue_t m_sortDevListQueue;        // 根据在线状态排序设备列表队列（串行）
    dispatch_queue_t m_updateDevStatusQueue;    // 更新设备列表在线状态队列（串行）
    dispatch_queue_t m_dbReadWriteQueue;        // 数据库读/写队列（串行）
    dispatch_queue_t m_reConnQueue;             // 重连操作队列（串行）
}

@property (weak, nonatomic) IBOutlet UITableView *devListTableView;
@property (nonatomic, readwrite, strong) iOSConfigSDK *configSdk;
/** 设备列表 */
@property (nonatomic, readwrite, strong) NSMutableArray <DevDataModel *>*devListArray;
/** 设备列表访问 锁 */
@property (nonatomic, readwrite, strong) GosReadWriteLock *devListLock;
@property (nonatomic, readwrite, strong) iOSDevSDK *devSdk;
/** DevSDK 是否已经初始化（防止二次初始化） */
@property (nonatomic, readwrite, assign) BOOL hasDevSdkInit;;
/** DevSDK 是否设置‘设置传输协议和服务器地址’ 成功 */
@property (nonatomic, readwrite, assign) BOOL isDevSdkInitSuccess;
@property (nonatomic, readwrite, strong) NSMutableArray<DevDataModel*> *autoConnPool;   // 自动连接池
/* 自动连接池管理队列 */
@property (nonatomic, readwrite, strong) dispatch_queue_t autoConnQueue;
/** 自动连接定时器 */
@property (nonatomic, readwrite, strong) GosThreadTimer *autoConnTimer;
/** 完成创建连接设备 ID 集合 */
@property (nonatomic, readwrite, strong) NSMutableSet<NSString*> *hasConnectedSet;
/** 正在创建连接设备 ID 集合（控制连接状态返回前重复创建连接） */
@property (nonatomic, readwrite, strong) NSMutableSet<NSString*> *connectingSet;
/** 正在断开连接设备 ID 集合（控制连接状态返回前重复断开连接） */
@property (nonatomic, readwrite, strong) NSMutableSet<NSString*> *disConnectingSet;
/** 需要获取设备能力集 ID 集合 */
@property (nonatomic, readwrite, strong) NSMutableSet<NSString*> *needReqAbilitySet;
/** 正在获取设备能力集 ID 集合 */
@property (nonatomic, readwrite, strong) NSMutableSet<NSString*> *reqingAbilitySet;
/** 操作需要获取设备能力集 ID 集合 锁*/
@property (nonatomic, readwrite, strong) GosReadWriteLock *abilitySetLock;
/** 当前选择的 IndexPath */
@property (nonatomic, readwrite, strong) NSIndexPath *curSelectedPath;
/** 当前选择的的设备 */
@property (nonatomic, readwrite, strong) DevDataModel *curSelectedDevice;
/** 扫描管理 */
@property (nonatomic, strong) ScanQRCodeManager *manager;
/** 设备命名管理 */
@property (nonatomic, strong) SetDevNameAlertManager *alertManager;
@end

static NSString * const kIpcCellId = @"IPCCellId";
static NSString * const kNVRCellId = @"kNVRCellId";
static NSString * const kPanoramic360CellId = @"kPanoramic360CellId";

@implementation DeviceListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initParam];
    [self configUI];
    [self addNetworkChangeNotify];
    [self addReDisConnAndConnNotify];
    [self addUpdateCoverNotify];
    [self addModifyDevInfoNotify];
    [self addDeleteDeviceNotify];
    [self addLogoutNotify];
    [self createAutoConnTimer];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (YES == self.hasNetWork)
    {
        self.configSdk.dmDelegate = self;
    }
    [self resetParam];
    
    if (self.isAddSuccess) {
        [self refreshDeviceList];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)dealloc
{
    [self.autoConnTimer destroy];
    self.autoConnTimer = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    GosLog(@"---------- DeviceListViewController dealloc ----------");
}

#pragma mark -- 初始化参数
- (void)initParam
{
    m_isFirstAutoConn                = YES;
    m_isRequestingDevList            = NO;
    m_isPauseAutoTimer               = NO;
    m_isCheckingPushStatus           = NO;
    m_hasCheckedPushStatus           = NO;
    m_sortDevListQueue               = dispatch_queue_create("GosSortDevListQueue", DISPATCH_QUEUE_SERIAL);
    m_updateDevStatusQueue           = dispatch_queue_create("GosUpdateDevStatusQueue", DISPATCH_QUEUE_SERIAL);
    m_dbReadWriteQueue               = dispatch_queue_create("GosDBReadWriteQueue", DISPATCH_QUEUE_SERIAL);
    m_reConnQueue                    = dispatch_queue_create("GosReConnDevQueue", DISPATCH_QUEUE_SERIAL);
    self.hasDevSdkInit               = NO;
    self.isDevSdkInitSuccess         = NO;
    self.hasLogined                  = self.hasNetWork;
//    self.devListLock                 = [[GosReadWriteLock alloc] init];
    self.devListLock.readTimeout     = OP_DEV_LIST_TIMEOUT;
    self.devListLock.writeTimeout    = OP_DEV_LIST_TIMEOUT;
//    self.abilitySetLock              = [[GosReadWriteLock alloc] init];
    self.abilitySetLock.readTimeout  = OP_ABILITY_SET_TIMEOUT;
    self.abilitySetLock.writeTimeout = OP_ABILITY_SET_TIMEOUT;
}

#pragma mark -- 重置参数
- (void)resetParam
{
    m_hasTurnToOtherVC     = NO;
    self.curSelectedDevice = nil;
}

- (void)configUI
{
    self.view.backgroundColor = GOS_VC_BG_COLOR;
    CurNetworkStatus curStatus = [MonitorNetwork currentStatus];
    if (curStatus == CurNetwork_unknow)    // 没有网络
    {
        [self configNavTitle:NaviTitle_noNetwork];
    }
    else
    {
        [self configNavTitle:NaviTitle_normal];
    }
    [self configTableView];
    [self addNavRightBarButton];
}

- (void)configTableView
{
    self.devListTableView.emptyDataSetSource = self;
    self.devListTableView.emptyDataSetDelegate = self;
    self.devListTableView.backgroundColor = GOS_VC_BG_COLOR;
    self.devListTableView.separatorStyle  = UITableViewCellSeparatorStyleNone;
    self.devListTableView.rowHeight       = [self heightOfTableViewCell];
    self.devListTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    // 头部刷新控件
    if ([self respondsToSelector:@selector(reqDeviceList)])
    {
        self.devListTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self
                                                                           refreshingAction:@selector(reqDeviceList)];
    }
    if (YES == self.isAutoLogin)    // 自动登录（等待登录成功后在请求列表
    {
        [self readDevListFromDB];   // 先加载历史数据
        [self addAutoLoginSuccessNotify];
        if (NO == self.hasNetWork)  // 没有网络
        {
            [self configNavTitle:NaviTitle_noNetwork];
        }
        else
        {
            m_isConnecting = YES;
            [self configNavTitle:NaviTitle_connecting];
        }
    }
    else
    {
        m_isConnecting = NO;
         [self refreshDeviceList];
    }
}

- (void)addNavRightBarButton
{
    UIImage *addDevImg = [[UIImage imageNamed:@"icon_add"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIBarButtonItem *rightBarItem =  [[UIBarButtonItem alloc] initWithImage:addDevImg
                                                                      style:UIBarButtonItemStylePlain
                                                                     target:self
                                                                     action:@selector(turnToAddDevVC)];
    self.navigationItem.rightBarButtonItem = rightBarItem;
}

#pragma mark -- 按比例（16:9）返回 Cell 高度
- (CGFloat)heightOfTableViewCell
{
    CGFloat margin      = 20.0f;
    CGFloat rowWidth    = GOS_SCREEN_W - margin * 2;
    CGFloat rowHeight   = rowWidth * GOS_VIDEO_H_W_SCALE + CELL_BOTTOM_VIEW_HEIGHT;
    return rowHeight;
}

#pragma mark -- 根据状态设置导航栏标题
- (void)configNavTitle:(NaviTitleStatus)nsStatus
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        switch (nsStatus)
        {
            case NaviTitle_normal:      // 普通状态：设备列表
            {
                self.navigationItem.title = DPLocalizedString(@"DeviceList");
            }
                break;
                
            case NaviTitle_connecting:  // 正在连接：设备列表（正在连接。。。）
            {
                self.navigationItem.title = [NSString stringWithFormat:@"%@(%@)", DPLocalizedString(@"DeviceList"), DPLocalizedString(@"Connecting")];
            }
                break;
                
            case NaviTitle_noNetwork:   // 没有网络：设备列表（未连接）
            {
                self.navigationItem.title = [NSString stringWithFormat:@"%@(%@)", DPLocalizedString(@"DeviceList"), DPLocalizedString(@"NotConnected")];
            }
                break;
                
            default:
                break;
        }
    });
}

#pragma mark - 自动登录通知处理
- (void)addAutoLoginSuccessNotify
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(autoLoginSuccess)
                                                 name:kAutoLoginSuccessNotify
                                               object:nil];
}

#pragma mark -- 自动登录成功
- (void)autoLoginSuccess
{
    if (NO == self.hasLogined)
    {
        self.hasLogined = YES;
        m_isConnecting  = YES;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (NO == [[self getCurrentVC] isKindOfClass:[self class]]) // 注意：非当前页面，MJRefresh 不工作
        {
            GosLog(@"自动登录成功，开始请求设备列表。。。");
            [self reqDeviceList];
        }
        else
        {
            GosLog(@"自动登录成功，MJRefresh-开始请求设备列表。。。");
            [self refreshDeviceList];
        }
        if (YES == m_isPauseAutoTimer)
        {
            GosLog(@"自动登录成功，把自动连接定时器开启！");
            [self.autoConnTimer resume];
            m_isPauseAutoTimer = NO;
        }
    });
}

#pragma mark -- 刷新列表
- (void)refreshDeviceList
{
    GOS_WEAK_SELF;
    dispatch_async(dispatch_get_main_queue(), ^{
        
        GOS_STRONG_SELF;
        [strongSelf.devListTableView.mj_header beginRefreshing];
    });
}

#pragma mark -- 停止刷新列（请求超时时）
- (void)stopRefreshDeviceList
{
    GOS_WEAK_SELF;
    dispatch_async(dispatch_get_main_queue(), ^{
        
        GOS_STRONG_SELF;
        [strongSelf.devListTableView.mj_header endRefreshing];
    });
}

#pragma mark -- 请求设备列表
- (void)reqDeviceList
{
    if (YES == m_isRequestingDevList)   // 正在请求，返回
    {
        GosLog(@"正在请求设备列表，请稍后...");
        return;
    }
    GosLog(@"请求列表超时设定...");
    [self performSelector:@selector(reqDeviceListTimeout)
               withObject:nil
               afterDelay:GOS_REQ_DEV_LIST_TIMEOUT];
    m_isRequestingDevList = YES;
    [self.configSdk reqDevListWithAccount:[GosLoggedInUserInfo account]];
}

#pragma mark -- 请求设备列表超时
- (void)reqDeviceListTimeout
{
    GosLog(@"请求列表超时时间到！");
    m_isRequestingDevList = NO;
    [self stopRefreshDeviceList];
}

#pragma mark -- 处理设备列表结果数据
- (void)handleDeviceList:(NSArray<DevDataModel*>*)deviceList
{
    if (!deviceList)
    {
        [self.devListTableView.mj_header endRefreshing];
        m_isRequestingDevList = NO;
        return;
    }
    NSArray<DevDataModel*>*tempArray = nil;
    if (0 == deviceList.count)
    {
        tempArray = @[];
    }
    else
    {
        tempArray = [self sortStatusWithDeviceList:deviceList];
    }
    
    [self.devListLock lockWrite];
    self.devListArray = [tempArray mutableCopy];
    [self.devListLock unLockWrite];
    [self.devListTableView.mj_header endRefreshing];
    [self saveDevlistToDB];
    GosLog(@"更新列表数据");
    [self reloadTableView];
    m_isRequestingDevList = NO;
    dispatch_async(dispatch_get_main_queue(), ^{    // 这是在回调函数中，需在主线程取消，否则会失败
        
        GosLog(@"设备列表数据已获取，取消超时执行！");
        [NSObject cancelPreviousPerformRequestsWithTarget:self
                                                 selector:@selector(reqDeviceListTimeout)
                                                   object:nil];
    });
    [self checkNeedHandleAutoConn];    // 检查是否有需要处理自动连接逻辑的设备
    if (YES == m_isFirstAutoConn)
    {
        [self autoConnected];
        m_isFirstAutoConn = NO;
    }
}

#pragma mark -- 更新设备在线状态
- (void)updateStatusWithList:(NSArray<DevStatusModel*>*)statusList
{
    if (!statusList || 0 >= statusList.count)
    {
        return;
    }
    [self.devListLock lockRead];
    NSMutableArray <DevDataModel*>*devList  = [self.devListArray mutableCopy];
    [self.devListLock unLockRead];
    NSMutableArray <DevDataModel*>*connPool = [self.autoConnPool mutableCopy];
    for (int i = 0; i < statusList.count; i++)
    {
        // 通知其他界面
        if ([statusList[i].DeviceId isEqualToString:self.curSelectedDevice.DeviceId])
        {
            NSDictionary *notifyDict = @{@"DeviceID" : statusList[i].DeviceId,
                                         @"Status"   : @(statusList[i].Status)};
            [[NSNotificationCenter defaultCenter] postNotificationName:kCurPreviewDevStatusNotify
                                                                object:notifyDict];
        }
        // 更新设备列表设备‘在线状态’
        [devList enumerateObjectsWithOptions:NSEnumerationConcurrent
                                  usingBlock:^(DevDataModel * _Nonnull obj,
                                               NSUInteger idx,
                                               BOOL * _Nonnull stop)
        {
            if ([statusList[i].DeviceId isEqualToString:obj.DeviceId])
            {
                obj.Status = statusList[i].Status;
                GosLog(@"更新列表设备（ID = %@）在线状态：%ld", obj.DeviceId, (long)obj.Status);
                *stop = YES;
            }
        }];
        
        // 更新自动连接池设备‘在线状态’
        [connPool enumerateObjectsWithOptions:NSEnumerationConcurrent
                                   usingBlock:^(DevDataModel * _Nonnull obj,
                                                NSUInteger idx,
                                                BOOL * _Nonnull stop)
        {
            if ([obj.DeviceId isEqualToString: statusList[i].DeviceId])
            {
                obj.Status = statusList[i].Status;
                GosLog(@"更新自动连接池设备（ID = %@）在线状态：%ld", obj.DeviceId, (long)obj.Status);
                *stop = YES;
            }
        }];
    }
    NSArray<DevDataModel*>*tempArray = [self sortStatusWithDeviceList:devList];
    [self.devListLock lockWrite];
    self.devListArray = [tempArray mutableCopy];
    [self.devListLock unLockWrite];
    self.autoConnPool = [connPool mutableCopy];
    [self reloadTableView];
    [self checkNeedHandleAutoConn];    // 检查是否有需要自动连接的设备
    [self checkNeedRemovAutoConn];      // 检查是否需要移除自动连接的设备
}

#pragma mark -- 根据在线状态排序列表
- (NSArray <DevDataModel*>*)sortStatusWithDeviceList:(NSArray<DevDataModel*>*)devList
{
    if (!devList || 0 >= devList.count)
    {
        return nil;
    }
    return [devList sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        DevDataModel *dev1 = obj1;
        DevDataModel *dev2 = obj2;
        return dev1.Status < dev2.Status;
    }];
}

#pragma mark -- 开始创建设备连接
- (void)startDevConnFormAutoConnPool
{
    if (NO == self.isDevSdkInitSuccess) // 初始化有延时，所有用此来判断，否则如果还未初始化成功就开始创建连接，底层库会 Crash
    {
        GosLog(@"iOSDevSDK 未初始化成功，无法创建设备连接！");
        if (NO == self.hasDevSdkInit)
        {
            GosLog(@"iOSDevSDK 还未初始化，开始初始化！");
            [self initDevSdk];
            self.hasDevSdkInit = YES;
        }
        return;
    }
    GOS_WEAK_SELF;
    [self.autoConnPool enumerateObjectsWithOptions:NSEnumerationConcurrent
                                        usingBlock:^(DevDataModel * _Nonnull obj,
                                                     NSUInteger idx,
                                                     BOOL * _Nonnull stop)
     {
         GOS_STRONG_SELF;
         if (DevStatus_onLine == obj.Status
             && NO == [strongSelf.hasConnectedSet containsObject:obj.DeviceId])
         {
             if ([strongSelf.connectingSet containsObject:obj.DeviceId])
             {
                 GosLog(@"该设备正在创建连接，自动连接请稍后。。。");
                 return ;
             }
             NetProType npType = NetPro_TUTK;
             switch (obj.devCapacity.platformType)
             {
                 case PlatformTUTK:      npType = NetPro_TUTK;  break;  // 3.5-TUTK
                 case PlatformP2P:       npType = NetPro_P2P;   break;  // 4.0：P2P-打洞
                 case PlatformTCP:       npType = NetPro_TCP;   break;  // 4.0：TCP-转发
                 case PlatformP2PAndTCP: npType = NetPro_P2P;   break;  // 4.0：TCP-转发 & P2P-打洞
                 default: break;
             }
             GosLog(@"准备连接设备：%@", obj.DeviceId);
             [strongSelf.connectingSet addObject:obj.DeviceId];
             [strongSelf.devSdk connDevId:obj.DeviceId
                                 password:GOS_DEFAULT_STREAM_PWD
                               toPlatform:npType
                            withUserParam:obj.DeviceId.hash];
         }
     }];
}

#pragma mark -- 获取设备能力集
- (void)reqAbility
{
    GOS_WEAK_SELF;
    [self.abilitySetLock lockRead];
    [self.needReqAbilitySet enumerateObjectsWithOptions:NSEnumerationConcurrent
                                             usingBlock:^(NSString * _Nonnull obj,
                                                          BOOL * _Nonnull stop)
     {
         GOS_STRONG_SELF;
         if (YES == [strongSelf.hasConnectedSet containsObject:obj]
             && NO == [strongSelf.reqingAbilitySet containsObject:obj])
         {
             GosLog(@"开始获取设备（ID = %@）能力集！", obj);
             [strongSelf.reqingAbilitySet addObject:obj];
             [strongSelf.configSdk reqAbilityOfDevId:obj];
         }
     }];
    [self.abilitySetLock unLockRead];
}

#pragma mark -- 查询推送状态
- (void)checkPushStatus
{
    if (YES == m_isCheckingPushStatus)
    {
        GosLog(@"正在查询所有设备推送状态，请稍后。。。");
        return;
    }
    m_isCheckingPushStatus = YES;
    GOS_WEAK_SELF;
    [APNSManager queryAllDevPushStatus:^(BOOL isSuccess,
                                         NSArray<DevPushStatusModel *>*sList)
     {
         GOS_STRONG_SELF;
         strongSelf->m_isCheckingPushStatus = NO;
         if (NO == isSuccess)
         {
             GosLog(@"查询所有设备推送状态失败!");
             strongSelf->m_hasCheckedPushStatus = NO;
             [strongSelf checkPushStatus];
         }
         else
         {
             GosLog(@"DeviceList：查询所有设备推送状态成功！");
             strongSelf->m_hasCheckedPushStatus = YES;
             for (int i = 0; i < sList.count; i++)
             {
                 [PushStatusMananger addPushStatusModel:sList[i]];
             }
             [PushStatusMananger notifyHasChecked];
             [[NSNotificationCenter defaultCenter] postNotificationName:kCheckedPushStatusNotify
                                                                 object:nil];
         }
     }];
}

#pragma mark -- 更新需要获取设备能力集集合
- (void)updateNeedReqAbilitySet
{
    GOS_WEAK_SELF;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        GOS_STRONG_SELF;
        [self.devListLock lockRead];
        NSArray<DevDataModel*>*tempDevList = [self.devListArray mutableCopy];
        [self.devListLock unLockRead];
        NSArray<AbilityModel*>*abModelLit  = [DevAbilityManager abilityList];
        [self.abilitySetLock lockWrite];
        for (int i = 0; i < tempDevList.count; i++)
        {
            if (NO == [strongSelf.hasConnectedSet containsObject:tempDevList[i].DeviceId])  // 没有创建连接，不考虑
            {
                continue;
            }
            __block BOOL isExist = NO;
            [abModelLit enumerateObjectsWithOptions:NSEnumerationConcurrent
                                         usingBlock:^(AbilityModel * _Nonnull obj,
                                                      NSUInteger idx,
                                                      BOOL * _Nonnull stop)
             {
                 if ([obj.DeviceId isEqualToString:tempDevList[i].DeviceId])
                 {
                     isExist = YES;
                     *stop   = YES;
                 }
             }];
            if (NO == isExist)
            {
                GosLog(@"设备（ID = %@）能力集不存在，需要获取！", tempDevList[i].DeviceId);
                [strongSelf.needReqAbilitySet addObject:tempDevList[i].DeviceId];
            }
        }
        [self.abilitySetLock unLockWrite];
        if (YES == m_isPauseAutoTimer)
        {
            GosLog(@"有新设备能力集需要获取，恢复自动连接管理定时器！");
            [self.autoConnTimer resume];
            m_isPauseAutoTimer = NO;
        }
    });
}

- (void)updateHasConnSetToSandBox
{
    GOS_WEAK_SELF;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        GOS_STRONG_SELF;
        NSData *setData = [NSKeyedArchiver archivedDataWithRootObject:strongSelf.hasConnectedSet];
        GOS_SAVE_OBJ(setData, GOS_HAS_CONN_SET_KEY);
    });
}

#pragma mark -- 刷新列表绘制
- (void)reloadTableView
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self.devListTableView reloadData];
    });
}

#pragma mark - 网络监控
- (void)addNetworkChangeNotify
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(networkChanged:)
                                                 name:kCurNetworkChangeNotify
                                               object:nil];
}


- (void)networkChanged:(NSNotification *)notification
{
    NSDictionary *dict = (NSDictionary *)notification.object;
    if (NO == [[dict allKeys] containsObject:@"CurNetworkStatus"])
    {
        return;
    }
    CurNetworkStatus curStatus = [dict[@"CurNetworkStatus"] integerValue];
    switch (curStatus)
    {
        case CurNetwork_unknow: // 未知
        {
            GosLog(@"监测到当前网络状态为：未知");
            [self configNavTitle:NaviTitle_noNetwork];
        }
            break;
            
        case CurNetwork_wifi:         // WiFi 连接
        {
            GosLog(@"监测到当前网络状态为：WiFi 连接");
            if (YES == self.isAutoLogin && NO == self.hasLogined ) // 开始自动登录
            {
                [self configNavTitle:NaviTitle_connecting];
                [self autoLogin];
            }
            else
            {
                [self configNavTitle:NaviTitle_normal];
            }
        }
            break;
            
        case CurNetwork_2G:     // 蜂窝数据连接 - 2G
        {
            GosLog(@"监测到当前网络状态为：蜂窝数据连接 - 2G");
            if (YES == self.isAutoLogin && NO == self.hasLogined ) // 开始自动登录
            {
                [self configNavTitle:NaviTitle_connecting];
                [self autoLogin];
            }
            else
            {
                [self configNavTitle:NaviTitle_normal];
            }
        }
            break;
            
        case CurNetwork_3G:     // 蜂窝数据连接 - 3G
        {
            GosLog(@"监测到当前网络状态为：蜂窝数据连接 - 3G");
            if (YES == self.isAutoLogin && NO == self.hasLogined ) // 开始自动登录
            {
                [self configNavTitle:NaviTitle_connecting];
                [self autoLogin];
            }
            else
            {
                [self configNavTitle:NaviTitle_normal];
            }
        }
            break;
            
        case CurNetwork_4G:     // 蜂窝数据连接 - 4G
        {
            GosLog(@"监测到当前网络状态为：蜂窝数据连接 - 4G");
            if (YES == self.isAutoLogin && NO == self.hasLogined ) // 开始自动登录
            {
                [self configNavTitle:NaviTitle_connecting];
                [self autoLogin];
            }
            else
            {
                [self configNavTitle:NaviTitle_normal];
            }
        }
            break;
            
        default:
            break;
    }
}

#pragma mark - 重连
#pragma mark -- 添加断开并重新创建连接通知
- (void)addReDisConnAndConnNotify
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reDisConnAndConn:)
                                                 name:kReDisConnAndConnAgainNotify
                                               object:nil];
}

#pragma mark -- 断开设备并重建连接通知消息
- (void)reDisConnAndConn:(NSNotification *)notifyData
{
    NSDictionary *recvDict = notifyData.object;
    if (!recvDict
        || NO == [[recvDict allKeys] containsObject:@"DeviceID"])
    {
        return;
    }
    NSString *deviceId = recvDict[@"DeviceID"];
    GOS_WEAK_SELF;
    dispatch_async(m_reConnQueue, ^{
        
        GOS_STRONG_SELF;
        [strongSelf reConnWithDeviceId:deviceId];
    });
}

#pragma mark -- 重连设备（慎用）
- (void)reConnWithDeviceId:(NSString *)deviceId
{
    if (IS_EMPTY_STRING(deviceId))
    {
        GosLog(@"无法重连设备（ID = %@）", deviceId);
        return;
    }
    __block BOOL isExist = NO;
    [self.devListLock lockRead];
    [self.devListArray enumerateObjectsWithOptions:NSEnumerationConcurrent
                                        usingBlock:^(DevDataModel * _Nonnull obj,
                                                     NSUInteger idx,
                                                     BOOL * _Nonnull stop)
    {
        if ([obj.DeviceId isEqualToString:deviceId])
        {
            isExist = YES;
            *stop   = YES;
        }
    }];
    [self.devListLock unLockRead];
    if (YES == isExist)
    {
        GosLog(@"断开设备连接，准备重新建立连接！");
        [self disConnDevice:deviceId];
    }
}

#pragma mark -- 检查断开连接的设备是否是需重连操作设备
- (void)checkIsNeedReConnWithDevId:(NSString *)deviceId
{
    if (IS_EMPTY_STRING(deviceId))
    {
        GosLog(@"无法断开连接的设备（ID = %@）是否是需重连操作", deviceId);
        return;
    }
    GOS_WEAK_SELF;
    [self.devListLock lockRead];
    [self.devListArray enumerateObjectsWithOptions:NSEnumerationConcurrent
                                        usingBlock:^(DevDataModel * _Nonnull obj,
                                                     NSUInteger idx,
                                                     BOOL * _Nonnull stop)
     {
         GOS_STRONG_SELF;
         if ([obj.DeviceId isEqualToString:deviceId]
             && DevStatus_onLine == obj.Status)
         {
             GosLog(@"添加需重连设备（ID = %@）到自动连接池！", obj.DeviceId);
             [strongSelf addNeedConnDevice:obj];
             *stop        = YES;
         }
     }];
    [self.devListLock unLockRead];
}

#pragma mark - 更新封面
#pragma makr -- 添加更新封面通知
- (void)addUpdateCoverNotify
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateCoverNotify:)
                                                 name:kSaveCoverNotify
                                               object:nil];
}

#pragma mark -- 更新封面通知处理
- (void)updateCoverNotify:(NSNotification *)notifyData
{
    NSDictionary *recvDict = notifyData.object;
    if (!recvDict
        || NO == [[recvDict allKeys] containsObject:@"DeviceID"])
    {
        return;
    }
    NSString *deviceId     = recvDict[@"DeviceID"];
    __block BOOL isExist   = NO;
    __block NSUInteger row = 0;
    [self.devListLock lockRead];
    [self.devListArray enumerateObjectsWithOptions:NSEnumerationConcurrent
                                        usingBlock:^(DevDataModel * _Nonnull obj,
                                                     NSUInteger idx,
                                                     BOOL * _Nonnull stop)
    {
        if ([obj.DeviceId isEqualToString:deviceId])
        {
            isExist = YES;
            row     = idx;
            *stop   = YES;
        }
    }];
    [self.devListLock unLockRead];
    if (YES == isExist)
    {
        self.curSelectedPath = [NSIndexPath indexPathForRow:row
                                                  inSection:0];
        dispatch_async(dispatch_get_main_queue(), ^{
            
            GosLog(@"更新选择的 Cell 封面！");
            [self updateSelectedCell];
        });
    }
}

#pragma mark -- 添加修改设备属性通知
- (void)addModifyDevInfoNotify
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(modifyDeviceInfo:)
                                                 name:kModifyDevInfoNotify
                                               object:nil];
}

- (void)modifyDeviceInfo:(NSNotification *)notifyData
{
    [self updateSelectedCell];
}

#pragma mark -- 删除设备通知
- (void)addDeleteDeviceNotify
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(deleteDevice:)
                                                 name:kDeleteDeviceNotify
                                               object:nil];
}

- (void)deleteDevice:(NSNotification *)notifyData
{
    [self refreshDeviceList];
}
#pragma makr -- 添加注销通知
- (void)addLogoutNotify
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(logoutSuccess:)
                                                 name:kLogoutSuccessNotify
                                               object:nil];
}

#pragma mark -- 注销账号处理
- (void)logoutSuccess:(NSNotification *)notifyData
{
    [self.devListArray removeAllObjects];
    [self.autoConnPool removeAllObjects];
    [self.hasConnectedSet removeAllObjects];
    [self.connectingSet removeAllObjects];
    [self.disConnectingSet removeAllObjects];
    [self.needReqAbilitySet removeAllObjects];
    [self.reqingAbilitySet removeAllObjects];
}

#pragma mark -- 更新当前选择的 Cell
- (void)updateSelectedCell
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        GOS_WEAK_SELF;
        [UIView performWithoutAnimation:^{  // 防止页面抖动一下
            
            GOS_STRONG_SELF;
            CGPoint loc = strongSelf.devListTableView.contentOffset;
            [strongSelf.devListTableView reloadRowsAtIndexPaths:@[strongSelf.curSelectedPath]
                                               withRowAnimation:UITableViewRowAnimationNone];
            strongSelf.devListTableView.contentOffset = loc;
        }];
    });
}

#pragma mark -- 开启自动连接定时器
- (void)createAutoConnTimer
{
    self.autoConnTimer = [[GosThreadTimer alloc] initWithInterval:AUTO_CONN_INTERVALE
                                                        forAction:@selector(autoConnected)
                                                          forModl:NSDefaultRunLoopMode
                                                         withName:@"GosDevAutoConnThread"
                                                         onTarget:self];
    GosLog(@"开启自动连接线程定时器：GosDevAutoConnThread");
}

#pragma mark - Device-DB
#pragma mark -- 保存
- (void)saveDevlistToDB
{
    GOS_WEAK_SELF;
    dispatch_async(m_dbReadWriteQueue, ^{
        
        GOS_STRONG_SELF;
        [GosDevManager synchDeviceList:strongSelf.devListArray];
    });
}

#pragma mark -- 获取
- (void)readDevListFromDB
{
    GOS_WEAK_SELF;
    dispatch_async(m_dbReadWriteQueue, ^{
        
        GOS_STRONG_SELF;
        GosLog(@"从数据读取旧数据临时加载列表！");
        NSArray<DevDataModel*>*tempArray = [strongSelf sortStatusWithDeviceList:[GosDevManager deviceList]];
        [strongSelf.devListLock lockWrite];
        strongSelf.devListArray = [tempArray mutableCopy];
        [strongSelf.devListLock unLockWrite];
        [strongSelf reloadTableView];
    });
}

#pragma mark - 按钮事件中心
- (void)handleClickActionWithType:(DeviceListClickActionType)actionType
                      onIndexPath:(NSIndexPath *)indexPath
{
    NSInteger rowIndex = indexPath.row;
    if (rowIndex >= self.devListArray.count)
    {
        return;
    }
    self.curSelectedPath   = indexPath;
    [self.devListLock lockRead];
    self.curSelectedDevice = self.devListArray[rowIndex];
    [self.devListLock unLockRead];
    switch (actionType)
    {
        case CellClickAction_liveStream: // 播放直播流
        {
            GosLog(@"播放直播流，rowIndex：%ld", (long)rowIndex);
            
            switch (self.curSelectedDevice.DeviceType)
            {
                case DevType_ipc:
                {
                    [self turnToIpcPlayVC];
                }
                    break;
                    
                case DevType_nvr:
                {
                    
                }
                    break;
                    
                case DevType_pano180:
                {
                    
                }
                    break;
                    
                case DevType_pano360:
                {
                    [self turnToVRPlayVC];
                }
                    break;
                    
                default:
                    break;
            }
        }
            break;
            
        case CellClickAction_message:    // 消息中心
        {
            GosLog(@"消息中心，rowIndex：%ld", (long)rowIndex);
            [self turnToDevMsgListVC];
        }
            break;
            
        case CellClickAction_CloudPB:    // 云存储回放
        {
            GosLog(@"云存储回放，rowIndex：%ld", (long)rowIndex);
            [self turnToCloudPlaybackVC];
        }
            break;
            
        case CellClickAction_TFCardPB:   // TF 卡回放
        {
            GosLog(@"TF 卡回放，rowIndex：%ld", (long)rowIndex);
            if (StreamStoreOnlyTF == self.curSelectedDevice.devCapacity.streamStoreType
                || StreamStoreCloud == self.curSelectedDevice.devCapacity.streamStoreType)
            {
                GosLog(@"该设备（ID = %@）TF 卡录像支持‘流播’！", self.curSelectedDevice.DeviceId);
                [self turnToTFCardStreamsVC];
            }
            else
            {
                GosLog(@"该设备（ID = %@）TF 卡录不支持‘流播’！", self.curSelectedDevice.DeviceId);
                [self turnToTFCardFilesVC];
            }
        }
            break;
            
        case CellClickAction_setting:    // 设置中心
        {
            GosLog(@"设置中心，rowIndex：%ld", (long)rowIndex);
            [self turnToSettingVC];
        }
            break;
            
        default:
            break;
    }
}

#pragma mark - 页面跳转
#pragma mark -- 跳转至添加设备页面
- (void)turnToAddDevVC
{
    GosLog(@"准备跳转至添加设备页面！");
    
    self.manager = [[ScanQRCodeManager alloc] init];
    self.manager.navigationController = self.navigationController;
    [self.manager startScanQrCode];
}

#pragma mark -- 跳转至 IPC 播放页面
- (void)turnToIpcPlayVC
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        IPCPlayViewController *ipcPlayVC = [IPCPlayViewController shareIpcPlayVC];
        ipcPlayVC.devModel               = self.curSelectedDevice;
        ipcPlayVC.abModel                = [DevAbilityManager abilityOfDevice:self.curSelectedDevice.DeviceId];
        if ([self.hasConnectedSet containsObject:ipcPlayVC.devModel.DeviceId])
        {
            ipcPlayVC.hasConnected = YES;
        }
        else
        {
            ipcPlayVC.hasConnected = NO;
        }
        
        [self.navigationController pushViewController:ipcPlayVC
                                             animated:YES];
        m_hasTurnToOtherVC = YES;
    });
}

#pragma mark -- 跳转至 VR 播放页面
- (void)turnToVRPlayVC
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        VRPlayViewController *vrPlayVC = [[VRPlayViewController alloc] initWithDisplayType:VRPlayViewControllerDisplayTypeVRLive];
        vrPlayVC.devModel              = self.curSelectedDevice;
        if ([self.hasConnectedSet containsObject:vrPlayVC.devModel.DeviceId])
        {
            vrPlayVC.hasConnected = YES;
        }
        else
        {
            vrPlayVC.hasConnected = NO;
        }
        [self.navigationController pushViewController:vrPlayVC
                                             animated:YES];
    });
}

#pragma mark -- 跳转至设备‘消息’页面
- (void)turnToDevMsgListVC
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        MessageListViewController *msgListVC = [[MessageListViewController alloc] init];
        msgListVC.deviceModel                = self.curSelectedDevice;
        msgListVC.isOnlyShowOnDevMsg         = YES;
        [self.navigationController pushViewController:msgListVC
                                             animated:YES];
    });
}

#pragma mark -- 跳转至'设置'页面
- (void)turnToSettingVC
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        MainSettingViewController *settingVC = [[MainSettingViewController alloc] init];
        settingVC.devModel                   = self.curSelectedDevice;
        [self.navigationController pushViewController:settingVC
                                             animated:YES];
        m_hasTurnToOtherVC = YES;
    });
}

#pragma mark -- 跳转至'TF 卡录像-文件夹'页面
- (void)turnToTFCardFilesVC
{
    TFCRDateListViewController *tfCardFilesVC = [[TFCRDateListViewController alloc] init];
    tfCardFilesVC.devModel                    = self.curSelectedDevice;
    [self.navigationController pushViewController:tfCardFilesVC
                                         animated:YES];
}

#pragma mark -- 跳转至'TF 卡录像-流播'页面
- (void)turnToTFCardStreamsVC
{
    [self.navigationController pushViewController:[[TFCardPlayViewController alloc] initWithDeviceId:self.curSelectedDevice.DeviceId]
                                         animated:YES];
    
}

#pragma mark -- 跳转至云存储回放页面
- (void)turnToCloudPlaybackVC
{
    [self.navigationController pushViewController:[[CloudPlaybackViewController alloc] initWithDeviceId:self.curSelectedDevice.DeviceId]
                                         animated:YES];
}

#pragma mark - 自动连接管理
#pragma mark -- 自动连（注意：此函数需调用时，请谨慎）
// 目前逻辑：设备连接、获取所有设备能力集、所有设备推送状态
- (void)autoConnected
{
    if (NO == self.hasLogined)
    {
        GosLog(@"还未登录成功，无法执行自动连接逻辑，先把定时器暂停！");
        if (NO == m_isPauseAutoTimer)
        {
            [self.autoConnTimer pause];
            m_isPauseAutoTimer = YES;
        }
        return;
    }
    if (0 == self.devListArray.count                /* 没有任何设备 */
        || (0 == self.autoConnPool.count            /* 没有需要自动连接设备 */
            && 0 == self.needReqAbilitySet.count    /* 没有需要自动获取能力集设备 */
            && YES == m_hasCheckedPushStatus))      /* 没有需要自动获取推送状态设备 */
    {
        if (NO == m_isPauseAutoTimer)
        {
            GosLog(@"没有需要自动连接的设备，也没有需要获取能力集的设备，也没有推送状态需要查询，暂停自动连接管理定时器！");
            [self.autoConnTimer pause];
            m_isPauseAutoTimer = YES;
        }
        return;
    }
    GosLog(@"自动连接管理");
    GOS_WEAK_SELF;
    if (0 < self.autoConnPool.count)
    {
        dispatch_async(self.autoConnQueue, ^{
            
            GOS_STRONG_SELF;
            GosLog(@"自动连接池里有需要创建连接的设备！");
            [strongSelf startDevConnFormAutoConnPool];
        });
    }
    if (0 < self.needReqAbilitySet.count)
    {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            
            GOS_STRONG_SELF;
            GosLog(@"集合里有需要获取能力集的设备！");
            [strongSelf reqAbility];
        });
    }
    if (NO == m_hasCheckedPushStatus && NO == m_isCheckingPushStatus)
    {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            
            GOS_STRONG_SELF;
            GosLog(@"检测到需要查询账号所有设备推送状态！");
            [strongSelf checkPushStatus];
        });
    }
}

#pragma mark -- 添加需自动连接设备
- (void)addNeedConnDevice:(DevDataModel *)device
{
    if (!device || IS_EMPTY_STRING(device.DeviceId))
    {
        return;
    }
    GOS_WEAK_SELF;
    dispatch_async(self.autoConnQueue, ^{
        
        GOS_STRONG_SELF;
        __block BOOL isExist = NO;
        [strongSelf.autoConnPool enumerateObjectsWithOptions:NSEnumerationConcurrent
                                                  usingBlock:^(DevDataModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                                                      if ([obj.DeviceId isEqualToString:device.DeviceId])
                                                      {
                                                          isExist = YES;
                                                          *stop   = YES;
                                                      }
                                                  }];
        if (YES == isExist)
        {
            return;
        }
        GosLog(@"添加设备（ID = %@）到自动连接池", device.DeviceId);
        [strongSelf.autoConnPool addObject:device]; // 自动连接池不存在该设备，新加
        if (YES == strongSelf->m_isPauseAutoTimer)
        {
            GosLog(@"设备上线需要自动连接，恢复自动连接管理定时器！");
            [strongSelf.autoConnTimer resume];
            strongSelf->m_isPauseAutoTimer = NO;
        }
    });
}

#pragma mark -- 删除不需自动连接设（已连接成功的）
- (void)delConnectedDeviceId:(NSString *)deviceId
{
    if (IS_EMPTY_STRING(deviceId))
    {
        return;
    }
    GOS_WEAK_SELF;
    dispatch_async(self.autoConnQueue, ^{
        
        GOS_STRONG_SELF;
        __block BOOL isExist = NO;
        __block NSUInteger index = 0;
        [strongSelf.autoConnPool enumerateObjectsWithOptions:NSEnumerationConcurrent
                                                  usingBlock:^(DevDataModel * _Nonnull obj,
                                                               NSUInteger idx,
                                                               BOOL * _Nonnull stop)
         {
             if ([obj.DeviceId isEqualToString:deviceId])
             {
                 isExist = YES;
                 index   = idx;
                 *stop   = YES;
             }
         }];
        if (YES == isExist && index < strongSelf.autoConnPool.count)
        {
            GosLog(@"将设备（ID = %@）从自动连接池删除", deviceId);
            [strongSelf.autoConnPool removeObjectAtIndex:index];
        }
    });
}

#pragma mark -- 更新设备连接状态
- (void)updateConnResult:(DeviceConnState)connStatus
               withDevId:(NSString *)devId
{
    if (IS_EMPTY_STRING(devId))
    {
        return;
    }
    [GosDevManager updateDevice:devId toConnState:connStatus];
    /*if ([devId isEqualToString: self.curSelectedDevice.DeviceId])*/ // 通知播放界面（不加条件判断，推送详情页面也可跳转播放页面）
    {
        NSDictionary *notifyDict = @{@"DeviceID"   : devId,
                                     @"ConnStatus" : @(connStatus)};
        [[NSNotificationCenter defaultCenter] postNotificationName:kCurDevConnectingNotify
                                                            object:notifyDict];
    }
    if ([self.connectingSet containsObject:devId])  // 移除正在创建连接设备
    {
        [self.connectingSet removeObject:devId];
    }
    if ([self.disConnectingSet containsObject:devId])  // 移除正在断开连接设备
    {
        [self.disConnectingSet removeObject:devId];
    }
    
    switch (connStatus)
    {
        case DeviceConnUnConn:  // 未连接
        {
            if ([self.hasConnectedSet containsObject:devId])
            {
                [self.hasConnectedSet removeObject:devId];
                [self updateHasConnSetToSandBox];
            }
            // 检查是否是重连操作设备
            GOS_WEAK_SELF;
            dispatch_async(m_reConnQueue, ^{
                
                GOS_STRONG_SELF;
                [strongSelf checkIsNeedReConnWithDevId:devId];
            });
        }
            break;
            
        case DeviceConnFailure: // 连接失败
        {
            if ([self.hasConnectedSet containsObject:devId])
            {
                [self.hasConnectedSet removeObject:devId];
                [self updateHasConnSetToSandBox];
            }
        }
            break;
            
        case DeviceConnecting:  // 正在连接
        {
            
        }
            break;
            
        case DeviceConnSuccess: // 连接成功
        {
            [self.hasConnectedSet addObject:devId];
            [self delConnectedDeviceId:devId];
            GosLog(@"设备（ID = %@）创建连接成功，检查是否需要获取能力集数据！", devId);
            [self updateNeedReqAbilitySet];
            [self updateHasConnSetToSandBox];
        }
            break;
            
        default:
            break;
    }
}

#pragma mark -- 检查是否有需要处理自动连接 - 添加到自动连接池的设备（由于设备上线情况下）
- (void)checkNeedHandleAutoConn
{
    GOS_WEAK_SELF;
    [self.devListLock lockRead];
    [self.devListArray enumerateObjectsWithOptions:NSEnumerationConcurrent
                                        usingBlock:^(DevDataModel * _Nonnull obj,
                                                     NSUInteger idx,
                                                     BOOL * _Nonnull stop)
     {
         GOS_STRONG_SELF;
         if (DevStatus_onLine == obj.Status)    // 设备在线
         {
             if (NO == [strongSelf.hasConnectedSet containsObject:obj.DeviceId])    // 还未连接成功，则重新添加到自动连接池
             {
                 [strongSelf addNeedConnDevice:obj];
             }
         }
         else   // 设备离线（注意：这里暂时把睡眠状态设备当做离线，如有需要唤醒设备功能的，须另外处理
         {
             if (YES == [strongSelf.hasConnectedSet containsObject:obj.DeviceId])   // 已连接设备，需断开连接
             {
                 GosLog(@"由于掉线通知，断开(已连接)设备（ID = %@）连接", obj.DeviceId);
                 [strongSelf.hasConnectedSet removeObject:obj.DeviceId];
                 [strongSelf disConnDevice:obj.DeviceId];
                 [strongSelf updateHasConnSetToSandBox];
             }
         }
     }];
    [self.devListLock unLockRead];
}

#pragma mark -- 检查（未连接）设备是否须要移除自动连接池（由于设备掉线情况下）
- (void)checkNeedRemovAutoConn
{
    GOS_WEAK_SELF;
    __block NSMutableArray<DevDataModel*>*rmvArray = [NSMutableArray arrayWithCapacity:0];
    [self.autoConnPool enumerateObjectsWithOptions:NSEnumerationConcurrent
                                        usingBlock:^(DevDataModel * _Nonnull obj,
                                                     NSUInteger idx,
                                                     BOOL * _Nonnull stop)
     {
         GOS_STRONG_SELF;
         if (DevStatus_offLine == obj.Status)
         {
             GosLog(@"设备（ID = %@）离线，将从自动连接池中删除！", obj.DeviceId);
             [rmvArray addObject:obj];  // 设备掉线，移除自动连接池
         }
     }];
    @autoreleasepool
    {
        [self.autoConnPool removeObjectsInArray:rmvArray];
        [rmvArray removeAllObjects];
        rmvArray = nil;
    }
}

#pragma mark -- 断开设备连接
- (void)disConnDevice:(NSString *)deviceId
{
    if (IS_EMPTY_STRING(deviceId))
    {
        return;
    }
    if ([self.disConnectingSet containsObject:deviceId])
    {
        GosLog(@"该设备正在断开连接，重新断开连接请稍后。。。");
        return;
    }
    GosLog(@"准备将设备（ID = %@）断开连接！", deviceId);
    [self.disConnectingSet addObject:deviceId];
    [self.devSdk disConnDevId:deviceId];
}

- (void)initDevSdk
{
    if (!_devSdk)
    {
        _devSdk = [iOSDevSDK shareDevSDK];
        _isDevSdkInitSuccess = [_devSdk setTransportType:TransportPro_All
                                           serverAddress:[GosLoggedInUserInfo streamServerAddr]];
        if (NO == _isDevSdkInitSuccess)
        {
            GosLog(@"iOSDevSDK 初始化失败！");
        }
        else
        {
            GosLog(@"iOSDevSDK 初始化成功！");
        }
        _devSdk.connDelegate = self;
    }
}

#pragma mark - 懒加载
- (iOSConfigSDK *)configSdk
{
    if (!_configSdk)
    {
        _configSdk = [iOSConfigSDK shareCofigSdk];
        _configSdk.dmDelegate = self;
        _configSdk.abDelegate = self;
    }
    return _configSdk;
}

- (NSMutableArray<DevDataModel *> *)devListArray
{
    if (!_devListArray)
    {
        _devListArray = [NSMutableArray arrayWithCapacity:0];
    }
    return _devListArray;
}

- (NSMutableArray<DevDataModel *> *)autoConnPool
{
    if (!_autoConnPool)
    {
        _autoConnPool = [NSMutableArray arrayWithCapacity:0];
    }
    return _autoConnPool;
}

- (dispatch_queue_t)autoConnQueue
{
    if (!_autoConnQueue)
    {
        _autoConnQueue = dispatch_queue_create("GosDeviceAutoConnQueue", DISPATCH_QUEUE_SERIAL);
    }
    return _autoConnQueue;
}

- (NSMutableSet<NSString *> *)hasConnectedSet
{
    if (!_hasConnectedSet)
    {
        _hasConnectedSet = [NSMutableSet setWithCapacity:0];
    }
    return _hasConnectedSet;
}

- (NSMutableSet<NSString *> *)connectingSet
{
    if (_connectingSet)
    {
        _connectingSet = [NSMutableSet setWithCapacity:0];
    }
    return _connectingSet;
}

- (NSMutableSet<NSString *> *)disConnectingSet
{
    if (!_disConnectingSet)
    {
        _disConnectingSet = [NSMutableSet setWithCapacity:0];
    }
    return _disConnectingSet;
}

- (NSMutableSet<NSString *> *)needReqAbilitySet
{
    if (!_needReqAbilitySet)
    {
        _needReqAbilitySet = [NSMutableSet setWithCapacity:0];
    }
    return _needReqAbilitySet;
}

- (NSMutableSet<NSString *> *)reqingAbilitySet
{
    if (!_reqingAbilitySet)
    {
        _reqingAbilitySet = [NSMutableSet setWithCapacity:0];
    }
    return _reqingAbilitySet;
}


#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.devListArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger rowIndex = indexPath.row;
    if (rowIndex >= self.devListArray.count)
    {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                       reuseIdentifier:@"DefaultCellId"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    [self.devListLock lockRead];
    DevDataModel *devData = self.devListArray[rowIndex];
    [self.devListLock unLockRead];
    if (DevType_ipc == devData.DeviceType)  // 普通 IPC
    {
        IpcDevListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kIpcCellId];
        if (!cell)
        {
            cell = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([IpcDevListTableViewCell class])
                                                 owner:self
                                               options:nil][0];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        cell.ipcDevListTBCellData = devData;
        GOS_WEAK_SELF;

        cell.cellActionBlock = ^(DeviceListClickActionType actionType) {
            GOS_STRONG_SELF;
                [strongSelf handleClickActionWithType:actionType
                                                  onIndexPath:indexPath];
        };
        return cell;
    }
    else if (DevType_nvr == devData.DeviceType) // NVR
    {
        NVRDevListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kNVRCellId];
        if (!cell) {
            cell = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([NVRDevListTableViewCell class])
                                                 owner:self
                                               options:nil][0];
            cell.NVRDevListTBCellData = devData;
            GOS_WEAK_SELF;
            cell.cellActionBlock = ^(DeviceListClickActionType actionType) {
                
                GOS_STRONG_SELF;
                [strongSelf handleClickActionWithType:actionType
                                          onIndexPath:indexPath];
                GosLog(@"点击推送消息 云存储 TF卡  设置回调");
            };
        }
        return cell;

    }
//    else if (DevType_pano180 == devData.DeviceType) // 全景 180
//    {
//        
//    }
    else if (DevType_pano360 == devData.DeviceType) // 全景 360
    {
        Panoramic360DevListCell *cell = [tableView dequeueReusableCellWithIdentifier:kPanoramic360CellId];
        if (!cell) {
            cell = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([Panoramic360DevListCell class])
                                                 owner:self
                                               options:nil][0];
            cell.PanoramicDevListTBCellData = devData;
            GOS_WEAK_SELF;
            cell.cellActionBlock = ^(DeviceListClickActionType actionType) {
                
                GOS_STRONG_SELF;
                [strongSelf handleClickActionWithType:actionType
                                          onIndexPath:indexPath];
            };
        }
        return cell;
    }
//    else if (DevType_socket == devData.DeviceType)  // 插座
//    {
//        
//    }
    else
    {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                       reuseIdentifier:@"DefaultCellId"];
        return cell;
    }
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

#pragma mark - iOSConfigSDKDMDelegate
 #pragma mark -- 设备列表数据回调
- (void)devlist:(NSArray <DevDataModel *>*)listArray
        account:(NSString *)account
{
    GosLog(@"设备列表数据回调：%lu", (unsigned long)listArray.count);
    if (YES == m_isConnecting)
    {
        [self configNavTitle:NaviTitle_normal];
        m_isConnecting = NO;
    }
    
    if (self.isAddSuccess) {
        self.isAddSuccess = NO;
        NSPredicate * filterPredicate1 = [NSPredicate predicateWithFormat:@"NOT (SELF IN %@)",self.devListArray];
        NSArray * filter = [listArray filteredArrayUsingPredicate:filterPredicate1];
        if (filter.count > 0) {
            DevDataModel *DevData;
            for (DevDataModel *tmpDevData in filter) {
                if ([tmpDevData.DeviceName hasPrefix:DPLocalizedString(@"AddDEV_DEVName")]) {
                    DevData = tmpDevData;
                    break;
                }
            }
            if (DevData) {
                self.alertManager = [[SetDevNameAlertManager alloc] init];
                self.alertManager.deviceModel = DevData;
                GOS_WEAK_SELF
                self.alertManager.resultBlock = ^(BOOL isSuccess) {
                    GOS_STRONG_SELF
                    if (isSuccess) {
                        [strongSelf refreshDeviceList];
                    }
                    strongSelf.alertManager = nil;
                    strongSelf.manager = nil;
                };
                [self.alertManager showRenameAlertWithViewController:self];
            }
        }
    }
    
    
    GOS_WEAK_SELF;
    dispatch_async(m_sortDevListQueue, ^{
        
        GOS_STRONG_SELF;
        [strongSelf handleDeviceList:[listArray copy]];
    });
}

 #pragma mark -- 设备在线状态回调
- (void)devStatusList:(NSArray <DevStatusModel*>*)statusList
{
    GosLog(@"设备在线状态数据回调：%lu", (unsigned long)statusList.count);
    
    GOS_WEAK_SELF;
    dispatch_async(m_updateDevStatusQueue, ^{
        
        GOS_STRONG_SELF;
        [strongSelf updateStatusWithList:[statusList mutableCopy]];
    });
}

#pragma mark - iOSDevConnDelegate
- (void)deviceId:(NSString *)deviceId
    devConnState:(DeviceConnState)devConnState
{
    if (IS_EMPTY_STRING(deviceId))
    {
        return;
    }
    GosLog(@"设备（deviceID：%s）连接结果：%ld", deviceId.UTF8String, (long)devConnState);
    GOS_WEAK_SELF;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
       
        GOS_STRONG_SELF;
        [strongSelf updateConnResult:devConnState
                           withDevId:deviceId];
    });
}


#pragma mark - iOSConfigSDKABDelegate
- (void)reqAbility:(BOOL)isSuccess
          deviceId:(NSString *)devId
           ability:(AbilityModel *)abModel
{
    if (IS_EMPTY_STRING(devId))
    {
        return;
    }
    if (YES == isSuccess)
    {
        GOS_WEAK_SELF;
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            
            GOS_STRONG_SELF;
            [DevAbilityManager addAbility:abModel];
            [strongSelf.abilitySetLock lockWrite];
            if ([strongSelf.needReqAbilitySet containsObject:devId])
            {
                GosLog(@"获取设备（ID = %@）能力集成功，将其从集合中删除！", devId);
                [strongSelf.needReqAbilitySet removeObject:devId];
            }
            else
            {
                GosLog(@"获取设备（ID = %@）能力集成功，但集合中不存在！", devId);
            }
            [strongSelf.abilitySetLock unLockWrite];
        });
    }
    else
    {
        GosLog(@"请求设备（ID = %@）能力集失败！", devId);
        if (YES == m_isPauseAutoTimer)
        {
            GosLog(@"请求设备（ID = %@）能力集失败，恢复自动连接管理定时器！", devId);
            [self.autoConnTimer resume];
            m_isPauseAutoTimer = NO;
        }
    }
    [self.reqingAbilitySet removeObject:devId];
}

#pragma mark - emptyDataDelegate
- (UIImage *)imageForEmptyDataSet:(UIScrollView *)scrollView {
    return [UIImage imageNamed:@"img_blankpage_camera"];
}
- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView {
    NSString * title = DPLocalizedString(@"Mine_NoDevices");
    NSDictionary *attributes = @{
                                 NSFontAttributeName:[UIFont systemFontOfSize:18.0f],
                                 NSForegroundColorAttributeName:GOS_COLOR_RGBA(198, 198, 198, 1)
                                 };
    return [[NSAttributedString alloc] initWithString:title attributes:attributes];
}
//- (NSAttributedString *)buttonTitleForEmptyDataSet:(UIScrollView *)scrollView forState:(UIControlState)state {
//    // 设置按钮标题
//    NSString *buttonTitle = DPLocalizedString(@"AddDEV_title");
//    NSDictionary *attributes = @{
//                                 NSFontAttributeName:[UIFont systemFontOfSize:16.0f],
//                                 NSBackgroundColorAttributeName:GOSCOM_THEME_START_COLOR,
//                                 NSForegroundColorAttributeName:[UIColor whiteColor],
//
//                                 };
//    NSAttributedString * attribut = [[NSAttributedString alloc] initWithString:buttonTitle attributes:attributes];
//
//    return attribut;
//    return [[NSAttributedString alloc] initWithString:buttonTitle attributes:attributes];
//}

#pragma mark - UITextViewDelegate
- (UIImage *)buttonImageForEmptyDataSet:(UIScrollView *)scrollView forState:(UIControlState)state {
    return [UIImage imageNamed:@"button_add_advice"];
}
- (CGFloat)verticalOffsetForEmptyDataSet:(UIScrollView *)scrollView {
    return -70.0f;
}
#pragma mark - DZNEmptyDataSetDelegate

- (void)emptyDataSet:(UIScrollView *)scrollView didTapButton:(UIButton *)button {
    // button clicked...
    GosLog(@"按钮点击");
    [self turnToAddDevVC];
}

- (void)emptyDataSetWillAppear:(UIScrollView *)scrollView {
    self.devListTableView.contentOffset = CGPointZero;
}
@end
