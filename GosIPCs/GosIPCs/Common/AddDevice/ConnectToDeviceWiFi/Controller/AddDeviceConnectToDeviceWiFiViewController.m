//
//  AddDeviceConnectToDeviceWiFiViewController.m
//  ULife3.5
//
//  Created by 罗乐 on 2018/10/9.
//  Copyright © 2018 GosCam. All rights reserved.
//

#import "AddDeviceConnectToDeviceWiFiViewController.h"
#import <SystemConfiguration/CaptiveNetwork.h>
#import <UIKit/UILocalNotification.h>
#import <UserNotifications/UserNotifications.h>
#import "AddDeviceConfigViewController.h"
//#import "JumpWiFiTipsView.h"

@interface AddDeviceConnectToDeviceWiFiViewController ()

@property (weak, nonatomic) IBOutlet UILabel *firstStepLabel;
@property (weak, nonatomic) IBOutlet UILabel *secondStepLabel;
@property (weak, nonatomic) IBOutlet UIImageView *firstStepImgView;
@property (weak, nonatomic) IBOutlet UIImageView *secondStepImgView;
@property (weak, nonatomic) IBOutlet UIButton *nextBtn;

@property (assign, nonatomic)  BOOL hasConnectedToAPWifi;

@property (strong, nonatomic) NSTimer *checkSSIDTimer;

@property (strong, nonatomic)  UILocalNotification *localNotification;

@property (nonatomic, strong) NSString *prefixStr;

@end

@implementation AddDeviceConnectToDeviceWiFiViewController
#pragma mark - 生命周期
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self configUI];
    
    [self addNotifications];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    self.nextBtn.backgroundColor = GOSCOM_THEME_START_COLOR;
    self.nextBtn.layer.cornerRadius = self.nextBtn.bounds.size.height / 2;
    self.nextBtn.hidden = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self addNotifications];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self removeNotifications];
    [SVProgressHUD dismiss];
}

#pragma mark - ui配置
- (void)configUI {
    self.title = DPLocalizedString(@"AddDEV_APAdd");
    
    NSString *devId = [self.devModel.devId substringToIndex:5];
    
    if ([devId hasSuffix:@"P5"]
        || [devId hasSuffix:@"Q5"]
        ) {
        self.prefixStr = @"GOS";
    } else if([devId hasSuffix:@"N5"]
             || [devId hasSuffix:@"66"]
             )
    {
        self.prefixStr = @"VR";
    } else {
        self.prefixStr = @"VR";
    }
    
    self.firstStepImgView.image = [UIImage imageNamed:
                                   [@"addDev_ApTip1_" stringByAppendingString:self.prefixStr]];
    self.secondStepImgView.image = [UIImage imageNamed:
                                    [@"addDev_ApTip2_" stringByAppendingString:self.prefixStr]];
    self.firstStepLabel.text = DPLocalizedString([@"AddDEV_APTip1_"
                                                  stringByAppendingString:self.prefixStr]);
    self.secondStepLabel.text = DPLocalizedString(@"AddDEV_APTip2");
    
    self.prefixStr = [self.prefixStr stringByAppendingString:@"-"];
    
    [self.nextBtn setTitle:DPLocalizedString(@"AddDEV_APButton") forState:UIControlStateNormal];
    
}

#pragma mark - 通知相关
#pragma mark -- 添加通知
- (void)addNotifications{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cancelAllLocalNotificationsFunc) name:@"APWifiConnected" object:nil];
    
    if (!_checkSSIDTimer) {
        [self queryCurWifiName:nil];
        _checkSSIDTimer = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(queryCurWifiName:) userInfo:nil repeats:YES];
    }
}

#pragma mark -- 移除通知
- (void)removeNotifications{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_checkSSIDTimer invalidate];
    _checkSSIDTimer = nil;
}

#pragma mark --取消本地通知发送
- (void)cancelAllLocalNotificationsFunc{
    
    if (!_checkSSIDTimer) {
        return;
    }
    if (@available(iOS 10.0, *)) {
        [UNUserNotificationCenter.currentNotificationCenter removeAllDeliveredNotifications];
        [UNUserNotificationCenter.currentNotificationCenter removeAllPendingNotificationRequests];
    } else {
        [[UIApplication sharedApplication] cancelAllLocalNotifications];
    }
    if (_checkSSIDTimer) {
        [_checkSSIDTimer invalidate];
        _checkSSIDTimer = nil;
    }
    
//    [self gotoAddDevVC];
    
}

#pragma mark -- 进入后台
- (void)applicationDidEnterBackground:(UIApplication *)sender {
    
    UIApplication *application = [UIApplication sharedApplication];
    __block UIBackgroundTaskIdentifier bgTaskIdentifier = [application beginBackgroundTaskWithExpirationHandler:^{
        
        GosLog(@"Starting background task with %f seconds remaining", application.backgroundTimeRemaining);
        
        if (bgTaskIdentifier != UIBackgroundTaskInvalid)
        {
            [application endBackgroundTask:bgTaskIdentifier];
            bgTaskIdentifier = UIBackgroundTaskInvalid;
        }
    }];
    
    
}

