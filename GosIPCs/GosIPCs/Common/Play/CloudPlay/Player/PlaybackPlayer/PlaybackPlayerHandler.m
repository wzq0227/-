//  PlaybackPlayerHandler.m
//  GosIPCs
//
//  Create by daniel.hu on 2019/2/13.
//  Copyright © 2019年 goscam. All rights reserved.

#import "PlaybackPlayerHandler.h"
#import "PlaybackPlayerView.h"
#import "PlaybackPlayerSDKHandler.h"
#import "PlaybackPlayerDataHandler.h"


@interface PlaybackPlayerHandler() <PlaybackPlayerSDKHandlerDelegate, PlaybackPlayerDataHandlerDelegate>
/// 播放视图
@property (nonatomic, readwrite, strong) PlaybackPlayerView *playerView;
/// sdk控制者
@property (nonatomic, strong) PlaybackPlayerSDKHandler *sdkHandler;
/// 数据控制者
@property (nonatomic, strong) PlaybackPlayerDataHandler *dataHandler;
/// 设备id
@property (nonatomic, copy) NSString *deviceId;

@end

@implementation PlaybackPlayerHandler
/// 初始化
- (instancetype)initWithDeviceId:(NSString *)deviceId {
    if (self = [super init]) {
        _deviceId = deviceId;
    }
    return self;
}


#pragma mark - public method
- (void)player_handler_fetchPreviewWithVideoModel:(VideoSlicesApiRespModel *)videoModel
                                           onTime:(NSUInteger)onTime {
    // 获取预览图文件路径
    [self.dataHandler data_handler_fetchPreviewFilePathWithVideoModel:videoModel
                                                               onTime:onTime];
}

- (void)player_handler_startPlayWithVideoModel:(VideoSlicesApiRespModel *)videoModel {
    // 获取视频文件路径
    [self.dataHandler data_handler_fetchVideoFilePathWithVideoModel:videoModel];
}

- (void)player_handler_startClipWithVideos:(NSArray <VideoSlicesApiRespModel *> *)videos
                                  fileName:(NSString *)fileName
                                 startTime:(NSUInteger)startTime
                                  duration:(NSUInteger)duration {
    // 获取剪切文件路径
    [self.dataHandler data_handler_fetchClipFilePathWithVideos:videos
                                                      fileName:fileName
                                                     startTime:startTime
                                                      duration:duration];
}

- (void)player_handler_snapshot {
    // 截图存储路径
    NSString *snapshotFilePath = [self.dataHandler data_handler_fetchSnapshotFilePath];
    // 截图
    [self.sdkHandler sdk_handler_snapshotWithImageFilePath:snapshotFilePath];
}

- (void)player_handler_openVoice {
    [self.sdkHandler sdk_handler_openVoice];
}

- (void)player_handler_closeVoice {
    [self.sdkHandler sdk_handler_closeVoice];
}

- (void)player_handler_resizePlayViewSize:(CGSize)size {
    [self.sdkHandler sdk_handler_resize:size];
}

- (void)player_handler_initialPlayer {
    [self.sdkHandler sdk_handler_initialPlayer];
}

- (void)player_handler_destoryPlayer {
    [self.dataHandler data_handler_clean];
    [self.sdkHandler sdk_handler_destoryPlayer];
}


#pragma mark - PlaybackPlayerSDKHandlerDelegate
/// 开始播放
- (void)sdk_handler:(PlaybackPlayerSDKHandler *)handler
           deviceId:(NSString *)deviceId
didStartPlayAtStartTimestamp:(NSTimeInterval)startTimestamp
           duration:(NSUInteger)duration {
    if (_delegate && [_delegate respondsToSelector:@selector(player_handler:didPlayedWithStartTimestamp:duration:)]) {
        [_delegate player_handler:self
      didPlayedWithStartTimestamp:startTimestamp
                         duration:duration];
    }
}

