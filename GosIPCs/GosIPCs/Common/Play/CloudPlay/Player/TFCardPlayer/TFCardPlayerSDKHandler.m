//  TFCardPlayerSDKHandler.m
//  GosIPCs
//
//  Create by daniel.hu on 2019/2/19.
//  Copyright © 2019年 goscam. All rights reserved.

#import "TFCardPlayerSDKHandler.h"
#import "GosDevManager.h"
#import "iOSConfigSDK.h"
#import "iOSDevSDK.h"
#import "iOSPlayerSDK.h"
#import <AVFoundation/AVFoundation.h>

/**
 操作状态
 */
typedef NS_ENUM(NSUInteger, GosPlayerOperateState) {
    /// 关闭
    GosPlayerOperateStateClose,
    /// 开启
    GosPlayerOperateStateOpen,
    /// 正在开启
    GosPlayerOperateStateOpening,
    /// 正在关闭
    GosPlayerOperateStateClosing,
};

@interface TFCardPlayerSDKHandler () <iOSDevSDKDelegate, iOSPlayerSDKDelegate, iOSDevOperateDelegate>
#pragma mark - SDK相关参数
/// device sdk
@property (nonatomic, strong) iOSDevSDK *devSDK;
/// player sdk
@property (nonatomic, strong) iOSPlayerSDK *playerSDK;
/// 设备id
@property (nonatomic, copy) NSString *deviceId;
/// 播放视图
@property (nonatomic, weak) UIView *playView;

#pragma mark - signal parameters
/// 是否正在播放
@property (nonatomic, assign, getter=isPlaying) BOOL playing;
/// 是否开启声音
@property (nonatomic, assign, getter=isOpenVoice) BOOL openVoice;
/// 操作拉流状态
@property (nonatomic, assign) GosPlayerOperateState operateStreamState;
/// 已连接设备，拉流失败再次重新拉流次数
@property (nonatomic, assign) NSInteger reOpenAvStreamCounts;

#pragma mark - 播放相关参数
/// 播放时间戳
@property (nonatomic, assign) NSTimeInterval playStartTimestamp;
/// 播放中时间戳
@property (nonatomic, assign) NSTimeInterval playingTimestamp;

#pragma mark - 预览图相关参数
/// 预览图的时间戳
@property (nonatomic, assign) NSTimeInterval previewTimestamp;
/// 预览图存储路径
@property (nonatomic, copy) NSString *previewImageFilePath;

#pragma mark - 剪切相关参数
/// 剪切存储路径
@property (nonatomic, copy) NSString *clipVideoFilePath;
/// 剪切开始时间戳
@property (nonatomic, assign) NSTimeInterval clipStartTimestamp;
/// 剪切时长
@property (nonatomic, assign) NSUInteger clipDuration;

#pragma mark - 截图相关参数
/// 拍照按钮点击声音 播放器
@property (nonatomic, strong) AVAudioPlayer *snapshotAudioPlayer;


#pragma mark - QUEUE
/// 控制音视频流队列（串行）
@property (nonatomic, readwrite, strong) dispatch_queue_t operateStreamQueue;
/// 控制声音队列（串行）
@property (nonatomic, readwrite, strong) dispatch_queue_t operateVoiceQueue;
/// 播放音视频回调数据队列（串行）
@property (nonatomic, readwrite, strong) dispatch_queue_t decodeAndPlayStreamQueue;
/// 正在播放队列
@property (nonatomic, readwrite, strong) dispatch_queue_t playingStreamQueue;
/// 播放缓存中队列
@property (nonatomic, readwrite, strong) dispatch_queue_t playStartLoadingQueue;
/// 播放结束缓存中队列
@property (nonatomic, readwrite, strong) dispatch_queue_t playEndedLoadingQueue;
/// 操作截图队列
@property (nonatomic, readwrite, strong) dispatch_queue_t operateSnapshotQueue;

@end

@implementation TFCardPlayerSDKHandler
#pragma mark - initialization
- (instancetype)initWithDeviceId:(NSString *)deviceId
                        playView:(UIView *)playView {
    if (self = [super init]) {
        
        _deviceId = deviceId;
        _playView = playView;
        
        // 初始化数据
        [self initialPlayer];
        
        [self playerSDK];
    }
    return self;
}

- (void)dealloc {
    // 移除观察者
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    GosLog(@"--------- TFCardPlayerSDKHandler dealloc --------------");
}

- (void)initialPlayer {
    self.playStartTimestamp = 0;
    self.reOpenAvStreamCounts = 0;
    self.operateStreamState = GosPlayerOperateStateClose;
    self.openVoice = NO;
    self.playing = NO;
    self.playStartTimestamp = 0;
    self.clipVideoFilePath = nil;
    self.clipStartTimestamp = 0;
    self.clipDuration = 0;
    self.playingTimestamp = 0;
    
    self.operateStreamQueue = dispatch_queue_create("DevSDKOperateStream", DISPATCH_QUEUE_SERIAL);
    self.operateVoiceQueue = dispatch_queue_create("DevSDKOperateVoice", DISPATCH_QUEUE_SERIAL);
    self.decodeAndPlayStreamQueue = dispatch_queue_create("PlayerSDKDecodeAndPlayStream", DISPATCH_QUEUE_SERIAL);
    self.playingStreamQueue = dispatch_queue_create("PlayerSDKPlayingStream", DISPATCH_QUEUE_SERIAL);
    self.playStartLoadingQueue = dispatch_queue_create("PlayerSDKPlayStartLoading", DISPATCH_QUEUE_SERIAL);
    self.playEndedLoadingQueue = dispatch_queue_create("PlayerSDKPlayEndedLoading", DISPATCH_QUEUE_SERIAL);
    self.operateSnapshotQueue = dispatch_queue_create("PlayerSDKOperateSnapshot", DISPATCH_QUEUE_SERIAL);
    
    // 监听设备在线状态通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedDeviceStatusNotification:)
                                                 name:kCurPreviewDevStatusNotify
                                               object:nil];
    // 监听设备连接状态通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedDeviceConnectStatusNotification:)
                                                 name:kCurDevConnectingNotify
                                               object:nil];
    // 监听app进入后台通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedEnterForegroundNotification:)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
    // 监听app进入活动状态通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedEnterBackgroundNotification:)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    
}

