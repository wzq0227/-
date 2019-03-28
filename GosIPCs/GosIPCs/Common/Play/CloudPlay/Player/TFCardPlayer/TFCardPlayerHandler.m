//  TFCardPlayerHandler.m
//  GosIPCs
//
//  Create by daniel.hu on 2019/2/19.
//  Copyright © 2019年 goscam. All rights reserved.

#import "TFCardPlayerHandler.h"
#import "PlaybackPlayerView.h"
#import "TFCardPlayerSDKHandler.h"
#import "TFCardPlayerMediaHelper.h"

@interface TFCardPlayerHandler () <TFCardPlayerSDKHandlerDelegate>
/// 播放视图
@property (nonatomic, readwrite, strong) PlaybackPlayerView *playerView;
/// 设备id
@property (nonatomic, copy) NSString *deviceId;
/// sdk控制者
@property (nonatomic, strong) TFCardPlayerSDKHandler *sdkHandler;

@end

@implementation TFCardPlayerHandler
#pragma mark - initialization
- (instancetype)initWithDeviceId:(NSString *)deviceId {
    if (self = [super init]) {
        _deviceId = deviceId;
    }
    return self;
}


#pragma mark - public method
- (void)player_handler_fetchPreviewAtTimestamp:(NSTimeInterval)timestamp {
    // 本地预览图存储路径
    NSString *previewImageFilePath = [TFCardPlayerMediaHelper previewFilePathWithDeviceId:_deviceId startTimestamp:timestamp];
    
    // 判断是否已存在
    BOOL previewExist = [TFCardPlayerMediaHelper fileExistWithFilePath:previewImageFilePath];
    
    if (previewExist) {
        // 存在预览图路径文件
        [self updateWithPreviewImageFilePath:previewImageFilePath
                              startTimestamp:timestamp
                                   isSucceed:YES];
    } else {
        // sdk获取预览图
        [self.sdkHandler sdk_handler_fetchPreviewWithImageFilePath:previewImageFilePath
                                                       atTimestamp:timestamp];
    }
}

- (void)player_handler_startPlayWithStartTimestamp:(NSTimeInterval)startTimestamp {
    // sdk开始播放
    [self.sdkHandler sdk_handler_startPlayWithStartTimestamp:startTimestamp];
}

- (void)player_handler_startClipWithFileName:(NSString *)fileName
                              startTimestamp:(NSTimeInterval)startTimestamp
                                    duration:(NSUInteger)duration {
    // 剪切存储路径
    NSString *clipFilePath = [TFCardPlayerMediaHelper clipFilePathWithDeviceId:_deviceId
                                                                      fileName:fileName];
    // sdk开始剪切
    [self.sdkHandler sdk_handler_startClipWithVideoFilePath:clipFilePath
                                             startTimestamp:startTimestamp
                                                   duration:duration];
}

- (void)player_handler_snapshot {
    // 截图路径
    NSString *snapshotFilePath = [TFCardPlayerMediaHelper snapshotFilePathWithDeviceId:_deviceId];
    
    // 获取截图
    [self.sdkHandler sdk_handler_snapshotWithImageFilePath:snapshotFilePath];
}

- (void)player_handler_openVoice {
    [self.sdkHandler sdk_handler_openVoice];
}

- (void)player_handler_closeVoice {
    [self.sdkHandler sdk_handler_closeVoice];
}

- (void)player_handler_initialPlayer {
    [self.sdkHandler sdk_handler_initialPlayer];
}

- (void)player_handler_destoryPlayer {
    [self.sdkHandler sdk_handler_destoryPlayer];
}

- (void)player_handler_resizePlayViewSize:(CGSize)size {
    [self.sdkHandler sdk_handler_resize:size];
}


#pragma mark - TFCardPlayerSDKHandlerDelegate
/// 在线状态、连接状态 更新
- (void)sdk_handler:(TFCardPlayerSDKHandler *)handler
           deviceId:(NSString *)deviceId
didChangedDeviceState:(DevStatusType)deviceStatus
       connectState:(DeviceConnState)connectState {
    
    if (_delegate && [_delegate respondsToSelector:@selector(player_handler:didChangedDeviceStateAndConnectState:)]) {
        TFPHDeviceStateAndConnectState state = [self convertStateFromDeviceState:deviceStatus connectState:connectState];
        [_delegate player_handler:self didChangedDeviceStateAndConnectState:state];
    }
}

