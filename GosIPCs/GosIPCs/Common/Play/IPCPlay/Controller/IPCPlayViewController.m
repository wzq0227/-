//
//  IPCPlayViewController.m
//  GosIPCs
//
//  Created by shenyuanluo on 2018/12/3.
//  Copyright © 2018 goscam. All rights reserved.
//

#import "IPCPlayViewController.h"
#import "iOSDevSDK.h"
#import "iOSPlayerSDK.h"
#import "MediaManager.h"
#import "GosThreadTimer.h"
#import "IPCPlayView.h"
#import "MediaManager.h"
#import <AVFoundation/AVFoundation.h>
#import "GosTalkCountDownView.h"        //  按住对讲view

/// 对讲时间
#define talkTime 50
@interface IPCPlayViewController () <
                                        iOSDevSDKDelegate,
                                        iOSPlayerSDKDelegate,
                                        iOSConfigSDKParamDelegate,
                                        SYFullScreenViewDeleaget,
                                        IPCPlayViewDelegate
                                    >
{
    BOOL m_isRatioPlay;         // 是否按比例播放视图
    BOOL m_isOpeningAvStream;   // 是否正在打开音视频流
    BOOL m_isClosingAvStream;   // 是否正在关闭音视频流
    BOOL m_isHiddenCover;       // 是否隐藏封面
    BOOL m_isHiddenLoading;     // 是否隐藏j视频加载提示 View
    BOOL m_isHiddenPTZView;     // 是否隐藏控制台视图
    BOOL m_hasCheckVideoQuality;// 是否已获取当前视频质量
    BOOL m_hasReqLullay;        // 是否以获取摇篮曲状态信息
    BOOL m_isStartHalfDuplex;   // 是否开启对讲（半双工）
    BOOL m_isStartFullDeplex;       // 是否开启对讲（全双工）
    BOOL m_isTalkingOnHalfDuplex;   // 是否正在对讲（半双工）
    BOOL m_isTalkingOnFullDuplex;   // 是否正在对讲（全双工）
    DevStatusType m_curStatus;  // 当前设备在线状态（需要监控）
    CGRect m_playViewPortraitFrame;
    CGRect m_playViewLandscapeFrame;
}
@property (nonatomic, readwrite, strong) IPCPlayView *ipcView;
@property (nonatomic, readwrite, weak) iOSDevSDK *devSdk;
@property (nonatomic, readwrite, strong) iOSPlayerSDK *playerSdk;
@property (nonatomic, readwrite, strong) iOSConfigSDK *configSdk;
/** 是否打开音视频流 */
@property (nonatomic, readwrite, assign) BOOL hasOpenStream;
/** 已连接设备，拉流失败再次重新拉流次数 */
@property (nonatomic, readwrite, assign) NSInteger reOpenAvStreamCounts;
/** 控制音视频流队列（串行） */
@property (nonatomic, readwrite, strong) dispatch_queue_t operateAvStreamQueue;
/** 控制 PlayerSDK 队列（串行） */
@property (nonatomic, readwrite, strong) dispatch_queue_t operatePlayerSdkQueue;
/** 播放音视频回调数据队列（串行） */
@property (nonatomic, readwrite, strong) dispatch_queue_t playAvStreamQueue;
/** 控制检查视频数据定时器队列（串行） */
@property (nonatomic, readwrite, strong) dispatch_queue_t opCheckVideoQueue;
/** 回音消除数据队列（串行） */
@property (nonatomic, readwrite, strong) dispatch_queue_t echoAudioQueue;
/** 视频数据检查定时器 */
@property (nonatomic, readwrite, strong) GosThreadTimer *checkVideoTimer;
/** 温度检查定时器 */
@property (nonatomic, readwrite, strong) GosThreadTimer *checkTemperatureTimer;
/** 对讲倒计时定时器 */
@property (nonatomic, readwrite, strong) GosThreadTimer *countDownTimer;

/** 是否正在接收视频数据 */
@property (nonatomic, readwrite, assign) BOOL hasRcvingVideo;
/** 是否开启音频 */
@property (nonatomic, readwrite, assign) BOOL hasOpenAudio;
/** 是否开启录像 */
@property (nonatomic, readwrite, assign) BOOL hasStartRecordVideo;
/** 录像定时器 */
@property (nonatomic, readwrite, strong)GosThreadTimer *recordVideoTimer;
/** 当前视频质量 */
@property (nonatomic, readwrite, assign) VideoQualityType vQuality;
/** 录像按钮点击声音 播放器 */
@property (nonatomic, strong) AVAudioPlayer *recordAudioPlayer;
/** 拍照按钮点击声音 播放器 */
@property (nonatomic, strong) AVAudioPlayer *snapshotAudioPlayer;
/** 正在播放摇篮曲序号 */
@property (nonatomic, readwrite, assign) LullabyNumber lullabyNum;
/** 摇篮曲播放状态 */
@property (nonatomic, readwrite, assign) LullabyStatus lullabyStatus;
/** 是否播放摇篮曲 */
@property (nonatomic, readwrite, assign) BOOL isPlayLullaby;
/** 是否是全双工 */
@property (nonatomic, readwrite, assign) BOOL isFullDuplex;
/** 半双工摁住(50秒)剩余时间提示  */
@property (nonatomic, strong) GosTalkCountDownView *countDownView;
/** 半双工摁住(50秒)倒计时时间  */
@property (assign, nonatomic) NSInteger repeatCount;
/** 全双工对讲弹出的View(图片) */
@property (nonatomic, strong) UIImageView *fullDuplextalkView;
@end

@implementation IPCPlayViewController


- (BOOL)shouldAutorotate
{
    return NO;
}


- (void)loadView
{
    self.ipcView = [[IPCPlayView alloc] initWithFrame:CGRectMake(0, 0, GOS_SCREEN_W, GOS_SCREEN_H)];
    self.ipcView.delegate = self;
    self.ipcView.videoShowView.delegate = self;
    self.view = self.ipcView;
}