- (void)resetPlayer {
    // 清除三个重要标记
    self.playStartTimestamp = 0;
    self.clipStartTimestamp = 0;
    self.previewTimestamp = 0;
    
    // 清理截图音效
    [self releaseSnapshotSoundEffect];
    // 关闭声音
    [self ps_closeVoiceWithDeviceId:_deviceId];
    // 关闭tfcard 命令
    [self ds_stopCommandWithDeviceId:_deviceId];
    // 关流
    [self ds_closeStreamWithDeviceId:_deviceId];
    // 释放devSDK
    [self ds_releaseDeviceSDK];
    // 释放playerSDK
    [self ps_releasePlayerSDK];
}

#pragma mark - public method
/// 初始化
- (void)sdk_handler_initialPlayer {
    
    DevStatusType status = [self dm_fetchDeviceStatusTypeWithDeviceId:_deviceId];
    DeviceConnState connectState = [self dm_fetchDeviceConnStateWithDeviceId:_deviceId];
    
    // 发出当前在线状态、
    if (_delegate && [_delegate respondsToSelector:@selector(sdk_handler:deviceId:didChangedDeviceState:connectState:)]) {
        [_delegate sdk_handler:self deviceId:_deviceId didChangedDeviceState:status connectState:connectState];
    }
    
    // 如果存在播放中的数据，就开始播放
    GosLog(@"daniel: 初始化TFSDK——%@", _playingTimestamp != 0?@"开始播放":@"初次开始不播放");
    if (_playingTimestamp != 0) {
        [self sdk_handler_startPlayWithStartTimestamp:_playingTimestamp];
    }

}

/// 开始播放
- (void)sdk_handler_startPlayWithStartTimestamp:(NSTimeInterval)startTimestamp {
    switch (self.operateStreamState) {
            // 流已开
        case GosPlayerOperateStateOpen: {
            // 已经开流，就直接播放
            _playStartTimestamp = startTimestamp;
            // 播放
            [self dh_startPlaybackWithDeviceId:_deviceId
                                startTimestamp:startTimestamp];
            break;
        }
           // 流已关
        case GosPlayerOperateStateClose: {
            // 已经关流，就记录时间戳并尝试开流
            _playStartTimestamp = startTimestamp;
            
            // 关闭就尝试开流
            [self sdk_handler_openStream];
            break;
        }
            // 流开启中
        case GosPlayerOperateStateOpening: {
            GosLog(@"daniel: 播放等待：流操作正处于 开启中");
            _playStartTimestamp = startTimestamp;
            break;
        }
            // 关闭中
        case GosPlayerOperateStateClosing: {
            // 理论上不会进入此处——主动关流并开始播放
            GosLog(@"daniel: 播放失败原因：流操作正处于 关闭中");
            break;
        }
        default:
            break;
    }
    
}

/// 获取预览图
- (void)sdk_handler_fetchPreviewWithImageFilePath:(NSString *)imageFilePath
                                      atTimestamp:(NSTimeInterval)timestamp {
    // 只能在流开的状态下获取预览图
    switch (self.operateStreamState) {
        case GosPlayerOperateStateOpen:
            // 记录预览图相关数据
            _previewTimestamp = timestamp;
            _previewImageFilePath = imageFilePath;
            
            // 获取预览图
            [self dh_fetchPreviewWithDeviceId:_deviceId
                                imageFilePath:imageFilePath
                                    timestamp:timestamp];
            break;
        case GosPlayerOperateStateClose:
            // 记录预览图相关数据
            _previewTimestamp = timestamp;
            _previewImageFilePath = imageFilePath;
            
            // 关闭就尝试开流
            [self sdk_handler_openStream];
            break;
        case GosPlayerOperateStateClosing:
            GosLog(@"daniel: 获取预览图失败：流操作正处于 关闭中");
            break;
        case GosPlayerOperateStateOpening:
            // 记录预览图相关数据
            _previewTimestamp = timestamp;
            _previewImageFilePath = imageFilePath;
            break;
        default:
            break;
    }
}

/// 剪切
- (void)sdk_handler_startClipWithVideoFilePath:(NSString *)videoFilePath
                                startTimestamp:(NSTimeInterval)startTimestamp
                                      duration:(NSUInteger)duration {
    // 路径错误
    if (IS_EMPTY_STRING(videoFilePath)) {
        GosLog(@"剪切失败：文件路径不存在，无法剪切");
        if (_delegate && [_delegate respondsToSelector:@selector(sdk_handler:deviceId:didClipAtVideoFilePath:startTimestamp:duration:isSucceed:)]) {
            [_delegate sdk_handler:self
                          deviceId:_deviceId
            didClipAtVideoFilePath:videoFilePath
                    startTimestamp:startTimestamp
                          duration:duration
                         isSucceed:NO];
        }
        return ;
    }
    
    switch (self.operateStreamState) {
            // 流已开启
        case GosPlayerOperateStateOpen: {
            // 记录剪切相关数据
            _clipVideoFilePath = videoFilePath;
            _clipStartTimestamp = startTimestamp;
            _clipDuration = duration;
            
            // 开始剪切
            [self dh_startClipWithDeviceId:_deviceId
                             videoFilePath:videoFilePath
                            startTimestamp:startTimestamp
                                  duration:duration];
            break;
        }
            // 流已关闭
        case GosPlayerOperateStateClose: {
            // 记录剪切相关数据
            _clipVideoFilePath = videoFilePath;
            _clipStartTimestamp = startTimestamp;
            _clipDuration = duration;
            
            // 关闭就尝试开流
            [self sdk_handler_openStream];
            break;
        }
        case GosPlayerOperateStateClosing: {
            GosLog(@"daniel: 开始剪切失败：流操作正处于 关闭中");
            break;
        }
        case GosPlayerOperateStateOpening: {
            GosLog(@"daniel: 剪切等待：流操作正处于 开启中");
            // 记录剪切相关数据
            _clipVideoFilePath = videoFilePath;
            _clipStartTimestamp = startTimestamp;
            _clipDuration = duration;
            break;
        }
        default:
            break;
    }
    
    // TODO: 开启剪切过程中 如果还未开启流，那么开启 定时器判断一定时间内是否开启流，执行剪切操作，如果不行，那么就关闭流
}

