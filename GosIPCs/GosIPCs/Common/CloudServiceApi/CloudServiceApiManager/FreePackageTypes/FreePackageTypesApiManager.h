//  FreePackageTypesApiManager.h
//  CloudStoreSDK
//
//  Create by daniel.hu on 2018/12/11.
//  Copyright © 2018年 daniel. All rights reserved.

#import "GosApiBaseManager.h"

NS_ASSUME_NONNULL_BEGIN

/**
 @brief 免费套餐种类
 @discussion
 request parameters: token, username, device_id
 
 @note reform data: FreePackageTypesApiRespModel or nil
 
 @note
 国内: http://cn-css.ulifecam.com/api/cloudstore/cloudstore-service/free-plan
 
 国外: http://css.ulifecam.com/api/cloudstore/cloudstore-service/free-plan
 
 @attention GET
 
 @code
 FreePackageTypesApiManager *manager = [[FreePackageTypesApiManager alloc] init];
 manager.delegate = self;
 
 // request
 [manager loadDataWithDeviceId:@"1"];
 
 /// fetch data , result maybe nil
 FreePackageTypesApiRespModel *result = [manager fetchDataWithReformer:manager];
 @endcode
 */
@interface FreePackageTypesApiManager : GosApiBaseManager <GosApiManager, GosApiManagerDataReformer>
/// 可选请求类方法
+ (NSInteger)loadDataWithDeviceId:(NSString *)deviceId success:(void (^)(GosApiBaseManager * _Nonnull))successCallback fail:(void (^)(GosApiBaseManager * _Nonnull))failCallback;
/// 请求
- (NSInteger)loadDataWithDeviceId:(NSString *)deviceId;
@end

NS_ASSUME_NONNULL_END
