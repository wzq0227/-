//  PlaybackPlayerHandler.h
//  GosIPCs
//
//  Create by daniel.hu on 2019/2/13.
//  Copyright © 2019年 goscam. All rights reserved.

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@protocol PlaybackPlayerHandlerDelegate;
@class PlaybackPlayerView;
@class VideoSlicesApiRespModel;

/**
 管理播放视图、SDK层（云回放核心逻辑）、数据管理者
 */
@interface PlaybackPlayerHandler : NSObject
/// 代理
@property (nonatomic, weak) id<PlaybackPlayerHandlerDelegate> delegate;
/// 播放视图
@property (nonatomic, readonly, strong) PlaybackPlayerView *playerView;

/**
 初始化

 @param deviceId 设备id
 @return PlaybackPlayerHandler
 */
- (instancetype)initWithDeviceId:(NSString *)deviceId;


/**
 获取预览图

 @param videoModel VideoSlicesApiRespModel
 @param onTime 时间点（从0开始）
 */
- (void)player_handler_fetchPreviewWithVideoModel:(VideoSlicesApiRespModel *)videoModel
                                           onTime:(NSUInteger)onTime;

/**
 开始播放
 
 @param videoModel VideoSlicesApiRespModel
 */
- (void)player_handler_startPlayWithVideoModel:(VideoSlicesApiRespModel *)videoModel;


/**
 开始剪切

 @param videos VideoSlicesApiRespModel数组
 @param fileName 剪切文件名
 @param startTime 开始时间点（从0开始）
 @param duration 总时长
 */
- (void)player_handler_startClipWithVideos:(NSArray <VideoSlicesApiRespModel *> *)videos
                                  fileName:(NSString *)fileName
                                 startTime:(NSUInteger)startTime
                                  duration:(NSUInteger)duration;

/** 截图 */
- (void)player_handler_snapshot;

/** 开启声音 */
- (void)player_handler_openVoice;

/** 关闭声音 */
- (void)player_handler_closeVoice;

/** 重新设置尺寸 */
- (void)player_handler_resizePlayViewSize:(CGSize)size;

/** 初始化播放器 */
- (void)player_handler_initialPlayer;

/** 销毁播放器 */
- (void)player_handler_destoryPlayer;

@end

#pragma mark - PlaybackPlayerHandlerDelegate
/**
 PlaybackPlayerHandler代理
 */
@protocol PlaybackPlayerHandlerDelegate <NSObject>
/**
 获取预览图 成功
 
 @param handler PlaybackPlayerHandler
 @param previewImage 预览图
 @param startTimestamp 开始时间戳
 @param onTime 开始时间点
 */
- (void)player_handler:(PlaybackPlayerHandler *)handler didSucceedFetchedPreviewImage:(UIImage *)previewImage startTimestamp:(NSTimeInterval)startTimestamp onTime:(NSUInteger)onTime;

/**
 获取预览图 失败
 
 @param handler PlaybackPlayerHandler
 @param imageFilePath 目标预览图片存储路径
 @param startTimestamp 开始时间戳
 @param onTime 开始时间点
 */
- (void)player_handler:(PlaybackPlayerHandler *)handler didFailedFetchedPreviewImageFromImageFilePath:(NSString *)imageFilePath startTimestamp:(NSTimeInterval)startTimestamp onTime:(NSUInteger)onTime;


/**
 截图成功
 
 @param handler PlaybackPlayerHandler
 @param imageFilePath 截图图片存储路径
 */
- (void)player_handler:(PlaybackPlayerHandler *)handler didSucceedSnapshotWithImageFilePath:(NSString *)imageFilePath;

/**
 截图失败
 
 @param handler PlaybackPlayerHandler
 @param imageFilePath 截图图片存储路径
 */
- (void)player_handler:(PlaybackPlayerHandler *)handler didFailedSnapshotWithImageFilePath:(NSString *)imageFilePath;

/**
 开始播放
 
 @param handler PlaybackPlayerHandler
 @param startTimestamp 开始时间戳
 @param duration 总时长
 */
- (void)player_handler:(PlaybackPlayerHandler *)handler didPlayedWithStartTimestamp:(NSTimeInterval)startTimestamp duration:(NSUInteger)duration;

/**
 正在播放
 
 @param handler PlaybackPlayerHandler
 @param playingTime 当前播放时间（从0开始）
 @param startTimestamp 开始时间戳
 @param duration 总时长
 */
- (void)player_handler:(PlaybackPlayerHandler *)handler didPlayingAtTime:(NSUInteger)playingTime startTimestamp:(NSTimeInterval)startTimestamp duration:(NSUInteger)duration;

/**
 结束播放
 
 @param handler PlaybackPlayerHandler
 @param startTimestamp 开始时间戳
 @param duration 总时长
 */
- (void)player_handler:(PlaybackPlayerHandler *)handler didEndedPlayAtStartTimestamp:(NSTimeInterval)startTimestamp duration:(NSUInteger)duration;

/**
 剪切 成功
 
 @param handler PlaybackPlayerHandler
 @param videoFilePath MP4文件存储路径
 @param startTime 开始时间点
 @param totalTime 总时长
 */
- (void)player_handler:(PlaybackPlayerHandler *)handler didSucceedClipWithVideoFilePath:(NSString *)videoFilePath startTime:(NSUInteger)startTime totalTime:(NSUInteger)totalTime;

/**
 剪切 失败
 
 @param handler PlaybackPlayerHandler
 @param videoFilePath MP4文件存储路径
 @param startTime 开始时间点
 @param totalTime 总时长
 */
- (void)player_handler:(PlaybackPlayerHandler *)handler didFailedClipWithVideoFilePath:(NSString *)videoFilePath startTime:(NSUInteger)startTime totalTime:(NSUInteger)totalTime;

@end
NS_ASSUME_NONNULL_END