/// 播放中
- (void)sdk_handler:(PlaybackPlayerSDKHandler *)handler
           deviceId:(NSString *)deviceId
   didPlayingAtTime:(NSUInteger)playingTime
     startTimestamp:(NSTimeInterval)startTimestamp
           duration:(NSUInteger)duration {
    if (_delegate && [_delegate respondsToSelector:@selector(player_handler:didPlayingAtTime:startTimestamp:duration:)]) {
        [_delegate player_handler:self
                 didPlayingAtTime:playingTime
                   startTimestamp:startTimestamp
                         duration:duration];
    }
}

/// 播放完成
- (void)sdk_handler:(PlaybackPlayerSDKHandler *)handler
           deviceId:(NSString *)deviceId
didEndedPlayAtStartTimestamp:(NSTimeInterval)startTimestamp
           duration:(NSUInteger)duration {
    if (_delegate && [_delegate respondsToSelector:@selector(player_handler:didEndedPlayAtStartTimestamp:duration:)]) {
        [_delegate player_handler:self
     didEndedPlayAtStartTimestamp:startTimestamp
                         duration:duration];
    }
}

/// 可以获取预览图
- (void)sdk_handler:(PlaybackPlayerSDKHandler *)handler
           deviceId:(NSString *)deviceId
previewCanBeFetchedAtImageFilePath:(NSString *)imageFilePath
     startTimestamp:(NSTimeInterval)startTimestamp
             onTime:(NSUInteger)onTime {
    // 更新预览图
    [self updateWithPreviewImageFilePath:imageFilePath
                          startTimestamp:startTimestamp
                                  onTime:onTime];
}

/// 剪切完成
- (void)sdk_handler:(PlaybackPlayerSDKHandler *)handler
           deviceId:(NSString *)deviceId
didClipAtVideoFilePath:(NSString *)videoFilePath
          startTime:(NSUInteger)startTime
          totalTime:(NSUInteger)totalTime
          isSucceed:(BOOL)isSucceed {
    [self updateWithClipVideoFilePath:videoFilePath
                            startTime:startTime
                            totalTime:totalTime
                            isSucceed:isSucceed];
}

// 完成截图
- (void)sdk_handler:(PlaybackPlayerSDKHandler *)handler
           deviceId:(NSString *)deviceId
didSnapshotAtImageFilePath:(NSString *)imageFilePath
          isSucceed:(BOOL)isSucceed {
    if (isSucceed) {
        if (_delegate && [_delegate respondsToSelector:@selector(player_handler:didSucceedSnapshotWithImageFilePath:)]) {
            [_delegate player_handler:self didSucceedSnapshotWithImageFilePath:imageFilePath];
        }
    } else {
        if (_delegate && [_delegate respondsToSelector:@selector(player_handler:didFailedSnapshotWithImageFilePath:)]) {
            [_delegate player_handler:self didFailedSnapshotWithImageFilePath:imageFilePath];
        }
    }
}

#pragma mark - PlaybackPlayerDataHandlerDelegate
- (void)data_handler:(PlaybackPlayerDataHandler *)handler
previewExistAtImageFilePath:(NSString *)imageFilePath
      startTimestamp:(NSTimeInterval)startTimestamp
              onTime:(NSUInteger)onTime {
    // 用预览图更新
    [self updateWithPreviewImageFilePath:imageFilePath
                          startTimestamp:startTimestamp
                                  onTime:onTime];
}

- (void)data_handler:(PlaybackPlayerDataHandler *)handler
previewNotExistAtImageFilePath:(NSString *)imageFilePath
       videoFilePath:(NSString *)videoFilePath
      startTimestamp:(NSTimeInterval)startTimestamp
              onTime:(NSUInteger)onTime {
    // 获取预览图
    [self.sdkHandler sdk_handler_fetchPreviewWithVideoFilePath:videoFilePath
                                                 imageFilePath:imageFilePath
                                                startTimestamp:startTimestamp
                                                        onTime:onTime];
}

- (void)data_handler:(PlaybackPlayerDataHandler *)handler
videoExistAtVideoFilePath:(NSString *)videoFilePath
      startTimestamp:(NSTimeInterval)startTimestamp
            duration:(NSUInteger)duration {
    // 开始播放
    [self.sdkHandler sdk_handler_startPlayWithVideoFilePath:videoFilePath
                                             startTimestamp:startTimestamp
                                                   duration:duration];
}

