//  PackageValidTimeApiRespModel.h
//  GosIPCs
//
//  Create by daniel.hu on 2018/12/24.
//  Copyright © 2018年 goscam. All rights reserved.

#import <Foundation/Foundation.h>
#import "CloudServiceApiRespProtocol.h"

NS_ASSUME_NONNULL_BEGIN

/**
 套餐时长反馈模型
 */
@interface PackageValidTimeApiRespModel : NSObject <CloudServiceApiRespProtocol>
/// 套餐数量
@property (nonatomic, copy) NSString *count;
/// 套餐创建时间
@property (nonatomic, copy) NSString *createTime;
/// 套餐创建者
@property (nonatomic, copy) NSString *createUser;
/// 数据过期时间——时间戳
@property (nonatomic, copy) NSString *dataExpiredTime;
/// 数据有效时长——时间戳
@property (nonatomic, copy) NSString *dataLife;
/// 设备id
@property (nonatomic, copy) NSString *deviceId;
/// 未知id
@property (nonatomic, copy) NSString *ID;
/// 过期时间
@property (nonatomic, copy) NSString *invalidTime;
/// 订单数量
@property (nonatomic, copy) NSString *orderCount;
/// 订单号
@property (nonatomic, copy) NSString *orderNo;
/// 支付时间 —— 例: 20181123072355
@property (nonatomic, copy) NSString *payTime;
/// 套餐id
@property (nonatomic, copy) NSString *planId;
/// 套餐名
@property (nonatomic, copy) NSString *planName;
/// 预过期时间——时间戳
@property (nonatomic, copy) NSString *preinvalidTime;
/// 服务时长—— 例：30
@property (nonatomic, copy) NSString *serviceLife;
/// 开始时间——时间戳
@property (nonatomic, copy) NSString *startTime;
/// 套餐状态
@property (nonatomic, copy) NSString *status;
/// 是否可开关
@property (nonatomic, copy) NSString *switchEnable;;
/// 时间戳——例：0
@property (nonatomic, copy) NSString *timeStamp;


/// status转换后的附以实意状态
@property (nonatomic, readonly, assign) CloudServicePackageStatusType cloudServicePackageStatusType;
@end

NS_ASSUME_NONNULL_END