/// 获取截图
- (void)sdk_handler_snapshotWithImageFilePath:(NSString *)imageFilePath {
    // 路径错误
    if (IS_EMPTY_STRING(imageFilePath)) {
        GosLog(@"截图失败：文件路径不存在，无法截图");
        if (_delegate && [_delegate respondsToSelector:@selector(sdk_handler:deviceId:didSnapshotAtImageFilePath:isSucceed:)]) {
            [_delegate sdk_handler:self
                          deviceId:_deviceId
        didSnapshotAtImageFilePath:imageFilePath
                         isSucceed:NO];
        }
        return ;
    }
    // 未正在播放
    if (!self.isPlaying) {
        GosLog(@"截图失败：没有正在播放TF流");
        if (_delegate && [_delegate respondsToSelector:@selector(sdk_handler:deviceId:didSnapshotAtImageFilePath:isSucceed:)]) {
            [_delegate sdk_handler:self
                          deviceId:_deviceId
        didSnapshotAtImageFilePath:imageFilePath
                         isSucceed:NO];
        }
        return ;
    }
    
    GOS_WEAK_SELF
    dispatch_async(self.operateSnapshotQueue, ^{
        GOS_STRONG_SELF
        // 播放音效
        [strongSelf playSnapshotSoundEffect];
        // 截图
        BOOL ret = [strongSelf dh_saveSnapshotWithDeviceId:strongSelf.deviceId imageFilePath:imageFilePath];
        GosLog(@"截图操作结果：%@", ret?@"成功":@"失败");
        
        
        if (strongSelf.delegate && [strongSelf.delegate respondsToSelector:@selector(sdk_handler:deviceId:didSnapshotAtImageFilePath:isSucceed:)]) {
            [strongSelf.delegate sdk_handler:strongSelf
                                    deviceId:strongSelf.deviceId
                  didSnapshotAtImageFilePath:imageFilePath
                                   isSucceed:ret];
        }
    });
}

/// 开声音
- (void)sdk_handler_openVoice {
    if (_openVoice) {
        GosLog(@"daniel: 已经开启音频，无需再次开启");
        return ;
    }
    
    GOS_WEAK_SELF
    dispatch_async(self.operateVoiceQueue, ^{
        GOS_STRONG_SELF
        [strongSelf dh_openVoiceWithDeviceId:strongSelf.deviceId];
        strongSelf.openVoice = YES;
    });
}

/// 关声音
- (void)sdk_handler_closeVoice {
    if (!_openVoice) {
        GosLog(@"daniel: 已经关闭音频，无需再次关闭");
        return ;
    }
    
    GOS_WEAK_SELF
    dispatch_async(self.operateVoiceQueue, ^{
        GOS_STRONG_SELF
        [strongSelf dh_closeVoiceWithDeviceId:strongSelf.deviceId];
        strongSelf.openVoice = NO;
    });
}

/// 销毁播放器
- (void)sdk_handler_destoryPlayer {
    GosLog(@"daniel: 清理TFCardPlayerSDKHandler");
    [self resetPlayer];
}

/// 开流
- (void)sdk_handler_openStream {
    if (_operateStreamState == GosPlayerOperateStateOpening) {
        GosLog(@"daniel: 正在开启音视频流，请稍后重试");
        return ;
    }
    
    // 设定状态——正在打开音视频流
    _operateStreamState = GosPlayerOperateStateOpening;
    
    GOS_WEAK_SELF
    dispatch_async(self.operateStreamQueue, ^{
        GOS_STRONG_SELF
        [strongSelf dh_openStreamWithDeviceId:strongSelf.deviceId];
    });
}

/// 关流
- (void)sdk_handler_closeSteam {
    if (_operateStreamState == GosPlayerOperateStateClosing) {
        GosLog(@"daniel: 正在关闭音视频流，请稍后重试");
        return ;
    }
    
    // 设定状态——正在关闭音视频流
    _operateStreamState = GosPlayerOperateStateClosing;
    
    GOS_WEAK_SELF
    dispatch_async(self.operateStreamQueue, ^{
        GOS_STRONG_SELF
        // 关流
        [strongSelf ds_closeStreamWithDeviceId:strongSelf.deviceId];
    });
}

/// 重置尺寸
- (void)sdk_handler_resize:(CGSize)size {
    [self ps_resize:size];
}


