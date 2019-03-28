//  VRPlayViewController.m
//  GosIPCs
//
//  Create by daniel.hu on 2018/12/6.
//  Copyright © 2018年 goscam. All rights reserved.

#import "VRPlayViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "VRPlayerControlBar.h"
#import "iOSDevSDK.h"
#import "GosThreadTimer.h"
#import "iOSPlayerSDK.h"
#import "VRPlayerControlBarDelegate.h"      // 中间NEMU代理
#import "GOSOpenGLESVCViewController.h"     // 播放VR三方库
#import "TFCRDateListViewController.h"      // TF卡回放界面

#define iPhone4 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ?CGSizeEqualToSize(CGSizeMake(640, 960), [[UIScreen mainScreen] currentMode].size) : NO)
#define PlayerViewRatio (iPhone4 ? (3/4.0f):(65/72.0f))

#define trueSreenWidth  (MIN(GOS_SCREEN_W, GOS_SCREEN_H))
#define trueScreenHeight (MAX(GOS_SCREEN_W, GOS_SCREEN_H))

#define mFileManager  ([NSFileManager defaultManager])

@interface VRPlayViewController () <
iOSDevSDKDelegate,
iOSPlayerSDKDelegate,
VRPlayerControlBarDelegate,
NSURLSessionDelegate
>
{
    BOOL m_isOpeningAvStream;   // 是否正在打开音视频流
    BOOL m_isClosingAvStream;   // 是否正在关闭音视频流
    BOOL m_autoRotateSignal;    // 开启自动巡航标志
    int  m_clickSig;            // 显示模式
    BOOL m_currentEnable;       // YES 隐藏  NO  显示
    BOOL m_isStartHalfDuplex;   // 是否开启对讲（半双工）
    BOOL m_isTalkingOnHalfDuplex;// 是否正在对讲（半双工）
    BOOL m_hasCheckVideoQuality; // 是否已获取当前视频质量
    DevStatusType m_curStatus;  // 当前设备在线状态（需要监控）
}
/** 播放器容器视图 */
@property (weak, nonatomic) IBOutlet UIView *playerView;
@property (weak, nonatomic) IBOutlet VRPlayerControlBar *controlBar;
@property (weak, nonatomic) IBOutlet UILabel *timeLab;
@property (weak, nonatomic) IBOutlet UIView *redRemindView;
@property (weak, nonatomic) IBOutlet UILabel *REGRemindLab;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityView;
@property (weak, nonatomic) IBOutlet UILabel *offLineTipsLab;


@property (nonatomic, readwrite, weak) iOSDevSDK *devSdk;
@property (nonatomic, readwrite, strong) iOSPlayerSDK *playerSdk;

/** 体验中心文件路径 */
@property(nonatomic,strong) NSString *vr360_h264FilePath;
/** 体验中心文件名 */
@property(nonatomic,strong) NSString *vr360_h264FileName;
/** 播放模式选择 */
@property (nonatomic, assign) VRPlayViewControllerDisplayType displayType;
/** 控制音视频流队列（串行） */
@property (nonatomic, readwrite, strong) dispatch_queue_t operateAvStreamQueue;
/** 控制 PlayerSDK 队列（串行） */
@property (nonatomic, readwrite, strong) dispatch_queue_t operatePlayerSdkQueue;
/** 播放音视频回调数据队列（串行） */
@property (nonatomic, readwrite, strong) dispatch_queue_t playAvStreamQueue;

/** 视频数据检查定时器 */
@property (nonatomic, readwrite, strong) GosThreadTimer *checkVideoTimer;
/** 录像定时器 */
@property (nonatomic, readwrite, strong)GosThreadTimer *recordVideoTimer;
/** OSD定时器 */
@property (nonatomic, readwrite, strong)GosThreadTimer *osdTimer;

/** 是否开启录像 */
@property (nonatomic, readwrite, assign) BOOL hasStartRecordVideo;
/** 是否打开音视频流 */
@property (nonatomic, readwrite, assign) BOOL hasOpenStream;
/** 是否正在接收视频数据 */
@property (nonatomic, readwrite, assign) BOOL hasRcvingVideo;
/** 是否开启音频 */
@property (nonatomic, readwrite, assign) BOOL hasOpenAudio;
/** 已连接设备，拉流失败再次重新拉流次数 */
@property (nonatomic, readwrite, assign) NSInteger reOpenAvStreamCounts;
/** 当前视频质量 */
@property (nonatomic, readwrite, assign) VideoQualityType vQuality;

/** 播放控制器 */
@property(nonatomic,strong) GOSOpenGLESVCViewController *displayVC;
/** 录像按钮点击声音 播放器 */
@property (nonatomic, strong) AVAudioPlayer *recordAudioPlayer;
/** 拍照按钮点击声音 播放器 */
@property (nonatomic, strong) AVAudioPlayer *snapshotAudioPlayer;
@end

@implementation VRPlayViewController

#pragma mark - 生命周期
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initParam];
    
    [self configUI];
    
    // 初始化控制器
    [self initAppearAction];
    // 添加当前设备连接状态通知
    [self addCurDevConnStatusNotify];
    // 添加当前设备在线状态通知
    [self addCurDevStatusNotify];

    // 实时流才创建定时器
    if (VRPlayViewControllerDisplayTypeVRLive == self.displayType) {
        [self createCheckVideoTimer];
    }
    GosLog(@"lololo --%s---",__PRETTY_FUNCTION__);
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (YES == self.hasConnected)
    {
        [self openAVStream];
    }

    [self postNotifyVideoIsShowing:YES];
    if (VRPlayViewControllerDisplayTypeVRLive == self.displayType)
    {
        [self configButtondisEnable];
    }
    GosLog(@"lololo --%s---",__PRETTY_FUNCTION__);
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self createPlayerSdk];
    if (VRPlayViewControllerDisplayTypeVRLive == self.displayType)
    {
        
    }
    else
    {
        [self initAppearAction];
        [self playH264Demo];
    }
    GosLog(@"lololo --%s---",__PRETTY_FUNCTION__);
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (YES == self.hasOpenStream)
    {
        [self saveCurDevCover];
    }
    //        [self recoverViews];
    [self restoreDisplayModeToDefault];
    [self postNotifyVideoIsShowing:NO];
    GosLog(@"lololo --%s---",__PRETTY_FUNCTION__);
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];

    if (YES == self.hasOpenStream)
    {
        [self closeAVStream];
    }
    if (YES == self.hasOpenAudio)
    {
        [self closeAudio];
    }
    [self releaseSource];

    self.reOpenAvStreamCounts = 0;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    GosLog(@"lololo --%s---",__PRETTY_FUNCTION__);
}




