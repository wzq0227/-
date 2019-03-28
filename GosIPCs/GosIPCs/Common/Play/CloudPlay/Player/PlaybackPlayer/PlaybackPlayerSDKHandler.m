//  PlaybackPlayerSDKHandler.m
//  Goscom
//
//  Create by daniel.hu on 2019/2/16.
//  Copyright © 2019年 goscam. All rights reserved.

#import "PlaybackPlayerSDKHandler.h"
#import "iOSPlayerSDK.h"
#import <AVFoundation/AVFoundation.h>

@interface PlaybackPlayerSDKHandler () <iOSPlayerSDKDelegate>
#pragma mark - SDK相关参数
/// player sdk
@property (nonatomic, strong) iOSPlayerSDK *player;
/// 设备id，在初始化即确定了内容
@property (nonatomic, readwrite, copy) NSString *deviceId;
/// 播放视图
@property (nonatomic, weak) UIView *playView;

#pragma mark - 预览图相关参数
/// 预览图图片路径
@property (nonatomic, copy) NSString *previewImageFilePath;
/// 预览图时间
@property (nonatomic, assign) NSUInteger previewOnTime;
/// 预览图开始时间戳
@property (nonatomic, assign) NSTimeInterval previewStartTimestamp;

#pragma mark - 播放相关参数
/// 播放的文件路径
@property (nonatomic, copy) NSString *playVideoFilePath;
/// 开始播放时间戳
@property (nonatomic, assign) NSTimeInterval playStartTimestamp;
/// 播放中时间戳
@property (nonatomic, assign) NSTimeInterval playingTimestamp;
/// 文件时长
@property (nonatomic, assign) NSUInteger playDuration;
/// 正在播放
@property (nonatomic, assign, getter=isPlaying) BOOL playing;
/// 播放文件队列（串行）
@property (nonatomic, strong) dispatch_queue_t operatePlayQueue;

#pragma mark - 声音相关
/// 是否开启声音
@property (nonatomic, assign, getter=isOpenVoice) BOOL openVoice;
/// 控制声音队列（串行）
@property (nonatomic, readwrite, strong) dispatch_queue_t operateVoiceQueue;


#pragma mark - 剪切相关参数
/// 剪切文件存储路径
@property (nonatomic, copy) NSString *clipDestionationFilePath;
/// 剪切开始时间（从原始H264文件0秒开始）
@property (nonatomic, assign) NSUInteger clipStartTime;
/// 剪切文件的总时长
@property (nonatomic, assign) NSUInteger clipTotalTime;

#pragma mark - 截图相关
/// 控制截图队列
@property (nonatomic, strong) dispatch_queue_t operateSnapshotQueue;
/// 拍照按钮点击声音 播放器
@property (nonatomic, strong) AVAudioPlayer *snapshotAudioPlayer;

@end

@implementation PlaybackPlayerSDKHandler
#pragma mark - initialization
/// 初始化
- (instancetype)initWithDeviceId:(NSString *)deviceId
                        playView:(UIView *)playView {
    if (self = [super init]) {
        
        _deviceId = deviceId;
        _playView = playView;
        
        [self initialPlayer];
        
        [self player];
    }
    return self;
}

- (void)initialPlayer {
    _previewOnTime = NSUIntegerMax;
    _previewImageFilePath = nil;
    
    _playVideoFilePath = nil;
    _playStartTimestamp = 0;
    _playDuration = 0;
    _playingTimestamp = 0;
    
    _openVoice = NO;
    
    _clipStartTime = 0;
    _clipTotalTime = 0;
    _clipDestionationFilePath = nil;
    
    self.operateVoiceQueue = dispatch_queue_create("PlayerSDKOperateVoice", DISPATCH_QUEUE_SERIAL);
    self.operatePlayQueue = dispatch_queue_create("PlayerSDKPlayingFile", DISPATCH_QUEUE_SERIAL);
    self.operateSnapshotQueue = dispatch_queue_create("PlayerSDKOperateSnapshot", DISPATCH_QUEUE_SERIAL);
    
    // 监听app进入后台通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
    // 监听app进入活动状态通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
}

