//  TokenCheckApiRespModel.h
//  GosIPCs
//
//  Create by daniel.hu on 2018/12/24.
//  Copyright © 2018年 goscam. All rights reserved.

#import <Foundation/Foundation.h>
#import "CloudServiceApiRespProtocol.h"

NS_ASSUME_NONNULL_BEGIN

/**
 获取云存储TOKEN的反馈模型
 */
@interface TokenCheckApiRespModel : NSObject <CloudServiceApiRespProtocol>
/// 过期时间（GMT时间）—— 例：2018-12-24T07:17:30Z
@property (nonatomic, copy) NSString *expiration;
/// 创建者
@property (nonatomic, copy) NSString *creater;
/// 设备id
@property (nonatomic, copy) NSString *deviceId;
/// 时长——秒
@property (nonatomic, copy) NSString *durationSeconds;
/// 终端
@property (nonatomic, copy) NSString *endPoint;
/// 秘钥
@property (nonatomic, copy) NSString *key;
/// 加密字符串
@property (nonatomic, copy) NSString *secret;
/// 时间戳
@property (nonatomic, copy) NSString *timeStamp;
/// token
@property (nonatomic, copy) NSString *token;

@end


NS_ASSUME_NONNULL_END
