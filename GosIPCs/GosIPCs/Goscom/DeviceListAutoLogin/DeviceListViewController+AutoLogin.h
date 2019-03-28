//
//  DeviceListViewController+AutoLogin.h
//  GosIPCs
//
//  Created by shenyuanluo on 2018/11/26.
//  Copyright © 2018 goscam. All rights reserved.
//

#import "DeviceListViewController.h"
#import "iOSConfigSDK.h"

NS_ASSUME_NONNULL_BEGIN

@interface DeviceListViewController (AutoLogin) <
                                                    iOSConfigSDKUMDelegate
                                                >

/*
 自动登录上次账号（记住密码情况下，网络从没到有变化后开启）
 */
- (void)autoLogin;

@end

NS_ASSUME_NONNULL_END
