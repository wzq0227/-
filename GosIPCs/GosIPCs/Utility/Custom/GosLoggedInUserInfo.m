//
//  GosLoggedInUserInfo.m
//  GosIPCs
//
//  Created by shenyuanluo on 2018/11/22.
//  Copyright © 2018 goscam. All rights reserved.
//

#import "GosLoggedInUserInfo.h"

#define GOS_LOGGED_IN_ACCOUNT       @"GosLoggedInAccount"
#define GOS_LOGGED_IN_USER_TOKEN    @"GosLoggedInUserToken"
#define GOS_LOGGED_IN_PASSWORD      @"GosLoggedInPassword"
#define GOS_LOGGED_IN_AREA          @"GosLoggedInArea"
#define GOS_IS_AUTO_LOGIN           @"GosIsAutoLogin"

@implementation GosLoggedInUserInfo

#pragma mark - 取
#pragma mark -- 获取已登录账号
+ (NSString *)account
{
    NSString *accountStr = GOS_GET_OBJ(GOS_LOGGED_IN_ACCOUNT);
    return accountStr;
}

#pragma mark -- 获取用户 token
+ (NSString *)userToken
{
    NSString *uTokenStr = GOS_GET_OBJ(GOS_LOGGED_IN_USER_TOKEN);
    return uTokenStr;
}

#pragma mark -- 获取已登录密码
+ (NSString *)password
{
    NSString *passwordStr = GOS_GET_OBJ(GOS_LOGGED_IN_PASSWORD);
    return passwordStr;
}

#pragma mark -- 获取已登录区域
+ (LoginServerArea)serverArea
{
    NSNumber *areaObj = GOS_GET_OBJ(GOS_LOGGED_IN_AREA);
    return (LoginServerArea)[areaObj integerValue];
}

#pragma mark -- 获取是否自动登录
+ (BOOL)isAutoLogin
{
    NSNumber *isAudoLoginObj = GOS_GET_OBJ(GOS_IS_AUTO_LOGIN);
    return [isAudoLoginObj boolValue];
}

#pragma makr -- 获取服务器地址
+ (NSString *)streamServerAddr
{
    NSString *serverIps     = nil;
    LoginServerArea lsArea = [self serverArea];
    switch (lsArea)
    {
        case LoginServerNorthAmerica:serverIps = kStreamServerAddrsNorthAmerica; break; // 北美
        case LoginServerEuropean:    serverIps = kStreamServerAddrsEuropean;     break; // 欧洲
        case LoginServerChina:       serverIps = kStreamServerAddrsChina;        break; // 中国
        case LoginServerAsiaPacific: serverIps = kStreamServerAddrsAsiaPacific;  break; // 亚太
        case LoginServerMiddleEast:  serverIps = kStreamServerAddrsMiddleEast;   break; // 中东
        default:                     serverIps = kStreamServerAddrsChina;        break;
    }
    return serverIps;
}

#pragma mark - 存
#pragma mark -- 保存已登录账号
+ (void)saveAccount:(NSString *)accountStr
{
    if (IS_EMPTY_STRING(accountStr))
    {
        GosLog(@"账号为空，无法保存！");
        return;
    }
    GOS_SAVE_OBJ(accountStr, GOS_LOGGED_IN_ACCOUNT);
}

#pragma mark -- 保存已登录用户 token
+ (void)saveUserToken:(NSString *)uTokenStr
{
    if (IS_EMPTY_STRING(uTokenStr))
    {
        GosLog(@"用户 token 为空，无法保存！");
        return;
    }
    GOS_SAVE_OBJ(uTokenStr, GOS_LOGGED_IN_USER_TOKEN);
}

#pragma mark -- 保存已登录密码
+ (void)savePassword:(NSString *)passwordStr
{
    if (IS_EMPTY_STRING(passwordStr))
    {
        GosLog(@"密码为空，无法保存！");
        return;
    }
    GOS_SAVE_OBJ(passwordStr, GOS_LOGGED_IN_PASSWORD);
}

#pragma mark -- 保存已登录区域
+ (void)saveServerArea:(LoginServerArea)lsArea
{
    GOS_SAVE_OBJ(@(lsArea), GOS_LOGGED_IN_AREA);
}

#pragma mark -- 保存是否自动登录
+ (void)saveAutoLogin:(BOOL)isAutoLogin
{
    GOS_SAVE_OBJ(@(isAutoLogin), GOS_IS_AUTO_LOGIN);
}

#pragma mark -- 更新密码
+ (void)updatePassword:(NSString *)passwordStr
{
    if (IS_EMPTY_STRING(passwordStr))
    {
        GosLog(@"密码为空，无法更新！");
        return;
    }
    GOS_SAVE_OBJ(passwordStr, GOS_LOGGED_IN_PASSWORD);
}
+ (void)clearPassword {
    GOS_SAVE_OBJ(@"", GOS_LOGGED_IN_PASSWORD);
}
@end
