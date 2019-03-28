//
//  AppDelegate.m
//  GosIPCs
//
//  Created by shenyuanluo on 2018/11/10.
//  Copyright © 2018 shenyuanluo. All rights reserved.
//

#import "AppDelegate.h"
#import "ExceptionCatch.h"
#import "IQKeyboardManager.h"
#import "AppDelegate+Jump.h"
#import "AppDelegate+Goscom.h"
#import "AppDelegate+GosBell.h"
#import "LoginViewController.h"
#import "GosRootViewController.h"
#import "AppDelegate+GosAutoLogin.h"
#import "APNSManager.h"
#import "GosDevManager.h"
#import "iOSDevSDK.h"
#import "GosDB.h"
#import <iOSPaymentSDK/iOSPaymentSDK.h>
#import "MonitorNetwork.h"


@interface AppDelegate () <
                            UIApplicationDelegate
                          >
@end


@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    GosLog(@"--- AppDelegate: didFinishLaunchingWithOptions ---");
    [MonitorNetwork startMonitor]; // 开启网络监控
    // 通用的请放这里
    [self setUpRootVC];
    // 不同定制 App-Target 请放这里
    switch (TargetType)
    {
        case Target_Goscom:
        {
            [self configGoscomDelegate];
        }
            break;
            
        case Target_GosBell:
        {
            [self configGosBellDelegate];
        }
            break;
            
        default:
            break;
    }
    [ExceptionCatch initCatcher];   // 异常捕获
    
    // 注册 APNS-Remote
    [APNSManager registiOSRemoteApns];
    
    if (NSFoundationVersionNumber_iOS_9_x_Max >= NSFoundationVersionNumber) // iOS 10.0 以前（iOS 10.0 以后由‘didReceiveNotificationResponse’ 处理
    {
        // 有推送消息（只有点击推送消息来重新启动 APP 时才会有，否则，如果是点击 APP-Icon 来重新启动 APP 的话，则不会有）
        NSDictionary *userInfo = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
        if (userInfo)
        {
            GosLog(@"didFinishLaunchingWithOptions - 接收到推送通知！");
            
            [APNSManager handleRemoteNotification:userInfo
                                          isClick:YES];
        }
    }
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    GosLog(@"--- AppDelegate: applicationWillResignActive ---");
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    GosLog(@"--- AppDelegate: applicationDidEnterBackground ---");
    [self saveAppLife];
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    GosLog(@"--- AppDelegate: applicationWillEnterForeground ---");
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    GosLog(@"--- AppDelegate: applicationDidBecomeActive ---");
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    GosLog(@"--- AppDelegate: applicationWillTerminate ---");
    
    [[iOSDevSDK shareDevSDK] disConnAllDevice];
    
    [GosDB closeDB];
}

#pragma mark --  设置 Root ViewController
- (void)setUpRootVC
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [IQKeyboardManager sharedManager].enable = YES;
    BOOL isAudoLogin  = [GosLoggedInUserInfo isAutoLogin];  // 是否自动登录（已记住密码）
    self.lastAccount  = [GosLoggedInUserInfo account];      // 已有登录账号
    self.lastPassword = [GosLoggedInUserInfo password];     // 已有登录密码
    
    CurNetworkStatus networkStatus = [MonitorNetwork currentStatus];
    BOOL hasNetwork = YES;
    if (networkStatus == CurNetwork_unknow)
    {
        hasNetwork = NO;
    }
    
    if (YES == isAudoLogin)    // 实现自动登录，不经过登录界面
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            
            if (NO == hasNetwork)    // 没有网络，不进行自动登录
            {
                return ;
            }
            [self autoLogin];
        });
        [AppDelegate setUpMainTabBarVCOnWindow:self.window
                                   isAutoLogin:YES
                                    hasNetwork:hasNetwork];
    }
    else
    {
        LoginViewController *loginVC = [[LoginViewController alloc] init];
        loginVC.hasNetWork = hasNetwork;
        GosRootViewController *navc  = [[GosRootViewController alloc] initWithRootViewController:loginVC];

        [self.window setRootViewController:navc];
        [self.window makeKeyAndVisible];
    }
}