#pragma mark - UI界面初始化
- (void)configUI
{
    NSString * titleName = @"";
    switch (self.displayType) {
        case VRPlayViewControllerDisplayTypeVRLive:
            titleName = self.devModel.DeviceName;
            break;
        case VRPlayViewControllerDisplayTypeVR360:
            titleName = @"VR-360";
            break;
        case VRPlayViewControllerDisplayTypeVR180:
            titleName = @"VR-180";
            break;
        default:
            break;
    }
    self.title = titleName;
    GOS_WEAK_SELF;
    dispatch_async(dispatch_get_main_queue(), ^{
        
        GOS_STRONG_SELF;
        [strongSelf.playerView bringSubviewToFront:strongSelf.timeLab];
        [strongSelf.playerView bringSubviewToFront:strongSelf.redRemindView];
        [strongSelf.playerView bringSubviewToFront:strongSelf.REGRemindLab];
        [strongSelf.playerView bringSubviewToFront:strongSelf.activityView];
        [strongSelf.playerView bringSubviewToFront:strongSelf.offLineTipsLab];
        strongSelf.offLineTipsLab.text = DPLocalizedString(@"DeviceOffLine");
    });
    self.redRemindView.layer.cornerRadius = 4.0f;
    self.redRemindView.clipsToBounds = YES;
    self.redRemindView.hidden = YES;
    self.REGRemindLab.hidden = YES;
    [self configOffLineLabHidden:YES];
    [self configActivityShow];
    if (VRPlayViewControllerDisplayTypeVRLive == self.displayType)
    {
//        [self configButtonEnable:NO];
        [self configButtondisEnable];
    }
    else
    {
        [self configMenuButtonDisEnable];
    }
    
    if(DevStatus_offLine == m_curStatus
       && VRPlayViewControllerDisplayTypeVRLive == self.displayType)
    {
        [self configOffLineLabHidden:NO];
        [self configActivityHidden];
    }
    GosLog(@"lololo --%s---",__PRETTY_FUNCTION__);
}
#pragma mark -- 设置录像红色提示View显示状态
- (void)configRecordingViewlHidden:(BOOL)isHidden
{
    GOS_WEAK_SELF;
    dispatch_async(dispatch_get_main_queue(), ^{
        
        GOS_STRONG_SELF;
        strongSelf.redRemindView.hidden = isHidden;
    });
    GosLog(@"lololo --%s---",__PRETTY_FUNCTION__);
}
#pragma mark -- 设置录像RGB文字显示状态
- (void)configREGLabelHidden:(BOOL)isHidden
{
    GOS_WEAK_SELF;
    dispatch_async(dispatch_get_main_queue(), ^{
        
        GOS_STRONG_SELF;
        strongSelf.REGRemindLab.hidden = isHidden;
    });
    GosLog(@"lololo --%s---",__PRETTY_FUNCTION__);
}
#pragma mark -- 设置拍照、声音、对讲按钮是否可用
- (void)configButtonEnable:(BOOL)isEnable
{
    if (m_currentEnable == isEnable) {
        return;
    }
    GosLog(@"传进来的isEnable = %d  记录的Enable = %d",isEnable,m_currentEnable);
    GOS_WEAK_SELF;
    dispatch_async(dispatch_get_main_queue(), ^{
        
        GOS_STRONG_SELF;
        [strongSelf.controlBar setupSnapshotButtonState:isEnable];/// 截图
        [strongSelf.controlBar setupRecordButtonState:isEnable];/// 录像
        [strongSelf.controlBar setupSpeakButtonState:isEnable];/// 对讲
        [strongSelf.controlBar setupNemuButtonEnable:isEnable];
    });
    [self.controlBar setupCruiseButtonState:YES];
    m_currentEnable = isEnable;  // 第一次进来在播放
    GosLog(@"lololo --%s---",__PRETTY_FUNCTION__);
}
#pragma mark -- 默认设置所有按钮不可用
- (void)configButtondisEnable{
    GOS_WEAK_SELF;
    dispatch_async(dispatch_get_main_queue(), ^{
        
        GOS_STRONG_SELF;
        [strongSelf.controlBar setupSnapshotButtonState:NO];/// 截图
        [strongSelf.controlBar setupRecordButtonState:NO];/// 录像
        [strongSelf.controlBar setupSpeakButtonState:NO];/// 对讲
        [strongSelf.controlBar setupNemuButtonEnable:NO];
    });
    m_currentEnable = NO;
    GosLog(@"lololo --%s---",__PRETTY_FUNCTION__);
}

#pragma mark -- 设置Menu按钮是否可用(体验中心)
- (void)configMenuButtonDisEnable
{
    GOS_WEAK_SELF;
    dispatch_async(dispatch_get_main_queue(), ^{
        
        GOS_STRONG_SELF;
        [strongSelf.controlBar setupSnapshotButtonState:NO];/// 截图
        [strongSelf.controlBar setupRecordButtonState:NO];/// 录像
        [strongSelf.controlBar setupSpeakButtonState:NO];/// 对讲
        [strongSelf.controlBar setupNemuButtonEnable:YES];
    });
    GosLog(@"lololo --%s---",__PRETTY_FUNCTION__);
}
#pragma mark -- 设置视频质量
- (void)configVideoQuality
{
    GOS_WEAK_SELF;
    dispatch_async(dispatch_get_main_queue(), ^{
        
        GOS_STRONG_SELF;
        [strongSelf.controlBar setupDefinitionButtonState:!self.vQuality];
    });
    GosLog(@"lololo --%s---",__PRETTY_FUNCTION__);
}
#pragma mark -- 显示小菊花
- (void)configActivityShow
{
    GOS_WEAK_SELF;
    dispatch_async(dispatch_get_main_queue(), ^{
        
        GOS_STRONG_SELF;
        [strongSelf.activityView startAnimating];
        strongSelf.activityView.hidden = NO;
    });
    GosLog(@"lololo --%s---",__PRETTY_FUNCTION__);
}
#pragma mark -- 隐藏小菊花
- (void)configActivityHidden
{
    if (self.activityView.isHidden)
    {
        return;
    }
    GOS_WEAK_SELF;
    dispatch_async(dispatch_get_main_queue(), ^{
        
        GOS_STRONG_SELF;
        [strongSelf.activityView stopAnimating];
        strongSelf.activityView.hidden = YES;
    });
    GosLog(@"lololo --%s---",__PRETTY_FUNCTION__);
}


#pragma mark - 设置参数
#pragma mark -- 基本数据初始化
- (void)initParam
{
    m_isOpeningAvStream        = NO;
    m_isClosingAvStream        = NO;
    m_autoRotateSignal         = YES;   //  默认开启自动巡航
    m_currentEnable            = NO;   //  默认可用，第一次启动configButton传NO
    m_clickSig                 = -1;
    m_curStatus                = self.devModel.Status;
    m_isStartHalfDuplex        = NO;
    m_isTalkingOnHalfDuplex    = NO;
    m_hasCheckVideoQuality     = NO;
    self.hasOpenStream         = NO;
    self.hasRcvingVideo        = NO;
    self.hasOpenAudio          = NO;
    self.reOpenAvStreamCounts  = NO;
    self.hasStartRecordVideo   = NO;
    self.controlBar.vrType     = (VRPlayerControlBarVRType)self.displayType; // 菜单枚举
    self.controlBar.vrControlBarDelegate = self;
    self.vQuality              = VideoQuality_unknown;
    self.operateAvStreamQueue  = dispatch_queue_create("GosOperateVRAVStreamQueue", DISPATCH_QUEUE_SERIAL);
    self.operatePlayerSdkQueue = dispatch_queue_create("GosOperateVRPlayerSdkQueue", DISPATCH_QUEUE_SERIAL);
    self.playAvStreamQueue     = dispatch_queue_create("GosPlayIPCAVStreamQueue", DISPATCH_QUEUE_SERIAL);
    GosLog(@"lololo --%s---",__PRETTY_FUNCTION__);
}

