//  CloudServiceApiConst.m
//  CloudStoreSDK
//
//  Create by daniel.hu on 2018/12/12.
//  Copyright © 2018年 daniel. All rights reserved.

#import "CloudServiceApiConst.h"
#pragma mark - 返回参数
/// 标记
NSString *const kCloudServiceApiRespKeyCode = @"code";
/// 数据
NSString *const kCloudServiceApiRespKeyData = @"data";
/// 错误信息
NSString *const kCloudServiceApiRespKeyMessage = @"message";

#pragma mark - 请求参数
/// 版本
NSString *const kCloudServiceApiReqKeyVersion = @"version";
/// 设备id
NSString *const kCloudServiceApiReqKeyDeviceId = @"device_id";
/// 令牌
NSString *const kCloudServiceApiReqKeyToken = @"token";
/// 用户名
NSString *const kCloudServiceApiReqKeyUsername = @"username";
/// 原设备id
NSString *const kCloudServiceApiReqKeyOriginDeviceId = @"ori_device";
/// 目标设备id
NSString *const kCloudServiceApiReqKeyDestinationDeviceId = @"dist_device";
/// 价格
NSString *const kCloudServiceApiReqKeyTotalPrice = @"total_price";
/// 数量
NSString *const kCloudServiceApiReqKeyCount = @"count";
/// 套餐Id
NSString *const kCloudServiceApiReqKeyPlanId = @"plan_id";
/// 订单号
NSString *const kCloudServiceApiReqKeyOrderNumber = @"order_no";
/// paypal专用-随机数
NSString *const kCloudServiceApiReqKeyNonce = @"payment_method_nonce";
/// paypal专用-总计
NSString *const kCloudServiceApiReqKeyAmount = @"amount";
/// alipay专用-凭据
NSString *const kCloudServiceApiReqKeyMemo = @"memo";
/// alipay专用-结果状态
NSString *const kCloudServiceApiReqKeyResultStatus = @"resultStatus";
/// alipay专用-结果参数
NSString *const kCloudServiceApiReqKeyResult = @"content-params";


/// 开始时间
NSString *const kCloudServiceApiReqKeyStartTime = @"start_time";
/// 结束时间
NSString *const kCloudServiceApiReqKeyEndTime = @"end_time";
/// 有效期
NSString *const kCloudServiceApiReqKeyExpires = @"Expires";
/// 允许使用秘钥
NSString *const kCloudServiceApiReqKeyAccessKey = @"OSSAccessKeyId";
/// 签名
NSString *const kCloudServiceApiReqKeySignature = @"Signature";
/// 安全证书
NSString *const kCloudServiceApiReqKeySecurityToken = @"security-token";
