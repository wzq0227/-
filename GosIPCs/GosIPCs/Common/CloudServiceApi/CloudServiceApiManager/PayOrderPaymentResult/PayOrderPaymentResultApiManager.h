//  PayOrderPaymentResultApiManager.h
//  CloudStoreSDK
//
//  Create by daniel.hu on 2018/12/11.
//  Copyright © 2018年 daniel. All rights reserved.

#import "GosApiBaseManager.h"

NS_ASSUME_NONNULL_BEGIN

/**
 @brief 查询付费套餐支付结果
 
 @discussion
 request parameters: token, username, order_no
 
 @note reform data: PayOrderPaymentResultApiRespModel or nil
 
 @note
 国内: http://cn-css.ulifecam.com/api/pay/pay-service/inland/cloudstore/payment/query
 
 国外: http://css.ulifecam.com/api/pay/pay-service/inland/cloudstore/payment/query
 
 @attention POST
 
 @code
 PayOrderPaymentResultApiManager *manager = [[PayOrderPaymentResultApiManager alloc] init];
 manager.delegate = self;
 
 // request
 [manager loadDataWithOrderNumber:@"123456"];
 // or
 [manager loadDataWithPayOrder:(PayOrderApiRespModel *)obj];
 
 // fetch data, result maybe nil
 PayOrderPaymentResultApiRespModel *result = [manager fetchDataWithReformer:manager];
 @endcode
 */
@class PayOrderApiRespModel;
@interface PayOrderPaymentResultApiManager : GosApiBaseManager <GosApiManager, GosApiManagerDataReformer>
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
