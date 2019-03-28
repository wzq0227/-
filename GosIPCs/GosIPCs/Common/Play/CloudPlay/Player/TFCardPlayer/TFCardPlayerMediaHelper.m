//  TFCardPlayerMediaHelper.m
//  Goscom
//
//  Create by daniel.hu on 2019/2/21.
//  Copyright © 2019年 goscam. All rights reserved.

#import "TFCardPlayerMediaHelper.h"

@implementation TFCardPlayerMediaHelper
#pragma mark - public class method
+ (BOOL)fileExistWithFilePath:(NSString *)filePath {
    // 如果字符串为空
    if (IS_EMPTY_STRING(filePath)) return NO;
    
    BOOL exist = NO;
    BOOL isDir = NO;
    exist = [[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:&isDir];
    
    return !isDir && exist;
}

+ (BOOL)previewFileExistWithDeviceId:(NSString *)deviceId
                      startTimestamp:(NSTimeInterval)startTimestamp {
    NSString *filePath = [TFCardPlayerMediaHelper previewFilePathWithDeviceId:deviceId
                                                               startTimestamp:startTimestamp];
    
    return [TFCardPlayerMediaHelper fileExistWithFilePath:filePath];
}
+ (NSString *)previewFilePathWithDeviceId:(NSString *)deviceId
                           startTimestamp:(NSTimeInterval)startTimestamp {
    // 文件名：设备id_时间戳，例子：Z99999999999_123456789
    NSString *fileName = [NSString stringWithFormat:@"%@_%zd", deviceId, [@(startTimestamp) integerValue]];
    
    return [TFCardPlayerMediaHelper previewFilePathWithDeviceId:deviceId
                                                       fileName:fileName];
}

+ (NSString *)clipFilePathWithDeviceId:(NSString *)deviceId
                              fileName:(NSString *)fileName {
    NSString *path = [MediaManager pathWithDevId:deviceId
                                        fileName:fileName
                                       mediaType:GosMediaTFCardCrop
                                      deviceType:GosDeviceIPC
                                        position:PositionMain];
    GosLog(@"MP4文件路径: %@", path);
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


#pragma mark - private class method
+ (NSString *)previewFilePathWithDeviceId:(NSString *)deviceId
                                 fileName:(NSString *)fileName {
    NSString *path = [MediaManager pathWithDevId:deviceId
                                        fileName:fileName
                                       mediaType:GosMediaTFCardPreview
                                      deviceType:GosDeviceIPC
                                        position:PositionMain];
    GosLog(@"预览图文件路径: %@", path);
    return path;
    
}
@end
