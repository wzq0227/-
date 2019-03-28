//  iOSPaymentDefines.h
//  GosPaymentSDK
//
//  Create by daniel.hu on 2018/12/13.
//  Copyright © 2018年 daniel. All rights reserved.

#ifndef iOSPaymentDefines_h
#define iOSPaymentDefines_h

/**
 GOS_SCHEME_URL_IDENTIFIER_**
 对应Info.plist->URL types->URL identifier的键值
 */
/// Schemes URL identifier - alipay
#define GOS_SCHEME_URL_IDENTIFIER_ALIPAY @"alipay"
/// Schemes URL identifier - wechat
#define GOS_SCHEME_URL_IDENTIFIER_WECHAT @"wechat"
/// Schemes URL identifier - paypal
#define GOS_SCHEME_URL_IDENTIFIER_PAYPAL @"paypal"

/// 支付订单状态
typedef NS_ENUM(NSInteger, GosPaymentStatus) {
    /// 默认
    GosPaymentStatusDefault,
    /// 支付成功
    GosPaymentStatusPaymentSuccess,
    /// 支付失败
    GosPaymentStatusPaymentFailure,
    /// 支付取消
    GosPaymentStatusPaymentCancel,
    /// 支付中
    GosPaymentStatusPaymentProcess,
   
    /// 订单类型无法识别
    GosPaymentStatusUnknowOrderType,
    /// 订单数据参数异常——可能部分为空、或存在非法字符
    GosPaymentStatusOrderParamsException,
};

/// 错误类型
typedef NS_ENUM(NSInteger, GosPaymentErrorType) {
    /// 没有错误
    GosPaymentErrorTypeNoError,
    // FIXME: 微信注册失败，外部要怎么处理?
    GosPaymentErrorTypeWechatRegisterFailed,
    /// 未装微信
    GosPaymentErrorTypeWechatNotInstalled,
};

typedef NS_OPTIONS(NSInteger, GosPaymentType) {
    /// 未知支付类型
    GosPaymentTypeUnknow   = 0,
    /// 支付宝
    GosPaymentTypeAlipay   = 1 << 0,
    /// 微信
    GosPaymentTypeWechat   = 1 << 1,
    /// 国际支付
    GosPaymentTypePayPal   = 1 << 2,
};

#ifdef DEBUG
#define PayLog(fmt, ...) NSLog((fmt), ##__VA_ARGS__);
#else
#define PayLog(fmt, ...)
#endif

#endif /* iOSPaymentDefines_h */
