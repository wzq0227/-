//
//  AppDelegate.h
//  GosIPCs
//
//  Created by shenyuanluo on 2018/11/10.
//  Copyright © 2018 shenyuanluo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, readwrite, copy) NSString *lastAccount;   // 上次登录账号
@property (nonatomic, readwrite, copy) NSString *lastPassword;  // 上次登录密码
@property (nonatomic, readwrite, assign) BOOL isAutoLogin;

- (BOOL)isNewVersion;


@end