#pragma mark - notification method
/** 接收到连接状态的改变的通知 */
- (void)receivedDeviceConnectStatusNotification:(NSNotification *)sender {
    NSDictionary *recvDict = sender.object;
    // 没有我要的数据就不管它
    if (!recvDict
        || ![recvDict objectForKey:@"DeviceID"]
        || ![recvDict objectForKey:@"ConnStatus"]) {
        return;
    }
    // 数据不是我要的也不管它
    if (![recvDict[@"DeviceID"] isEqualToString:_deviceId]) { return; }
    
    // 设备id
    NSString *deviceId  = recvDict[@"DeviceID"];
    // 连接状态
    NSNumber *statusObj = recvDict[@"ConnStatus"];
    DeviceConnState connStatus = (DeviceConnState)[statusObj integerValue];
    
    // 非连接状态都标记为关流状态
    if (connStatus != DeviceConnSuccess) {
        GosLog(@"daniel: 非连接状态导致的关流");
        self.operateStreamState = GosPlayerOperateStateClose;
    }
    
    switch (connStatus) {
        case DeviceConnSuccess: {   // 连接成功
            GosLog(@"daniel: 当前预览设备（ID = %@）建立连接成功！", deviceId);
            // 尝试开流
            if (self.operateStreamState == GosPlayerOperateStateClose) {
                [self sdk_handler_openStream];
            }
            break;
        }
        case DeviceConnUnConn: {    // 未连接
            GosLog(@"daniel: 当前预览设备（ID = %@）没有建立连接！", deviceId);
            break;
        }
        case DeviceConnFailure: {   // 连接失败
            GosLog(@"daniel: 当前预览设备（ID = %@）建立连接失败！", deviceId);
            break;
        }
        case DeviceConnecting: {    // 正在连接
            GosLog(@"daniel: 当前预览设备（ID = %@）正在建立连接！", deviceId);
            break;
        }
            
        default:
            break;
    }
    
    // 发出连接连接状态代理
    if (_delegate && [_delegate respondsToSelector:@selector(sdk_handler:deviceId:didChangedDeviceState:connectState:)]) {
        DevStatusType deviceState = [self dm_fetchDeviceStatusTypeWithDeviceId:_deviceId];
        [_delegate sdk_handler:self
                      deviceId:deviceId
         didChangedDeviceState:deviceState
                  connectState:connStatus];
    }
}

/** 接收到在线状态的改变的通知 */
- (void)receivedDeviceStatusNotification:(NSNotification *)sender {
    NSDictionary *recvDict = sender.object;
    // 没有我要的数据就不管它
    if (!recvDict
        || ![recvDict objectForKey:@"DeviceID"]
        || ![recvDict objectForKey:@"Status"]) {
        return;
    }
    // 数据不是我要的也不管它
    if (![recvDict[@"DeviceID"] isEqualToString:_deviceId]) { return; }
    
    // 设备id
    NSString *deviceId  = recvDict[@"DeviceID"];
    // 在线状态
    NSNumber *statusObj = recvDict[@"Status"];
    DevStatusType devStatus = (DevStatusType)[statusObj integerValue];
    
    switch (devStatus) {
        case DevStatus_onLine: {    // 在线
            // 处理离线操作：这里打开加载提示，不需重新连接设备，设备列表会自动连接，只需监听连接状态即可
            
            break;
        }
        case DevStatus_sleep:       // 睡眠
        case DevStatus_offLine: {   // 离线
            GosLog(@"daniel: 因%@导致的关流", devStatus==DevStatus_offLine?@"离线":@"睡眠");
            self.operateStreamState = GosPlayerOperateStateClose;
            
            break;
        }
        default:
            break;
    }
    
    // 发出在线状态的改变的代理
    if (_delegate && [_delegate respondsToSelector:@selector(sdk_handler:deviceId:didChangedDeviceState:connectState:)]) {
        DeviceConnState connState = [self dm_fetchDeviceConnStateWithDeviceId:_deviceId];
        [_delegate sdk_handler:self
                      deviceId:deviceId
         didChangedDeviceState:devStatus
                  connectState:connState];
    }
}

/** 进入前台 */
- (void)receivedEnterForegroundNotification:(NSNotification *)sender {
    // 开启声音
    [self sdk_handler_openVoice];
    // 开流
    [self sdk_handler_openStream];
}

/** 进入后台 */
- (void)receivedEnterBackgroundNotification:(NSNotification *)sender {
    // 关闭声音
    [self sdk_handler_closeVoice];
    // 关流
    [self sdk_handler_closeSteam];
    
}