#pragma mark -- 判断是否是新版本
- (BOOL)isNewVersion
{
#if DEBUG
//    return YES;
#endif
    // 取得当前应用的版本号
    NSDictionary *infoDic = [[NSBundle mainBundle] infoDictionary];
    NSString *curVersion  = infoDic[@"CFBundleShortVersionString"];
    
    // 取得当前保存的版本号
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    NSString *saveVerion    = [userDef objectForKey:APP_VERSION_KEY];
    if (!saveVerion || ![saveVerion isEqualToString:curVersion])
    {
        // 保存最新的版本号
        [userDef setObject:curVersion forKey:APP_VERSION_KEY];
        GosLog(@"有新版本，显示引导页！");
        return YES;
    }
    return NO;
}

#pragma mark -- 保活 APP 处理
- (void)saveAppLife
{
    UIApplication*   app = [UIApplication sharedApplication];
    __block    UIBackgroundTaskIdentifier bgTask;
    bgTask = [app beginBackgroundTaskWithExpirationHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if (bgTask != UIBackgroundTaskInvalid)
            {
                bgTask = UIBackgroundTaskInvalid;
            }
        });
    }];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if (bgTask != UIBackgroundTaskInvalid)
            {
                bgTask = UIBackgroundTaskInvalid;
            }
        });
    });
}


#pragma mark -- ‘Remote’推送消息接收代理
// 此代理方法仅当 APP 处于‘foreground’模式下才会执行而且 iOS 10.0 以后被‘建议不使用’
//- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    GosLog(@"didReceiveRemoteNotification - 接收到推送通知：%@", userInfo);
    UIApplicationState appState = [application applicationState];
    switch (appState)
    {
        case UIApplicationStateActive:      // 应用在前台，接收‘Remote’推送，会进入这个状态
        {
            GosLog(@"UIApplicationStateActive - 接收到推送通知！");
            
            [APNSManager handleRemoteNotification:userInfo
                                          isClick:NO];
        }
            break;
            
        case UIApplicationStateInactive:    // 应用在后台，通过点击‘Remote’推送通知，进入这个状态
        {
            GosLog(@"UIApplicationStateInactive - 接收到推送通知！");
            
            [APNSManager handleRemoteNotification:userInfo
                                          isClick:YES];
        }
            break;
            
        case UIApplicationStateBackground:  // 应用在后台，收到静默‘Remote’推送（用户界面是不会有任何提示），进入这个状态
        {
            GosLog(@"UIApplicationStateBackground - 接收到推送通知！");
            
            [APNSManager handleRemoteNotification:userInfo
                                          isClick:NO];
        }
            break;
            
        default:
            break;
    }
    
    /* 此处用于设置当 APP 处于后台是继续执行此方法（即通过 API--Background Fetch 允许在后台处理推送）
     记得在 APP-capabilities 中打开 'Background Mode' 并设置 "Remote Notifications" */
    // 在此方法中一定要调用completionHandler这个回调，告诉系统是否处理成功
    if (userInfo)   // 有推送消息
    {
        completionHandler(UIBackgroundFetchResultNewData);  // 告知系统成功接收到数据
    }
    else    // 无推送消息
    {
        completionHandler(UIBackgroundFetchResultNoData);   // 告知系统没有收到数据
    }
}

#pragma mark - 第三方支付跳转
/// iOS9.0以后的新API
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    return [iOSPaymentSDK paymentHandleOpenURL:url options:options sourceApplication:nil];
}
/// iOS2.0-9.0
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    return [iOSPaymentSDK paymentHandleOpenURL:url options:nil sourceApplication:nil];
}
/// iOS4.2-9.0
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [iOSPaymentSDK paymentHandleOpenURL:url options:nil sourceApplication:sourceApplication];
}

#pragma mark - UIApplicationDelegate （APNS）
#pragma mark -- APNS-Remote 注册回调（成功时）
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    GosLog(@"APNS-Remote 注册成功且返回 deviceToken！");
    [APNSManager saveiOSToken:deviceToken];
}

#pragma mark -- APNS-Remote 注册回调（失败时）
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    GosLog(@"APNS-Remote 注册失败！");
}

@end