#pragma mark -- 初始化360控制器
- (void)initAppearAction
{
    GOS_WEAK_SELF;
    if (!self.displayVC)
    {
        GOS_STRONG_SELF;
        self.displayVC = [[GOSOpenGLESVCViewController alloc] init];
//        self.displayVC.audioDelegate = self;
        CGFloat displayW = GOS_SCREEN_W;
        CGFloat displayH = GOS_SCREEN_W*PlayerViewRatio;
        self.displayVC.autoRotSig = m_autoRotateSignal;
        self.displayVC.clickSig = m_clickSig;
        self.displayVC.initialMode = (self.displayType==VRPlayViewControllerDisplayTypeVR180||self.devModel.DeviceType == GosDevice180)? InitialModeVertical: InitialModeHorizontal;
        self.displayVC.devType = (GosDeviceType)self.devModel.DeviceType;
        [self.displayVC configPlayerWidth:displayW height:displayH];
        self.playerView.multipleTouchEnabled = YES;
        
//        __weak UIView *tempView = self.displayVC.view;
        [self.playerView addSubview:self.displayVC.view];
        [self addChildViewController:self.displayVC];

        [self.displayVC didMoveToParentViewController:self];

        self.displayVC.view.frame = CGRectMake(0, 0, displayW, displayH);
        [self.displayVC.view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.playerView);
        }];
        self.displayVC.deviceId = self.devModel.DeviceId;
    }
    GosLog(@"lololo --%s---",__PRETTY_FUNCTION__);
    
    
}


/*-----------------------<方法相关>------------------------------*/
#pragma mark -通知相关
#pragma mark -- 通知正在视频播放页面
- (void)postNotifyVideoIsShowing:(BOOL)isShowing
{
    NSDictionary *notifyDict = @{@"IsShowing" : @(isShowing)};
    [[NSNotificationCenter defaultCenter] postNotificationName:kIsVideoShowingNotify
                                                        object:notifyDict];
    GosLog(@"lololo --%s---",__PRETTY_FUNCTION__);
}
#pragma mark -- 添加当前设备连接状态通知（未连接成功时）
- (void)addCurDevConnStatusNotify
{
    GosLog(@"IPCPlayViewController：添加当前设备连接状态通知!");
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(notifyDeviceConnStatus:)
                                                 name:kCurDevConnectingNotify
                                               object:nil];
    GosLog(@"lololo --%s---",__PRETTY_FUNCTION__);
}
#pragma mark -- 添加当前设备在线状态通知
- (void)addCurDevStatusNotify
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(notifyDeviceStatus:)
                                                 name:kCurPreviewDevStatusNotify
                                               object:nil];
    GosLog(@"lololo --%s---",__PRETTY_FUNCTION__);
}

#pragma mark -- 获取当前设备连接状态
- (void)notifyDeviceConnStatus:(NSNotification *)notifyData
{
    NSDictionary *recvDict = notifyData.object;
    if (!recvDict
        || NO == [[recvDict allKeys] containsObject:@"DeviceID"]
        || NO == [[recvDict allKeys] containsObject:@"ConnStatus"])
    {
        return;
    }
    NSString *deviceId  = recvDict[@"DeviceID"];
    NSNumber *statusObj = recvDict[@"ConnStatus"];
    DeviceConnState connStatus = (DeviceConnState)[statusObj integerValue];
    if (NO == [deviceId isEqualToString:self.devModel.DeviceId])
    {
        return;
    }
    switch (connStatus)
    {
        case DeviceConnUnConn:  // 未连接
        {
            GosLog(@"当前预览设备（ID = %@）没有建立连接！", deviceId);
            self.hasConnected = NO;
        }
            break;
            
        case DeviceConnFailure: // 连接失败
        {
            GosLog(@"当前预览设备（ID = %@）建立连接失败！", deviceId);
            self.hasConnected = NO;
        }
            break;
            
        case DeviceConnecting:  // 正在连接
        {
            GosLog(@"当前预览设备（ID = %@）正在建立连接！", deviceId);
        }
            break;
            
        case DeviceConnSuccess: // 连接成功
        {
            GosLog(@"当前预览设备（ID = %@）建立连接成功！", deviceId);
            self.hasConnected = YES;
            if (NO == self.hasOpenStream)
            {
                [self openAVStream];
            }
        }
            break;
            
        default:
            break;
    }
    GosLog(@"lololo --%s---",__PRETTY_FUNCTION__);
}
#pragma mark -- 获取当前设备在线状态
- (void)notifyDeviceStatus:(NSNotification *)notifyData
{
    NSDictionary *recvDict = notifyData.object;
    if (!recvDict
        || NO == [[recvDict allKeys] containsObject:@"DeviceID"]
        || NO == [[recvDict allKeys] containsObject:@"Status"])
    {
        return;
    }
    NSString *deviceId  = recvDict[@"DeviceID"];
    NSNumber *statusObj = recvDict[@"Status"];
    DevStatusType devStatus = (DevStatusType)[statusObj integerValue];
    if (NO == [deviceId isEqualToString:self.devModel.DeviceId])
    {
        return;
    }
    switch (devStatus)
    {
        case DevStatus_offLine: // 离线
        {
            self.hasOpenStream = NO;
            [self stopCheckIPCVideoData];
            [self configButtondisEnable];
            [self configOffLineLabHidden:NO];
            [self configActivityHidden];
        }
            break;
            
        case DevStatus_onLine:  // 在线
        {
            [self configOffLineLabHidden:YES];

            if (NO == self.hasOpenStream)   // 处理离线操作：这里打开加载提示，不需重新连接设备，设备列表会自动连接，只需监听连接状态即可
            {
                //                [self configLoadingIndicatorHidden:NO];
            }
            //                        [self configOfflineTipsLabelHidden:YES];
        }
            break;
            
        case DevStatus_sleep:   // 睡眠
        {
            
        }
            break;
            
        default:
            break;
    }
    m_curStatus = devStatus;
    GosLog(@"lololo --%s---",__PRETTY_FUNCTION__);
}

- (void)configOffLineLabHidden:(BOOL) isHidden{
    GOS_WEAK_SELF;
    dispatch_async(dispatch_get_main_queue(), ^{
        
        GOS_STRONG_SELF;
        strongSelf.offLineTipsLab.hidden = isHidden;
    });
    GosLog(@"lololo --%s---",__PRETTY_FUNCTION__);
}



#pragma mark -定时器方法相关
#pragma mark -- 创建音视频流检查定时器
- (void)createCheckVideoTimer
{
    GosLog(@"音视频流检查定时器（Thread）准备创建！");
    self.checkVideoTimer = [[GosThreadTimer alloc] initWithInterval:CHECK_VIDEO_INTERVAL
                                                          forAction:@selector(checkVRVideoData)
                                                            forModl:NSDefaultRunLoopMode
                                                           withName:@"GosCheckVRVideoThread"
                                                           onTarget:self];
    GosLog(@"音视频流检查定时器（Thread） 完成创建！");
    GosLog(@"lololo --%s---",__PRETTY_FUNCTION__);
}


