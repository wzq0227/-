//  iOSPaymentSDK.h
//  iOSPaymentSDK
//
//  Create by daniel.hu on 2018/12/18.
//  Copyright © 2018年 daniel. All rights reserved.

#import <UIKit/UIKit.h>
#import "iOSPaymentDefines.h"
#import "iOSPaymentResult.h"
#import "iOSPaymentOrderProtocol.h"
#import "iOSPaymentOrder.h"

typedef NSString *iOSPaymentCallbackUserInfoKey;
/**
 支付结果 反馈数据
 @note status在以下情况下反馈Order数据
 GosPaymentStatusOrderParamsException
 
 @note status在以下情况下反馈Result数据
 GosPaymentStatusPaymentSuccess
 */
static iOSPaymentCallbackUserInfoKey kiOSPaymentCallbackUserInfoKeyResult = @"result";
/**
 支付回调代理
 */
@protocol iOSPaymentCallbackDelegate <NSObject>

/**
 支付结果代理回调
 
 @param paymentType 参考GosPaymentType
 @param status 参考GosPaymentStatus
 @param userInfo 可能存在result键值或为空
 */
- (void)payment:(GosPaymentType)paymentType status:(GosPaymentStatus)status userInfo:(NSDictionary *_Nullable)userInfo;
@end

NS_ASSUME_NONNULL_BEGIN

/**
 支付结果块回调
 
 @param paymentType 参考GosPaymentType
 @param status 参考GosPaymentStatus
 @param userInfo 可能存在result键值或为空
 */
typedef void(^iOSPaymentCallbackBlock) (GosPaymentType paymentType, GosPaymentStatus status, NSDictionary *_Nullable userInfo);
/// 订单模型协议
@protocol iOSPaymentOrderProtocol;
/**
 支付SDK
 */
@interface iOSPaymentSDK : NSObject
/// iOSPaymentCallbackDelegate代理
@property (nonatomic, weak) id<iOSPaymentCallbackDelegate> delegate;
/// 单例
+ (instancetype)sharedInstance;

/**
 @brief 判断支付是否可用
 
 @attention 务必确保在主线程调用此方法
 
 @param type 支付类型
 @return GosPaymentErrorTypeSuccess or
 GosPaymentErrorTypeWechatRegisterFailed or
 GosPaymentErrorTypeWechatNotInstalled or
 */
+ (GosPaymentErrorType)paymentIsAvailable:(GosPaymentType)type;

/**
 @brief 处理支付订单
 
 @attention 需要接受delegate回调结果
 
 @param order 订单 id<iOSPaymentOrderProtocol>
 */
+ (void)paymentHandleOrder:(id<iOSPaymentOrderProtocol>)order;

/**
 @brief 处理支付订单
 
 @param order 订单 id<iOSPaymentOrderProtocol>
 @param callback 块回调结果
 */
+ (void)paymentHandleOrder:(id<iOSPaymentOrderProtocol>)order callback:(iOSPaymentCallbackBlock)callback;

/**
 @brief 处理跳转地址
 
 @discussion 可能需要在AppDelegate.m里以下方法中调用
 -application:openURL:sourceApplication:annotation:
 -application:handleOpenURL:
 -application:openURL:options:
 
 @param url NSURL 跳转地址
 @param options 字典，可无
 @param sourceApplication 资源程序，可无
 
 @return BOOL
 */
+ (BOOL)paymentHandleOpenURL:(NSURL *)url
                     options:(NSDictionary<NSString*, id> *_Nullable)options
           sourceApplication:(NSString *_Nullable)sourceApplication;
@end

NS_ASSUME_NONNULL_END