/// 预览图保存
- (void)sdk_handler:(TFCardPlayerSDKHandler *)handler
           deviceId:(NSString *)deviceId
didSavedPreviewAtImageFilePath:(NSString *)imageFilePath
          timestamp:(NSTimeInterval)timestamp
          isSucceed:(BOOL)isSucceed {
    [self updateWithPreviewImageFilePath:imageFilePath
                          startTimestamp:timestamp
                               isSucceed:isSucceed];
}

/// 播放失败
- (void)sdk_handler:(TFCardPlayerSDKHandler *)handler
           deviceId:(NSString *)deviceId
didFailedPlayAtStartTimestamp:(NSTimeInterval)startTimestamp {
    if (_delegate && [_delegate respondsToSelector:@selector(player_handler:didFailedPlayAtStartTimestamp:)]) {
        [_delegate player_handler:self
    didFailedPlayAtStartTimestamp:startTimestamp];
    }
}

/// 开始播放
- (void)sdk_handler:(TFCardPlayerSDKHandler *)handler
           deviceId:(NSString *)deviceId
didStartPlayAtStartTimestamp:(NSTimeInterval)startTimestamp {
    if (_delegate && [_delegate respondsToSelector:@selector(player_handler:didStartPlayAtStartTimestamp:)]) {
        [_delegate player_handler:self
     didStartPlayAtStartTimestamp:startTimestamp];
    }
}

/// 播放中
- (void)sdk_handler:(TFCardPlayerSDKHandler *)handler
           deviceId:(NSString *)deviceId
didPlayingAtTimestamp:(NSTimeInterval)playingTimestamp
     startTimestamp:(NSTimeInterval)startTimestamp {
    if (_delegate && [_delegate respondsToSelector:@selector(player_handler:didPlayingAtTimestamp:startTimestamp:)]) {
        [_delegate player_handler:self
            didPlayingAtTimestamp:playingTimestamp
                   startTimestamp:startTimestamp];
    }
}

/// 完成播放
- (void)sdk_handler:(TFCardPlayerSDKHandler *)handler
           deviceId:(NSString *)deviceId
didEndedPlayAtStartTimestamp:(NSTimeInterval)startTimestamp {
    if (_delegate && [_delegate respondsToSelector:@selector(player_handler:didEndedPlayAtStartTimestamp:)]) {
        [_delegate player_handler:self
     didEndedPlayAtStartTimestamp:startTimestamp];
    }
}

/// 播放缓存中
- (void)sdk_handler:(TFCardPlayerSDKHandler *)handler
           deviceId:(NSString *)deviceId
playStartLoadingAtStartTimestamp:(NSTimeInterval)startTimestamp {
    if (_delegate && [_delegate respondsToSelector:@selector(player_handler:playStartLoadingAtStartTimestamp:)]) {
        [_delegate player_handler:self
   playStartLoadingAtStartTimestamp:startTimestamp];
    }
}

/// 播放结束缓存
- (void)sdk_handler:(TFCardPlayerSDKHandler *)handler
           deviceId:(NSString *)deviceId
playEndedLoadingAtStartTimestamp:(NSTimeInterval)startTimestamp {
    if (_delegate && [_delegate respondsToSelector:@selector(player_handler:playEndedLoadingAtStartTimestamp:)]) {
        [_delegate player_handler:self
 playEndedLoadingAtStartTimestamp:startTimestamp];
    }
}

/// 完成剪切
- (void)sdk_handler:(TFCardPlayerSDKHandler *)handler
           deviceId:(NSString *)deviceId
didClipAtVideoFilePath:(NSString *)videoFilePath
     startTimestamp:(NSTimeInterval)startTimestamp
           duration:(NSUInteger)duration
          isSucceed:(BOOL)isSucceed {
    [self updateWithClipVideoFilePath:videoFilePath
                       startTimestamp:startTimestamp
                             duration:duration
                            isSucceed:isSucceed];
}

// 完成截图
- (void)sdk_handler:(TFCardPlayerSDKHandler *)handler
           deviceId:(NSString *)deviceId
