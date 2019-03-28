//  PayPalCheckApiManager.h
//  CloudStoreSDK
//
//  Create by daniel.hu on 2018/12/11.
//  Copyright © 2018年 daniel. All rights reserved.

#import "GosApiBaseManager.h"

NS_ASSUME_NONNULL_BEGIN

/**
 @brief 检验国际支付结果
 @discussion
 request parameters: token, username, payment_method_nonce, order_no, amount
 
 @note reform data: @(YES) or @(NO)
 
 @note
 国内: http://cn-css.ulifecam.com/api/pay/pay-service/paypal/check/payment
 
 国外: http://css.ulifecam.com/api/pay/pay-service/paypal/check/payment
 
 @attention POST
 
 @code
 PayPalCheckApiManager *manager = [[PayPalCheckApiManager alloc] init];
 manager.delegate = self;
 
 // request
 [manager loadDataWithMemo:@"asdf" result:@"ghjkl" resultStauts:@"9000"];
 
 // fetch data
 BOOL result = [[manager fetchDataWithReformer:manager] boolValue];
 @endcode
 */
@class PayOrderApiRespModel;
@interface PayPalCheckApiManager : GosApiBaseManager <GosApiManager, GosApiManagerDataReformer>
/// 可选请求类方法
+ (NSInteger)loadDataWithOrderNumber:(NSString *)orderNumner amount:(NSString *)amount nonce:(NSString *)nonce success:(void (^)(GosApiBaseManager * _Nonnull))successCallback fail:(void (^)(GosApiBaseManager * _Nonnull))failCallback;
/// 可选请求类方法
+ (NSInteger)loadDataWithPayOrder:(PayOrderApiRespModel *)payOrder nonce:(NSString *)nonce success:(void (^)(GosApiBaseManager * _Nonnull))successCallback fail:(void (^)(GosApiBaseManager * _Nonnull))failCallback;
/// 请求
- (NSInteger)loadDataWithPayOrder:(PayOrderApiRespModel *)payOrder nonce:(NSString *)nonce;
/// 请求
- (NSInteger)loadDataWithOrderNumber:(NSString *)orderNumner amount:(NSString *)amount nonce:(NSString *)nonce;
@end

NS_ASSUME_NONNULL_END