#pragma mark - iOSDevSDKDelegate
/** 开流回调 */
- (void)deviceId:(NSString *)deviceId
 openStreamState:(OpenStreamState)sState
       errorType:(StreamErrorType)errType {
    // 非当前设备id不处理
    if (IS_EMPTY_STRING(deviceId)
        || ![deviceId isEqualToString:_deviceId]) {
        return;
    }
    
    switch (sState) {
        case OpenStreamUnknown:     // 未知
        case OpenStreamFailure: {   // 打开音视频流失败
            // 标记开流状态为关闭
            self.operateStreamState = GosPlayerOperateStateClose;
            
            switch (errType) {
                case StreamError_disConn: { // 设备未连接成功导致开流失败
                    GosLog(@"daniel: 打开设备（ID = %@）音视频流失败，原因：设备未连接成功", deviceId);
                    // 更新状态
                    if (_delegate && [_delegate respondsToSelector:@selector(sdk_handler:deviceId:didChangedDeviceState:connectState:)]) {
                        DevStatusType statusType = [self dm_fetchDeviceStatusTypeWithDeviceId:_deviceId];
                        DeviceConnState connState = [self dm_fetchDeviceConnStateWithDeviceId:_deviceId];
                        [_delegate sdk_handler:self
                                      deviceId:_deviceId
                         didChangedDeviceState:statusType
                                  connectState:connState];
                    }
                    
                    // _clipStartTimestamp != 0 表示正在尝试剪切操作
                    if (_clipStartTimestamp != 0) {
                        if (_delegate && [_delegate respondsToSelector:@selector(sdk_handler:deviceId:didClipAtVideoFilePath:startTimestamp:duration:isSucceed:)]) {
                            [_delegate sdk_handler:self
                                          deviceId:_deviceId
                            didClipAtVideoFilePath:_clipVideoFilePath
                                    startTimestamp:_clipStartTimestamp
                                          duration:_clipDuration
                                         isSucceed:NO];
                        }
                    }
                    break;
                }
                case StreamError_unknown: { // 未知原因导致开流失败，尝试重启
                    // 此时理论上设备是显示已连接状态的
                    if (GOS_REOPEN_AV_STREAM_COUNTS > self.reOpenAvStreamCounts++) {
                        GosLog(@"daniel: 打开设备（ID = %@）音视频流失败，原因：未知，开启重新拉流策略", deviceId);
#if DEBUG
                        NSString *debugInfo = [NSString stringWithFormat:@"打开设备音视频流失败，重新拉流(%ld)", (long)self.reOpenAvStreamCounts];
                        [SVProgressHUD showInfoWithStatus:debugInfo forDuration:2];
#endif
                        // 重试拉流
                        [self sdk_handler_openStream];
                    } else {
#if DEBUG
                        NSString *debugInfo = [NSString stringWithFormat:@"打开设备音视频流失败(%ld)，重连设备", (long)self.reOpenAvStreamCounts];
                        [SVProgressHUD showInfoWithStatus:debugInfo forDuration:2];
#endif
                        
                        GosLog(@"daniel: 打开设备（ID = %@）音视频流失败，重新拉流拉流次数已到达，发送重新建立连接通知", deviceId);
                        // 重置重试计数
                        self.reOpenAvStreamCounts = 0;
                        // 重试连接设备
                        NSDictionary *notifyDict = @{@"DeviceID" : deviceId,};
                        [[NSNotificationCenter defaultCenter] postNotificationName:kReDisConnAndConnAgainNotify object:notifyDict];
                        // 接下来 理论上会接收到kCurDevConnectingNotify的通知
                    }
                    
                    break;
                }
                default:
                    break;
            }
            break;
        }
        case OpenStreamSuccess: {   // 打开音视频流成功
            GosLog(@"daniel: 打开设备（ID = %@）音视频流成功", deviceId);
            
            self.operateStreamState = GosPlayerOperateStateOpen;
            // _playStartTimestamp != 0 表示正在尝试播放操作
            if (_playStartTimestamp != 0) {
                GosLog(@"daniel: 音视频流成功——播放");
                // 尝试播放
                [self dh_startPlaybackWithDeviceId:_deviceId
                                    startTimestamp:_playStartTimestamp];
            }

            // _clipStartTimestamp != 0 表示正在尝试剪切操作
            if (_clipStartTimestamp != 0) {
                // 尝试剪切
                GosLog(@"daniel: 音视频流成功——剪切");
                [self dh_startClipWithDeviceId:_deviceId
                                 videoFilePath:_clipVideoFilePath
                                startTimestamp:_clipStartTimestamp
                                      duration:_clipDuration];
            }

            // _previewTimestamp != 0 表示正在尝试获取预览图操作
            if (_previewTimestamp != 0) {
                GosLog(@"daniel: 音视频流成功——获取预览图");
                // 尝试获取预览图操作
                [self dh_fetchPreviewWithDeviceId:_deviceId
                                    imageFilePath:_previewImageFilePath
                                        timestamp:_previewTimestamp];
            }
            
            break;
        }
            
        default:
            break;
    }
}

/** 关流回调 */
- (void)deviceId:(NSString *)deviceId
closeStreamState:(CloseStreamState)cState
       errorType:(StreamErrorType)errType {
    // 非当前设备不处理
    if (IS_EMPTY_STRING(deviceId)
        || ![deviceId isEqualToString:_deviceId]) {
        return;
    }
    // 进入此处，无论何种错误都标志着流已经关闭
    self.operateStreamState = GosPlayerOperateStateClose;
    
    switch (cState) {
        case CloseStreamUnknown:    // 未知
        case CloseStreamFailure: {  // 关闭音视频流失败
            self.operateStreamState = GosPlayerOperateStateClose;
            
            switch (errType) {
                case StreamError_disConn: { // 设备未连接导致关流失败
                    GosLog(@"daniel: 关闭设备（ID = %@）音视频流失败，原因：设备未连接成功", deviceId);
                    break;
                }
                case StreamError_Closed: { // 重复关流
                    GosLog(@"daniel: 关闭设备（ID = %@）音视频流失败，原因：流已关闭", deviceId);
                    break;

                }
                default:
                    break;
            }
            break;
        }
        case CloseStreamSuccess: { // 关闭音视频流成功
            GosLog(@"daniel: 关闭设备（ID = %@）音视频流成功", deviceId);
            
            self.operateStreamState = GosPlayerOperateStateClose;
            
            break;
        }
        default:
            break;
    }
    
}

/** 视频数据（已编码）回调 */
- (void)deviceId:(NSString *)deviceId
       videoData:(unsigned char*)vBuffer
          length:(unsigned int)dLen
         frameNo:(unsigned int)frameNo
       timeStamp:(unsigned int)timeStamp
       frameRate:(unsigned int)fRate
       frameType:(VideoFrameType)fType
       avChannel:(int)avChn {
    // 非当前设备不处理
    if (IS_EMPTY_STRING(deviceId)
        || ![deviceId isEqualToString:_deviceId]) {
        return;
    }
    GosLog(@"daniel: frameType: %zd", fType);
    // 视频解码渲染
    NSData *videoData = [NSData dataWithBytes:vBuffer length:dLen];
    GOS_WEAK_SELF
    dispatch_async(self.decodeAndPlayStreamQueue, ^{
        GOS_STRONG_SELF
        [strongSelf.playerSDK addVideoData:(unsigned char *)videoData.bytes
                                    length:dLen
                                 timeStamp:timeStamp
                                   frameNo:frameNo
                                 frameRate:fRate
                                  isIframe:fType==VideoFrame_iFrame
                                  deviceId:deviceId];
    });
    
    if (fType == VideoFrame_recStartFrame) {
        GosLog(@"daniel: 历史流播放开始");
        self.playing = YES;
        
        GOS_WEAK_SELF
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            GOS_STRONG_SELF
            if (strongSelf.delegate && [strongSelf.delegate respondsToSelector:@selector(sdk_handler:deviceId:didStartPlayAtStartTimestamp:)]) {
                [strongSelf.delegate sdk_handler:strongSelf
                                        deviceId:strongSelf.deviceId
                    didStartPlayAtStartTimestamp:strongSelf.playStartTimestamp];
            }
        });
    }
    
}