#pragma mark - 音视频流管理
#pragma mark -- 打开音视频流
- (void)openAVStream
{
    if (YES == m_isOpeningAvStream)
    {
        GosLog(@"正在打开当前设备（ID = %@）音视频流，请稍后！", self.devModel.DeviceId);
        return;
    }
    m_isOpeningAvStream = YES;
    GosLog(@"准备打开设备（ID = %@）音视频流！", self.devModel.DeviceId);
    GOS_WEAK_SELF;
    dispatch_async(self.operateAvStreamQueue, ^{
        
        GOS_STRONG_SELF;
        [strongSelf.devSdk openStreamOfType:DeviceStream_all
                                  withDevId:strongSelf.devModel.DeviceId
                                   password:strongSelf.devModel.StreamPassword];
    });
    [self startCheckVRVideoData];
    GosLog(@"lololo --%s---",__PRETTY_FUNCTION__);
}

#pragma mark - 视频数据检查定时器
#pragma mark -- 开启视频数据监测定时器
- (void)startCheckVRVideoData
{
    [self.checkVideoTimer resume];
    GosLog(@"lololo --%s---",__PRETTY_FUNCTION__);
}

#pragma mark -- 停止视频数据监测定时器
- (void)stopCheckVRVideoData
{
    [self.checkVideoTimer pause];
    GosLog(@"lololo --%s---",__PRETTY_FUNCTION__);
}

#pragma mark -- 视频数据定时检查
- (void)checkVRVideoData
{
    GosLog(@"视频数据定时检查(%@)。。。", [NSThread currentThread]);
    if (NO == self.hasRcvingVideo)
    {
        self.hasRcvingVideo = NO;
        GosLog(@"当前没有视频数据！");
        if (DevStatus_onLine == self.devModel.Status)
        {
            //                        [self configLoadingIndicatorHidden:NO];
        }
    }
    if (VRPlayViewControllerDisplayTypeVRLive == self.displayType) {
//        [self configButtonEnable:self.hasRcvingVideo];
    }
}

#pragma mark - 离开界面方法
#pragma mark -- 保存当前设备封面
- (void)saveCurDevCover
{
    NSString *coverPath = [MediaManager pathWithDevId:self.devModel.DeviceId
                                             fileName:nil
                                            mediaType:GosMediaCover
                                           deviceType:(GosDeviceType)self.devModel.DeviceType
                                             position:PositionMain];
    GOS_WEAK_SELF;
    dispatch_async(self.operatePlayerSdkQueue, ^{
        
        GOS_STRONG_SELF;
        NSString *devId = [strongSelf.devModel.DeviceId copy];
        BOOL ret =  [strongSelf.playerSdk snapshotAtPath:coverPath
                                                deviceId:devId];
        if (YES == ret)
        {
            GosLog(@"设备（ID = %@）封面保存成功！", devId);
            NSDictionary *notifyObj = @{@"DeviceID" : devId};
            [[NSNotificationCenter defaultCenter] postNotificationName:kSaveCoverNotify
                                                                object:notifyObj];
        }
    });
}


#pragma mark - 流相关方法
#pragma mark -- 关闭音视频流
- (void)closeAVStream
{
    if (YES == m_isClosingAvStream)
    {
        GosLog(@"正在关闭当前设备（ID = %@）音视频流，请稍后！", self.devModel.DeviceId);
        return;
    }
    m_isClosingAvStream = YES;
    if (YES == m_isStartHalfDuplex)
    {
        [self.devSdk stopTalkWithDevId:self.devModel.DeviceId];
    }
    GosLog(@"准备关闭设备（ID = %@）音视频流！", self.devModel.DeviceId);
    GOS_WEAK_SELF;
    dispatch_async(self.operateAvStreamQueue, ^{
        
        GOS_STRONG_SELF;
        [strongSelf.devSdk closeStreamOfType:DeviceStream_all
                                   withDevId:strongSelf.devModel.DeviceId];
    });
    [self stopCheckVRVideoData];
    GosLog(@"lololo --%s---",__PRETTY_FUNCTION__);
}

#pragma mark -- 开启音频播放
- (void)openAudio
{
    if (YES == self.hasOpenAudio)
    {
        GosLog(@"音频播放已开启，无需再次开启！");
        return;
    }
    GOS_WEAK_SELF;
    dispatch_async(self.operatePlayerSdkQueue, ^{
        
        GOS_STRONG_SELF;
        [strongSelf.playerSdk startVoiceWidthDevId:strongSelf.devModel.DeviceId];
        strongSelf.hasOpenAudio = YES;
        [strongSelf.controlBar setupVoiceButtonState:YES];
    });
    GosLog(@"lololololo --%s---",__PRETTY_FUNCTION__);
}

#pragma mark -- 关闭音频播放
- (void)closeAudio
{
    if (NO == self.hasOpenAudio)
    {
        GosLog(@"音频播放已关闭，无需再次关闭！");
        return;
    }
    GOS_WEAK_SELF;
    dispatch_async(self.operatePlayerSdkQueue, ^{
        
        GOS_STRONG_SELF;
        [strongSelf.playerSdk stopVoiceWidthDevId:strongSelf.devModel.DeviceId];
        strongSelf.hasOpenAudio = NO;
        [strongSelf.controlBar setupVoiceButtonState:NO];
    });
    GosLog(@"lololololo --%s---",__PRETTY_FUNCTION__);
}



#pragma mark - 时间戳相关方法
#pragma mark -- 开启录像定时器时间戳
- (void)startRecordVideoTimer{
    if (!_recordVideoTimer)
    {
        _recordVideoTimer = [[GosThreadTimer alloc] initWithInterval:1.0
                                                           forAction:@selector(recorVideoAction)
                                                             forModl:NSDefaultRunLoopMode
                                                            withName:@"GosRecordVideo"
                                                            onTarget:self];
    }
    GosLog(@"lololo --%s---",__PRETTY_FUNCTION__);
}
#pragma mark -- 开启OSD时间戳
- (void)startOSDTimer{
    if (!_osdTimer) {
        _osdTimer = [[GosThreadTimer alloc] initWithInterval:1.0
                                                   forAction:@selector(osdTimerFunc)
                                                     forModl:NSDefaultRunLoopMode
                                                    withName:@"GosPOSDTimer"
                                                    onTarget:self];
        
    }
}