+ (instancetype)shareIpcPlayVC
{
    static IPCPlayViewController *g_ipcPlayVC = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (nil == g_ipcPlayVC)
        {
            g_ipcPlayVC = [[IPCPlayViewController alloc] init];
        }
    });
    return g_ipcPlayVC;
}

- (void)viewDidLoad // 注意：这个控制器使用【单例】
{
    [super viewDidLoad];
    
    [self initParam];
    [self configUI];

    [self createCheckVideoTimer];
    [self createCheckTemperatureTimer];
    
}

- (void)viewWillAppear:(BOOL)animated   // 注意：这个控制器使用【单例】
{
    [super viewWillAppear:animated];
    
    [self resetParam];
    [self resetUI];
    [self configCoverHidden:NO];
    [self loadCurCover];
    [self configLoadingIndicatorHidden:NO];
    [self addCurDevStatusNotify];
    [self addCurDevConnStatusNotify];
    [self addReqAbilityNotify];
    
    if (LullabyDev_unSupport == self.abModel.lullabyDevType)
    {
        [self configLullabyBtnlHidden:YES];
    }
    else
    {
        [self configLullabyBtnlHidden:NO];
    }
    if (NO == self.abModel.hasTemDetect)
    {
        [self configTemperatureViewHidden:YES];
    }
    else
    {
        [self configTemperatureViewHidden:NO];
    }
    [self configPZTHidden:self.abModel.hasPTZ];
    [self configLullabyIcon];
    [self configTalkbackBtnIcon];
    [self configRecordingViewlHidden:YES];
    [self configButtonEnable:self.hasRcvingVideo];
    [self.ipcView configSoundBtnIcon:self.hasOpenAudio];

    if (DevStatus_onLine != self.devModel.Status)
    {
        [self stopCheckIPCVideoData];
        [self configOfflineTipsLabelHidden:NO];
        [self configLoadingIndicatorHidden:YES];
    }
    else
    {
        [self configOfflineTipsLabelHidden:YES];
        [self configLoadingIndicatorHidden:NO];
    }
    
    [self createPplayerSdk];
    
    if (YES == self.hasConnected)
    {
        [self openAVStream];
    }
    [self postNotifyVideoIsShowing:YES];
}

- (void)viewDidAppear:(BOOL)animated    // 注意：这个控制器使用【单例】
{
    [super viewDidAppear:animated];
    
    [self.ipcView showCenterCtrlView];
    
    GOS_WEAK_SELF;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        GOS_STRONG_SELF;
        
        [self startCheckTemperature];
        
        [strongSelf reqLullaby];
    });
}

- (void)viewWillDisappear:(BOOL)animated    // 注意：这个控制器使用【单例】
{
    [super viewWillDisappear:animated];
    
    if (YES == self.hasOpenStream)
    {
        [self saveCurDevCover];
    }
    [self recoverViews];
    
    [self postNotifyVideoIsShowing:NO];
}

- (void)viewDidDisappear:(BOOL)animated // 注意：这个控制器使用【单例】
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
}

- (BOOL)willDealloc
{
    return NO;
}

- (void)dealloc // 注意：这个控制器使用【单例】
{
    GosLog(@"GosCheckVideoThread 准备销毁！");
    [self.checkVideoTimer destroy];
    _checkVideoTimer = nil;
    [self.checkTemperatureTimer destroy];
    _checkTemperatureTimer = nil;
    [self.countDownTimer destroy];
    _countDownTimer = nil;
    GosLog(@"GosCheckVideoThread 完成销毁！");
    [self releaseSoundAudioPlayer];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    GosLog(@"---------- IPCPlayViewController dealloc ----------");
}

#pragma mark -- 初始化参数
- (void)initParam
{
    m_isRatioPlay              = YES;
    self.operateAvStreamQueue  = dispatch_queue_create("GosOperateIPCAVStreamQueue", DISPATCH_QUEUE_SERIAL);
    self.operatePlayerSdkQueue = dispatch_queue_create("GosOperateIPCPlayerSdkQueue", DISPATCH_QUEUE_SERIAL);
    self.playAvStreamQueue     = dispatch_queue_create("GosPlayIPCAVStreamQueue", DISPATCH_QUEUE_SERIAL);
    self.opCheckVideoQueue     = dispatch_queue_create("GosCheckVideoDataQueue", DISPATCH_QUEUE_SERIAL);
    self.echoAudioQueue        = dispatch_queue_create("GosEchoAudioDataQueue", DISPATCH_QUEUE_SERIAL);
    
    m_playViewPortraitFrame    = CGRectMake(0, 0, GOS_SCREEN_W, GOS_SCREEN_W * GOS_VIDEO_H_W_SCALE);
    m_playViewLandscapeFrame   = CGRectMake(0, 0, GOS_SCREEN_H, GOS_SCREEN_W);
}

- (void)configUI
{
    self.view.backgroundColor  = GOS_VC_BG_COLOR;
    self.ipcView.offlineTipsLabel.text = DPLocalizedString(@"DeviceOffLine");
    [self.view addSubview:self.countDownView];
    [self.view bringSubviewToFront:self.countDownView];
    [self.countDownView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.view);
        make.width.height.mas_equalTo(100);
    }];
    // 修改逻辑，隐藏该实现(2019-03-08 kuangweiqun)
//    [self.view addSubview:self.fullDuplextalkView];
//    [self.view bringSubviewToFront:self.fullDuplextalkView];
//    [self.fullDuplextalkView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.center.equalTo(self.view);
//        make.width.height.mas_equalTo(120);
//    }];
}