/** 音频数据（已编码）回调 */
- (void)deviceId:(NSString *)deviceId
       audioData:(unsigned char*)aBuffer
          length:(unsigned int)dLen
         frameNo:(unsigned int)frameNo
        codeType:(AudioCodeType)acType {
    // 非当前设备不处理
    if (IS_EMPTY_STRING(deviceId)
        || ![deviceId isEqualToString:_deviceId]) {
        return;
    }
    
    // 音频解码播放
    NSData *audioData = [NSData dataWithBytes:aBuffer length:dLen];
    GOS_WEAK_SELF;
    dispatch_async(self.decodeAndPlayStreamQueue, ^{
        GOS_STRONG_SELF;
        [strongSelf.playerSDK addAudioData:(unsigned char*)audioData.bytes
                                    length:dLen
                                   frameNo:frameNo
                                  deviceId:deviceId
                                  codeType:(PlayerAudioCodeType)acType];
    });
}


#pragma mark - iOSDevOperateDelegate
- (void)sdCarPlayBack:(BOOL)isSuccess
          ofEventType:(SDCarPBEventType)eType {
    GosLog(@"daniel: sdCarPlayBacks: %zd success", eType);
    // 成功不管、只管失败
    if (isSuccess) return ;
    
    GosLog(@"daniel: sdCarPlayBacks: %zd failed", eType);
    
    switch (eType) {
            // 预览图失败
        case SDCarPBEvent_preview: {
            if (_delegate && [_delegate respondsToSelector:@selector(sdk_handler:deviceId:didSavedPreviewAtImageFilePath:timestamp:isSucceed:)]) {
                [_delegate sdk_handler:self
                              deviceId:_deviceId
        didSavedPreviewAtImageFilePath:_previewImageFilePath
                             timestamp:_previewTimestamp
                             isSucceed:NO];
            }
            break;
        }
            
        case SDCarPBEvent_playback: {
            if (_delegate && [_delegate respondsToSelector:@selector(sdk_handler:deviceId:didFailedPlayAtStartTimestamp:)]) {
                [_delegate sdk_handler:self
                              deviceId:_deviceId
         didFailedPlayAtStartTimestamp:_playStartTimestamp];
            }
            break;
        }
        case SDCarPBEvent_clip: {
            if (_delegate && [_delegate respondsToSelector:@selector(sdk_handler:deviceId:didClipAtVideoFilePath:startTimestamp:duration:isSucceed:)]) {
                [_delegate sdk_handler:self
                              deviceId:_deviceId
                didClipAtVideoFilePath:_clipVideoFilePath
                        startTimestamp:_clipStartTimestamp
                              duration:_clipDuration
                             isSucceed:NO];
            }
            break;
        }
        case SDCarPBEvent_stop:
            GosLog(@"daniel: 停止回放指令发送失败");
            break;
            
        default:
            break;
    }
}

#pragma mark - iOSPlayerSDKDelegate
/**
 解码文件回调，只处理播放中状态，此时解码的是数据流不是文件
 原因：SDK解码数据流回调方法-decodeH264StreamState:回调只有state没有data，而此接口有所以就进入此处
 */
- (void)decodeH264State:(DecodeH264FileState)state data:(long)data {
    GosPrintf("daniel: h264State: %zd data: %ld", state, data);
    switch (state) {
            // 当前播放时长
        case DecodeH264_curTime: {
            // 当前播放时间戳
            NSTimeInterval playingTimestamp = data;
            // 记录播放中时间戳
            _playingTimestamp = playingTimestamp;
            
            GOS_WEAK_SELF
            dispatch_async(self.playingStreamQueue, ^{
                GOS_STRONG_SELF
                if (strongSelf.delegate && [strongSelf.delegate respondsToSelector:@selector(sdk_handler:deviceId:didPlayingAtTimestamp:startTimestamp:)]) {
                    [strongSelf.delegate sdk_handler:strongSelf
                                            deviceId:strongSelf.deviceId
                               didPlayingAtTimestamp:playingTimestamp
                                      startTimestamp:strongSelf.playStartTimestamp];
                }
            });
            break;
        }
        default:
            break;
    }
}

