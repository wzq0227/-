//  DeviceOrderListApiManager.h
//  CloudStoreSDK
//
//  Create by daniel.hu on 2018/12/11.
//  Copyright © 2018年 daniel. All rights reserved.

#import "GosApiBaseManager.h"

NS_ASSUME_NONNULL_BEGIN

/**
 @brief 设备购买记录
 @discussion
 request parameters: token, username, version, device_id
 
 @note reform data: NSArray<DeviceOrderListApiModel> or @[]
 
 @note
 国内: http://cn-css.ulifecam.com/api/cloudstore/cloudstore-service/service/list
 
 国外: http://css.ulifecam.com/api/cloudstore/cloudstore-service/service/list
 
 @attention GET
 
 @code
 DeviceOrderListApiManager *manager = [[DeviceOrderListApiManager alloc] init];
 manager.delegate = self;
 
 // request
 [manager loadDataWithDeviceId:@"1"];
 
 // fetch data
 NSArray *dataArray = [manager fetchDataWithReformer:manager];
 @endcode
 */
@interface DeviceOrderListApiManager : GosApiBaseManager <GosApiManager, GosApiManagerDataReformer>
/// 可选请求类方法
+ (NSInteger)loadDataWithDeviceId:(NSString *_Nonnull)deviceId success:(void (^ _Nullable)(GosApiBaseManager * _Nonnull apiManager))successCallback fail:(void (^ _Nullable)(GosApiBaseManager * _Nonnull apiManager))failCallback;
/// 必须使用此方法请求
- (NSInteger)loadDataWithDeviceId:(NSString *)deviceId;

@end

NS_ASSUME_NONNULL_END
