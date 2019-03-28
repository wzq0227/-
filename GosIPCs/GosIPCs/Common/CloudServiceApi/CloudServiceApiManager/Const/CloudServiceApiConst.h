//  CloudServiceApiConst.h
//  CloudStoreSDK
//
//  Create by daniel.hu on 2018/12/12.
//  Copyright © 2018年 daniel. All rights reserved.

#import <Foundation/Foundation.h>
#pragma mark - 返回参数
/// 标记
extern NSString *const kCloudServiceApiRespKeyCode;
/// 数据
extern NSString *const kCloudServiceApiRespKeyData;
/// 错误信息
extern NSString *const kCloudServiceApiRespKeyMessage;


#pragma mark - 请求参数
/// 版本
extern NSString *const kCloudServiceApiReqKeyVersion;
/// 设备id
extern NSString *const kCloudServiceApiReqKeyDeviceId;
/// 令牌
extern NSString *const kCloudServiceApiReqKeyToken;
/// 用户名
extern NSString *const kCloudServiceApiReqKeyUsername;
/// 原设备id
extern NSString *const kCloudServiceApiReqKeyOriginDeviceId;
/// 目标设备id
extern NSString *const kCloudServiceApiReqKeyDestinationDeviceId;
/// 价格
extern NSString *const kCloudServiceApiReqKeyTotalPrice;
/// 数量
extern NSString *const kCloudServiceApiReqKeyCount;
/// 套餐Id
extern NSString *const kCloudServiceApiReqKeyPlanId;
/// 订单号
extern NSString *const kCloudServiceApiReqKeyOrderNumber;
/// paypal专用-随机数
extern NSString *const kCloudServiceApiReqKeyNonce;
/// paypal专用-总计
extern NSString *const kCloudServiceApiReqKeyAmount;
/// alipay专用-凭据
extern NSString *const kCloudServiceApiReqKeyMemo;
/// alipay专用-结果状态
extern NSString *const kCloudServiceApiReqKeyResultStatus;
/// alipay专用-结果参数
extern NSString *const kCloudServiceApiReqKeyResult;

/// 开始时间
extern NSString *const kCloudServiceApiReqKeyStartTime;
/// 结束时间
extern NSString *const kCloudServiceApiReqKeyEndTime;
/// 有效期
extern NSString *const kCloudServiceApiReqKeyExpires;
/// 允许使用秘钥
extern NSString *const kCloudServiceApiReqKeyAccessKey;
/// 签名
extern NSString *const kCloudServiceApiReqKeySignature;
/// 安全证书
extern NSString *const kCloudServiceApiReqKeySecurityToken;
