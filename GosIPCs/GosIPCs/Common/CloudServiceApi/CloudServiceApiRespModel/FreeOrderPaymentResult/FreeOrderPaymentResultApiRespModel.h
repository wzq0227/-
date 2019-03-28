//  FreeOrderPaymentResultApiRespModel.h
//  CloudStoreSDK
//
//  Create by daniel.hu on 2018/12/18.
//  Copyright © 2018年 daniel. All rights reserved.

#import <Foundation/Foundation.h>
#import "CloudServiceApiRespProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface FreeOrderPaymentResultApiRespModel : NSObject <CloudServiceApiRespProtocol>
/// 订单支付状态
@property (nonatomic, copy) NSString *status;
/// 由status转化的支付状态
@property (nonatomic, readonly, assign) CloudServicePaymentStatusType cloudServicePaymentStatusType;
@end

NS_ASSUME_NONNULL_END