- (void)resetPlayer {
    // 释放音效
    [self releaseSnapshotSoundEffect];
    // 关闭声音
    [self sdk_handler_closeVoice];
    // 停止播放
    [self sdk_handler_stopPlay];
    // 释放
    [self ps_releasePlayer];
    
}

- (void)dealloc {
    // 移除观察者
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    GosLog(@"-------------- PlaybackPlayerSDKHandler dealloc ---------------");
}


#pragma mark - public method
/** 开始播放 */
- (void)sdk_handler_startPlayWithVideoFilePath:(NSString *)videoFilePath
                                startTimestamp:(NSTimeInterval)startTimestamp
                                      duration:(NSUInteger)duration {
    if (IS_EMPTY_STRING(videoFilePath)
        || startTimestamp == 0
        || duration == 0) {
        GosLog(@"云存储开启播放失败，因为文件路径为空 或开始时间戳为0 或时长为0");
        return ;
    }
    
    // 开启解码之前必需 关闭解码
    [self ps_stopDecodeWithDeviceId:_deviceId];
    // 开启自动渲染
    [self ps_configAutoRender:YES];
    
    // 记录播放操作数据
    _playVideoFilePath = videoFilePath;
    _playStartTimestamp = startTimestamp;
    _playDuration = duration;
    
    // 开始解码
    [self ps_startDecodeWithDeviceId:_deviceId videoFilePath:videoFilePath];
}

/** 获取预览图 */
- (void)sdk_handler_fetchPreviewWithVideoFilePath:(NSString *)videoFilePath
                                    imageFilePath:(NSString *)imageFilePath
                                   startTimestamp:(NSTimeInterval)startTimestamp
                                           onTime:(NSUInteger)onTime {
    // 开启解码之前必需 关闭解码
    [self ps_stopPreviewDecodeWithDeviceId:_deviceId];
    
    // 记录预览操作数据
    _previewOnTime = onTime;
    _previewImageFilePath = imageFilePath;
    _previewStartTimestamp = startTimestamp;
    
    // 开始解码
    [self ps_startPreviewDecodeWithDeviceId:_deviceId videoFilePath:videoFilePath];
}

/** 获取截图 */
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
        GosLog(@"截图失败：没有正在播放");
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
        BOOL ret = [strongSelf ps_saveSnapshotWithDeviceId:strongSelf.deviceId imageFilePath:imageFilePath];
        GosLog(@"截图操作结果：%@", ret?@"成功":@"失败");
        
        if (strongSelf.delegate && [strongSelf.delegate respondsToSelector:@selector(sdk_handler:deviceId:didSnapshotAtImageFilePath:isSucceed:)]) {
            [strongSelf.delegate sdk_handler:strongSelf
                                    deviceId:strongSelf.deviceId
                  didSnapshotAtImageFilePath:imageFilePath
                                   isSucceed:ret];
        }
    });
}

/** 开启剪切 */
- (void)sdk_handler_startClipWithOriginalFilePath:(NSString *)originalFilePath
                             destionationFilePath:(NSString *)destionationFilePath
                                        startTime:(NSUInteger)startTime
                                        totalTime:(NSUInteger)totalTime {
    
    // 原路径错误
    if (IS_EMPTY_STRING(originalFilePath)) {
        GosLog(@"剪切失败：源文件路径不存在，无法剪切");
        if (_delegate && [_delegate respondsToSelector:@selector(sdk_handler:deviceId:didClipAtVideoFilePath:startTime:totalTime:isSucceed:)]) {
            [_delegate sdk_handler:self
                          deviceId:_deviceId
            didClipAtVideoFilePath:destionationFilePath
                         startTime:startTime
                         totalTime:totalTime
                         isSucceed:NO];
        }
        return ;
    }
    
    // 重启解码器
    [self ps_stopDecodeWithDeviceId:_deviceId];
    [self ps_startDecodeWithDeviceId:_deviceId videoFilePath:originalFilePath];
    
    // 记录剪切操作数据
    _clipDestionationFilePath = destionationFilePath;
    _clipStartTime = startTime;
    _clipTotalTime = totalTime;
    
    // 剪切H264视频
    [self ps_startClipWithDeviceId:_deviceId
                  originalFilePath:originalFilePath
              destionationFilePath:destionationFilePath
                         startTime:startTime
                         totalTime:totalTime];
}

