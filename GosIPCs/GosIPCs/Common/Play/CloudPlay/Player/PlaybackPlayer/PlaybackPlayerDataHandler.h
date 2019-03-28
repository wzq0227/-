//  PlaybackPlayerDataHandler.h
//  Goscom
//
//  Create by daniel.hu on 2019/2/16.
//  Copyright © 2019年 goscam. All rights reserved.

#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

@protocol PlaybackPlayerDataHandlerDelegate;
@class VideoSlicesApiRespModel;

/**
 管理的云回放 数据、下载、存取
 */
@interface PlaybackPlayerDataHandler : NSObject
/// 代理
@property (nonatomic, weak) id<PlaybackPlayerDataHandlerDelegate> delegate;
/// 初始化
- (instancetype)initWithDeviceId:(NSString *)deviceId;

/**
 获取预览图路径

 @param videoModel VideoSlicesApiRespModel
 @param onTime 时间点
 */
- (void)data_handler_fetchPreviewFilePathWithVideoModel:(VideoSlicesApiRespModel *)videoModel
                                            onTime:(NSUInteger)onTime;


/**
 获取视频(H264)文件路径

 @param videoModel VideoSlicesApiRespModel
 */
- (void)data_handler_fetchVideoFilePathWithVideoModel:(VideoSlicesApiRespModel *)videoModel;

/**
 获取截图路径

 @return 截图路径
 */
- (NSString *_Nullable)data_handler_fetchSnapshotFilePath;

/**
 获取剪切路径
 
 @param videos VideoSlicesApiRespModel数组
 @param fileName 剪切文件名，有后缀就使用后缀没有会自动加.mp4。如为空就根据videoModel与startTime使用默认文件名
 @param startTime 时间点
 @param duration 总时长
 */
- (void)data_handler_fetchClipFilePathWithVideos:(NSArray <VideoSlicesApiRespModel *> *)videos
                                        fileName:(NSString *_Nullable)fileName
                                       startTime:(NSUInteger)startTime
                                        duration:(NSUInteger)duration;

/** 文件是否存在 */
- (BOOL)data_handler_fileExistAtFilePath:(NSString *)filePath;

/** 清理 */
- (void)data_handler_clean;

@end


#pragma mark - PlaybackPlayerDataHandlerDelegate

/**
 PlaybackPlayerDataHandler代理
 */
@protocol PlaybackPlayerDataHandlerDelegate <NSObject>

/**
 @brief 预览图存在
 
 @param handler PlaybackPlayerDataHandler
 @param imageFilePath 预览图路径
 @param startTimestamp 开始时间戳
 @param onTime 开始时间点
 */
- (void)data_handler:(PlaybackPlayerDataHandler *)handler previewExistAtImageFilePath:(NSString *)imageFilePath startTimestamp:(NSTimeInterval)startTimestamp onTime:(NSUInteger)onTime;

/**
 @brief 不存在预览图
 
 @param handler PlaybackPlayerDataHandler
 @param imageFilePath 预览图路径
 @param videoFilePath H264视频路径
 @param startTimestamp 开始时间戳
 @param onTime 距离文件起始点(0秒)的指定时间（单位：秒）
 */
- (void)data_handler:(PlaybackPlayerDataHandler *)handler previewNotExistAtImageFilePath:(NSString *)imageFilePath videoFilePath:(NSString *)videoFilePath startTimestamp:(NSTimeInterval)startTimestamp onTime:(NSUInteger)onTime;

/**
 @brief 视频存在
 
 @param handler PlaybackPlayerDataHandler
 @param videoFilePath H264视频路径
 @param startTimestamp 开始时间戳
 @param duration 视频总时长
 */
- (void)data_handler:(PlaybackPlayerDataHandler *)handler videoExistAtVideoFilePath:(NSString *)videoFilePath startTimestamp:(NSTimeInterval)startTimestamp duration:(NSUInteger)duration;

/**
 @brief 视频不存在，即将开始下载ing
 @note 此方法只在-data_handler_fetchVideoWithVideoModel:方法中反馈
 
 @param handler PlaybackPlayerDataHandler
 @param videoFilePath H264视频路径
 @param startTimestamp 开始时间戳
 @param duration 视频总时长
 */
- (void)data_handler:(PlaybackPlayerDataHandler *)handler videoNotExistAtVideoFilePath:(NSString *)videoFilePath startTimestamp:(NSTimeInterval)startTimestamp duration:(NSUInteger)duration;

/**
 @brief 剪切预存储路径
 
 @param handler PlaybackPlayerDataHandler
 @param clipVideoFilePath 剪切预存储路径
 @param startTime 开始时间（从0开始）
 @param totalTime 总时长
 @param originVideoFilePath 源H264文件路径
 */
- (void)data_handler:(PlaybackPlayerDataHandler *)handler clipVideoFilePath:(NSString *)clipVideoFilePath startTime:(NSUInteger)startTime totalTime:(NSUInteger)totalTime fromOriginVideoFilePath:(NSString *)originVideoFilePath;

@end

NS_ASSUME_NONNULL_END