#pragma mark -- 重置参数
- (void)resetParam
{
    m_isOpeningAvStream          = NO;
    m_isClosingAvStream          = NO;
    m_isHiddenCover              = NO;
    m_isHiddenLoading            = NO;
    m_isHiddenPTZView            = YES;
    m_hasCheckVideoQuality       = NO;
    m_curStatus                  = self.devModel.Status;
    m_hasReqLullay               = NO;
    m_isStartHalfDuplex          = NO;
    m_isStartFullDeplex          = NO;
    m_isTalkingOnHalfDuplex      = NO;
    m_isTalkingOnFullDuplex      = NO;
    self.reOpenAvStreamCounts    = 0;
    self.hasOpenStream           = NO;
    self.hasRcvingVideo          = NO;
    self.hasOpenAudio            = NO;
    self.hasStartRecordVideo     = NO;
    self.isPlayLullaby           = NO;
    self.lullabyStatus           = LullabyStatus_unknow;
    self.lullabyNum              = LullabyNum_unknow;
    self.vQuality                = VideoQuality_unknown;
    self.configSdk.paramDelegate = self;
    
    if (DuplexUnknow == self.devModel.devCapacity.duplexType
        || DuplexHalf == self.devModel.devCapacity.duplexType)
    {
        self.isFullDuplex = NO;
    }
    else
    {
        self.isFullDuplex = YES;
    }
    [self activeAudioSessionMode];
}

- (void)resetUI
{
    self.navigationItem.title = self.devModel.DeviceName;;
}

#pragma mark -- 恢复视图
- (void)recoverViews
{
    m_isHiddenPTZView = YES;
    [self.ipcView configPTZViewHidden:m_isHiddenPTZView];
}

#pragma mark -- 释放解码器资源
- (void)releaseSource
{
    [self stopCheckIPCVideoData];
    [self stopCheckTemperature];
    [self.playerSdk releasePlayer];
    self.configSdk.paramDelegate = nil;
    self.playerSdk.delegate      = nil;
    _playerSdk                   = nil;
    self.devSdk.delegate         = nil;
    _devSdk                      = nil;
}

#pragma mark -- 创建 PlayerSDK 对象
- (void)createPplayerSdk
{
    self.playerSdk = [[iOSPlayerSDK alloc] initWithDeviceId:self.devModel.DeviceId
                                                 onPlayView:self.ipcView.videoShowView
                                                  ratioPlay:NO];
    self.playerSdk.delegate = self;
    GOS_WEAK_SELF;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        GOS_STRONG_SELF;
        [strongSelf.playerSdk enableScale:YES
                                 minScale:1.0f
                                 maxScale:4.0f];
    });
}

#pragma mark -- 预加载当前设备封面
- (void)loadCurCover
{
    UIImage *coverImg = [MediaManager coverWithDevId:self.devModel.DeviceId
                                            fileName:nil
                                          deviceType:(GosDeviceType)self.devModel.DeviceType
                                            position:PositionMain];
    dispatch_async(dispatch_get_main_queue(), ^{
       
        self.ipcView.previewImgView.image = coverImg;
        if (YES == m_isRatioPlay)
        {
            self.ipcView.previewImgView.contentMode = UIViewContentModeScaleAspectFit;
        }
        else
        {
            self.ipcView.previewImgView.contentMode = UIViewContentModeScaleToFill;
        }
    });
}

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

#pragma mark -- 设置当前设备封面是否隐藏
- (void)configCoverHidden:(BOOL)isHidden
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        self.ipcView.previewImgView.hidden = isHidden;
    });
}

#pragma mark -- 设置视频加载提示 View 是否隐藏
- (void)configLoadingIndicatorHidden:(BOOL)isHidden
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (NO == isHidden)
        {
            [self.ipcView.loadingIndicator startAnimating];
        }
        else
        {
            [self.ipcView.loadingIndicator stopAnimating];
        }
        m_isHiddenLoading = isHidden;
        self.ipcView.loadingIndicator.hidden = isHidden;
    });
}

#pragma mark -- 设置设备离线提示 Label 是否隐藏
- (void)configOfflineTipsLabelHidden:(BOOL)isHidden
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        self.ipcView.offlineTipsLabel.hidden = isHidden;
    });
}

#pragma mark -- 设置录像提示 View 是否隐藏
- (void)configRecordingViewlHidden:(BOOL)isHidden
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        self.ipcView.recordingView.hidden = isHidden;
    });
}

#pragma mark -- 设置摇篮曲按钮是否隐藏
- (void)configLullabyBtnlHidden:(BOOL)isHidden
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        self.ipcView.lullabyBtn.hidden = isHidden;
    });
}

#pragma mark -- 设置温度提示是否隐藏
- (void)configTemperatureViewHidden:(BOOL)isHidden
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        self.ipcView.tempImgView.hidden = isHidden;
        self.ipcView.tempLabel.hidden   = isHidden;
    });
}

#pragma mark -- 云台按钮是否隐藏
- (void)configPZTHidden:(BOOL)hasPTZ{
    [self.ipcView configHasPTZ:hasPTZ];
}
#pragma mark -- 设置拍照、声音、对讲按钮是否可用
- (void)configButtonEnable:(BOOL)isEnable
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        self.ipcView.audioBtn.enabled    = isEnable;
        self.ipcView.talkbackBtn.enabled = isEnable;
        self.ipcView.snapshotBtn.enabled = isEnable;
        self.ipcView.isOffLine           = isEnable;
    });
}

#pragma mark -- 设置视频质量
- (void)configVideoQuality
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSString *qualityTitle = nil;
        if (VideoQuality_HD == self.vQuality)
        {
            qualityTitle = DPLocalizedString(@"VideoQualityHD");
        }
        else
        {
            qualityTitle = DPLocalizedString(@"VideoQualitySD");
        }
        
        [self.ipcView.videoQualityBtn setTitle:qualityTitle
                                      forState:UIControlStateNormal];
    });
}

#pragma mark -- 设置摇篮曲按钮状态
- (void)configLullabyIcon
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        UIImage *image = nil;
        switch (self.lullabyStatus)
        {
            case LullabyStatus_unknow:
            {
                image = GOS_IMAGE(@"icon_music_off");
            }
                break;
                
            case LullabyStatus_playing:
            {
                image = GOS_IMAGE(@"icon_music_on");
            }
                break;
                
            case LullabyStatus_stop:
            {
                image = GOS_IMAGE(@"icon_music_off");
            }
                break;
                
            default:
                break;
        }
        
        [self.ipcView.lullabyBtn setBackgroundImage:image
                                           forState:UIControlStateNormal];
    });
}


