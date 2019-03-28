//  WechatPaymentApiRespModel.h
//  CloudStoreSDK
//
//  Create by daniel.hu on 2018/12/18.
//  Copyright © 2018年 daniel. All rights reserved.

#import <Foundation/Foundation.h>
#import "CloudServiceApiRespProtocol.h"

NS_ASSUME_NONNULL_BEGIN

/**
 微信支付
 */
@interface WechatPaymentApiRespModel : NSObject <CloudServiceApiRespProtocol>
/// 时间戳
@property (nonatomic, copy) NSString *timestamp;
/// 商户id
@property (nonatomic, copy) NSString *partnerid;
/// 预支付id
@property (nonatomic, copy) NSString *prepayid;
/// 随机数
@property (nonatomic, copy) NSString *noncestr;
/// 套餐
@property (nonatomic, copy) NSString *package;
/// 签名
@property (nonatomic, copy) NSString *sign;
@end

NS_ASSUME_NONNULL_END
