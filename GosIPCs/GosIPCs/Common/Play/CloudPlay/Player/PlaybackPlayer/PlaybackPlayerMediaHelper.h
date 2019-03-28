//  PlaybackPlayerMediaHelper.h
//  Goscom
//
//  Create by daniel.hu on 2019/2/16.
//  Copyright © 2019年 goscam. All rights reserved.

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class VideoSlicesApiRespModel;

/**
 云回放 文件管理类
 */
@interface PlaybackPlayerMediaHelper : NSObject
#pragma mark - 文件名
/// H264文件名 .H264
+ (NSString *)videoFileNameWithVideoModel:(VideoSlicesApiRespModel *)videoModel;

/// H264某时间点预览图文件名 .jpg
+ (NSString *)previewFileNameWithVideoModel:(VideoSlicesApiRespModel *)videoModel
                                     onTime:(NSUInteger)onTime;

/// 剪切默认文件名
+ (NSString *)clipFileNameWithVideoModel:(VideoSlicesApiRespModel *)videoModel
                               startTime:(NSUInteger)startTime;

#pragma mark - 视频文件相关 .H264
/// 判断下载的H264文件目标文件是否已存在
+ (BOOL)videoFileExistWithDeviceId:(NSString *)deviceId
                        videoModel:(VideoSlicesApiRespModel *)videoModel;

/// 获取H264下载路径
+ (NSString *)videoFilePathWithDeviceId:(NSString *)deviceId
                             videoModel:(VideoSlicesApiRespModel *)videoModel;

#pragma mark - 预览图文件相关 .jpg
/// 判断预览图文件是否已存在
+ (BOOL)previewFileExistWithDeviceId:(NSString *)deviceId
                          videoModel:(VideoSlicesApiRespModel *)videoModel
                              onTime:(NSUInteger)onTime;

/// 获取预览图下载路径
+ (NSString *)previewFilePathWithDeviceId:(NSString *)deviceId
                               videoModel:(VideoSlicesApiRespModel *)videoModel
                                   onTime:(NSUInteger)onTime;

#pragma mark - 剪切文件相关 .mp4
/// 获取剪切文件下载路径
+ (NSString *)clipFilePathWithDeviceId:(NSString *)deviceId
                              fileName:(NSString *)fileName;

#pragma mark - 截图文件相关 .jpg
/// 获取截图路径
+ (NSString *)snapshotFilePathWithDeviceId:(NSString *)deviceId;

#pragma mark - 临时文件 .H264 写H264文件到此文件，为剪切做准备
/// 判断临时文件是否已存在
+ (BOOL)temporaryVideoFileForClipExist;

/// 获取临时文件路径
+ (NSString *)temporaryVideoFilePathForClip;

#pragma mark - Helper
+ (BOOL)fileExistWithFilePath:(NSString *)filePath;

@end

NS_ASSUME_NONNULL_END
