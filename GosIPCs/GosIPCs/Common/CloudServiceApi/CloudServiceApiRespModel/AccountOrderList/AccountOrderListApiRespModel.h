//  AccountOrderListApiRespModel.h
//  CloudStoreSDK
//
//  Create by daniel.hu on 2018/12/18.
//  Copyright © 2018年 daniel. All rights reserved.

#import <Foundation/Foundation.h>
#import "CloudServiceApiRespProtocol.h"

NS_ASSUME_NONNULL_BEGIN
/**
 账户订单列表
 */
@interface AccountOrderListApiRespModel : NSObject <CloudServiceApiRespProtocol>

/// 数量
@property (nonatomic, copy) NSString *count;
/// 创建时间
@property (nonatomic, copy) NSString *createTime;
/// 创建者
@property (nonatomic, copy) NSString *createUser;
/// 数据过期时间
@property (nonatomic, copy) NSString *dataExpiredTime;
/// 数据有效时间（多少天循环录制）
@property (nonatomic, copy) NSString *dataLife;
/// 设备id
@property (nonatomic, copy) NSString *deviceId;
/// 记录id
@property (nonatomic, copy) NSString *ID;
/// 订单数量
@property (nonatomic, copy) NSString *orderCount;
/// 订单号
@property (nonatomic, copy) NSString *orderNo;
/// 付款时间
@property (nonatomic, copy) NSString *payTime;
/// 套餐id
@property (nonatomic, copy) NSString *planId;
/// 套餐名
@property (nonatomic, copy) NSString *planName;
/// FIXME：预失效时间
@property (nonatomic, copy) NSString *preinvalidTime;
/// 服务有效期
@property (nonatomic, copy) NSString *serviceLife;
/// 开始时间
@property (nonatomic, copy) NSString *startTime;
/// 状态
@property (nonatomic, copy) NSString *status;
/// 是否能开关
@property (nonatomic, copy) NSString *switchEnable;
/// 时间戳
@property (nonatomic, copy) NSString *timeStamp;

/// status转换后的附以实意状态
@property (nonatomic, readonly, assign) CloudServicePackageStatusType cloudServicePackageStatusType;
@end

NS_ASSUME_NONNULL_END