#pragma mark -- 录像处理
- (void)recorVideoAction
{
    static int recDuration = 0;
    recDuration++;
    if (0 == (recDuration&1))
    {
        [self configRecordingViewlHidden:YES];
    }
    else
    {
        [self configRecordingViewlHidden:NO];
    }
    GosLog(@"lololo --%s---",__PRETTY_FUNCTION__);
}
#pragma mark - OSD时间显示方法
- (void)osdTimerFunc
{
    self.timeLab.text = [self currentDateStr];
}
- (NSString *)currentDateStr
{
    NSDate *date =[NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *currentDate = [formatter stringFromDate:date];
    return currentDate;
}

#pragma mark - 播放体验中心的360或180的流
- (void)playH264Demo
{
    if (VRPlayViewControllerDisplayTypeVR360 == self.displayType) {
        self.displayVC.correctMode_180 = CorrectionMode180_Standard;
    }else{
        self.displayVC.correctMode = CorrectionModeStandard;
    }
    
    if([mFileManager fileExistsAtPath:self.vr360_h264FilePath]){
//        [self.displayVC startToDecH264FileWithPort:0 filePath:self.vr360_h264FilePath];
        [self.playerSdk startDecodeH246:self.vr360_h264FilePath
                              withDevId:@"tiyanzhongxin"];
    }else{
        [self downloadH264File];
    }
    GosLog(@"lololo --%s---",__PRETTY_FUNCTION__);
}

- (void)downloadH264File{
    
    NSString *baseURLStr = nil;
    
    //    ServerAddress *upsAddr = [ServerAddress yy_modelWithDictionary:[mUserDefaults objectForKey:@"UPSAddress"]];
    //    if (upsAddr.Address.length >0) {
    //        baseURLStr = [NSString stringWithFormat:@"http://%@:%d/H264",upsAddr.Address,upsAddr.Port];
    //    }else{
    baseURLStr = @"http://119.23.128.98:5302/H264/";
    //    }
    NSString *urlStr = [baseURLStr stringByAppendingString:self.vr360_h264FileName];
    
    NSURL *url = [NSURL URLWithString:urlStr];
    NSURLRequest *req = [NSURLRequest requestWithURL:url];
    
    //3.创建session ：注意代理为NSURLSessionDownloadDelegate
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    
    NSURLSessionDownloadTask *task = [session downloadTaskWithRequest:req];
    
    [task resume];
    GosLog(@"lololo --%s---",__PRETTY_FUNCTION__);
}

#pragma mark - 全屏代理
-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                               duration:(NSTimeInterval)duration
{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [UIView animateWithDuration:0.25 animations:^{
        if (UIDeviceOrientationIsLandscape((UIDeviceOrientation)toInterfaceOrientation))
        {   
            [self.navigationController setNavigationBarHidden:YES animated:NO];
            [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
            [[UIApplication sharedApplication] setStatusBarHidden:YES];
            
            //全屏约束
            
            [self.playerView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(self.view);
            }];
      
            [self.displayVC setEnterFullScreen:YES];
            if (self.displayVC) {
                [self.displayVC updatePlayerViewFrame:CGRectMake(0, 0, trueScreenHeight, trueSreenWidth)];
            }
//            self.playerView.hidden = YES;
            self.controlBar.hidden = YES;
        }
        else{
            [self.navigationController setNavigationBarHidden:NO animated:NO];
            [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
            [[UIApplication sharedApplication] setStatusBarHidden:NO];
            
            //半屏幕约束
            [self.playerView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.view).offset(0);
                make.left.right.equalTo(self.view);
                make.height.mas_equalTo(self.view.mas_width).multipliedBy(PlayerViewRatio);
            }];
 
            [self.displayVC setEnterFullScreen:YES];
            if (self.displayVC) {
                [self.displayVC updatePlayerViewFrame:CGRectMake(0, 0, trueSreenWidth, trueSreenWidth * PlayerViewRatio)];
            }
            
//            self.playerView.hidden = NO;
            self.controlBar.hidden = NO;
        }
        
        [self.view setNeedsLayout];
        [self.view layoutIfNeeded];
        
    } completion:^(BOOL finished) {
    }];
    GosLog(@"lololo --%s---",__PRETTY_FUNCTION__);
}


#pragma mark - 音视频代理回调
#pragma mark -- 音频数据回调
- (void)deviceId:(NSString *)deviceId
       audioData:(unsigned char*)aBuffer
          length:(unsigned int)dLen
         frameNo:(unsigned int)frameNo
        codeType:(AudioCodeType)acType
{
    if (IS_EMPTY_STRING(deviceId)
        || NO == [deviceId isEqualToString:self.devModel.DeviceId])
    {
        return;
    }
    GosPrintf("音频数据-deviceId:%s, lenght:%d, frameNo:%d, codeType:%ld\n", deviceId.UTF8String, dLen, frameNo, (long)acType);
    
    NSData *audioData = [NSData dataWithBytes:aBuffer length:dLen];
    GOS_WEAK_SELF;
    dispatch_async(self.playAvStreamQueue, ^{
        
        GOS_STRONG_SELF;
        [strongSelf.playerSdk addAudioData:(unsigned char*)audioData.bytes
                                    length:dLen
                                   frameNo:frameNo
                                  deviceId:deviceId
                                  codeType:(PlayerAudioCodeType)acType];
    });
}

#pragma mark -- 视频数据回调
- (void)deviceId:(NSString *)deviceId
       videoData:(unsigned char*)vBuffer
          length:(unsigned int)dLen
         frameNo:(unsigned int)frameNo
       timeStamp:(unsigned int)timeStamp
       frameRate:(unsigned int)fRate
       frameType:(VideoFrameType)fType
       avChannel:(int)avChn
{
    if (IS_EMPTY_STRING(deviceId)
        || NO == [deviceId isEqualToString:self.devModel.DeviceId])
    {
        return;
    }
    GosPrintf("视频数据-deviceId:%s, length:%d, frameNo:%d, timeStamp:%d, frameRate:%d, frameType:%ld, avchannel:%d\n", deviceId.UTF8String, dLen, frameNo, timeStamp, fRate, (long)fType, avChn);
    
    self.hasRcvingVideo = YES;          // 标识有视频数据
//    [self configButtonEnable:YES];      // 标记按钮可用状态
    // 视频渲染
    NSData *videoData = [NSData dataWithBytes:vBuffer length:dLen];
    [self startOSDTimer];
    GOS_WEAK_SELF;
    dispatch_async(self.playAvStreamQueue, ^{
        
        GOS_STRONG_SELF;
        [strongSelf.playerSdk addVideoData:(unsigned char*)videoData.bytes
                                    length:dLen
                                 timeStamp:timeStamp
                                   frameNo:frameNo
                                 frameRate:fRate
                                  isIframe:VideoFrame_iFrame == fType
                                  deviceId:deviceId];
    });
    
    if (NO == m_hasCheckVideoQuality)
    {
        GOS_WEAK_SELF;
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            
            GOS_STRONG_SELF;
            [strongSelf.devSdk checkQualityWithDevId:strongSelf.devModel.DeviceId];
        });
        m_hasCheckVideoQuality = YES;
    }
}

#pragma mark -- VR 解码数据回调（临时解决方法）
- (void)vrYUVData:(unsigned char*)buffer
           length:(long)length
            width:(unsigned int)width
           height:(unsigned int)height
{
    [self configActivityHidden];        //  去渲染的时候再隐藏小菊花
    if (VRPlayerControlBarVRTypeLive == self.displayType)
    {
        [self configButtonEnable:YES];      //  让所有按钮可用(实时流状态)
    }
    [self.displayVC startPlayYUVData:width
                             lHeight:height
                               lpBuf:buffer];
}



