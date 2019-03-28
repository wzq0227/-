//
//  AppDelegate+GosAutoLogin.h
//  GosIPCs
//
//  Created by shenyuanluo on 2018/11/24.
//  Copyright © 2018 goscam. All rights reserved.
//

/*
 自动登录实现类
 */

#import "AppDelegate.h"
#import "iOSConfigSDK.h"

NS_ASSUME_NONNULL_BEGIN

@interface AppDelegate (GosAutoLogin) <
                                        iOSConfigSDKUMDelegate
                                      >

/*
 自动登录上次账号（记住密码情况下）
 */
- (void)autoLogin;

@end

NS_ASSUME_NONNULL_END