- (void)data_handler:(PlaybackPlayerDataHandler *)handler
videoNotExistAtVideoFilePath:(NSString *)videoFilePath
      startTimestamp:(NSTimeInterval)startTimestamp
            duration:(NSUInteger)duration {
    GosLog(@"需要播放的文件不存在，下载ing");
}

- (void)data_handler:(PlaybackPlayerDataHandler *)handler
   clipVideoFilePath:(NSString *)clipVideoFilePath
           startTime:(NSUInteger)startTime
           totalTime:(NSUInteger)totalTime
fromOriginVideoFilePath:(NSString *)originVideoFilePath {
    // 开始剪切
    [self.sdkHandler sdk_handler_startClipWithOriginalFilePath:originVideoFilePath
                                          destionationFilePath:clipVideoFilePath
                                                     startTime:startTime
                                                     totalTime:totalTime];
}


#pragma mark - private method
- (void)updateWithPreviewImageFilePath:(NSString *)imageFilePath
                        startTimestamp:(NSTimeInterval)startTimestamp
                                onTime:(NSUInteger)onTime {
    // 预览图
    UIImage *previewImage = [UIImage imageWithContentsOfFile:imageFilePath];
    GosLog(@"daniel: 获取到的预览图：%@", previewImage);
    if (previewImage) {
        if (_delegate && [_delegate respondsToSelector:@selector(player_handler:didSucceedFetchedPreviewImage:startTimestamp:onTime:)]) {
            [_delegate player_handler:self
        didSucceedFetchedPreviewImage:previewImage
                       startTimestamp:startTimestamp
                               onTime:onTime];
        }
    } else {
        if (_delegate && [_delegate respondsToSelector:@selector(player_handler:didFailedFetchedPreviewImageFromImageFilePath:startTimestamp:onTime:)]) {
            [_delegate player_handler:self
didFailedFetchedPreviewImageFromImageFilePath:imageFilePath
                       startTimestamp:startTimestamp
                               onTime:onTime];
        }
    }
}

- (void)updateWithClipVideoFilePath:(NSString *)videoFilePath
                          startTime:(NSUInteger)startTime
                          totalTime:(NSUInteger)totalTime
                          isSucceed:(BOOL)isSucceed {
    // 判断剪切文件是否存在
    BOOL clipExist = [self.dataHandler data_handler_fileExistAtFilePath:videoFilePath];
    GosLog(@"daniel: 剪切%@后的文件: %@", isSucceed?@"成功":@"失败", clipExist?@"存在":@"不存在——即失败");
    
    if (isSucceed && clipExist) {
        // 剪切文件存在并成功剪切
        if (_delegate && [_delegate respondsToSelector:@selector(player_handler:didSucceedClipWithVideoFilePath:startTime:totalTime:)]) {
            [_delegate player_handler:self
      didSucceedClipWithVideoFilePath:videoFilePath
                            startTime:startTime
                            totalTime:totalTime];
        }
    } else {
        // 不存在
        if (_delegate && [_delegate respondsToSelector:@selector(player_handler:didFailedClipWithVideoFilePath:startTime:totalTime:)]) {
            [_delegate player_handler:self
       didFailedClipWithVideoFilePath:videoFilePath
                            startTime:startTime
                            totalTime:totalTime];
        }
    }
    
}


#pragma mark - getters and setters
- (PlaybackPlayerView *)playerView {
    if (!_playerView) {
        _playerView = [[PlaybackPlayerView alloc] init];
    }
    return _playerView;
}

- (PlaybackPlayerSDKHandler *)sdkHandler {
    if (!_sdkHandler) {
        _sdkHandler = [[PlaybackPlayerSDKHandler alloc] initWithDeviceId:_deviceId
                                                                playView:self.playerView];
        _sdkHandler.delegate = self;
    }
    return _sdkHandler;
}

- (PlaybackPlayerDataHandler *)dataHandler {
    if (!_dataHandler) {
        _dataHandler = [[PlaybackPlayerDataHandler alloc] initWithDeviceId:_deviceId];
        _dataHandler.delegate = self;
    }
    return _dataHandler;
}

@end