/** 开启声音 */
- (void)sdk_handler_openVoice {
    if (_openVoice) {
        GosLog(@"已经开启声音，无需再次开启");
        return ;
    }
    
    GOS_WEAK_SELF
    dispatch_async(self.operateVoiceQueue, ^{
        GOS_STRONG_SELF
        [strongSelf ps_openVoiceWithDeviceId:_deviceId];
        strongSelf.openVoice = YES;
    });
}

/** 关闭声音 */
- (void)sdk_handler_closeVoice {
    if (!_openVoice) {
        GosLog(@"已经关闭声音，无需再次关闭");
        return ;
    }
    
    GOS_WEAK_SELF
    dispatch_async(self.operateVoiceQueue, ^{
        GOS_STRONG_SELF
        [strongSelf ps_closeVoiceWithDeviceId:_deviceId];
        strongSelf.openVoice = NO;
    });
}

/** 停止播放 */
- (void)sdk_handler_stopPlay {
    // 关闭解码
    [self ps_stopDecodeWithDeviceId:_deviceId];
    // 关闭预览图解码器
    [self ps_stopPreviewDecodeWithDeviceId:_deviceId];
}

/** 重新设置尺寸 */
- (void)sdk_handler_resize:(CGSize)size{
    [self ps_resize:size];
}

/** 初始化播放器 */
- (void)sdk_handler_initialPlayer {
    if (_playStartTimestamp != 0) {
        // 如果存在播放，就开始播放
        [self sdk_handler_startPlayWithVideoFilePath:_playVideoFilePath startTimestamp:_playStartTimestamp duration:_playDuration];
    }
}

/** 销毁播放器 */
- (void)sdk_handler_destoryPlayer {
    [self resetPlayer];
}


#pragma mark - notification method
- (void)enterForeground {
    // 开启声音
    [self sdk_handler_openVoice];
    
    // 尝试开始播放
    [self sdk_handler_startPlayWithVideoFilePath:_playVideoFilePath
                                  startTimestamp:_playStartTimestamp
                                        duration:_playDuration];
}

- (void)enterBackground {
    // 关闭声音
    [self sdk_handler_closeVoice];
    
    // 停止播放
    [self sdk_handler_stopPlay];
    
}


