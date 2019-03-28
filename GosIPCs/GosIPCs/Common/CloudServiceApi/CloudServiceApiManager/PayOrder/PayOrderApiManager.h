//  PayOrderApiManager.h
//  CloudStoreSDK
//
//  Create by daniel.hu on 2018/12/11.
//  Copyright © 2018年 daniel. All rights reserved.

#import "GosApiBaseManager.h"

NS_ASSUME_NONNULL_BEGIN


/**
 @brief 创建付费套餐订单
 
 @discussion
 request parameters: token, username, device_id, plan_id, total_price, count
 
 @note reform data: PayOrderApiRespModel or  nil
 
 @note
 国内: http://cn-css.ulifecam.com/api/pay/pay-service/inland/cloudstore/order/create
 
 国外: http://css.ulifecam.com/api/pay/pay-service/inland/cloudstore/order/create
 
 @attention POST
 
 @code
 PayOrderApiManager *manager = [[PayOrderApiManager alloc] init];
 manager.delegate = self;
 
 // request one way
 [manager loadDataWithDeviceId:@"1" payPackage:(PayPackageTypesApiRespModel *)obj];
 // or
 [manager loadDataWithDeviceId:@"1" totalPrice:@"12.99" planId:@"1" count:@"1"];
 // or
 [manager loadDataWithDeviceId:@"1" totalPrice:@"12.99" planId:@"1"];
 
 // fetch data, result maybe nil
 PayOrderApiRespModel *result = [manager fetchDataWithReformer:manager];
 @endcode
 */
@class PayPackageTypesApiRespModel;
@interface PayOrderApiManager : GosApiBaseManager <GosApiManager, GosApiManagerDataReformer>
/// 可选请求类方法
+ (NSInteger)loadDataWithDeviceId:(NSString *)deviceId payPackage:(PayPackageTypesApiRespModel *)payPackage success:(void (^)(GosApiBaseManager * _Nonnull))successCallback fail:(void (^)(GosApiBaseManager * _Nonnull))failCallback;
/// 可选请求类方法
+ (NSInteger)loadDataWithDeviceId:(NSString *)deviceId totalPrice:(NSString *)totalPrice planId:(NSString *)planId count:(NSString *)count success:(void (^)(GosApiBaseManager * _Nonnull))successCallback fail:(void (^)(GosApiBaseManager * _Nonnull))failCallback;
/// 请求，默认count = 1
- (NSInteger)loadDataWithDeviceId:(NSString *)deviceId payPackage:(PayPackageTypesApiRespModel *)payPackage;
/// 请求，默认count = 1
- (NSInteger)loadDataWithDeviceId:(NSString *)deviceId totalPrice:(NSString *)totalPrice planId:(NSString *)planId;
/// 请求
- (NSInteger)loadDataWithDeviceId:(NSString *)deviceId totalPrice:(NSString *)totalPrice planId:(NSString *)planId count:(NSString *)count;
@end

NS_ASSUME_NONNULL_END
