//  PayPalPaymentApiManager.h
//  CloudStoreSDK
//
//  Create by daniel.hu on 2018/12/11.
//  Copyright © 2018年 daniel. All rights reserved.

#import "GosApiBaseManager.h"

NS_ASSUME_NONNULL_BEGIN

/**
 @brief 国际支付付费套餐
 
 @discussion
 request parameters: token, username, order_no
 
 @note reform data: PayPalPaymentApiRespModel or nil
 
 @note
 国内: http://cn-css.ulifecam.com/api/pay/pay-service/paypal/check/client_token

 国外: http://css.ulifecam.com/api/pay/pay-service/paypal/check/client_token
 
 @attention POST
 
 @code
 PayPalPaymentApiManager *manager = [[PayPalPaymentApiManager alloc] init];
 manager.delegate = self;
 
 // request
 [manager loadDataWithOrderNumber:@"1"];
 // or
 [manager loadDataWithPayOrder:(PayOrderApiRespModel *)obj];
 
 // fetch data, result maybe nil
 PayPalPaymentApiRespModel *result = [manager fetchDataWithReformer:manager];
 */
@class PayOrderApiRespModel;
@interface PayPalPaymentApiManager : GosApiBaseManager <GosApiManager, GosApiManagerDataReformer>
/// 可选请求类方法
+ (NSInteger)loadDataWithOrderNumber:(NSString *)orderNumnber success:(void (^)(GosApiBaseManager * _Nonnull))successCallback fail:(void (^)(GosApiBaseManager * _Nonnull))failCallback;
/// 可选请求类方法
+ (NSInteger)loadDataWithPayOrder:(PayOrderApiRespModel *)payOrder success:(void (^)(GosApiBaseManager * _Nonnull))successCallback fail:(void (^)(GosApiBaseManager * _Nonnull))failCallback;
/// 请求
- (NSInteger)loadDataWithOrderNumber:(NSString *)orderNumnber;
/// 请求
- (NSInteger)loadDataWithPayOrder:(PayOrderApiRespModel *)payOrder;
@end

NS_ASSUME_NONNULL_END