- (void)configTalkBtnIcon:(BOOL)isFullDuplex
      TalkingOnHalfDuplex:(BOOL)isTalkingOnHalfDuplex
             hasConnected:(BOOL)ishasConnected
{
    
}
#pragma mark -- 设置对讲按钮 Icon
- (void)configTalkbackBtnIcon
{
//    dispatch_async(dispatch_get_main_queue(), ^{
//
//        UIImage *img = nil;
//        if (NO == self.isFullDuplex)
//        {
//            if (NO == m_isTalkingOnHalfDuplex)
//            {
//                img = GOS_IMAGE(@"icon_mic_noraml");
//            }
//            else
//            {
//                img = GOS_IMAGE(@"icon_mic_pressed");
//            }
//            if (NO == self.hasConnected)
//            {
//                img = GOS_IMAGE(@"icon_mic_disabled");
//            }
//        }
//        else
//        {
//            if (NO == m_isTalkingOnFullDuplex)
//            {
//                img = GOS_IMAGE(@"icon_hangup_normal");
//                GosLog(@"全双工未在对讲");
//            }
//            else
//            {
//                img = GOS_IMAGE(@"icon_hangup_pressed");
//                GosLog(@"全双工正在对讲");
//            }
//            if (NO == self.hasConnected)
//            {
//                img = GOS_IMAGE(@"icon_hangup_disabled");
//            }
//        }
//        [self.ipcView.talkbackBtn setBackgroundImage:img
//                                            forState:UIControlStateNormal];
//    });
    [self.ipcView configTalkBtnIcon:self.isFullDuplex
                TalkingOnHalfDuplex:m_isTalkingOnFullDuplex
                       hasConnected:_hasConnected];
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
}

#pragma mark -- 通知正在视频播放页面
- (void)postNotifyVideoIsShowing:(BOOL)isShowing
{
    NSDictionary *notifyDict = @{@"IsShowing" : @(isShowing)};
    [[NSNotificationCenter defaultCenter] postNotificationName:kIsVideoShowingNotify
                                                        object:notifyDict];
}

#pragma mark -- 添加当前设备在线状态通知
- (void)addCurDevStatusNotify
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(notifyDeviceStatus:)
                                                 name:kCurPreviewDevStatusNotify
                                               object:nil];
}

#pragma mark -- 添加当前设备连接状态通知（未连接成功时）
- (void)addCurDevConnStatusNotify
{
    GosLog(@"IPCPlayViewController：添加当前设备连接状态通知!");
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(notifyDeviceConnStatus:)
                                                 name:kCurDevConnectingNotify
                                               object:nil];
}

#pragma mark -- 添加设备能力集请求成功通知
- (void)addReqAbilityNotify
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(notifyDeviceAbility:)
                                                 name:kAddAbilityNotify
                                               object:nil];
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
            [self configOfflineTipsLabelHidden:NO];
            [self configLoadingIndicatorHidden:YES];
        }
            break;
            
        case DevStatus_onLine:  // 在线
        {
            if (NO == self.hasOpenStream)   // 处理离线操作：这里打开加载提示，不需重新连接设备，设备列表会自动连接，只需监听连接状态即可
            {
                [self configLoadingIndicatorHidden:NO];
            }
            [self configOfflineTipsLabelHidden:YES];
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
            [self startCheckTemperature];
            [self reqLullaby];
            [self configTalkbackBtnIcon];
        }
            break;
            
        default:
            break;
    }
}

