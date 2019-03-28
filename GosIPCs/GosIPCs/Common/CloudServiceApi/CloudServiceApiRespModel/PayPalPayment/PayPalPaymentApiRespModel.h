//  PayPalPaymentApiRespModel.h
//  CloudStoreSDK
//
//  Create by daniel.hu on 2018/12/18.
//  Copyright © 2018年 daniel. All rights reserved.

#import <Foundation/Foundation.h>
#import "CloudServiceApiRespProtocol.h"

NS_ASSUME_NONNULL_BEGIN

/**
 国际支付
 */
@interface PayPalPaymentApiRespModel : NSObject <CloudServiceApiRespProtocol>
@property (nonatomic, copy) NSString *payPalToken;
@end

NS_ASSUME_NONNULL_END
