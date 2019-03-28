//  CloudPlaybackViewModel.h
//  GosIPCs
//
//  Create by daniel.hu on 2019/1/4.
//  Copyright © 2019年 goscam. All rights reserved.

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class DevDataModel;
@class GosTimeAxisData;
@class RecMonthDataModel;
@class VideoSlicesApiRespModel;
@class PackageValidTimeApiRespModel;
@interface CloudPlaybackViewModel : NSObject

#pragma mark - VideoSlicesApiRespModel
/**
 PackageValidTimeApiRespModel => NSDate模型数组
 */
- (NSArray <NSDate *> *)convertPackageValidTimeApiRespModelToDateArray:(PackageValidTimeApiRespModel *)respModel;

/**
 RecMonthDataModel模型数组 => NSDate模型数组
 */
- (NSArray <NSDate *> *)convertRecMonthDataModelArrayToDateArray:(NSArray <RecMonthDataModel *> *)respModelArray;

/**
 优化数据——去重
 */
- (NSArray *)optimiseVideosModelArray:(NSArray *)videosModelArray;

/**
 优化数据——合并去重
 */
- (NSArray *)optimiseVideosModelArray:(NSArray *)videosModelArray other:(NSArray *)other;

/**
 判断模型数据是否属于date为当天
 @param respModel VideoSlicesApiRespModel
 @param date 指定判断日期
 */
- (BOOL)validateVideoSlicesRespModel:(VideoSlicesApiRespModel *)respModel
                      isBelongToDate:(NSDate *)date;

/**
 VideoSlicesApiRespModel模型数组 or SDAlarmDataModel模型数组
 转化为GosTimeAxisData模型数组
 */
- (NSArray <GosTimeAxisData *> *)convertVideosModelArrayToTimeAxisDataModelArray:(NSArray *)videosModelArray;


#pragma mark - 设备相关

/**
 根据设备id 获取 设备名
 */
- (NSString *_Nullable)fetchDeviceNameFromDeviceId:(NSString *)deviceId;

/**
 通过设备id 获取设备模型
 */
- (DevDataModel *)fetchDeviceDataModelWithDeviceId:(NSString *)deviceId;

@end

NS_ASSUME_NONNULL_END
