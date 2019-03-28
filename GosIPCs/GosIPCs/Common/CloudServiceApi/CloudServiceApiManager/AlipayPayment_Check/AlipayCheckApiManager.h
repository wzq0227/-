//  AlipayCheckApiManager.h
//  CloudStoreSDK
//
//  Create by daniel.hu on 2018/12/12.
//  Copyright © 2018年 daniel. All rights reserved.

#import "GosApiBaseManager.h"

NS_ASSUME_NONNULL_BEGIN

/**
 @brief 检验支付宝支付结果
 @discussion
 request parameters: token, username, memo, resultStatus, content-params
 
 @note reform data: @(YES) or @(NO)
 
 @note
 国内: http://cn-css.ulifecam.com/api/pay/pay-service/alipay/payment/check
 
 国外: http://css.ulifecam.com/api/pay/pay-service/alipay/payment/check
 
 @attention POST
 
 @code
 AlipayCheckApiManager *manager = [[AlipayCheckApiManager alloc] init];
 manager.delegate = self;
 
 // request
 [manager loadDataWithMemo:@"asdf" result:@"ghjkl" resultStauts:@"9000"];
 
 // fetch data
 BOOL result = [[manager fetchDataWithReformer:manager] boolValue];
 @endcode
 */
@interface AlipayCheckApiManager : GosApiBaseManager <GosApiManager, GosApiManagerDataReformer>
/// 可选请求类方法
+ (NSInteger)loadDataWithMemo:(NSString *)memo result:(NSString *)result resultStatus:(NSString *)resultStatus success:(void (^)(GosApiBaseManager * _Nonnull))successCallback fail:(void (^)(GosApiBaseManager * _Nonnull))failCallback;
/// 请求
- (NSInteger)loadDataWithMemo:(NSString *)memo result:(NSString *)result resultStatus:(NSString *)resultStatus;
@end

NS_ASSUME_NONNULL_END
