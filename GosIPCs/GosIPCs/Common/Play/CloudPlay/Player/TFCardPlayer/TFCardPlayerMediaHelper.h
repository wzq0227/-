//  TFCardPlayerMediaHelper.h
//  Goscom
//
//  Create by daniel.hu on 2019/2/21.
//  Copyright © 2019年 goscam. All rights reserved.

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 TF卡 文件管理类
 */
@interface TFCardPlayerMediaHelper : NSObject

/// 判断文件是否存在
+ (BOOL)fileExistWithFilePath:(NSString *)filePath;

/// 判断预览图是否已存在
+ (BOOL)previewFileExistWithDeviceId:(NSString *)deviceId
                      startTimestamp:(NSTimeInterval)startTimestamp;
/// 获取预览图文件路径
+ (NSString *)previewFilePathWithDeviceId:(NSString *)deviceId
                           startTimestamp:(NSTimeInterval)startTimestamp;

/// 获取剪切文件下载路径
+ (NSString *)clipFilePathWithDeviceId:(NSString *)deviceId
                              fileName:(NSString *)fileName;

/// 获取截图路径
+ (NSString *)snapshotFilePathWithDeviceId:(NSString *)deviceId;

@end

NS_ASSUME_NONNULL_END
