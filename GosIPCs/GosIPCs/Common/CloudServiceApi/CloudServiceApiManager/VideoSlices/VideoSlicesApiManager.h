//  VideoSlicesApiManager.h
//  GosIPCs
//
//  Create by daniel.hu on 2018/12/24.
//  Copyright © 2018年 goscam. All rights reserved.

#import "GosApiBaseManager.h"

/// APIManger的方法类型——决定methodName
typedef NS_ENUM(NSUInteger, VideoSlicesApiManagerMethodType) {
    /// 普通视频
    VideoSlicesApiManagerMethodTypeNormal,
    /// 报警视频
    VideoSlicesApiManagerMethodTypeAlarm,
};

NS_ASSUME_NONNULL_BEGIN
/**
 @brief 获取报警查询时间段视频 or 获取裸流切片数据
 @discussion
  request parameters: token, username, device_id, start_time, end_time
 
 
 @note reform data: NSArray<VideoSlicesApiRespModel> or @[]
 
 @note
 - 国内:
 
 获取报警查询时间段视频: http://cn-css.ulifecam.com/api/cloudstore/cloudstore-service/move-video/time-line
 
 获取裸流切片数据: http://cn-css.ulifecam.com/api/cloudstore/cloudstore-service/move-video/time-line/details
 
 - 国外:
 
 获取报警查询时间段视频: http://css.ulifecam.com/api/cloudstore/cloudstore-service/move-video/time-line
 
 获取裸流切片数据: http://css.ulifecam.com/api/cloudstore/cloudstore-service/move-video/time-line/details
 
 @attention GET
 
 @code
 // init for alarm 
 VideoSlicesApiManager *manager = [[VideoSlicesApiManager alloc] initForAlarm];
 manager.delegate = self;
 
 // request
 [manager loadDataWithDeviceId:@"1" startTime:12345678 endTime:12345679];
 
 // fetch data
 NSArray *result = [manager fetchDataWithReformer:manager];
 @endcode
 */
@interface VideoSlicesApiManager : GosApiBaseManager <GosApiManager, GosApiManagerDataReformer>
/// 类请求方法——获取报警查询时间段视频
+ (NSInteger)loadAlarmDataWithDeviceId:(NSString *)deviceId startTime:(NSTimeInterval)startTime endTime:(NSTimeInterval)endTime success:(void (^)(GosApiBaseManager * _Nonnull))successCallback fail:(void (^)(GosApiBaseManager * _Nonnull))failCallback;
/// 类请求方法——获取普通查询时间段视频
+ (NSInteger)loadNormalDataWithDeviceId:(NSString *)deviceId startTime:(NSTimeInterval)startTime endTime:(NSTimeInterval)endTime success:(void (^)(GosApiBaseManager * _Nonnull))successCallback fail:(void (^)(GosApiBaseManager * _Nonnull))failCallback;

/// 初始化
- (instancetype)initWithApiMethodType:(VideoSlicesApiManagerMethodType)apiType;

/// 请求
- (NSInteger)loadDataWithDeviceId:(NSString *)deviceId startTime:(NSTimeInterval)startTime endTime:(NSTimeInterval)endTime;

@end

NS_ASSUME_NONNULL_END
