//
//  GosLoggedSSIDInfo.m
//  Goscom
//
//  Created by 罗乐 on 2018/12/8.
//  Copyright © 2018 goscam. All rights reserved.
//

#import "GosLoggedSSIDInfo.h"

#define GOS_LOGGED_IN_SSID      @"GosLoggedInSSID"
#define GOS_LOGGED_IN_SSIDPWD   @"GosLoggedInSSIDPWD"

@implementation GosLoggedSSIDInfo
#pragma mark -- 获取已登录账号
+ (NSString *)SSID
{
    NSString *accountStr = GOS_GET_OBJ(GOS_LOGGED_IN_SSID);
    return accountStr;
}

#pragma mark -- 获取已登录密码
+ (NSString *)SSIDPassword
{
    NSString *passwordStr = GOS_GET_OBJ(GOS_LOGGED_IN_SSIDPWD);
    return passwordStr;
}

#pragma mark -- 保存已登录账号
+ (void)saveSSID:(NSString *)SSIDStr
{
    if (IS_EMPTY_STRING(SSIDStr))
    {
        GosLog(@"账号为空，无法保存！");
        return;
    }
    GOS_SAVE_OBJ(SSIDStr, GOS_LOGGED_IN_SSID);
}

#pragma mark -- 保存已登录密码
+ (void)saveSSIDPassword:(NSString *)passwordStr
{
    if (IS_EMPTY_STRING(passwordStr))
    {
        GosLog(@"密码为空，无法保存！");
        return;
    }
    GOS_SAVE_OBJ(passwordStr, GOS_LOGGED_IN_SSIDPWD);
}

+ (void)clearPassword {
    GOS_SAVE_OBJ(@"", GOS_LOGGED_IN_SSIDPWD);
}

+ (void)clearSSID {
    GOS_SAVE_OBJ(@"", GOS_LOGGED_IN_SSID);
}
@end
