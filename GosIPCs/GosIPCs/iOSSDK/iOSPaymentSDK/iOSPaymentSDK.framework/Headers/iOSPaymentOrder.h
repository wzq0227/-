//  iOSPaymentOrder.h
//  GosPaymentSDK
//
//  Create by daniel.hu on 2018/12/13.
//  Copyright © 2018年 daniel. All rights reserved.

#import <Foundation/Foundation.h>
#import "iOSPaymentOrderProtocol.h"

NS_ASSUME_NONNULL_BEGIN
#pragma mark - 支付宝订单模型
/**
 支付宝订单
 */
@interface iOSPaymentAlipayOrder : NSObject <iOSPaymentOrderProtocol>
/// 签名参数
@property (nonatomic, copy) NSString *signParam;
@end

#pragma mark - 微信订单模型
/**
 微信订单
 */
@interface iOSPaymentWechatOrder : NSObject <iOSPaymentOrderProtocol>
/// 商家号
@property (nonatomic, copy) NSString *partnerid;
/// 预支付订单号
@property (nonatomic, copy) NSString *prepayid;
/// 随机数
@property (nonatomic, copy) NSString *noncestr;
/// 时间戳
@property (nonatomic, copy) NSString *timestamp;
/// 数据
@property (nonatomic, copy) NSString *package;
/// 签名
@property (nonatomic, copy) NSString *sign;
@end

#pragma mark - 国际订单模型
/// 货币代码
typedef NSString *GosPaymentCurrencyCode;
/// 美国货币代码——美元
static GosPaymentCurrencyCode kGosPaymentCurrencyCodeUSD = @"USD";
/**
 国际订单
 */
@interface iOSPaymentPayPalOrder : NSObject <iOSPaymentOrderProtocol>
/// 令牌
@property (nonatomic, copy) NSString *authToken;
/// 总计价格
@property (nonatomic, copy) NSString *amount;
/// 货币代码 参考GosPaymentCurrencyCode类型, 默认为kGosPaymentCurrencyCodeUSD
@property (nonatomic, copy) GosPaymentCurrencyCode currencyCode;
@end

NS_ASSUME_NONNULL_END
