//  FreeOrderApiManager.h
//  CloudStoreSDK
//
//  Create by daniel.hu on 2018/12/11.
//  Copyright © 2018年 daniel. All rights reserved.

#import "GosApiBaseManager.h"

NS_ASSUME_NONNULL_BEGIN

/**
 @brief 创建免费套餐订单
 @discussion
 request parameters: token, username, device_id, plan_id
 
 @note reform data: FreeOrderApiRespModel or nil
 
 @note
 国内: http://cn-css.ulifecam.com/api/pay/pay-service/inland/cloudstore/free-order/create
 
 国外: http://css.ulifecam.com/api/pay/pay-service/inland/cloudstore/free-order/create
 
 @attention POST
 
 @code
 FreeOrderApiManager *manager = [[FreeOrderApiManager alloc] init];
 manager.delegate = self;
 
 // request
 [manager loadDataWithDeviceId:@"1" planId:@"1"];
 
 // fetch data, result maybe nil
 FreeOrderApiRespModel *result = [manager fetchDataWithReformer:manager];
 @endcode 
 */
@interface FreeOrderApiManager : GosApiBaseManager <GosApiManager, GosApiManagerDataReformer>
/// 可选请求类方法
+ (NSInteger)loadDataWithDeviceId:(NSString *)deviceId planId:(NSString *)planId success:(void (^)(GosApiBaseManager * _Nonnull))successCallback fail:(void (^)(GosApiBaseManager * _Nonnull))failCallback;
/// 请求
- (NSInteger)loadDataWithDeviceId:(NSString *)deviceId planId:(NSString *)planId;
@end

NS_ASSUME_NONNULL_END
