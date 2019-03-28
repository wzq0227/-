//
//  GosLoggedInUserInfo.h
//  GosIPCs
//
//  Created by shenyuanluo on 2018/11/22.
//  Copyright © 2018 goscam. All rights reserved.
//

/*
 获取已登录用户信息数据
 */

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/* 服务器登录区域枚举 */
typedef NS_ENUM(NSInteger, LoginServerArea) {
    LoginServerUnknow           = -1,   // 未知
    LoginServerNorthAmerica     = 0,    // 北美
    LoginServerEuropean         = 1,    // 欧洲
    LoginServerChina            = 2,    // 中国
    LoginServerAsiaPacific      = 3,    // 亚太
    LoginServerMiddleEast       = 4,    // 中东
};

@interface GosLoggedInUserInfo : NSObject

#pragma mark - 取
/*
 获取已登录账号
 
 @return 已登录账号
 */
+ (NSString *)account;

/*
 获取用户 token
 
 @return 用户 token
 */
+ (NSString *)userToken;

/*
 获取已登录密码
 
 @return 已登录密码
 */
+ (NSString *)password;

/*
 获取已登录服务器区域
 
 @return 已登录区域
 */
+ (LoginServerArea)serverArea;

/*
 获取是否自动登录
 
 @return 是否自动登录；YES：是，NO：否
 */
+ (BOOL)isAutoLogin;

/*
 获取负载均衡(流媒体)分派服务器地址（多个地址以分号间隔，例如 192.168.0.1:9999; 192.168.0.2:9999; )
 */
+ (NSString *)streamServerAddr;

#pragma mark - 存
/*
 保存已登录账号

 @param accountStr 已登录账号
 */
+ (void)saveAccount:(NSString *)accountStr;

/*
 保存已登录用户 token
 
 @param accountStr 已登录用户 token
 */
+ (void)saveUserToken:(NSString *)uTokenStr;

/*
 保存已登录密码
 
 @param accountStr 已登录密码
 */
+ (void)savePassword:(NSString *)passwordStr;

/*
 保存已登录区域
 
 @param accountStr 已登录服务器区域
 */
+ (void)saveServerArea:(LoginServerArea)lsArea;

/*
 保存是否自动登录
 
 @param isAutoLogin 是否自动登录；YES：是，NO：否
 */
+ (void)saveAutoLogin:(BOOL)isAutoLogin;

/*
 更新已登录密码（修改密码之后）
 
 @param accountStr 新密码
 */
+ (void)updatePassword:(NSString *)passwordStr;

/**
 清空密码
 */
+ (void)clearPassword;
@end

NS_ASSUME_NONNULL_END