#pragma mark -- 设备能力集
- (void)notifyDeviceAbility:(NSNotification *)notifyData
{
    NSDictionary *recvDict = notifyData.object;
    if (!recvDict || NO == [[recvDict allKeys] containsObject:@"DeviceID"])
    {
        return;
    }
    NSString *deviceId  = recvDict[@"DeviceID"];
    if ([deviceId isEqualToString:self.devModel.DeviceId])
    {
        self.abModel = [DevAbilityManager abilityOfDevice:deviceId];
    }
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


#pragma mark - 手势处理
// 获取侧滑返回手势
- (UIScreenEdgePanGestureRecognizer *)screenEdgePanGestureRecognizer
{
    UIScreenEdgePanGestureRecognizer *screenEdgePanGestureRecognizer = nil;
    if (self.view.gestureRecognizers.count > 0)
    {
        for (UIGestureRecognizer *recognizer in self.view.gestureRecognizers)
        {
            if ([recognizer isKindOfClass:[UIScreenEdgePanGestureRecognizer class]])
            {
                screenEdgePanGestureRecognizer = (UIScreenEdgePanGestureRecognizer *)recognizer;
                break;
            }
        }
    }
    return screenEdgePanGestureRecognizer;
}

#pragma mark -- 激活音频会话模式
- (void)activeAudioSessionMode
{
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    NSError *error               = nil;
    BOOL ret                     = NO;
    if ([self isBlueToothOutput])
    {
        // 设为蓝牙输出
        ret = [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord
                            withOptions:AVAudioSessionCategoryOptionAllowBluetooth
                                  error:&error];
    }
    else
    {
        // 设为扬声器输出
        ret = [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord
                            withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker
                                  error:&error];
    }
    [audioSession setActive:YES error:&error];
    if (NO == ret)
    {
        GosLog(@"激活音频会话模式失败：%@", error.localizedDescription);
    }
    else
    {
        GosLog(@"激活音频会话模式成功！");
    }
}

#pragma mark -- 判断当前是否是蓝牙输出
-(BOOL)isBlueToothOutput
{
    AVAudioSessionRouteDescription *currentRount = [AVAudioSession sharedInstance].currentRoute;
    AVAudioSessionPortDescription *outputPortDesc = currentRount.outputs[0];
    if([self isBluetoothDevice:outputPortDesc.portType])
    {
        GosLog(@"AVAudioSession：当前输出的线路是蓝牙输出，并且已连接");
        return YES;
    }
    else
    {
        GosLog(@"AVAudioSession：当前是扬声器输出");
        return NO;
    }
}

#pragma mark - 是否是蓝牙
- (BOOL)isBluetoothDevice:(NSString *)portType
{
    BOOL isBluetooth = NO;
    if ([portType isEqualToString:AVAudioSessionPortBluetoothA2DP]
        || [portType isEqualToString:AVAudioSessionPortBluetoothHFP])
    {
        isBluetooth = YES;
    }
    return isBluetooth;
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
    [self startCheckICVideoData];
}

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
    if (YES == m_isStartFullDeplex)
    {
        [self.devSdk stopTalkWithDevId:self.devModel.DeviceId];
        [self.playerSdk closeEchoCanceller];
    }
    GosLog(@"准备关闭设备（ID = %@）音视频流！", self.devModel.DeviceId);
    GOS_WEAK_SELF;
    dispatch_async(self.operateAvStreamQueue, ^{
        
        GOS_STRONG_SELF;
        [strongSelf.devSdk closeStreamOfType:DeviceStream_all
                                   withDevId:strongSelf.devModel.DeviceId];
    });
    [self stopCheckIPCVideoData];
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
        [strongSelf.ipcView configSoundBtnIcon:strongSelf.hasOpenAudio];
    });
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
        [strongSelf.ipcView configSoundBtnIcon:strongSelf.hasOpenAudio];
    });
}
#pragma mark -- 显示50秒的倒计时
- (void)showCountDownView
{
    [self createCountDownTimer];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.countDownView.hidden = NO;
        [self.countDownView configView];
        [self.countDownView setNeedsDisplay];
    });
}
#pragma mark -- 隐藏50秒的倒计时
- (void)hiddenCountDownView
{
    [self.countDownTimer destroy];
    self.countDownTimer = nil;
    
    _repeatCount = 0;
    GOS_WEAK_SELF;
    dispatch_async(dispatch_get_main_queue(), ^{
        
        GOS_STRONG_SELF;
        strongSelf.countDownView.remainSeconds = 50;
        strongSelf.countDownView.hidden = YES;
    });
    GosLog(@"没有执行吗 = 倒计时计时器已销毁");
}
//#pragma mark -- 显示全双工的图片
//- (void)showFullDuplextalkView
//{
//    dispatch_async(dispatch_get_main_queue(), ^{
//        self.fullDuplextalkView.hidden = NO;
//    });
//}
//#pragma mark -- 隐藏全双工的图片
//- (void)hiddenFullDuplextalkView
//{
//    dispatch_async(dispatch_get_main_queue(), ^{
//        self.fullDuplextalkView.hidden = YES;
//    });
//}
#pragma mark - 对讲倒计时定时器
- (void)createCountDownTimer
{
    self.countDownTimer = [[GosThreadTimer alloc] initWithInterval:1
                                                         forAction:@selector(countDownTimerDiminish)
                                                           forModl:NSDefaultRunLoopMode
                                                          withName:@"countDownTimerRepeat"
                                                          onTarget:self];
}

#pragma mark - 视频数据检查定时器
#pragma mark -- 创建音视频流检查定时器
- (void)createCheckVideoTimer
{
    GosLog(@"音视频流检查定时器（Thread）准备创建！");
    self.checkVideoTimer = [[GosThreadTimer alloc] initWithInterval:CHECK_VIDEO_INTERVAL
                                                          forAction:@selector(checkIPCVideoData)
                                                            forModl:NSDefaultRunLoopMode
                                                           withName:@"GosCheckIPCVideoThread"
                                                           onTarget:self];
    GosLog(@"音视频流检查定时器（Thread） 完成创建！");
}

#pragma mark -- 开启视频数据监测定时器
- (void)startCheckICVideoData
{
    [self.checkVideoTimer resume];
}

#pragma mark -- 停止视频数据监测定时器
- (void)stopCheckIPCVideoData
{
    [self.checkVideoTimer pause];
}

#pragma mark -- 视频数据定时检查
- (void)checkIPCVideoData
{
    GosLog(@"视频数据定时检查(%@)。。。", [NSThread currentThread]);
    if (NO == self.hasRcvingVideo)
    {
        GosLog(@"当前没有视频数据！");
        if (DevStatus_onLine == self.devModel.Status)
        {
             [self configLoadingIndicatorHidden:NO];
        }
    }
//    self.hasRcvingVideo = NO;
//    [self configButtonEnable:self.hasRcvingVideo];
    GOS_WEAK_SELF;
    dispatch_async(dispatch_get_main_queue(), ^{
        
        GOS_STRONG_SELF;
        [strongSelf performSelector:@selector(configButtonDisable:) withObject:@"test" afterDelay:1.5];
    });
}
- (void)configButtonDisable:(BOOL)enable {
    self.hasRcvingVideo = NO;
    [self configButtonEnable:self.hasRcvingVideo];
}
#pragma mark -- 对讲倒计时
- (void)countDownTimerDiminish
{
    if (!_countDownTimer) {
        _repeatCount = 0;
    }else{
        
        GOS_WEAK_SELF;
        // 正在对讲 半双工
        if(m_isTalkingOnHalfDuplex){
            _repeatCount++;
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.countDownView setNeedsDisplay];
                [weakSelf.countDownView setRemainSeconds:talkTime-weakSelf.repeatCount];
                GosLog(@"没有执行吗？");
            });
            if (weakSelf.repeatCount >= 50) {
                weakSelf.countDownView.remainSeconds = 50;
                [weakSelf hiddenCountDownView];
                dispatch_async(self.operatePlayerSdkQueue, ^{
                    
                    GOS_STRONG_SELF;
                    [strongSelf.playerSdk stopRecordAudio];
                });
                m_isTalkingOnHalfDuplex = NO;
                [self openAudio];
            }
        }
    }
    
    
}
#pragma mark - 设备温度检查定时器
#pragma mark -- 创建温度检查定时器
- (void)createCheckTemperatureTimer
{
    GosLog(@"温度检查定时器（Thread）准备创建！");
    self.checkTemperatureTimer = [[GosThreadTimer alloc] initWithInterval:CHECK_TEMPERATURE_INTERVAL
                                                                forAction:@selector(checkTemperature)
                                                            forModl:NSDefaultRunLoopMode
                                                           withName:@"GosCheckTemperatureThread"
                                                           onTarget:self];
    GosLog(@"温度检查定时器（Thread）完成创建！");
}

