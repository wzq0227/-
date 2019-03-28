//
//  AppDelegate+Jump.h
//  GosIPCs
//
//  Created by shenyuanluo on 2018/11/15.
//  Copyright © 2018 shenyuanluo. All rights reserved.
//

#import "AppDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface AppDelegate (Jump)

/**
 设置主页
 
 @param rootWindow 应用主窗口 （[UIApplication sharedApplication].keyWindow）
 @param autoLogin 是否是自动登录；YES：是，NO：否
  @param hasNetwork 是否是有网络连接；YES：是，NO：否
 */
+ (void)setUpMainTabBarVCOnWindow:(UIWindow *)rootWindow
                      isAutoLogin:(BOOL)autoLogin
                       hasNetwork:(BOOL)hasNetwork;

@end

NS_ASSUME_NONNULL_END
