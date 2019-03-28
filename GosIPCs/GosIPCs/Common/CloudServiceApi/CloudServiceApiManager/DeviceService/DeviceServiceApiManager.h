//  DeviceServiceApiManager.h
//  GosIPCs
//
//  Create by daniel.hu on 2018/12/25.
//  Copyright © 2018年 goscam. All rights reserved.

#import "GosApiBaseManager.h"

NS_ASSUME_NONNULL_BEGIN
/**
 @brief 查询当前设备是否开通过 云存储服务
 @discussion
 request parameters: token, username, version, device_id
 
 @note reform data: DeviceServiceApiRespModel
 
 @note
 国内: http://cn-css.ulifecam.com/api/cloudstore/cloudstore-service/service/current
 
 国外: http://css.ulifecam.com/api/cloudstore/cloudstore-service/service/current
 
 @attention GET
 
 @code
 DeviceServiceApiManager *manager = [[DeviceServiceApiManager alloc] init];
 manager.delegate = self;
 
 // request
 [manager loadDataWithDeviceId:@"1"];
 
 // fetch data
 NSArray *dataArray = [manager fetchDataWithReformer:manager];
 @endcode
 */
@interface DeviceServiceApiManager : GosApiBaseManager <GosApiManager, GosApiManagerDataReformer>

/// 可选请求类方法
+ (NSInteger)loadDataWithDeviceId:(NSString *_Nonnull)deviceId success:(void (^ _Nullable)(GosApiBaseManager * _Nonnull apiManager))successCallback fail:(void (^ _Nullable)(GosApiBaseManager * _Nonnull apiManager))failCallback;
/// 必须使用此方法请求
- (NSInteger)loadDataWithDeviceId:(NSString *)deviceId;
@end

NS_ASSUME_NONNULL_END
