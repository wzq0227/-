//  MigratePackageApiManager.h
//  CloudStoreSDK
//
//  Create by daniel.hu on 2018/12/11.
//  Copyright © 2018年 daniel. All rights reserved.

#import "GosApiBaseManager.h"

NS_ASSUME_NONNULL_BEGIN

/**
 @brief 转移设备的套餐至其他设备
 
 @discussion
 request parameters: token, username, version, ori_device, dest_device
 
 @note reform data: @(YES) or @(NO)
 
 @note
 国内: http://cn-css.ulifecam.com/api/cloudstore/cloudstore-service/manage/device/migrate
 
 国外: http://css.ulifecam.com/api/cloudstore/cloudstore-service/manage/device/migrate
 
 @attention POST
 
 @code
 MigratePackageApiManager *manager = [[MigratePackageApiManager alloc] init];
 manager.delegate = self;
 
 // request
 [manager loadDataWithOriginDeviceId:@"1" destinationDeviceId:@"2"];
 
 // fetch data
 BOOL result = [[manager fetchDataWithReformer:manager] boolValue];
 @endcode
 */
@interface MigratePackageApiManager : GosApiBaseManager <GosApiManager, GosApiManagerDataReformer>

/// 可选请求类方法
+ (NSInteger)loadDataWithOriginDeviceId:(NSString *)origin destinationDeviceId:(NSString *)destination success:(void (^)(GosApiBaseManager * _Nonnull))successCallback fail:(void (^)(GosApiBaseManager * _Nonnull))failCallback;
/// 请求
- (NSInteger)loadDataWithOriginDeviceId:(NSString *)origin destinationDeviceId:(NSString *)destination;
@end

NS_ASSUME_NONNULL_END
