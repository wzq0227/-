//  FreeOrderPaymentResultApiManager.h
//  CloudStoreSDK
//
//  Create by daniel.hu on 2018/12/11.
//  Copyright © 2018年 daniel. All rights reserved.

#import "GosApiBaseManager.h"

NS_ASSUME_NONNULL_BEGIN

/**
 @brief 查询免费套餐支付结果
 @discussion
 request parameters: token, username, order_no
 
 @note reform data: @(YES) or @(NO)
 
 @note
 国内: http://cn-css.ulifecam.com/api/pay/pay-service/inland/cloudstore/payment-free
 
 国外: http://css.ulifecam.com/api/pay/pay-service/inland/cloudstore/payment-free
 
 @attention POST
 
 @code
 FreeOrderPaymentResultApiManager *manager = [[FreeOrderPaymentResultApiManager alloc] init];
 manager.delegate = self;
 // request
 [manager loadDataWithOrderNumber:@"1"];
 // or
 [manager loadDataWithPayOrder:(FreeOrderApiModel *)obj];
 
 // fetch data
 BOOL result = [[manager fetchDataWithReformer:manager] boolValue];
 @endcode
 */
@class FreeOrderApiRespModel;
@interface FreeOrderPaymentResultApiManager : GosApiBaseManager <GosApiManager, GosApiManagerDataReformer>
/// 可选请求类方法
+ (NSInteger)loadDataWithOrderNumber:(NSString *)orderNumber success:(void (^)(GosApiBaseManager * _Nonnull))successCallback fail:(void (^)(GosApiBaseManager * _Nonnull))failCallback;
/// 可选请求类方法
+ (NSInteger)loadDataWithPayOrder:(FreeOrderApiRespModel *)payOrder success:(void (^)(GosApiBaseManager * _Nonnull))successCallback fail:(void (^)(GosApiBaseManager * _Nonnull))failCallback;
/// 请求
- (NSInteger)loadDataWithOrderNumber:(NSString *)orderNumnber;
/// 请求
- (NSInteger)loadDataWithPayOrder:(FreeOrderApiRespModel *)payOrder;
@end

NS_ASSUME_NONNULL_END
