//  CloudPaymentService.h
//  CloudStoreSDK
//
//  Create by daniel.hu on 2018/12/11.
//  Copyright © 2018年 daniel. All rights reserved.

#import <Foundation/Foundation.h>
#import "GosServiceProtocol.h"

NS_ASSUME_NONNULL_BEGIN

/**
 构造如下url
 http://cn-css.ulifecam.com/api/pay/pay-service/...
 
 http://css.ulifecam.com/api/pay/pay-service/...
 
 @attention params是添加在url上的
 */
@interface CloudPaymentService : NSObject <GosServiceProtocol>

@end

NS_ASSUME_NONNULL_END
