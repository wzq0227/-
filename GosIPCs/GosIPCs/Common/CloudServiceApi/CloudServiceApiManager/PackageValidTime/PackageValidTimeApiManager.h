//  PackageValidTimeApiManager.h
//  GosIPCs
//
//  Create by daniel.hu on 2018/12/24.
//  Copyright © 2018年 goscam. All rights reserved.

#import "GosApiBaseManager.h"

NS_ASSUME_NONNULL_BEGIN

/**
 @brief 获取云服务套餐时长
 @discussion
 request parameters: token, username, version, device_id
 
 @note reform data: PackageValidTimeApiRespModel or nil
 
 @note
 国内: http://cn-css.ulifecam.com/api/cloudstore/cloudstore-service/service/data-valid
 
 国外: http://css.ulifecam.com/api/cloudstore/cloudstore-service/service/data-valid
 
 @attention GET
 
 @code
 PackageValidTimeApiManager *manager = [[PackageValidTimeApiManager alloc] init];
 manager.delegate = self;
 
 // request
 [manager loadDataWithDeviceId:@"1"];
 
 // fetch data, result maybe nil
 PackageValidTimeApiRespModel *result = [manager fetchDataWithReformer:manager];
 @endcode
 */
@interface PackageValidTimeApiManager : GosApiBaseManager <GosApiManager, GosApiManagerDataReformer>
/// 可选请求类方法
+ (NSInteger)loadDataWithDeviceId:(NSString *_Nonnull)deviceId success:(void (^ _Nullable)(GosApiBaseManager * _Nonnull apiManager))successCallback fail:(void (^ _Nullable)(GosApiBaseManager * _Nonnull apiManager))failCallback;
/// 必须使用此方法请求
- (NSInteger)loadDataWithDeviceId:(NSString *)deviceId;

@end

NS_ASSUME_NONNULL_END
