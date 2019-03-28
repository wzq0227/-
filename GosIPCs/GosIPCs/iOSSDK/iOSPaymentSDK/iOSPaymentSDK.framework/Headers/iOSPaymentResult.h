//  iOSPaymentResult.h
//  GosPaymentSDK
//
//  Create by daniel.hu on 2018/12/13.
//  Copyright © 2018年 daniel. All rights reserved.

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#pragma mark - alipay
@interface iOSPaymentAlipayResult : NSObject
/// 状态码
@property (nonatomic, copy) NSString *resultStatus;
/// 支付凭据
@property (nonatomic, copy) NSString *memo;
/// 结果
@property (nonatomic, copy) NSString *result;
@end

#pragma mark - wechat
@interface iOSPaymentWechatResult : NSObject
/// 返回给商家的信息
@property (nonatomic, copy) NSString *resultKey;
@end

#pragma mark - paypal
@interface iOSPaymentPayPalResult : NSObject
/// 支付随机数
@property (nonatomic, copy) NSString *nonce;
@end
NS_ASSUME_NONNULL_END
