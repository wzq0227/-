//
//  GosInfoLegalCheck.m
//  GosIPCs
//
//  Created by shenyuanluo on 2018/11/21.
//  Copyright © 2018 goscam. All rights reserved.
//

#import "GosInfoLegalCheck.h"
#import "NSString+GosCheck.h"

@implementation GosInfoLegalCheck

#pragma mark -- 检查账号是否合法
+ (BOOL)isLegalWithAccount:(NSString *)accountStr
{
    if (IS_EMPTY_STRING(accountStr))
    {
        return NO;
    }
    if (GOS_ACCOUNT_MAX_LEN <= accountStr.length)
    {
        [SVProgressHUD showErrorWithStatus:DPLocalizedString(@"AccountOrPwdFmtError")];
        return NO;
    }
    if ([accountStr isMetacharacter])
    {
        [SVProgressHUD showErrorWithStatus:DPLocalizedString(@"AccountOrPwdFmtError")];
        return NO;
    }
    return YES;
}

#pragma mark -- 检查密码是否合法
+ (BOOL)isLegalWithPassword:(NSString *)passwordStr
{
    if (IS_EMPTY_STRING(passwordStr))
    {
        return NO;
    }
    if (GOS_PASSWORD_MAX_LEN <= passwordStr.length)
    {
        [SVProgressHUD showErrorWithStatus:DPLocalizedString(@"PasswordLenLimit")];
        return NO;
    }
    if ([passwordStr isMetacharacter])
    {
        [SVProgressHUD showErrorWithStatus:DPLocalizedString(@"AccountOrPwdFmtError")];
        return NO;
    }
    return YES;
}

@end