#pragma mark -- 开启视频数据监测定时器
- (void)startCheckTemperature
{
    if (YES == self.abModel.hasTemDetect
        && YES == self.hasConnected)
    {
        return;
    }
    GosLog(@"开启温度监测定时器！");
    [self.checkTemperatureTimer resume];
}

#pragma mark -- 停止视频数据监测定时器
- (void)stopCheckTemperature
{
    GosLog(@"暂停温度监测定时器！");
    [self.checkTemperatureTimer pause];
}

#pragma mark -- 设备温度定时检查
- (void)checkTemperature
{
    GosLog(@"设备温度定时检查(%@)。。。", [NSThread currentThread]);
    [self.configSdk reqTemDetectOfDevId:self.devModel.DeviceId];
}

#pragma mark -- 更新温度
- (void)updateTemperature:(TemDetectModel *)tempDetect
{
    if (!tempDetect)
    {
        return;
    }
    NSString *tempType = nil;
    if (Temperature_C == tempDetect)
    {
        tempType = @"°C";
    }
    else
    {
        tempType = @"°F";
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        
        self.ipcView.tempLabel.text = [NSString stringWithFormat:@"%.1f%@", tempDetect.currentTem, tempType];
    });
}

#pragma mark - 摇篮曲
#pragma mark -- 请求摇篮曲播放状态
- (void)reqLullaby
{
    if (LullabyDev_unSupport == self.abModel.lullabyDevType
        || NO == self.hasConnected || YES == m_hasReqLullay)
    {
        GosLog(@"无法请求设备（ID = %@）摇篮曲播放状态；LullabyType：%ld, hasConnected：%d, hasReqLullaby：%d", self.devModel.DeviceId, self.abModel.lullabyDevType, self.hasConnected, m_hasReqLullay);
        return;
    }
    [self.configSdk reqLullabyNumWithDevId:self.devModel.DeviceId];
}

#pragma mark -- 播放摇篮曲
- (void)playLullaby
{
    if (NO == m_hasReqLullay)
    {
        GosLog(@"还未获取到摇篮曲状态信息，无法执行操作");
        return;
    }
    switch (self.lullabyStatus)
    {
        case LullabyStatus_unknow:
        {
            self.isPlayLullaby = NO;
        }
            break;
            
        case LullabyStatus_playing:
        {
            self.isPlayLullaby = NO;
        }
            break;
            
        case LullabyStatus_stop:
        {
            self.isPlayLullaby = YES;
        }
            break;
            
        default:
            break;
    }
    [self.configSdk configSwitch:Switch_lullaby
                           state:self.isPlayLullaby
                       withDevId:self.devModel.DeviceId];
}

#pragma mark - 懒加载
- (iOSDevSDK *)devSdk
{
    if (!_devSdk)
    {
        _devSdk = [iOSDevSDK shareDevSDK];
        _devSdk.delegate = self;
    }
    return _devSdk;
}