#pragma mark - iOSPlayerSDKDelegate
- (void)decodeH264State:(DecodeH264FileState)state
                   data:(long)data {
    GosLog(@"%s state: %zd - data: %ld", __PRETTY_FUNCTION__, state, data);
    switch (state) {
            /// 已获取总时长（此时可以获取预览图）
        case DecodeH264_duration: {
           
            self.playing = YES;
            NSUInteger duration = data;
            
            GOS_WEAK_SELF
            dispatch_async(self.operatePlayQueue, ^{
                GOS_STRONG_SELF
                // 发出开始播放的代理
                if (strongSelf.delegate && [strongSelf.delegate respondsToSelector:@selector(sdk_handler:deviceId:didStartPlayAtStartTimestamp:duration:)]) {
                    [strongSelf.delegate sdk_handler:self
                                            deviceId:strongSelf.deviceId
                        didStartPlayAtStartTimestamp:strongSelf.playStartTimestamp
                                            duration:duration];
                }
                
            });
            
            break;
        }
        
            /// 当前播放时长
        case DecodeH264_curTime: {
            // 当前播放时间
            NSUInteger playingTime = data;
            
            _playingTimestamp = _playStartTimestamp + playingTime;
            GOS_WEAK_SELF
            dispatch_async(self.operatePlayQueue, ^{
                GOS_STRONG_SELF
                // 发出正在播放的代理
                if (strongSelf.delegate && [strongSelf.delegate respondsToSelector:@selector(sdk_handler:deviceId:didPlayingAtTime:startTimestamp:duration:)]) {
                    [strongSelf.delegate sdk_handler:self
                                            deviceId:strongSelf.deviceId
                                    didPlayingAtTime:playingTime
                                      startTimestamp:strongSelf.playStartTimestamp
                                            duration:strongSelf.playDuration];
                }
            });

            break;
        }
            
            /// 播放结束
        case DecodeH264_finish: {
            // 标记播放结束
            self.playing = NO;
            // 关闭解码器
            [self ps_stopDecodeWithDeviceId:_deviceId];
            
            GOS_WEAK_SELF
            dispatch_async(self.operatePlayQueue, ^{
                GOS_STRONG_SELF
                // 发出播放结束的代理
                if (strongSelf.delegate && [strongSelf.delegate respondsToSelector:@selector(sdk_handler:deviceId:didEndedPlayAtStartTimestamp:duration:)]) {
                    [strongSelf.delegate sdk_handler:self
                                            deviceId:strongSelf.deviceId
                        didEndedPlayAtStartTimestamp:strongSelf.playStartTimestamp
                                            duration:strongSelf.playDuration];
                }
                // 重置播放参数
                [strongSelf resetPlayParameters];
            });
            
            break;
        }
            /// 剪切完成
        case DecodeH264_cutFinish: {
            // 关闭解码器
            [self ps_stopDecodeWithDeviceId:_deviceId];
            // 发出剪切完成的代理
            if (_delegate && [_delegate respondsToSelector:@selector(sdk_handler:deviceId:didClipAtVideoFilePath:startTime:totalTime:isSucceed:)]) {
                [_delegate sdk_handler:self
                              deviceId:_deviceId
                didClipAtVideoFilePath:_clipDestionationFilePath
                             startTime:_clipStartTime
                             totalTime:_clipTotalTime
                             isSucceed:YES];
            }
            
            break;
        }
        default:
            break;
    }
}

- (void)pre_decodeH264State:(DecodeH264FileState)state data:(long)data {
    GosLog(@"%s state: %zd - data: %ld", __PRETTY_FUNCTION__, state, data);
    switch (state) {
        case DecodeH264_duration: {
            // 保存预览图——调用此方法后，接下来才会得到DecodeH264_preview的回调
            [self ps_configPreviewSavingPathWithDeviceId:_deviceId
                                           imageFilePath:_previewImageFilePath
                                                  onTime:_previewOnTime];
            break;
        }
            /// 已获得预览图
        case DecodeH264_preview: {
            // 此时得到预览图，关闭解码器
            [self ps_stopPreviewDecodeWithDeviceId:_deviceId];
            
            // 发出代理，已经得到预览图，使用即可
            GOS_WEAK_SELF
            dispatch_async(self.operatePlayQueue, ^{
                GOS_STRONG_SELF
                if (strongSelf.delegate && [strongSelf.delegate respondsToSelector:@selector(sdk_handler:deviceId:previewCanBeFetchedAtImageFilePath:startTimestamp:onTime:)]) {
                    [strongSelf.delegate sdk_handler:self
                                            deviceId:strongSelf.deviceId
                  previewCanBeFetchedAtImageFilePath:strongSelf.previewImageFilePath
                                      startTimestamp:strongSelf.previewStartTimestamp
                                              onTime:strongSelf.previewOnTime];
                }
                // 重置保存预览图参数
                [strongSelf resetPreviewParmeters];
            });
            
            break;
        }
        default:
            break;
    }
}


