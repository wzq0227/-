//  TFCardPlayerHandler.h
//  GosIPCs
//
//  Create by daniel.hu on 2019/2/19.
//  Copyright © 2019年 goscam. All rights reserved.

#import <Foundation/Foundation.h>

/**
 设备在线状态、连接状态
 */
typedef NS_ENUM(NSInteger, TFPHDeviceStateAndConnectState) {
    /// 不在线状态
    TFPHDeviceStateAndConnectStateNotOnline,
    /// 在线并连接状态
    TFPHDeviceStateAndConnectStateOnlineAndConnected,
    /// 在线并非连接状态
    TFPHDeviceStateAndConnectStateOnlineAndNotConnected,
};

NS_ASSUME_NONNULL_BEGIN
@class PlaybackPlayerView;
@protocol TFCardPlayerHandlerDelegate;

/**
 管理播放视图（PlayerView)、SDK层（TF卡流播处理核心逻辑）、数据存取
 */
@interface TFCardPlayerHandler : NSObject
/// 代理
@property (nonatomic, weak) id<TFCardPlayerHandlerDelegate> delegate;
/// 播放视图
@property (nonatomic, readonly, strong) PlaybackPlayerView *playerView;

/**
 初始化
 
 @param deviceId 设备id
 */
- (instancetype)initWithDeviceId:(NSString *)deviceId;

/** 初始化播放器 */
- (void)player_handler_initialPlayer;

/** 摧毁播放器 */
- (void)player_handler_destoryPlayer;

/**
 获取预览图

 @param timestamp 预览图时间戳
 */
- (void)player_handler_fetchPreviewAtTimestamp:(NSTimeInterval)timestamp;

/**
 开始播放

 @param startTimestamp 播放开始时间戳
 */
- (void)player_handler_startPlayWithStartTimestamp:(NSTimeInterval)startTimestamp;

/**
 开始剪切

 @param fileName 剪切的文件名。存在后缀名时使用该命名，不存在后缀名则默认.mp4
 @param startTimestamp 剪切开始时间戳
 @param duration 剪切总时长
 */
- (void)player_handler_startClipWithFileName:(NSString *)fileName
                              startTimestamp:(NSTimeInterval)startTimestamp
                                    duration:(NSUInteger)duration;

/** 截图 */
- (void)player_handler_snapshot;

/** 开启声音 */
- (void)player_handler_openVoice;

/** 关闭声音 */
- (void)player_handler_closeVoice;

/** 重置尺寸 */
- (void)player_handler_resizePlayViewSize:(CGSize)size;

@end


#pragma mark - TFCardPlayerHandlerDelegate
/**
 TFCardPlayerHandler代理
 */
@protocol TFCardPlayerHandlerDelegate <NSObject>
/**
 设备在线状态、连接状态 更新
 
 @param handler TFCardPlayerHandler
 @param deviceStateAndConnectState 设备在线状态、连接状态
 */
- (void)player_handler:(TFCardPlayerHandler *)handler didChangedDeviceStateAndConnectState:(TFPHDeviceStateAndConnectState)deviceStateAndConnectState;

/**
 获取预览图 成功
 
 @param handler TFCardPlayerHandler
 @param previewImage 预览图
 @param startTimestamp 开始时间戳
 */
- (void)player_handler:(TFCardPlayerHandler *)handler didSucceedFetchedPreviewImage:(UIImage *)previewImage startTimestamp:(NSTimeInterval)startTimestamp;

/**
 获取预览图 失败
 
 @param handler TFCardPlayerHandler
 @param imageFilePath 目标预览图片存储路径
 @param startTimestamp 开始时间戳
 */
- (void)player_handler:(TFCardPlayerHandler *)handler didFailedFetchedPreviewImageFromImageFilePath:(NSString *)imageFilePath startTimestamp:(NSTimeInterval)startTimestamp;
/**
 截图成功
 
 @param handler TFCardPlayerHandler
 @param imageFilePath 截图图片存储路径
 */
- (void)player_handler:(TFCardPlayerHandler *)handler didSucceedSnapshotWithImageFilePath:(NSString *)imageFilePath;

/**
 截图失败
 
 @param handler TFCardPlayerHandler
 @param imageFilePath 截图图片存储路径
 */
- (void)player_handler:(TFCardPlayerHandler *)handler didFailedSnapshotWithImageFilePath:(NSString *)imageFilePath;

/**
 播放失败

 @param handler TFCardPlayerHandler
 @param startTimestamp 播放开始时间戳
 */
- (void)player_handler:(TFCardPlayerHandler *)handler didFailedPlayAtStartTimestamp:(NSTimeInterval)startTimestamp;

/**
 开始播放

 @param handler TFCardPlayerHandler
 @param startTimestamp 播放开始时间戳
 */
- (void)player_handler:(TFCardPlayerHandler *)handler didStartPlayAtStartTimestamp:(NSTimeInterval)startTimestamp;

/**
 播放缓存中

 @param handler TFCardPlayerHandler
 @param startTimestamp 播放开始时间戳
 */
- (void)player_handler:(TFCardPlayerHandler *)handler playStartLoadingAtStartTimestamp:(NSTimeInterval)startTimestamp;

/**
 播放结束缓存
 
 @param handler TFCardPlayerHandler
 @param startTimestamp 播放开始时间戳
 */
- (void)player_handler:(TFCardPlayerHandler *)handler playEndedLoadingAtStartTimestamp:(NSTimeInterval)startTimestamp;

/**
 播放完成
 
 @param handler TFCardPlayerHandler
 @param startTimestamp 播放开始时间戳
 */
- (void)player_handler:(TFCardPlayerHandler *)handler didEndedPlayAtStartTimestamp:(NSTimeInterval)startTimestamp;

/**
 正在播放
 
 @param handler TFCardPlayerHandler
 @param playingTimestamp 正在播放的时间戳
 @param startTimestamp 播放开始时间戳
 */
- (void)player_handler:(TFCardPlayerHandler *)handler didPlayingAtTimestamp:(NSTimeInterval)playingTimestamp startTimestamp:(NSTimeInterval)startTimestamp;

/**
 剪切 成功

 @param handler TFCardPlayerHandler
 @param videoFilePath 剪切存储路径
 @param startTimestamp 剪切开始时间戳
 @param duration 剪切总时长
 */
- (void)player_handler:(TFCardPlayerHandler *)handler didSucceedClipAtVideoFilePath:(NSString *)videoFilePath startTimestamp:(NSTimeInterval)startTimestamp duration:(NSUInteger)duration;

/**
 剪切 失败

 @param handler TFCardPlayerHandler
 @param videoFilePath 剪切存储路径
 @param startTimestamp 剪切开始时间戳
 @param duration 剪切总时长
 */
- (void)player_handler:(TFCardPlayerHandler *)handler didFailedClipAtVideoFilePath:(NSString *)videoFilePath startTimestamp:(NSTimeInterval)startTimestamp duration:(NSUInteger)duration;

@end

NS_ASSUME_NONNULL_END