#pragma mark -- 打开流状态回调
- (void)deviceId:(NSString *)deviceId
 openStreamState:(OpenStreamState)sState
       errorType:(StreamErrorType)errType
{
    if (IS_EMPTY_STRING(deviceId)
        || NO == [deviceId isEqualToString:self.devModel.DeviceId])
    {
        return;
    }
    switch (sState)
    {
        case OpenStreamUnknown: // 未知
        {
            
        }
            break;
            
        case OpenStreamFailure: // 打开音视频流失败
        {
            m_isOpeningAvStream = NO;
            self.hasOpenStream  = NO;
            switch (errType)
            {
                case StreamError_disConn:
                {
                    GosLog(@"打开设备（ID = %@）音视频流失败，原因：设备未连接成功", deviceId);
                }
                    break;
                    
                case StreamError_unknown:
                {
                    if (GOS_REOPEN_AV_STREAM_COUNTS > self.reOpenAvStreamCounts++)
                    {
                        GosLog(@"打开设备（ID = %@）音视频流失败，原因：未知，开启重新拉流策略", deviceId);
#if DEBUG
                        NSString *debugInfo = [NSString stringWithFormat:@"打开设备音视频流失败，重新拉流(%ld)", (long)self.reOpenAvStreamCounts];
                        [SVProgressHUD showInfoWithStatus:debugInfo forDuration:2];
#endif
                        [self openAVStream];
                    }
                    else
                    {
#if DEBUG
                        NSString *debugInfo = [NSString stringWithFormat:@"打开设备音视频流失败(%ld)，重连设备", (long)self.reOpenAvStreamCounts];
                        [SVProgressHUD showInfoWithStatus:debugInfo forDuration:2];
#endif
                        GosLog(@"打开设备（ID = %@）音视频流失败，重新拉流拉流次数已到达，发送重新建立连接通知", deviceId);
                        NSDictionary *notifyDict = @{@"DeviceID" : deviceId,};
                        [[NSNotificationCenter defaultCenter] postNotificationName:kReDisConnAndConnAgainNotify
                                                                            object:notifyDict];
                    }
                }
                    break;
                    
                default:
                    break;
            }
        }
            break;
            
        case OpenStreamSuccess: // 打开音视频流成功
        {
            GosLog(@"打开设备（ID = %@）音视频流成功", deviceId);
            m_isOpeningAvStream = NO;
            self.hasOpenStream  = YES;
        }
            break;
            
        default:
            break;
    }
    GosLog(@"lololo --%s---",__PRETTY_FUNCTION__);
}

#pragma mark -- 关闭流状态回调
- (void)deviceId:(NSString *)deviceId
closeStreamState:(CloseStreamState)cState
       errorType:(StreamErrorType)errType
{
    if (IS_EMPTY_STRING(deviceId)
        || NO == [deviceId isEqualToString:self.devModel.DeviceId])
    {
        return;
    }
    switch (cState)
    {
        case CloseStreamUnknown: // 未知
        {
            
        }
            break;
            
        case CloseStreamFailure: // 关闭音视频流失败
        {
            m_isClosingAvStream = NO;
            self.hasOpenStream  = NO;
            switch (errType)
            {
                case StreamError_disConn:
                {
                    GosLog(@"关闭设备（ID = %@）音视频流失败，原因：设备未连接成功", deviceId);
                }
                    break;
                    
                case StreamError_Closed:
                {
                    GosLog(@"关闭设备（ID = %@）音视频流失败，原因：流已关闭", deviceId);
                }
                    break;
                    
                default:
                    break;
            }
        }
            break;
            
        case CloseStreamSuccess: // 关闭音视频流成功
        {
            GosLog(@"关闭设备（ID = %@）音视频流成功", deviceId);
            m_isClosingAvStream = NO;
            self.hasOpenStream  = NO;
        }
            break;
            
        default:
            break;
    }
    GosLog(@"lololo --%s---",__PRETTY_FUNCTION__);
}

#pragma mark -- 查询视频质量回调
- (void)deviceid:(NSString *)deviceId
       isChecked:(BOOL)isChecked
    videoQuality:(VideoQualityType)vqType
{
    if (IS_EMPTY_STRING(deviceId)
        || NO == [deviceId isEqualToString:self.devModel.DeviceId])
    {
        return;
    }
    if (NO == isChecked)
    {
        GosLog(@"查询设备（ID = %@）视频质量失败！", deviceId);
    }
    else
    {
        GosLog(@"查询设备（ID = %@）视频质量成功，质量：%ld", deviceId, (long)vqType);
        self.vQuality = vqType;
        [self configVideoQuality];
    }
    GosLog(@"lololo --%s---",__PRETTY_FUNCTION__);
}

#pragma mark -- 对讲操作回调
- (void)deviceId:(NSString *)deviceId
       talkEvent:(TalkEvent)tEvent
       talkState:(TalkState)tState
{
    if (IS_EMPTY_STRING(deviceId)
        || NO == [deviceId isEqualToString:self.devModel.DeviceId])
    {
        return;
    }
    GosLog(@"设备（ID = %@）对讲操作回调，talkEvent = %ld, talkStatus = %ld", deviceId, (long)tEvent, (long)tState);
    switch (tEvent)
    {
        case Talk_start:
        {
            m_isStartHalfDuplex = YES;
            switch (tState)
            {
                case Talk_unknown:
                {
                    
                }
                    break;
                    
                case Talk_Failure:
                {
                    [SVProgressHUD showErrorWithStatus:DPLocalizedString(@"StartTalkFileFailure")];
                }
                    break;
                    
                case Talk_success:
                {
                    
                }
                    break;
                    
                default:
                    break;
            }
        }
            break;
            
        case Talk_stop:
        {
            m_isStartHalfDuplex = NO;
            switch (tState)
            {
                case Talk_unknown:
                {
                    
                }
                    break;
                    
                case Talk_Failure:
                {
                    [SVProgressHUD showErrorWithStatus:DPLocalizedString(@"StopTalkFileFailure")];
                }
                    break;
                    
                case Talk_success:
                {
                    
                }
                    break;
                    
                default:
                    break;
            }
        }
            break;
            
        case Talk_sendFile:
        {
            switch (tState)
            {
                case Talk_unknown:
                {
                    
                }
                    break;
                    
                case Talk_Failure:
                {
                    [SVProgressHUD showErrorWithStatus:DPLocalizedString(@"SendTalkFileFailure")];
                }
                    break;
                    
                case Talk_success:
                {
                    
                }
                    break;
                    
                default:
                    break;
            }
        }
            break;
            
        default:
            break;
    }
    GosLog(@"lololo --%s---",__PRETTY_FUNCTION__);
}

#pragma mark -- 录音回调
- (void)recordAudioPath:(NSString *)recPath
              isSuccess:(BOOL)isSuccess
{
    if (NO == isSuccess)
    {
        GosLog(@"对讲录音失败！");
        [SVProgressHUD showErrorWithStatus:DPLocalizedString(@"TalkFileRecordFailure")];
    }
    else
    {
        GosLog(@"对讲录音成功：%@", recPath);
        [self.devSdk sendTalkFile:recPath
                        withDevId:self.devModel.DeviceId];
    }
    GosLog(@"lololo --%s---",__PRETTY_FUNCTION__);
}


#pragma mark - 下载体验中心的文件回调
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location{
    NSLog(@"downloadedLoc:%@",location);
    
    //1 文件存在的话先移除
    if ([mFileManager fileExistsAtPath:self.vr360_h264FilePath]) {
        
        [mFileManager removeItemAtPath:self.vr360_h264FilePath error:nil];
    }
    
    //2 剪切文件
    NSError *error;
    [[NSFileManager defaultManager]moveItemAtURL:location toURL:[NSURL fileURLWithPath:self.vr360_h264FilePath] error:&error];
    NSLog(@"moveToPath:%@",self.vr360_h264FilePath);
    dispatch_async(dispatch_get_main_queue(), ^{
//        [self.loadVideoActivity stopAnimating];
//        self.loadVideoActivity.hidden = YES;
    });
    
    if (!error) {//No error
//        [self.displayVC startToDecH264FileWithPort:0 filePath:self.vr360_h264FilePath];
        [self.playerSdk startDecodeH246:self.vr360_h264FilePath withDevId:@"tiyanzhongxin"];
    }else{
        NSLog(@"moveFileError:%@",error.description);
    }
    GosLog(@"lololo --%s---",__PRETTY_FUNCTION__);
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite{
    NSLog(@"progress:%4.2f",totalBytesWritten*1.0/totalBytesExpectedToWrite);
    GosLog(@"lololo --%s---",__PRETTY_FUNCTION__);
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error{
    if (error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD showErrorWithStatus:DPLocalizedString(@"network_error") ];
        });
    }
    GosLog(@"lololo --%s---",__PRETTY_FUNCTION__);
}



