//  CloudServiceApiRespProtocol.h
//  CloudStoreSDK
//
//  Create by daniel.hu on 2018/12/18.
//  Copyright © 2018年 daniel. All rights reserved.

#import <Foundation/Foundation.h>

/**
 套餐状态
 */
typedef NS_ENUM(NSUInteger, CloudServicePackageStatusType) {
    /// 套餐过期
    CloudServicePackageStatusTypeExpired,
    /// 套餐使用中
    CloudServicePackageStatusTypeInUse,
    /// 套餐未使用
    CloudServicePackageStatusTypeUnused,
    /// 套餐未绑定
    CloudServicePackageStatusTypeUnbind,
    /// 套餐未授权
    CloudServicePackageStatusTypeForbidden,
};

/**
 订单支付状态
 */
typedef NS_ENUM(NSUInteger, CloudServicePaymentStatusType) {
    /// 订单失败
    CloudServicePaymentStatusTypeFailed,
    /// 订单因超时关闭
    CloudServicePaymentStatusTypeFailedWithTimeout,
    /// 订单支付成功
    CloudServicePaymentStatusTypeSuccess,
    /// 订单支付主动取消
    CloudServicePaymentStatusTypeCanceled,
    /// 订单支付中——可能待支付，或支付处理中
    CloudServicePaymentStatusTypeProcess
    
};

/**
 视频数据 报警类型
 */
typedef NS_ENUM(NSUInteger, VideoSlicesAlarmType) {
    /// 未知报警类型
    VideoSlicesAlarmTypeUnknow,
    /// 移动侦测
    VideoSlicesAlarmTypeMotionDetection,
    /// 声音侦测
    VideoSlicesAlarmTypeVoiceDetection,
    /// 温度报警
    VideoSlicesAlarmTypeTemperture,
};

NS_ASSUME_NONNULL_BEGIN

@protocol CloudServiceApiRespProtocol <NSObject>

@end

NS_ASSUME_NONNULL_END
