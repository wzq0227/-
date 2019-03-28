//  PlaybackPlayerSDKHandler.h
//  Goscom
//
//  Create by daniel.hu on 2019/2/16.
//  Copyright © 2019年 goscam. All rights reserved.

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@protocol PlaybackPlayerSDKHandlerDelegate;
/**
 封装PlayerSDK 关于云回放逻辑
 */
@interface PlaybackPlayerSDKHandler : NSObject
/// 代理
@property (nonatomic, weak) id<PlaybackPlayerSDKHandlerDelegate> delegate;

/**
 初始化
 
 @param deviceId 设备id
 @param playView 播放视图
 */
- (instancetype)initWithDeviceId:(NSString *)deviceId
                        playView:(UIView *)playView;

/**
 @brief 开始播放
 @param videoFilePath H264文件路径
 */
- (void)sdk_handler_startPlayWithVideoFilePath:(NSString *)videoFilePath
                                startTimestamp:(NSTimeInterval)startTimestamp
                                      duration:(NSUInteger)duration;

/**
 @brief 获取预览图
 @param videoFilePath H264文件路径
 @param imageFilePath 预览图.jpg文件存储路径
 @param onTime 距离文件起始点(0秒)的指定时间（单位：秒）
 */
- (void)sdk_handler_fetchPreviewWithVideoFilePath:(NSString *)videoFilePath
                               imageFilePath:(NSString *)imageFilePath
                              startTimestamp:(NSTimeInterval)startTimestamp
                                      onTime:(NSUInteger)onTime;

/**
 @brief 开始剪切
 
 @param originalFilePath 源H264文件路径
 @param destionationFilePath 目标mp4文件存储路径
 @param startTime 距离文件起始点(0秒)的指定时间（单位：秒）
 @param totalTime mp4总时长
 */
- (void)sdk_handler_startClipWithOriginalFilePath:(NSString *)originalFilePath
                             destionationFilePath:(NSString *)destionationFilePath
                                        startTime:(NSUInteger)startTime
                                        totalTime:(NSUInteger)totalTime;


/**
 @brief 获取截图
 @param imageFilePath 截图.jpg存储路径
 */
- (void)sdk_handler_snapshotWithImageFilePath:(NSString *)imageFilePath;

/**
 @brief 开启声音
 */
- (void)sdk_handler_openVoice;

/**
 @brief 关闭声音
 */
- (void)sdk_handler_closeVoice;

/**
 重新设置尺寸

 @param size CGSize
 */
- (void)sdk_handler_resize:(CGSize)size;

/**
 初始化播放器
 */
- (void)sdk_handler_initialPlayer;

/**
 销毁播放器
 */
- (void)sdk_handler_destoryPlayer;

@end


#pragma mark - PlaybackPlayerSDKHandlerDelegate
/**
 PlaybackPlayerSDKHandler代理
 */
@protocol PlaybackPlayerSDKHandlerDelegate <NSObject>
/**
 @brief 开始播放
 
 @param handler PlaybackPlayerSDKHandler
 @param deviceId 设备id
 @param startTimestamp 开始播放时间戳
 @param duration 总时长
 */
- (void)sdk_handler:(PlaybackPlayerSDKHandler *)handler
           deviceId:(NSString *)deviceId
didStartPlayAtStartTimestamp:(NSTimeInterval)startTimestamp
           duration:(NSUInteger)duration;

/**
 @brief 当前正在播放
 
 @param handler PlaybackPlayerSDKHandler
 @param deviceId 设备id
 @param playingTime 当前播放时间——从0~duration的时间（秒）
 @param startTimestamp 开始播放时间戳
 @param duration 总时长
 */
- (void)sdk_handler:(PlaybackPlayerSDKHandler *)handler
           deviceId:(NSString *)deviceId
   didPlayingAtTime:(NSUInteger)playingTime
     startTimestamp:(NSTimeInterval)startTimestamp
           duration:(NSUInteger)duration;

/**
 @brief 结束播放
 
 @param handler PlaybackPlayerSDKHandler
 @param deviceId 设备id
 @param startTimestamp 开始时间戳
 @param duration 总时长
 */
- (void)sdk_handler:(PlaybackPlayerSDKHandler *)handler
           deviceId:(NSString *)deviceId
didEndedPlayAtStartTimestamp:(NSTimeInterval)startTimestamp
           duration:(NSUInteger)duration;

/**
 @brief 可以获取预览图
 
 @param handler PlaybackPlayerSDKHandler
 @param deviceId 设备id
 @param imageFilePath 预览图路径
 @param startTimestamp 开始时间戳
 @param onTime 距离文件起始点(0秒)的指定时间（单位：秒）
 */
- (void)sdk_handler:(PlaybackPlayerSDKHandler *)handler
           deviceId:(NSString *)deviceId
previewCanBeFetchedAtImageFilePath:(NSString *)imageFilePath
     startTimestamp:(NSTimeInterval)startTimestamp
             onTime:(NSUInteger)onTime;


/**
 @brief 剪切完成
 
 @param handler PlaybackPlayerSDKHandler
 @param deviceId 设备id
 @param videoFilePath 剪切后的MP4文件存储路径
 @param startTime 距离源H264文件起始点(0秒)的开始时间
 @param totalTime 剪切后的MP4文件时长
 @param isSucceed 是否成功
 */
- (void)sdk_handler:(PlaybackPlayerSDKHandler *)handler
           deviceId:(NSString *)deviceId
didClipAtVideoFilePath:(NSString *)videoFilePath
          startTime:(NSUInteger)startTime
          totalTime:(NSUInteger)totalTime
          isSucceed:(BOOL)isSucceed;

/**
 完成截图
 
 @param handler PlaybackPlayerSDKHandler
 @param deviceId 设备id
 @param imageFilePath 截图保存路径
 @param isSucceed 是否成功
 */
- (void)sdk_handler:(PlaybackPlayerSDKHandler *)handler
           deviceId:(NSString *)deviceId
didSnapshotAtImageFilePath:(NSString *)imageFilePath
          isSucceed:(BOOL)isSucceed;
@end

NS_ASSUME_NONNULL_END
