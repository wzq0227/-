//  GosHUD.m
//  GosIPCs
//
//  Create by daniel.hu on 2018/11/20.
//  Copyright © 2018年 goscam. All rights reserved.

#import "GosHUD.h"
#import "SVProgressHUD.h"
#import "GosBottomTipsView.h"
#import "GosHUDView.h"
@implementation GosHUD
+ (void)showProcessHUDSuccessWithStatus:(NSString *)status {
    dispatch_async(dispatch_get_main_queue(), ^{
        [SVProgressHUD showSuccessWithStatus:DPLocalizedString(status)];
    });
}
+ (void)showProcessHUDInfoWithStatus:(NSString *)status {
    dispatch_async(dispatch_get_main_queue(), ^{
        [SVProgressHUD showInfoWithStatus:DPLocalizedString(status)];
    });
}
+ (void)showProcessHUDErrorWithStatus:(NSString *)status {
    dispatch_async(dispatch_get_main_queue(), ^{
        [SVProgressHUD showErrorWithStatus:DPLocalizedString(status)];
    });
}
+ (void)showProcessHUDWithStatus:(NSString *)status {
    dispatch_async(dispatch_get_main_queue(), ^{
        [SVProgressHUD showWithStatus:DPLocalizedString(status)];
    });
}

+ (void)showProcessHUDForLoading {
    [GosHUD showProcessHUDWithStatus:@"SVPLoading"];
}

+ (void)dismiss {
    dispatch_async(dispatch_get_main_queue(), ^{
        [SVProgressHUD dismiss];
    });
}


+ (void)showBottomHUDWithStatus:(NSString *)status {
    dispatch_async(dispatch_get_main_queue(), ^{
        [GosBottomTipsView showWithMessge:DPLocalizedString(status)];
    });
}

+ (void)showScreenfulHUDSuccessWithStatus:(NSString *)status {
    dispatch_async(dispatch_get_main_queue(), ^{
        [GosHUDView showSuccessWithStatus:DPLocalizedString(status)];
    });
}
+ (void)showScreenfulHUDErrorWithStatus:(NSString *)status {
    dispatch_async(dispatch_get_main_queue(), ^{
        [GosHUDView showErrorWithStatus:DPLocalizedString(status)];
    });
}
@end
