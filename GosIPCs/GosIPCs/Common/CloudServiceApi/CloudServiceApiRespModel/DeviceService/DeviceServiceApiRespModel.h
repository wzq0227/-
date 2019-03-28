//  DeviceServiceApiRespModel.h
//  GosIPCs
//
//  Create by daniel.hu on 2018/12/25.
//  Copyright © 2018年 goscam. All rights reserved.

#import <Foundation/Foundation.h>
#import "CloudServiceApiRespProtocol.h"
NS_ASSUME_NONNULL_BEGIN

@interface DeviceServiceApiRespModel : NSObject <CloudServiceApiRespProtocol>
/// 附加code值
@property (nonatomic, copy) NSString *code;
/// 订单号
@property (nonatomic, copy) NSString *orderNo;
/// 设备id
@property (nonatomic, copy) NSString *deviceId;
/// 记录id
@property (nonatomic, copy) NSString *ID;
/// 套餐id
@property (nonatomic, copy) NSString *planId;
/// 套餐名
@property (nonatomic, copy) NSString *planName;
/// 数据有效时长
@property (nonatomic, copy) NSString *dateLife;
/// 服务有效时长
@property (nonatomic, copy) NSString *serviceLife;
/// 服务生效时间
@property (nonatomic, copy) NSString *startTime;
/// 服务有效截止时间
@property (nonatomic, copy) NSString *preinvalidTime;
/// 是否可用——1可用，0禁用
@property (nonatomic, copy) NSString *switchEnable;
/// 套餐状态
@property (nonatomic, copy) NSString *status;

/// status转换后的附以实意状态
@property (nonatomic, readonly, assign) CloudServicePackageStatusType cloudServicePackageStatusType;

@end

NS_ASSUME_NONNULL_END
