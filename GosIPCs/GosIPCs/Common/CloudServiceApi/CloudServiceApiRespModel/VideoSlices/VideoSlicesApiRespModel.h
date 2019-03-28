//  VideoSlicesApiRespModel.h
//  GosIPCs
//
//  Create by daniel.hu on 2018/12/24.
//  Copyright © 2018年 goscam. All rights reserved.

#import <Foundation/Foundation.h>
#import "CloudServiceApiRespProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface VideoSlicesApiRespModel : NSObject <CloudServiceApiRespProtocol, NSCopying>
/// 警报类型
@property (nonatomic, copy) NSString *alarmType;
/// 未知名 —— 例：gos-media-u-west
@property (nonatomic, copy) NSString *bucket;
/// 循环与否
@property (nonatomic, copy) NSString *cycle;
/// 数据有效时间
@property (nonatomic, copy) NSString *dateLife;
/// 结束时间——时间戳
@property (nonatomic, copy) NSString *endTime;
/// 开始时间——时间戳
@property (nonatomic, copy) NSString *startTime;
/// 秘钥
@property (nonatomic, copy) NSString *key;

/// 由alarmType转化而来的可认知类型
@property (nonatomic, readonly, assign) VideoSlicesAlarmType videoSlicesAlarmType;
@end

NS_ASSUME_NONNULL_END