/** 解码数据流回调 */
- (void)decodeH264StreamState:(DecodeH264StreamState)state {
    GosPrintf("daniel: streamState: %ld", (long)state);
    switch (state) {
        case DecodeH264Stream_unknow:
            break;
            // 历史流加载中
        case DecodeH264Stream_loading: {
            GosLog(@"daniel: 历史流加载中");
            GOS_WEAK_SELF
            dispatch_async(self.playStartLoadingQueue, ^{
                GOS_STRONG_SELF
                if (strongSelf.delegate && [strongSelf.delegate respondsToSelector:@selector(sdk_handler:deviceId:playStartLoadingAtStartTimestamp:)]) {
                    [strongSelf.delegate sdk_handler:strongSelf
                                            deviceId:strongSelf.deviceId
                    playStartLoadingAtStartTimestamp:strongSelf.playStartTimestamp];
                }
            });
            break;
        }
            // 历史流加载完成
        case DecodeH264Stream_loadSuccess: {
            GosLog(@"daniel: 历史流加载完成");
            GOS_WEAK_SELF
            dispatch_async(self.playEndedLoadingQueue, ^{
                GOS_STRONG_SELF
                if (strongSelf.delegate && [strongSelf.delegate respondsToSelector:@selector(sdk_handler:deviceId:playEndedLoadingAtStartTimestamp:)]) {
                    [strongSelf.delegate sdk_handler:strongSelf
                                            deviceId:strongSelf.deviceId
                    playEndedLoadingAtStartTimestamp:strongSelf.playStartTimestamp];
                }
            });
            break;
        }
            // 历史流播放开始
            // NOTE: 此标记SDK偶尔会返回，不准确，因此将此标记下操作设置在裸流回调中判断
        case DecodeH264Stream_startPlay: {
            break;
        }
            // 历时流播放完成
        case DecodeH264Stream_finishPlay: {
            GosLog(@"daniel: 历史流播放完成");
            self.playing = NO;
            
            if (_delegate && [_delegate respondsToSelector:@selector(sdk_handler:deviceId:didEndedPlayAtStartTimestamp:)]) {
                [_delegate sdk_handler:self
                              deviceId:_deviceId
          didEndedPlayAtStartTimestamp:_playStartTimestamp];
            }
            [self resetPlayParameters];
            
            break;
        }
            // 历史流截图完成
        case DecodeH264Stream_captureSuccess: {
            if (_delegate && [_delegate respondsToSelector:@selector(sdk_handler:deviceId:didSavedPreviewAtImageFilePath:timestamp:isSucceed:)]) {
                [_delegate sdk_handler:self
                              deviceId:_deviceId
        didSavedPreviewAtImageFilePath:_previewImageFilePath
                             timestamp:_previewTimestamp
                             isSucceed:YES];
            }
            // 重置预览图参数
            [self resetPreviewParameters];
            break;
        }
            // 历时流剪切完成
        case DecodeH264Stream_cutSuccess: {
            if (_delegate && [_delegate respondsToSelector:@selector(sdk_handler:deviceId:didClipAtVideoFilePath:startTimestamp:duration:isSucceed:)]) {
                [_delegate sdk_handler:self
                              deviceId:_deviceId
                didClipAtVideoFilePath:_clipVideoFilePath
                        startTimestamp:_clipStartTimestamp
                              duration:_clipDuration
                             isSucceed:YES];
            }
            // 重置剪切参数
            [self resetClipParameters];
            break;
        }
        default:
            break;
    }
}

#pragma mark - 封装方法 —— 统一接口使用方法
/** 开流 */
- (void)dh_openStreamWithDeviceId:(NSString *)deviceId {
    // 获取开流密码
    NSString *streamPassword = [self dm_fetchStreamPasswordWithDeviceId:deviceId];
    [self ds_openStreamWithDeviceId:deviceId
                     streamPassword:streamPassword];
}

/** 关流 */
- (void)dh_closeStreamWithDeviceId:(NSString *)deviceId {
    [self ds_closeStreamWithDeviceId:deviceId];
}

/** 获取预览图 */
- (void)dh_fetchPreviewWithDeviceId:(NSString *)deviceId
                      imageFilePath:(NSString *)imageFilePath
                          timestamp:(NSTimeInterval)timestamp {
    [self ps_configPreviewSavingPathWithDeviceId:deviceId
                                   imageFilePath:imageFilePath];
    [self ds_fetchPreviewWithDeviceId:deviceId
                          atTimestamp:timestamp];
}

/** 截图 */
- (BOOL)dh_saveSnapshotWithDeviceId:(NSString *)deviceId
                      imageFilePath:(NSString *)imageFilePath {
    return [self ps_saveSnapshotWithDeviceId:_deviceId
                               imageFilePath:imageFilePath];
}

/** 剪切 */
- (void)dh_startClipWithDeviceId:(NSString *)deviceId
                   videoFilePath:(NSString *)videoFilePath
                  startTimestamp:(NSTimeInterval)startTimestamp
                        duration:(NSUInteger)duration {
    [self ps_configClipSavingPathWithDeviceId:deviceId
                                videoFilePath:videoFilePath];
    [self ds_startClipWithDeviceId:deviceId
                    startTimestamp:startTimestamp
                          duration:duration];
}

/** 回放 */
- (void)dh_startPlaybackWithDeviceId:(NSString *)deviceId
                      startTimestamp:(NSTimeInterval)startTimestamp {
    [self ps_preparePlaybackWithDeviceId:deviceId];
    [self ds_startPlaybackWithDeviceId:deviceId
                        startTimestamp:startTimestamp];
}

/** 开启声音 */
- (void)dh_openVoiceWithDeviceId:(NSString *)deviceId {
    [self ps_openVoiceWithDeviceId:deviceId];
}

/** 关闭声音 */
- (void)dh_closeVoiceWithDeviceId:(NSString *)deviceId {
    [self ps_closeVoiceWithDeviceId:deviceId];
}

/** 释放播放器 */
- (void)dh_releasePlayer {
    [self ps_releasePlayerSDK];
    [self ds_releaseDeviceSDK];
}


#pragma mark - iOSDevSDK method 设备SDK方法
/** 开启音视频流 */
- (void)ds_openStreamWithDeviceId:(NSString *)deviceId
                   streamPassword:(NSString *)streamPassword {
    [self.devSDK openStreamOfType:DeviceStream_rec
                        withDevId:deviceId
                         password:streamPassword];
}

/** 关闭音视频流 */
- (void)ds_closeStreamWithDeviceId:(NSString *)deviceId {
    [self.devSDK closeStreamOfType:DeviceStream_rec
                         withDevId:deviceId];
}

/** 关闭指令 */
- (void)ds_stopCommandWithDeviceId:(NSString *)deviceId {
    [self.devSDK sdCarPlayBackWithEventType:SDCarPBEvent_stop
                                  startTime:0
                                   duration:0
                                  withDevId:deviceId];
}

/** 剪切视频 */
- (void)ds_startClipWithDeviceId:(NSString *)deviceId
                  startTimestamp:(NSTimeInterval)startTimestamp
                        duration:(NSUInteger)duration {
    [self.devSDK sdCarPlayBackWithEventType:SDCarPBEvent_clip
                                  startTime:(unsigned int)startTimestamp
                                   duration:(int)duration
                                  withDevId:deviceId];
}