#pragma mark - 点击代理回调
#pragma mark -- 中间控制器回调
/// 声音
- (void)controlBar:(UIView *)controlBar voiceDidClick:(UIButton *)sender
{
    GosLog(@"声音打开 = %d",sender.selected);
    [self dealWithVoice];
}
/// 巡航
- (void)controlBar:(UIView *)controlBar cruiseDidClick:(UIButton *)sender
{
    m_autoRotateSignal =! m_autoRotateSignal;
    self.displayVC.player.autoRotSig = m_autoRotateSignal;
    GosLog(@"lololo --%s---",__PRETTY_FUNCTION__);
}
/// 安装模式
- (void)controlBar:(UIView *)controlBar mountingModeDidClick:(UIButton *)sender
{
    
}
/// 显示模式
- (void)controlBar:(UIView *)controlBar displayModeDidChanged:(VRPlayerControlBarDisplayMode)displayMode
{
    switch (displayMode) {
//            360模式的切换
        case VRPlayerControlBarDisplayModeAsteroid:
            m_clickSig = 0;
            break;
        case VRPlayerControlBarDisplayModeCylinder:
            m_clickSig = 1;
            break;
        case VRPlayerControlBarDisplayModeTwoPicture:
            m_clickSig = 3;
            break;
        case VRPlayerControlBarDisplayModeFourPicture:
            m_clickSig = 4;
            break;
//            180模式的切换
            case VRPlayerControlBarDisplayModeWideAngle:
            m_clickSig = 6;
        default:
            break;
    }

    GosLog(@"lololo --%s---",__PRETTY_FUNCTION__);
    self.displayVC.player.clickSig = m_clickSig;
    [self.displayVC.player gosPanorama_updateClickSignal];
    [self restoreDisplayModeToDefault];
}
/// 回放
- (void)controlBar:(UIView *)controlBar playbackDidClick:(UIButton *)sender
{
    if (VRPlayViewControllerDisplayTypeVRLive != self.displayType)
    {
        return;
    }
    [self turnToTFCardFilesVC];
}
/// 清晰度
- (void)controlBar:(UIView *)controlBar definitionDidClick:(UIButton *)sender
{
    GosLog(@"视频质量切换按钮事件！");
    [self dealWithClarity];
}
/// 录像回调
- (void)controlBar:(UIView *)controlBar recordDidClick:(UIButton *)sender
{
    GosLog(@"录像按钮事件！");
    [self dealWithRecord];
}
/// 对讲
- (void)controlBar:(UIView *)controlBar speakDidTouchDown:(UIButton *)sender
{
    GosLog(@"-----按住");
    [self dealWithSpeakTouchDown];
}
- (void)controlBar:(UIView *)controlBar speakDidTouchDragExit:(UIButton *)sender
{
    GosLog(@"-----离开");
    [self dealWithSpeakTouchDragExit];
}
- (void)controlBar:(UIView *)controlBar speakDidTouchUpInside:(UIButton *)sender
{
    GosLog(@"-----点击");
    [self dealWithSpeakTouchUpInside];
}

/// 截图(抓拍 拍照)
- (void)controlBar:(UIView *)controlBar snapshotDidClick:(UIButton *)sender
{
    [self snapshotBtnAction];
}


#pragma mark -- 回调处理事件
/// 处理声音开关
- (void)dealWithVoice
{
    if (NO == self.hasOpenAudio)
    {
        GosLog(@"开启声音播放！");
        [self openAudio];
    }
    else
    {
        GosLog(@"关闭声音播放！");
        [self closeAudio];
    }
}
/// 处理录像事件
- (void)dealWithRecord
{
    self.hasStartRecordVideo =! self.hasStartRecordVideo;
    [self playRecordSound];
    
    if (NO == self.hasStartRecordVideo) // 关闭录像
    {
        if (_recordVideoTimer)
        {
            [_recordVideoTimer destroy];
            _recordVideoTimer = nil;
        }
        [self configRecordingViewlHidden:YES];
        GOS_WEAK_SELF;
        dispatch_async(self.operatePlayerSdkQueue, ^{
            
            GOS_STRONG_SELF;
            [strongSelf.playerSdk stopRecordVideoWidthDevId:strongSelf.devModel.DeviceId];
            [strongSelf configREGLabelHidden:YES];
        });
        
    }
    else    // 开启录像
    {
        NSString *recordPath = [MediaManager pathWithDevId:self.devModel.DeviceId
                                                  fileName:nil
                                                 mediaType:GosMediaRecord
                                                deviceType:GosDevice360
                                                  position:PositionMain];
        if (IS_EMPTY_STRING(recordPath))
        {
            GosLog(@"文件路径不存在，无法录像！");
            return;
        }
        [self startRecordVideoTimer];
        GOS_WEAK_SELF;
        dispatch_async(self.operatePlayerSdkQueue, ^{
            
            GOS_STRONG_SELF;
            [strongSelf configREGLabelHidden:NO];
            [strongSelf.playerSdk startRecordVideoAtPath:recordPath
                                                deviceId:strongSelf.devModel.DeviceId];
        });
    }
    
    
    [self.controlBar configRecordSelect:self.hasStartRecordVideo];
}

/// 对讲touchDown
- (void)dealWithSpeakTouchDown
{
    if (NO == m_isStartHalfDuplex)
    {
        [self.devSdk startTalkWithDevId:self.devModel.DeviceId];
    }
    GOS_WEAK_SELF;
    dispatch_async(self.operatePlayerSdkQueue, ^{
        
        GOS_STRONG_SELF;
        [strongSelf.playerSdk startRecordAudio];
    });
    m_isTalkingOnHalfDuplex = YES;
    [self closeAudio];
}

/// 对讲touchDragDragExit
- (void)dealWithSpeakTouchDragExit
{
    if (NO == m_isStartHalfDuplex)
    {
        [self.devSdk startTalkWithDevId:self.devModel.DeviceId];
    }
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        [self.playerSdk startRecordAudio];
    });
    m_isTalkingOnHalfDuplex = YES;
    [self closeAudio];
}

/// 对讲TouchUpInside
- (void)dealWithSpeakTouchUpInside
{
    GOS_WEAK_SELF;
    dispatch_async(self.operatePlayerSdkQueue, ^{
        
        GOS_STRONG_SELF;
        [strongSelf.playerSdk stopRecordAudio];
    });
    m_isTalkingOnHalfDuplex = NO;
    [self openAudio];
}

