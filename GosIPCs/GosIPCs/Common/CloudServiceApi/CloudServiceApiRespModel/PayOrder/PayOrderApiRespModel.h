//  PayOrderApiRespModel.h
//  CloudStoreSDK
//
//  Create by daniel.hu on 2018/12/18.
//  Copyright © 2018年 daniel. All rights reserved.

#import <Foundation/Foundation.h>
#import "CloudServiceApiRespProtocol.h"

NS_ASSUME_NONNULL_BEGIN

/**
 付费订单模型
 */
@interface PayOrderApiRespModel : NSObject <CloudServiceApiRespProtocol>
/// 订单号
@property(nonatomic, copy)  NSString *orderNo;
/// 用户ID
@property(nonatomic, copy)  NSString *userId;
/// 设备id
@property(nonatomic, copy)  NSString *devId;
/// 套餐id
@property(nonatomic, copy)  NSString *planId;
/// 订购数量
@property(nonatomic, copy)  NSString *orderCount;
/// 总价格
@property(nonatomic, copy)  NSString *totalPrice;
/// 订单创建时间
@property(nonatomic, copy)  NSString *createTime;
/// 订单支付状态
@property(nonatomic, copy)  NSString *status;

/// 由status转化的支付状态
@property (nonatomic, readonly, assign) CloudServicePaymentStatusType cloudServicePaymentStatusType;
@end

NS_ASSUME_NONNULL_END