#pragma mark -- 进入前台
- (void)applicationWillEnterForeground:(id)sender{
    
//    NSString *curSSID = [self getWifiName];
//    NSString *cmpString = [self.prefixStr stringByAppendingString:@"-"];
//    if ([curSSID containsString:cmpString]) {
//        if (_checkSSIDTimer) {
//            [self cancelAllLocalNotificationsFunc];
//        } else {
//            [self gotoAddDevVC];
//        }
//    }
}

#pragma mark - 查询连接wifi名称
- (void)queryCurWifiName:(id)sender{
    NSString *curSSID = [self getWifiName];
//    NSString *cmpString = [self.prefixStr stringByAppendingString:@"-"];
    if ( [curSSID containsString:self.prefixStr] ) {
        if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
            [self gotoAddDevVC];
        } else {
            [self sendNotification];
        }
        
        GosLog(@"Wifi is connected");
    }else{
        GosLog(@"Wifi not connected");
    }
}

- (void)sendNotification {
    if (@available(iOS 10.0, *)) {
        UNUserNotificationCenter *curUNCenter = UNUserNotificationCenter.currentNotificationCenter;
        UNMutableNotificationContent *unContent = [UNMutableNotificationContent new];
        unContent.body = DPLocalizedString(@"AddDEV_APNotificaton");
        unContent.sound = [UNNotificationSound defaultSound];
        unContent.userInfo = @{@"LocalNotification":@"APWifiConnected"};
        unContent.categoryIdentifier = @"com.goscam.localNotification";
        UNTimeIntervalNotificationTrigger *timeTrigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:3 repeats:NO];
        UNNotificationRequest *req = [UNNotificationRequest requestWithIdentifier:@"LocalNotification" content:unContent trigger:timeTrigger];
        [curUNCenter addNotificationRequest:req withCompletionHandler:^(NSError * _Nullable error) {
            if (error) {
                GosLog(@"addNotificationRequest:%@",error.description);
            }
        }];
    } else {
        NSDate *date = [NSDate dateWithTimeIntervalSinceNow:3];
        _localNotification = [[UILocalNotification alloc] init];
        _localNotification.timeZone = [NSTimeZone defaultTimeZone];
        _localNotification.fireDate = date;
        GosLog(@"localNotification________fireDate:%@",_localNotification.fireDate);
        _localNotification.repeatInterval = 0;
        
        _localNotification.alertBody = DPLocalizedString(@"AddDEV_APNotificaton");
        _localNotification.userInfo = @{@"LocalNotification":@"APWifiConnected"};
        _localNotification.soundName = UILocalNotificationDefaultSoundName;
        
        [[UIApplication sharedApplication] scheduleLocalNotification:_localNotification];
    }
}

- (NSString *) getWifiName {
    NSString *wifiName = nil;
    CFArrayRef wifiInterfaces = CNCopySupportedInterfaces();
    if (!wifiInterfaces)
        return @"";
    
    NSArray *interfaces = (__bridge NSArray *)wifiInterfaces;
    for (NSString *interfaceName in interfaces) {
        CFDictionaryRef dictRef = CNCopyCurrentNetworkInfo((__bridge CFStringRef)(interfaceName));
        if (dictRef) {
            NSDictionary *networkInfo = (__bridge NSDictionary *)dictRef;
            wifiName = [networkInfo objectForKey:(__bridge NSString *)kCNNetworkInfoKeySSID];
            
            CFRelease(dictRef);
        }
    }
    
    CFRelease(wifiInterfaces);
    return wifiName;
}

#pragma mark - 页面跳转
#pragma mark -- 跳转添加设备页面
- (void)gotoAddDevVC{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        AddDeviceConfigViewController *vc = [[AddDeviceConfigViewController alloc] init];
        vc.devModel = self.devModel;
        vc.addMethodType = SupportAdd_apNew;
        [self.navigationController pushViewController:vc animated:NO];
    });
}

#pragma mark - btnAction
- (IBAction)nextbtnAction:(UIButton *)sender {
    /*
    NSString *cmpString = [self.prefixStr stringByAppendingString:@"-"];
    NSString *curSSID = [CommonlyUsedFounctions getCurSSID];
    if ([curSSID containsString:cmpString] && _checkSSIDTimer ) {
        [self cancelAllLocalNotificationsFunc];
    }else if ([curSSID containsString:cmpString]){
        [self gotoAddDevVC];
    }else{
        [self jumpToSysWiFiSetting];//
    }
     */
}
@end
