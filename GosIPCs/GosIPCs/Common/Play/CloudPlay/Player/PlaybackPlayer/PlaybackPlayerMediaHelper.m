//  PlaybackPlayerMediaHelper.m
//  Goscom
//
//  Create by daniel.hu on 2019/2/16.
//  Copyright © 2019年 goscam. All rights reserved.

#import "PlaybackPlayerMediaHelper.h"
#import "VideoSlicesApiRespModel.h"

@implementation PlaybackPlayerMediaHelper
#pragma mark - 文件路径方法
+ (NSString *)videoFilePathWithDeviceId:(NSString *)deviceId
                             videoModel:(VideoSlicesApiRespModel *)videoModel {
    NSString *fileName = [PlaybackPlayerMediaHelper videoFileNameWithVideoModel:videoModel];
    
    return [PlaybackPlayerMediaHelper videoFilePathWithDeviceId:deviceId
                                                       fileName:fileName];
}

+ (NSString *)previewFilePathWithDeviceId:(NSString *)deviceId
                               videoModel:(VideoSlicesApiRespModel *)videoModel onTime:(NSUInteger)onTime {
    NSString *fileName = [PlaybackPlayerMediaHelper previewFileNameWithVideoModel:videoModel onTime:onTime];
    
    return [PlaybackPlayerMediaHelper previewFilePathWithDeviceId:deviceId
                                                         fileName:fileName];
}

+ (NSString *)clipFileNameWithVideoModel:(VideoSlicesApiRespModel *)videoModel
                               startTime:(NSUInteger)startTime {
    // 例：startTime = 0
    // 例：7_Z99A42100000001/201812240154440b.H264 -> 7_Z99A42100000001_201812240154440b_0.mp4
    NSString *result = [[videoModel.key stringByReplacingOccurrencesOfString:@"/" withString:@"_"] stringByReplacingOccurrencesOfString:@".H264" withString:[NSString stringWithFormat:@"_%zd.mp4", startTime]];
    
    return result;
}

#pragma mark - 文件存在判断方法
+ (BOOL)videoFileExistWithDeviceId:(NSString *)deviceId
                        videoModel:(VideoSlicesApiRespModel *)videoModel {
    NSString *filePath = [PlaybackPlayerMediaHelper videoFilePathWithDeviceId:deviceId videoModel:videoModel];
    
    return [PlaybackPlayerMediaHelper fileExistWithFilePath:filePath];
}

+ (BOOL)previewFileExistWithDeviceId:(NSString *)deviceId
                          videoModel:(VideoSlicesApiRespModel *)videoModel
                              onTime:(NSUInteger)onTime {
    NSString *filePath = [PlaybackPlayerMediaHelper previewFilePathWithDeviceId:deviceId videoModel:videoModel onTime:onTime];
    
    return [PlaybackPlayerMediaHelper fileExistWithFilePath:filePath];
}

+ (BOOL)temporaryVideoFileForClipExist {
    NSString *filePath = [PlaybackPlayerMediaHelper temporaryVideoFilePathForClip];
    
    return [PlaybackPlayerMediaHelper fileExistWithFilePath:filePath];
}

+ (BOOL)fileExistWithFilePath:(NSString *)filePath {
    // 如果字符串为空
    if (IS_EMPTY_STRING(filePath)) return NO;
    
    BOOL exist = NO;
    BOOL isDir = NO;
    exist = [[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:&isDir];
    
    return !isDir && exist;
}


#pragma mark - 文件路径核心方法
+ (NSString *)videoFilePathWithDeviceId:(NSString *)deviceId
                               fileName:(NSString *)fileName {
    NSString *path = [MediaManager pathWithDevId:deviceId
                                        fileName:fileName
                                       mediaType:GosMediaCloudH264
                                      deviceType:GosDeviceIPC
                                        position:PositionMain];
    GosLog(@"H264文件路径: %@", path);
    return path;
}

+ (NSString *)clipFilePathWithDeviceId:(NSString *)deviceId
                              fileName:(NSString *)fileName {
    NSString *path = [MediaManager pathWithDevId:deviceId
                                        fileName:fileName
                                       mediaType:GosMediaCloudCrop
                                      deviceType:GosDeviceIPC
                                        position:PositionMain];
    GosLog(@"MP4文件路径: %@", path);
    return path;
}

+ (NSString *)previewFilePathWithDeviceId:(NSString *)deviceId
                                 fileName:(NSString *)fileName {
    NSString *path = [MediaManager pathWithDevId:deviceId
                                        fileName:fileName
                                       mediaType:GosMediaCloudPreview
                                      deviceType:GosDeviceIPC
                                        position:PositionMain];
    GosLog(@"预览图文件路径: %@", path);
    return path;
    
}

+ (NSString *)snapshotFilePathWithDeviceId:(NSString *)deviceId {
    NSString *path = [MediaManager pathWithDevId:deviceId
                                        fileName:nil
                                       mediaType:GosMediaSnapshot
                                      deviceType:GosDeviceIPC
                                        position:PositionMain];
    GosLog(@"截图文件路径: %@", path);
    return path;
}

+ (NSString *)temporaryVideoFilePathForClip {
    // 缓存文件夹
    NSString *cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    return [cachePath stringByAppendingPathComponent:@"ACEDONG_0806.H264"];
}


#pragma mark - 文件名
+ (NSString *)videoFileNameWithVideoModel:(VideoSlicesApiRespModel *)videoModel {
    return [PlaybackPlayerMediaHelper videoFileNameWithVideoModelKey:videoModel.key];
}

+ (NSString *)previewFileNameWithVideoModel:(VideoSlicesApiRespModel *)videoModel
                                     onTime:(NSUInteger)onTime {
    return [PlaybackPlayerMediaHelper previewFileNameWithVideoModelKey:videoModel.key
                                                                onTime:onTime];
}


#pragma mark - 文件名核心方法
+ (NSString *)previewFileNameWithVideoModelKey:(NSString *)key
                                        onTime:(NSUInteger)onTime {
    // 例：onTime = 0
    // 例：7_Z99A42100000001/201812240154440b.H264 -> 7_Z99A42100000001_201812240154440b_0.jpg
    NSString *result = [[key stringByReplacingOccurrencesOfString:@"/" withString:@"_"] stringByReplacingOccurrencesOfString:@".H264" withString:[NSString stringWithFormat:@"_%zd.jpg", onTime]];
    
    return result;
}

+ (NSString *)videoFileNameWithVideoModelKey:(NSString *)key {
    // 例：7_Z99A42100000001/201812240154440b.H264 -> 7_Z99A42100000001_201812240154440b
    NSString *result = [key stringByReplacingOccurrencesOfString:@"/" withString:@"_"];
    
    return result;
}

@end
