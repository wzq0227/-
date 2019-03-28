//  DeviceOrderListApiRespModel.h
//  CloudStoreSDK
//
//  Create by daniel.hu on 2018/12/18.
//  Copyright © 2018年 daniel. All rights reserved.

#import <Foundation/Foundation.h>
#import "CloudServiceApiRespProtocol.h"

NS_ASSUME_NONNULL_BEGIN

/**
 设备订单列表模型
 */
@interface DeviceOrderListApiRespModel : NSObject <CloudServiceApiRespProtocol>
/// 数量
@property (nonatomic, copy) NSString *count;
/// 套餐创建时间
@property (nonatomic, copy) NSString *createTime;
/// 套餐创建者
@property (nonatomic, copy) NSString *createUser;
/// 数据过期时间
@property (nonatomic, copy) NSString *dataExpiredTime;
/// 数据有效时间
@property (nonatomic, copy) NSString *dataLife;
/// 记录id
@property (nonatomic, copy) NSString *ID;// id
/// 设备id
@property (nonatomic, copy) NSString *deviceId;
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
/// 预失效时间
@property (nonatomic, copy) NSString *preinvalidTime;
/// 服务有效期
@property (nonatomic, copy) NSString *serviceLife;
/// 开始时间
@property (nonatomic, copy) NSString *startTime;
/// 套餐状态
@property (nonatomic, copy) NSString *status;
/// 可用状态： 1可用；0禁用
@property (nonatomic, copy) NSString *switchEnable;
/// 时间戳
@property (nonatomic, copy) NSString *timeStamp;

/// status转换后的附以实意状态
@property (nonatomic, readonly, assign) CloudServicePackageStatusType cloudServicePackageStatusType;

@end

NS_ASSUME_NONNULL_END