/** 获取预览图片 */
- (void)ds_fetchPreviewWithDeviceId:(NSString *)deviceId
                        atTimestamp:(NSTimeInterval)timestamp {
    [self.devSDK sdCarPlayBackWithEventType:SDCarPBEvent_preview
                                  startTime:(unsigned int)timestamp
                                   duration:0
                                  withDevId:deviceId];
}

/** 回放 */
- (void)ds_startPlaybackWithDeviceId:(NSString *)deviceId
                      startTimestamp:(NSTimeInterval)startTimestamp {
    [self.devSDK sdCarPlayBackWithEventType:SDCarPBEvent_playback
                                  startTime:(unsigned int)startTimestamp
                                   duration:0
                                  withDevId:deviceId];
}

/** 释放SDK */
- (void)ds_releaseDeviceSDK {
    if (_devSDK) {
        _devSDK.operateDelegate = nil;
        _devSDK.delegate = nil;
        _devSDK = nil;
    }
}


#pragma mark - iOSPlayerSDK method 播放器SDK方法
/** 开启声音 */
- (void)ps_openVoiceWithDeviceId:(NSString *)deviceId {
    [self.playerSDK startVoiceWidthDevId:deviceId];
}

/** 关闭声音 */
- (void)ps_closeVoiceWithDeviceId:(NSString *)deviceId {
    [self.playerSDK stopVoiceWidthDevId:deviceId];
}

/** 为回放做准备 */
- (BOOL)ps_preparePlaybackWithDeviceId:(NSString *)deviceId {
    return [self.playerSDK configSdH264OperationType:SDH264StreamOperation_playBack
                                        saveFilePath:nil
                                        withDeviceId:deviceId];
}

/** 设置预览图保存路径 */
- (BOOL)ps_configPreviewSavingPathWithDeviceId:(NSString *)deviceId
                                 imageFilePath:(NSString *)imageFilePath {
    return [self.playerSDK configSdH264OperationType:SDH264StreamOperation_preview
                                        saveFilePath:imageFilePath
                                        withDeviceId:deviceId];
    
}

/** 设置剪切保存路径 */
- (BOOL)ps_configClipSavingPathWithDeviceId:(NSString *)deviceId
                              videoFilePath:(NSString *)videoFilePath {
    return [self.playerSDK configSdH264OperationType:SDH264StreamOperation_cut
                                        saveFilePath:videoFilePath
                                        withDeviceId:deviceId];
}

/** 保存截图 */
- (BOOL)ps_saveSnapshotWithDeviceId:(NSString *)deviceId
                      imageFilePath:(NSString *)imageFilePath {
    return [self.playerSDK snapshotAtPath:imageFilePath
                                 deviceId:deviceId];
}

/** 重置尺寸 */
- (void)ps_resize:(CGSize)size {
    [self.playerSDK resize:size];
}

/** 释放播放器 */
- (void)ps_releasePlayerSDK {
    if (_playerSDK) {
        [_playerSDK releasePlayer];
        
        _playerSDK.delegate = self;
        _playerSDK = nil;
    }
    
}


#pragma mark - GosDevManager 设备信息获取
/** App与设备连接状态 */
- (DeviceConnState)dm_fetchDeviceConnStateWithDeviceId:(NSString *)deviceId {
    return [GosDevManager connStateOfDevice:deviceId];
}

/** 服务器显示的设备在线状态 */
- (DevStatusType)dm_fetchDeviceStatusTypeWithDeviceId:(NSString *)deviceId {
    return [GosDevManager devcieWithId:deviceId].Status;
}

/** 获取流密码 */
- (NSString *)dm_fetchStreamPasswordWithDeviceId:(NSString *)deviceId {
    return [GosDevManager devcieWithId:deviceId].StreamPassword;
}


#pragma mark - private method
- (void)resetPreviewParameters {
    _previewTimestamp = 0;
    _previewImageFilePath = nil;
}

- (void)resetPlayParameters {
    _playStartTimestamp = 0;
}

- (void)resetClipParameters {
    _clipDuration = 0;
    _clipVideoFilePath = nil;
    _clipStartTimestamp = 0;
}

- (void)playSnapshotSoundEffect {
    if (self.snapshotAudioPlayer) {
        [self.snapshotAudioPlayer prepareToPlay];
        [self.snapshotAudioPlayer play];
    }
}

- (void)releaseSnapshotSoundEffect {
    if (_snapshotAudioPlayer) {
        [_snapshotAudioPlayer stop];
        _snapshotAudioPlayer = nil;
    }
}

#pragma mark - getters and setters
- (iOSDevSDK *)devSDK {
    if (!_devSDK) {
        _devSDK = [iOSDevSDK shareDevSDK];
        _devSDK.delegate = self;
        _devSDK.operateDelegate = self;
    }
    return _devSDK;
}

- (iOSPlayerSDK *)playerSDK {
    if (!_playerSDK) {
        // 初始化时，内部已开启解码
        _playerSDK = [[iOSPlayerSDK alloc] initWithDeviceId:_deviceId
                                                 onPlayView:_playView
                                                  ratioPlay:YES];
        _playerSDK.delegate = self;
    }
    return _playerSDK;
}

- (AVAudioPlayer *)snapshotAudioPlayer {
    if (!_snapshotAudioPlayer) {
        // 截图音频资源
        NSString *audioFilePath = [[NSBundle mainBundle] pathForResource:@"SnapshotSound"
                                                                  ofType:@"wav"];
        NSURL *audioFileUrl = [NSURL fileURLWithPath:audioFilePath];
        
        _snapshotAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:audioFileUrl error:NULL];
    }
    return _snapshotAudioPlayer;
}

@end