- (iOSConfigSDK *)configSdk
{
    if (!_configSdk)
    {
        _configSdk = [iOSConfigSDK shareCofigSdk];
        _configSdk.paramDelegate = self;
    }
    return _configSdk;
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

#pragma mark -- 倒计时提示框(半双工)
- (GosTalkCountDownView *)countDownView
{
    if (!_countDownView)
    {
        _countDownView = [[GosTalkCountDownView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
        _countDownView.hidden = YES;
        [_countDownView setRemainSeconds:talkTime];
    }
    return _countDownView;
}

#pragma mark -- 按住对讲提示图片(全双工)
//- (UIImageView *)fullDuplextalkView
//{
//    if (!_fullDuplextalkView) {
//        _fullDuplextalkView = [[UIImageView alloc]init];
//        _fullDuplextalkView.image = [UIImage imageNamed:@"img_micspeak"];
//        _fullDuplextalkView.hidden = YES;
//    }
//    return _fullDuplextalkView;
//}
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


#pragma mark - iOSPlayerSDKDelegate
#pragma mark -- 录像回调
- (void)deviceId:(NSString *)deviceId
     recordState:(RecordState)rState
      recordTime:(unsigned int)duration
{
    switch (rState)
    {
        case Record_faiure:
        {
            [SVProgressHUD showErrorWithStatus:DPLocalizedString(@"RecordFailure")];
            GosLog(@"设备（ID = %@）开启录像失败！", deviceId);
        }
            break;
            
        case Record_success:
        {
            GosLog(@"设备（ID = %@）开启录像成功！", deviceId);
        }
            break;
            
        case Record_time:
        {
            GosLog(@"设备（ID = %@）录像时长：%d", deviceId, duration);
        }
            break;
            
        case Record_end:
        {
            [SVProgressHUD showSuccessWithStatus:DPLocalizedString(@"RecordSuccess")];
            GosLog(@"设备（ID = %@）录像结束！", deviceId);
        }
            break;
            
        default:
            break;
    }
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
}

#pragma mark -- 回音消除数据回调
- (void)echoCancelData:(unsigned char*)audioBuf
                  size:(unsigned int)size
{
    GOS_WEAK_SELF;
    dispatch_async(self.echoAudioQueue, ^{
        
        GOS_STRONG_SELF;
        [strongSelf.devSdk sendTalkData:audioBuf
                                   size:size
                              withDevId:self.devModel.DeviceId];
    });
}

#pragma mark -- Swipe 手势回调
- (void)swipeGesDirection:(SwipeGesDirection)sDirection
                moveSpace:(CGFloat)mSpace
{
    if (NO == self.abModel.hasPTZ)
    {
        return;
    }
    switch (sDirection)
    {
        case SwipeGes_up:
        {
            [self.devSdk ptzCtrTurnTo:PTZCtrTurn_up
                            withDevId:self.devModel.DeviceId];
        }
            break;
            
        case SwipeGes_down:
        {
            [self.devSdk ptzCtrTurnTo:PTZCtrTurn_down
                            withDevId:self.devModel.DeviceId];
        }
            break;
            
        case SwipeGes_left:
        {
            [self.devSdk ptzCtrTurnTo:PTZCtrTurn_left
                            withDevId:self.devModel.DeviceId];
        }
            break;
            
        case SwipeGes_right:
        {
            [self.devSdk ptzCtrTurnTo:PTZCtrTurn_right
                            withDevId:self.devModel.DeviceId];
        }
            break;
            
        default:
            break;
    }
}


#pragma mark - iOSDevSDKDelegate
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
                        self.reOpenAvStreamCounts = 0;
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
//    GosPrintf("视频数据-deviceId:%s, length:%d, frameNo:%d, timeStamp:%d, frameRate:%d, frameType:%ld, avchannel:%d\n", deviceId.UTF8String, dLen, frameNo, timeStamp, fRate, (long)fType, avChn);
    
    if (NO == m_isHiddenCover && VideoFrame_iFrame == fType)
    {
        GOS_WEAK_SELF;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            GOS_STRONG_SELF;
            [strongSelf configCoverHidden:YES];
        });
        m_isHiddenCover = YES;
    }
    if (NO == m_isHiddenLoading && VideoFrame_iFrame == fType)
    {
        GOS_WEAK_SELF;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            GOS_STRONG_SELF;
            [strongSelf configLoadingIndicatorHidden:YES];
        });
        m_isHiddenLoading = YES;
    }
    if (NO == m_hasCheckVideoQuality)
    {
        GOS_WEAK_SELF;
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            
            GOS_STRONG_SELF;
            [strongSelf.devSdk checkQualityWithDevId:strongSelf.devModel.DeviceId];
        });
        m_hasCheckVideoQuality = YES;
    }
    self.hasRcvingVideo = YES;  // 标识有视频数据
    dispatch_async(dispatch_get_main_queue(), ^{
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(configButtonDisable:) object:@"test"];
        
    });
    // 更新不在线状态（这里目的是为了解决点击推送消息进入预览界面，导致设备在线状态不准确问题，但理论上不应该这样判断，只是临时方法）
    if (DevStatus_onLine != self.devModel.Status)
    {
        self.devModel.Status = DevStatus_onLine;
        [self configOfflineTipsLabelHidden:YES];
    }
    
    // 更新 UI
    [self configButtonEnable:self.hasRcvingVideo];
    
    // 视频渲染
    NSData *videoData = [NSData dataWithBytes:vBuffer length:dLen];
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
}

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
//    GosPrintf("音频数据-deviceId:%s, lenght:%d, frameNo:%d, codeType:%ld\n", deviceId.UTF8String, dLen, frameNo, acType);
    
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
        GosLog(@"查询设备（ID = %@）视频质量成功，质量：%ld", deviceId, vqType);
        self.vQuality = vqType;
        [self configVideoQuality];
    }
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
            m_isStartFullDeplex = YES;
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
            m_isStartFullDeplex = NO;
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
    [self configTalkbackBtnIcon];
}


#pragma mark - iOSConfigSDKParamDelegate
#pragma mark -- 温度回调
- (void)reqTemDetect:(BOOL)isSuccess
            deviceId:(NSString *)devId
         detectParam:(TemDetectModel *)tDetect
{
    if (IS_EMPTY_STRING(devId)
        || NO == [devId isEqualToString:self.devModel.DeviceId]
        || !tDetect)
    {
        return;
    }
    if (NO == isSuccess)
    {
        GosLog(@"检查设备（ID = %@）当前温度失败！", devId);
    }
    else
    {
        GosLog(@"检查设备（ID = %@）当前温度成功！", devId);
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
           
            [self updateTemperature:tDetect];
        });
    }
}

#pragma mark -- 请求摇篮曲播放序号、播放状态结果回调
- (void)reqLullaby:(BOOL)isSuccess
            number:(LullabyNumber)lNum
        playStatus:(LullabyStatus)lStatus
          deviceId:(NSString *)devId
{
    if (IS_EMPTY_STRING(devId)
        || NO == [devId isEqualToString:self.devModel.DeviceId])
    {
        return;
    }
    if (NO == isSuccess)
    {
        GosLog(@"查询设备（ID = %@）摇篮曲状态信息失败！", devId);
    }
    else
    {
        GosLog(@"查询设备（ID = %@）摇篮曲信息成功，number：%ld, status：%ld", devId, lNum, lStatus);
        m_hasReqLullay     = YES;
        self.lullabyNum    = lNum;
        self.lullabyStatus = lStatus;
        [self configLullabyIcon];
    }
}

#pragma mark -- 设置摇篮曲开关状态结果回调
- (void)configSwitch:(BOOL)isSuccess
                type:(SwitchType)sType
            deviceId:(NSString *)devId
{
    if (IS_EMPTY_STRING(devId)
        || NO == [devId isEqualToString:self.devModel.DeviceId])
    {
        return;
    }
    switch (sType)
    {
        case Switch_lullaby:
        {
            if (NO == isSuccess)
            {
                GosLog(@"设置设备（ID = %@）摇篮曲播放状态失败！", devId);
                [SVProgressHUD showErrorWithStatus:DPLocalizedString(@"GosComm_Set_Failed")];
            }
            else
            {
                GosLog(@"设置设备（ID = %@）摇篮曲播放状态成功！", devId);
                if (YES == self.isPlayLullaby)
                {
                    self.lullabyStatus = LullabyStatus_playing;
                }
                else
                {
                    self.lullabyStatus = LullabyStatus_stop;
                }
                [self configLullabyIcon];
            }
        }
            break;
            
        default:
            break;
    }
}


#pragma mark - IPCPlayViewDelegate
#pragma mark -- 摇篮曲按钮点击事件回调
- (void)lullabyBtnAction
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        [self playLullaby];
    });
}

