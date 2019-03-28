//  PayPackageTypesApiRespModel.h
//  CloudStoreSDK
//
//  Create by daniel.hu on 2018/12/18.
//  Copyright © 2018年 daniel. All rights reserved.

#import <Foundation/Foundation.h>
#import "CloudServiceApiRespProtocol.h"

NS_ASSUME_NONNULL_BEGIN

/**
 付费套餐列表
 */
@interface PayPackageTypesApiRespModel : NSObject <CloudServiceApiRespProtocol>

/// 创建时间
@property (nonatomic, copy) NSString *createTime;
/// 数据保存时间（多少天可循环录制）
@property (nonatomic, copy) NSString *dataLife;
/// 是否可删除
@property (nonatomic, copy) NSString *deleteEnable;
/// 套餐是否开启
@property (nonatomic, copy) NSString *enable;
/// 免费标记
@property (nonatomic, copy) NSString *freeFlag;
/// 原价格
@property (nonatomic, copy) NSString *originalPrice;
/// 套餐描述
@property (nonatomic, copy) NSString *planDesc;
/// 套餐id
@property (nonatomic, copy) NSString *planId;
/// 套餐名
@property (nonatomic, copy) NSString *planName;
/// 价格
@property (nonatomic, copy) NSString *price;
/// 产品代码
@property (nonatomic, copy) NSString *productCode;
/// 套餐续费
@property (nonatomic, copy) NSString *renewEnable;
/// 服务有效期
@property (nonatomic, copy) NSString *serviceLife;
/// 是否一直能够可写
@property (nonatomic, copy) NSString *alwaysWriteEnable;
@end

NS_ASSUME_NONNULL_END