/// 跳转至'TF 卡录像-文件夹'页面
- (void)turnToTFCardFilesVC
{
    TFCRDateListViewController *tfCardFilesVC = [[TFCRDateListViewController alloc] init];
    tfCardFilesVC.devModel                    = self.devModel;
    [self.navigationController pushViewController:tfCardFilesVC
                                         animated:YES];
}
/// 处理清晰度
- (void)dealWithClarity
{
    if (VideoQuality_SD == self.vQuality)
    {
        self.vQuality = VideoQuality_HD;
    }
    else if (VideoQuality_HD == self.vQuality)
    {
        self.vQuality = VideoQuality_SD;
    }
    else
    {
        self.vQuality = VideoQuality_SD;
    }
    [self.devSdk switchWithDevId:self.devModel.DeviceId
                       toQuality:self.vQuality];
}
/// 抓拍事件
- (void)snapshotBtnAction
{
    NSString *snapshotPath = [MediaManager pathWithDevId:self.devModel.DeviceId
                                                fileName:nil
                                               mediaType:GosMediaSnapshot
                                              deviceType:GosDevice360
                                                position:PositionMain];
    if (IS_EMPTY_STRING(snapshotPath))
    {
        GosLog(@"文件路径不存在，无法拍照！");
        return;
    }
    [self playSnapshotSound];
    GOS_WEAK_SELF;
    dispatch_async(self.operatePlayerSdkQueue, ^{
        
        GOS_STRONG_SELF;
        BOOL ret = [strongSelf.playerSdk snapshotAtPath:snapshotPath
                                               deviceId:strongSelf.devModel.DeviceId];
        if (NO == ret)
        {
            GosLog(@"抓拍失败！");
            [SVProgressHUD showErrorWithStatus:DPLocalizedString(@"SnapshotFailure")];
        }
        else
        {
            GosLog(@"抓拍成功，路径：%@", snapshotPath);
            [SVProgressHUD showSuccessWithStatus:DPLocalizedString(@"SnapshotSuccess")];
        }
    });
}


#pragma mark -- 播放‘拍照’音效
- (void)playSnapshotSound
{
    if (self.snapshotAudioPlayer)
    {
        [self.snapshotAudioPlayer prepareToPlay];
        [self.snapshotAudioPlayer play];
    }
}
#pragma mark -- 播放‘录像’音效
- (void)playRecordSound
{
    if (self.recordAudioPlayer)
    {
        [self.recordAudioPlayer prepareToPlay];
        [self.recordAudioPlayer play];
    }
}
#pragma mark -- 停止按钮音效播放器
-(void)releaseSoundAudioPlayer
{
    if (_snapshotAudioPlayer)
    {
        [_snapshotAudioPlayer stop];
        _snapshotAudioPlayer = nil;
    }
    if (_recordAudioPlayer)
    {
        [_recordAudioPlayer stop];
        _recordAudioPlayer = nil;
    }
}


#pragma mark - 资源释放
#pragma mark -- 释放解码器资源
- (void)releaseSource
{
    [self stopCheckIPCVideoData];
    [self.playerSdk releasePlayer];
    self.controlBar.vrControlBarDelegate = nil;
    //        self.configSdk.paramDelegate = nil;
    self.playerSdk.delegate      = nil;
    _playerSdk                   = nil;
    self.devSdk.delegate         = nil;
    _devSdk                      = nil;
    self.displayVC.audioDelegate = nil;
    self.displayVC               = nil;
    
    [self.checkVideoTimer destroy];
    [self.recordVideoTimer destroy];
    [self.osdTimer destroy];
    self.checkVideoTimer = nil;
    self.recordVideoTimer =nil;
    self.osdTimer = nil;
    
}
#pragma mark -- 停止视频数据监测定时器
- (void)stopCheckIPCVideoData
{
    [self.checkVideoTimer pause];
}
- (void)restoreDisplayModeToDefault{
    m_clickSig = self.displayVC.clickSig = self.displayVC.player.clickSig = -1;
    GosLog(@"lololo---------- %s ---------- ",__PRETTY_FUNCTION__);
}
#pragma mark -- Dealloc
- (void)dealloc
{
    GosLog(@"---------- %s ---------- ",__PRETTY_FUNCTION__);
    [self.checkVideoTimer destroy];
    _checkVideoTimer = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - 懒加载(数据初始化)
#pragma mark -- DevSDK初始化
- (iOSDevSDK *)devSdk
{
    if (!_devSdk)
    {
        _devSdk = [iOSDevSDK shareDevSDK];
        _devSdk.delegate = self;
    }
    return _devSdk;
}
#pragma mark -- 体验中心文件路径
- (NSString*)vr360_h264FilePath
{
    if (!_vr360_h264FilePath) {
        _vr360_h264FilePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:(VRPlayViewControllerDisplayTypeVR180 == self.displayType)?@"stream_chn0_1.h264":@"kk_stream_chn0_5.h264"] ;
    }
    return _vr360_h264FilePath;
}
#pragma mark -- 演示视频文件名
- (NSString*)vr360_h264FileName
{
    if (!_vr360_h264FileName) {
        if (_displayType == VRPlayViewControllerDisplayTypeVR180) {
            _vr360_h264FileName = @"stream_chn0_1.h264";
        }else{
            _vr360_h264FileName = @"kk_stream_chn0_5.h264";
        }
    }
    return _vr360_h264FileName;
}
#pragma mark -- 初始化视频模式
- (instancetype)initWithDisplayType:(VRPlayViewControllerDisplayType)displayType
{
    if (self = [super init])
    {
        self.displayType = displayType;
    }
    return self;
}
#pragma mark -- ‘录像’按钮音效播放器
- (AVAudioPlayer *)recordAudioPlayer
{
    if (!_recordAudioPlayer)
    {
        NSString *audioFilePath = [[NSBundle mainBundle] pathForResource:@"RecordSound"
                                                                  ofType:@"wav"];
        NSURL *audioFileUrl     = [NSURL fileURLWithPath:audioFilePath];
        _recordAudioPlayer      = [[AVAudioPlayer alloc] initWithContentsOfURL:audioFileUrl
                                                                         error:NULL];
    }
    return _recordAudioPlayer;
}
#pragma mark -- ‘拍照’按钮音效播放器
- (AVAudioPlayer *)snapshotAudioPlayer
{
    if (!_snapshotAudioPlayer)
    {
        NSString *audioFilePath = [[NSBundle mainBundle] pathForResource:@"SnapshotSound"
                                                                  ofType:@"wav"];
        NSURL *audioFileUrl     = [NSURL fileURLWithPath:audioFilePath];
        _snapshotAudioPlayer    = [[AVAudioPlayer alloc] initWithContentsOfURL:audioFileUrl
                                                                         error:NULL];
    }
    return _snapshotAudioPlayer;
}


#pragma mark -- 创建 PlayerSDK 对象
- (void)createPlayerSdk
{
    if (VRPlayViewControllerDisplayTypeVRLive == self.displayType)
    {
        self.playerSdk = [[iOSPlayerSDK alloc] initWithDeviceId:self.devModel.DeviceId
                                                   onVRPlayView:self.view];
    }
    else
    {
        self.playerSdk = [[iOSPlayerSDK alloc] initWithDeviceId:@"tiyanzhongxin"
                                                   onVRPlayView:self.view];
    }
    
    self.playerSdk.delegate = self;
    GosLog(@"lololo --%s---",__PRETTY_FUNCTION__);
}

@end