#pragma mark -- 录像按钮点击事件回调
- (void)recordVideoBtnAction
{
    GosLog(@"录像按钮事件！");
    [self playRecordSound];
    self.hasStartRecordVideo = !self.hasStartRecordVideo;
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
            [strongSelf.ipcView configRecordSelect:NO];
            [strongSelf.ipcView configRecoringLabeHidden:YES];
        });
        
    }
    else    // 开启录像
    {
        NSString *recordPath = [MediaManager pathWithDevId:self.devModel.DeviceId
                                                  fileName:nil
                                                 mediaType:GosMediaRecord
                                                deviceType:GosDeviceIPC
                                                  position:PositionMain];
        if (IS_EMPTY_STRING(recordPath))
        {
            GosLog(@"文件路径不存在，无法录像！");
            return;
        }
        if (!_recordVideoTimer)
        {
            _recordVideoTimer = [[GosThreadTimer alloc] initWithInterval:1.0
                                                               forAction:@selector(recorVideoAction)
                                                                 forModl:NSDefaultRunLoopMode
                                                                withName:@"GosRecordVideo"
                                                                onTarget:self];
        }
        GOS_WEAK_SELF;
        dispatch_async(self.operatePlayerSdkQueue, ^{
            
            GOS_STRONG_SELF;
            [strongSelf.ipcView configRecordSelect:YES];
            [strongSelf.ipcView configRecoringLabeHidden:NO];
            [strongSelf.playerSdk startRecordVideoAtPath:recordPath
                                                deviceId:strongSelf.devModel.DeviceId];
        });
    }
}

#pragma mark -- 控制台 View 显示按钮点击事件回调
- (void)ptzViewBtnAction
{
    if (NO == self.abModel.hasPTZ)
    {
        return;
    }
    GosLog(@"控制台 View 显示按钮事件！");
    m_isHiddenPTZView = !m_isHiddenPTZView;
    [self.ipcView configPTZViewHidden:m_isHiddenPTZView];
}

#pragma mark -- 视频质量切换按钮点击事件回调
- (void)videoQualityBtnAction
{
    GosLog(@"视频质量切换按钮事件！");
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

#pragma mark -- 声音按钮点击事件回调
- (void)audioBtnAction
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

#pragma mark - 对讲按钮点击事件回调
#pragma mark -- 对讲按钮'TouchDown'事件回调
- (void)talkbackBtnTouchDownAction
{
    GosLog(@"对讲按钮'TouchDown'事件！");
    if (NO == self.isFullDuplex)    // 半双工
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
        [self showCountDownView];       //  显示50秒的倒计时
        GosLog(@"对讲按钮 半双工按下");
    }
    else    // 全双工
    {
        
    }
    [self configTalkbackBtnIcon];
}

#pragma mark -- 对讲按钮'TouchDragExit'事件回调
- (void)talkbackBtnToucDragExitAction
{
    GosLog(@"对讲按钮'TouchDragExit'事件！");
    if (NO == self.isFullDuplex)    // 半双工
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
    else    // 全双工
    {
        
    }
    [self configTalkbackBtnIcon];
}

#pragma mark -- 对讲按钮'TouchUpInside'事件回调
- (void)talkbackBtnAction
{
    GosLog(@"对讲按钮'TouchUpInside'事件！");

    if (NO == self.isFullDuplex)    // 半双工
    {
        GOS_WEAK_SELF;
        dispatch_async(self.operatePlayerSdkQueue, ^{
            
            GOS_STRONG_SELF;
            [strongSelf.playerSdk stopRecordAudio];
        });
        m_isTalkingOnHalfDuplex = NO;
        [self hiddenCountDownView];
        [self openAudio];
    }
    else    // 全双工
    {
        if (NO == m_isStartFullDeplex)
        {
            [self.playerSdk openEchoCanceller];
            [self.devSdk startTalkWithDevId:self.devModel.DeviceId];
            [self openAudio];
            m_isTalkingOnFullDuplex = NO;
//            [self hiddenFullDuplextalkView];
        }
        else
        {
            [self closeAudio];
            [self.devSdk stopTalkWithDevId:self.devModel.DeviceId];
            [self.playerSdk closeEchoCanceller];
            m_isTalkingOnFullDuplex = YES;
//            [self showFullDuplextalkView];
        }
    }
    [self configTalkbackBtnIcon];
}

#pragma mark -- 拍照按钮点击事件回调
- (void)snapshotBtnAction
{
    NSString *snapshotPath = [MediaManager pathWithDevId:self.devModel.DeviceId
                                                fileName:nil
                                               mediaType:GosMediaSnapshot
                                              deviceType:GosDeviceIPC
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

#pragma mark -- 云台转动控制按钮事件回调
- (void)ptzBtnAction:(GosPTZDirection)direction
{
    GosLog(@"云台转动（方向：%ld)控制按钮事件！", direction);
    switch (direction)
    {
        case GosPTZD_left:
        {
            [self.devSdk ptzCtrTurnTo:PTZCtrTurn_left
                            withDevId:self.devModel.DeviceId];
        }
            break;
            
        case GosPTZD_right:
        {
            [self.devSdk ptzCtrTurnTo:PTZCtrTurn_right
                            withDevId:self.devModel.DeviceId];
        }
            break;
            
        case GosPTZD_up:
        {
            [self.devSdk ptzCtrTurnTo:PTZCtrTurn_up
                            withDevId:self.devModel.DeviceId];
        }
            break;
            
        case GosPTZD_down:
        {
            [self.devSdk ptzCtrTurnTo:PTZCtrTurn_down
                            withDevId:self.devModel.DeviceId];
        }
            break;
            
        default:
            break;
    }
}


#pragma mark - SYFullScreenViewDeleaget
- (void)curDevOrientation:(UIDeviceOrientation)orientation
{
    if (UIDeviceOrientationLandscapeLeft == orientation
        || UIDeviceOrientationLandscapeRight == orientation) // 横屏
    {
        [self.playerSdk resize:m_playViewLandscapeFrame.size];
    }
    else
    {
        [self.playerSdk resize:m_playViewPortraitFrame.size];
    }
}

@end
