//  LogoutModuleCommand.m
//  GosIPCs
//
//  Create by daniel.hu on 2018/11/28.
//  Copyright © 2018年 goscam. All rights reserved.

#import "LogoutModuleCommand.h"
#import "iOSConfigSDK.h"
#import "GosHUD.h"
#import "GosLoggedInUserInfo.h"
#import "GosLoggedInUserInfo+SDKExtension.h"
#import "LoginViewController.h"
#import "GosRootViewController.h"
#import "PushStatusMananger.h"
#import "APNSManager.h"
#import "MonitorNetwork.h"


@interface LogoutModuleCommand ()
@property (nonatomic, strong) iOSConfigSDK *configSDK;
@end
@implementation LogoutModuleCommand

- (void)execute {
    [GosHUD showProcessHUDWithStatus:@"Mine_Loading"];
    BOOL isLogout = [self.configSDK logout];
    
    if (isLogout) {
        // 清空密码
        [GosLoggedInUserInfo saveAutoLogin:NO];
        [GosLoggedInUserInfo clearPassword];
        [self closePush];
        // 跳转到登录页面
        dispatch_async(dispatch_get_main_queue(), ^{
            [GosHUD dismiss];
            
            CurNetworkStatus networkStatus = [MonitorNetwork currentStatus];
            LoginViewController *loginVC = [[LoginViewController alloc] init];
            loginVC.hasNetWork = (networkStatus == CurNetwork_unknow)?NO:YES;
            GosRootViewController *navc  = [[GosRootViewController alloc] initWithRootViewController:loginVC];
            [UIApplication sharedApplication].keyWindow.rootViewController = navc;
        });
        [[NSNotificationCenter defaultCenter] postNotificationName:kLogoutSuccessNotify
                                                            object:nil];
    } else {
        [GosHUD showProcessHUDErrorWithStatus:@"NetworkError"];
    }
}

- (void)closePush
{
    NSArray<DevPushStatusModel*>* dpsList = [PushStatusMananger pushStatusList];
    for (int i = 0; i < dpsList.count; i++)
    {
        if (NO == dpsList[i].PushFlag)
        {
            return;
        }
        [APNSManager closePushWithDevId:dpsList[i].DeviceId
                                 result:^(BOOL isSuccess)
         {
             if (NO == isSuccess)
             {
                 GosLog(@"注销登录时，关闭设备（ID = %@）推送失败！", dpsList[i].DeviceId);
             }
             else
             {
                 GosLog(@"注销登录时，关闭设备（ID = %@）推送成功！", dpsList[i].DeviceId);
             }
         }];
    }
}

- (iOSConfigSDK *)configSDK {
    if (!_configSDK) {
        _configSDK = [iOSConfigSDK shareCofigSdk];
    }
    return _configSDK;
}
@end