didSnapshotAtImageFilePath:(NSString *)imageFilePath
          isSucceed:(BOOL)isSucceed {
    
    if (isSucceed) {
        // 理论上运行到此处就说明截图文件存储到snapshotFilePath了
        if (_delegate && [_delegate respondsToSelector:@selector(player_handler:didSucceedSnapshotWithImageFilePath:)]) {
            [_delegate player_handler:self
  didSucceedSnapshotWithImageFilePath:imageFilePath];
        }
    } else {
        if (_delegate && [_delegate respondsToSelector:@selector(player_handler:didFailedSnapshotWithImageFilePath:)]) {
            [_delegate player_handler:self
   didFailedSnapshotWithImageFilePath:imageFilePath];
        }
    }
}

#pragma mark - private method
- (void)updateWithPreviewImageFilePath:(NSString *)imageFilePath
                        startTimestamp:(NSTimeInterval)startTimestamp
                             isSucceed:(BOOL)isSucceed {
    // 预览图
    UIImage *previewImage = [UIImage imageWithContentsOfFile:imageFilePath];
    GosLog(@"daniel: 获取到的预览图：%@", previewImage);
    
    if (previewImage && isSucceed) {
        // 预览图存在
        if (_delegate && [_delegate respondsToSelector:@selector(player_handler:didSucceedFetchedPreviewImage:startTimestamp:)]) {
            [_delegate player_handler:self
        didSucceedFetchedPreviewImage:previewImage
                       startTimestamp:startTimestamp];
        }
    } else {
        // 不存在
        if (_delegate && [_delegate respondsToSelector:@selector(player_handler:didFailedFetchedPreviewImageFromImageFilePath:startTimestamp:)]) {
            [_delegate player_handler:self
didFailedFetchedPreviewImageFromImageFilePath:imageFilePath
                       startTimestamp:startTimestamp];
        }
    }
}

- (void)updateWithClipVideoFilePath:(NSString *)videoFilePath
                     startTimestamp:(NSTimeInterval)startTimestamp
                           duration:(NSUInteger)duration
                          isSucceed:(BOOL)isSucceed {
    // 判断剪切文件是否存在
    BOOL clipExist = [TFCardPlayerMediaHelper fileExistWithFilePath:videoFilePath];
    GosLog(@"daniel: 剪切%@后的文件: %@", isSucceed?@"成功":@"失败", clipExist?@"存在":@"不存在——即失败");
    
    if (isSucceed && clipExist) {
        // 剪切文件存在并成功
        if (_delegate && [_delegate respondsToSelector:@selector(player_handler:didSucceedClipAtVideoFilePath:startTimestamp:duration:)]) {
            [_delegate player_handler:self
        didSucceedClipAtVideoFilePath:videoFilePath
                       startTimestamp:startTimestamp
                             duration:duration];
        }
    } else {
        // 不存在或失败
        if (_delegate && [_delegate respondsToSelector:@selector(player_handler:didFailedClipAtVideoFilePath:startTimestamp:duration:)]) {
            [_delegate player_handler:self
         didFailedClipAtVideoFilePath:videoFilePath
                       startTimestamp:startTimestamp
                             duration:duration];
        }
    }
}

- (TFPHDeviceStateAndConnectState)convertStateFromDeviceState:(DevStatusType)deviceState connectState:(DeviceConnState)connectState {
    TFPHDeviceStateAndConnectState state = TFPHDeviceStateAndConnectStateNotOnline;
    if (deviceState != DevStatus_onLine) {
        // 非在线
        state = TFPHDeviceStateAndConnectStateNotOnline;
    } else if (deviceState == DevStatus_onLine && connectState == DeviceConnSuccess) {
        // 在线并连接
        state = TFPHDeviceStateAndConnectStateOnlineAndConnected;
    } else {
        // 在线并非连接
        state = TFPHDeviceStateAndConnectStateOnlineAndNotConnected;
    }
    return state;
}


#pragma mark - getters and setters
- (TFCardPlayerSDKHandler *)sdkHandler {
    if (!_sdkHandler) {
        _sdkHandler = [[TFCardPlayerSDKHandler alloc] initWithDeviceId:_deviceId playView:self.playerView];
        _sdkHandler.delegate = self;
    }
    return _sdkHandler;
}

- (PlaybackPlayerView *)playerView {
    if (!_playerView) {
        _playerView = [[PlaybackPlayerView alloc] init];
    }
    return _playerView;
}

@end