#pragma mark - SDK 方法
/** 开启解码 */
- (BOOL)ps_startDecodeWithDeviceId:(NSString *)deviceId
                  videoFilePath:(NSString *)videoFilePath {
    return [self.player startDecodeH246:videoFilePath
                              withDevId:deviceId];
}

/** 停止解码 */
- (BOOL)ps_stopDecodeWithDeviceId:(NSString *)deviceId {
    return [self.player stopDecodeH246WithDevId:deviceId];
}

/** 开启预览图解码 */
- (BOOL)ps_startPreviewDecodeWithDeviceId:(NSString *)deviceId
                            videoFilePath:(NSString *)videoFilePath {
    return [self.player pre_startDecodeH246:videoFilePath
                                  withDevId:deviceId];
}

/** 停止预览图解码 */
- (BOOL)ps_stopPreviewDecodeWithDeviceId:(NSString *)deviceId {
    return [self.player pre_stopDecodeH246WithDevId:deviceId];
}

/** 剪切H264视频 */
- (BOOL)ps_startClipWithDeviceId:(NSString *)deviceId
                originalFilePath:(NSString *)originalFilePath
            destionationFilePath:(NSString *)destionationFilePath
                       startTime:(NSUInteger)startTime
                       totalTime:(NSUInteger)totalTime {
    return [self.player convertH264:originalFilePath
                              toMp4:destionationFilePath
                           fromTime:(unsigned int)startTime
                         toDuration:(unsigned int)totalTime
                          withDevId:deviceId];
}

/** 设置预览图存储路径 */
- (BOOL)ps_configPreviewSavingPathWithDeviceId:(NSString *)deviceId
                                 imageFilePath:(NSString *)imageFilePath
                                        onTime:(NSUInteger)onTime {
    return [self.player pre_saveH264PreviewToPath:imageFilePath
                                           onTime:(unsigned int)onTime
                                        withDevId:deviceId];
}



/** 保存截图 */
- (BOOL)ps_saveSnapshotWithDeviceId:(NSString *)deviceId
                      imageFilePath:(NSString *)imageFilePath {
    return [self.player snapshotAtPath:imageFilePath deviceId:deviceId];
}

/** 开启声音 */
- (void)ps_openVoiceWithDeviceId:(NSString *)deviceId {
    [self.player startVoiceWidthDevId:deviceId];
}

/** 关闭声音 */
- (void)ps_closeVoiceWithDeviceId:(NSString *)deviceId {
    [self.player stopVoiceWidthDevId:deviceId];
}

/** 配置自动渲染 */
- (void)ps_configAutoRender:(BOOL)autoRender {
    [self.player configAutoRender:autoRender];
}

/** 重置播放视图尺寸 */
- (void)ps_resize:(CGSize)size {
    [self.player resize:size];
}

/** 释放播放器 */
- (void)ps_releasePlayer {
    if (_player) {
        [self.player releasePlayer];
        
        _player.delegate = nil;
        _player = nil;
    }
}


#pragma mark - private method
/** 是否应该保存预览图 */
- (BOOL)shouldProcessPreview {
    return _previewOnTime != NSUIntegerMax;
}

/** 重置保存预览图动作的标志 */
- (void)resetPreviewProcessSignal {
    _previewOnTime = NSUIntegerMax;
}

/** 重置播放参数 */
- (void)resetPlayParameters {
    _playStartTimestamp = 0;
    _playingTimestamp = 0;
    _playDuration = 0;
}

/** 重置预览图参数 */
- (void)resetPreviewParmeters {
    _previewOnTime = NSUIntegerMax;
    _previewImageFilePath = nil;
    _previewStartTimestamp = 0;
}

/** 播放截图音效 */
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
- (iOSPlayerSDK *)player {
    if (!_player) {
        _player = [[iOSPlayerSDK alloc] initWithDeviceId:_deviceId
                                              onPlayView:_playView
                                               ratioPlay:YES];
        _player.delegate = self;
    }
    return _player;
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
