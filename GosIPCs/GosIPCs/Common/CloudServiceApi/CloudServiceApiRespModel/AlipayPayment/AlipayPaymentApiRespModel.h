//  AlipayPaymentApiRespModel.h
//  CloudStoreSDK
//
//  Create by daniel.hu on 2018/12/18.
//  Copyright © 2018年 daniel. All rights reserved.

#import <Foundation/Foundation.h>
#import "CloudServiceApiRespProtocol.h"
NS_ASSUME_NONNULL_BEGIN
/**
 支付宝支付
 */
@interface AlipayPaymentApiRespModel : NSObject <CloudServiceApiRespProtocol>
/// 支付宝订单参数
@property (nonatomic, copy) NSString *signParam;
@end

NS_ASSUME_NONNULL_END
