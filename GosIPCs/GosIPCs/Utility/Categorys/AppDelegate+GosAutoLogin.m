//
//  AppDelegate+GosAutoLogin.m
//  GosIPCs
//
//  Created by shenyuanluo on 2018/11/24.
//  Copyright © 2018 goscam. All rights reserved.
//

#import "AppDelegate+GosAutoLogin.h"
#import "LoginViewController.h"
#import "GosRootViewController.h"
#import "CheckNetwork.h"
#import "AppDelegate+Jump.h"


@implementation AppDelegate (GosAutoLogin)

- (void)autoLogin
{
    LoginServerArea loginArea = [GosLoggedInUserInfo serverArea];
    ServerAreaType sArea = ServerArea_unknown;
    switch (loginArea)
    {
        case LoginServerNorthAmerica: sArea = ServerArea_overseas; break;   // 北美
        case LoginServerEuropean:     sArea = ServerArea_overseas; break;   // 欧洲
        case LoginServerChina:        sArea = ServerArea_domestic; break;   // 中国
        case LoginServerAsiaPacific:  sArea = ServerArea_overseas; break;   // 亚太
        case LoginServerMiddleEast:   sArea = ServerArea_overseas; break;   // 中东
        default: break;
    }
    GosLog(@"自动登录开始！");
    [iOSConfigSDK setupServerArea:sArea];
    iOSConfigSDK *configSdk = [iOSConfigSDK shareCofigSdk];
    configSdk.umDelegate = self;
    [configSdk loginWithAccount:self.lastAccount
                       password:self.lastPassword];
}

#pragma mark - iOSConfigSDKUMDelegate
#pragma mark --  iOSConfigSDK 初始化回调
- (void)initConfigSdk:(BOOL)isSuccess
            errorCode:(int)eCode
{
    if (YES == isSuccess)
    {
        GosLog(@"iOSConfigSDK 初始化成功！");
        return;
    }
    GosLog(@"iOSConfigSDK 初始化失败，错误码：%d", eCode);
    switch (eCode)
    {
        case CONSDK_ERR_NO_SUPPORT_BLOCK_MODE:      // 不支持阻塞模式
        {
            GosLog(@"iOSConfigSDK 初始化失败，原因：不支持阻塞模式");
        }
            break;
            
        case CONSDK_ERR_TIMEOUT:                    // 请求超时
        {
            GosLog(@"iOSConfigSDK 初始化失败，原因：请求超时");
        }
            break;
            
        case CONSDK_ERR_NO_SUPPORT_REQ:             // SDK不支持该请求
        {
            GosLog(@"iOSConfigSDK 初始化失败，原因：SDK不支持该请求");
        }
            break;
            
        case CONSDK_ERR_SEND_FAILED:                // 发送请求失败
        {
            GosLog(@"iOSConfigSDK 初始化失败，原因：发送请求失败");
        }
            break;
            
        case CONSDK_ERR_SEND_REQ_WHEN_DISCONNECT:   // 在断线的情况下发送的请求
        {
            GosLog(@"iOSConfigSDK 初始化失败，原因：在断线的情况下发送的请求");
        }
            break;
            
        case CONSDK_ERR_CONNECT_FAILED:             // 连接服务器失败
        {
            GosLog(@"iOSConfigSDK 初始化失败，原因：连接服务器失败");
        }
            break;
            
        case CONSDK_ERR_SOCKET_ERROR:               // 套接字异常
        {
            GosLog(@"iOSConfigSDK 初始化失败，原因：套接字异常");
        }
            break;
            
        case CONSDK_ERR_BUFFER_IS_TOO_SMALL:        // 用作输出拷贝的buffer空间不够
        {
            GosLog(@"iOSConfigSDK 初始化失败，原因：用作输出拷贝的buffer空间不够");
        }
            break;
            
        default:
            break;
    }
}

#pragma mark -- 登录回调
- (void)login:(BOOL)isSuccess
    userToken:(NSString *)uToken
    errorCode:(int)eCode
{
    if (YES == isSuccess)
    {
        GosLog(@"自动登录成功！");
        [GosLoggedInUserInfo saveUserToken:uToken];
        [[NSNotificationCenter defaultCenter] postNotificationName:kAutoLoginSuccessNotify
                                                            object:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:kLoginSuccessNotify
                                                            object:nil];
    }
    else
    {
        GosLog(@"登录失败！");
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self backToLoginVC];
        });
        switch (eCode)
        {
            case CONSDK_ERR_PARAM_ILLEGAL:  // 参数不合法
            {
                GosLog(@"登录失败，error：参数不合法");
                [SVProgressHUD showErrorWithStatus:DPLocalizedString(@"ParamIllegal")];
            }
                break;
                
            case CONSDK_ERR_USER_NOT_EXIST: // 用户不存在
            {
                GosLog(@"登录失败，error：用户不存在");
                [SVProgressHUD showErrorWithStatus:DPLocalizedString(@"AccountNotExist")];
            }
                break;
                
            case CONSDK_ERR_USER_NAME_ERROR:    // 用户名错误
            {
                GosLog(@"登录失败，error：用户名错误");
                [SVProgressHUD showErrorWithStatus:DPLocalizedString(@"UserNameError")];
            }
                break;
                
            case CONSDK_ERR_USER_PWD_ERROR: // 密码错误
            {
                GosLog(@"登录失败，error：密码错误");
                [SVProgressHUD showErrorWithStatus:DPLocalizedString(@"PasswordError")];
            }
                break;
                
            default:    // 网络诊断
            {
                [CheckNetwork showCheckAlert];
            }
                break;
        }
    }
}

#pragma mark -- 自动登录失败，跳转回登录界面
- (void)backToLoginVC
{
    LoginViewController *loginVC = [[LoginViewController alloc] init];
    loginVC.hasNetWork           = YES;
    GosRootViewController *navc  = [[GosRootViewController alloc] initWithRootViewController:loginVC];
    [self.window setRootViewController:navc];
    [self.window makeKeyAndVisible];
}

@end
