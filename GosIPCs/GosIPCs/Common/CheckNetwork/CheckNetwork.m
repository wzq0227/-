//
//  CheckNetwork.m
//  GosIPCs
//
//  Created by shenyuanluo on 2018/11/24.
//  Copyright © 2018 goscam. All rights reserved.
//

#import "CheckNetwork.h"
#import "CheckNetworkViewController.h"
#import "NSObject+CurrentVC.h"
@implementation CheckNetwork

+ (void)showCheckAlert
{
    [SVProgressHUD dismiss];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil
                                                                   message:DPLocalizedString(@"NetworkReqTimeOUt")
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:DPLocalizedString(@"GosComm_Cancel")
                                                           style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction * _Nonnull action) {
                                                             
                                                         }];
    UIAlertAction *checkAction = [UIAlertAction actionWithTitle:DPLocalizedString(@"CheckNetwork")
                                                          style:UIAlertActionStyleDefault
                                                        handler:^(UIAlertAction * _Nonnull action) {
                                                            
                                                            GosLog(@"检查网络");
                                                            CheckNetworkViewController * vc = [[CheckNetworkViewController alloc] init];
                                                            [[self getCurNavigationVC] pushViewController:vc
                                                                                                 animated:YES];
                                                            //                                                            [self turnToCheckNetwork];
                                                        }];
    [alert addAction:cancelAction];
    [alert addAction:checkAction];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [[self currentViewController] presentViewController:alert
                                                   animated:YES
                                                 completion:nil];
    });
}

#pragma mark - 获取当前控制器
+ (UIViewController *)currentViewController
{
    UIWindow *rootWindow = [UIApplication sharedApplication].keyWindow;
    UIViewController *vc = rootWindow.rootViewController;
    while (vc.presentedViewController)
    {
        vc = vc.presentedViewController;
        
        if ([vc isKindOfClass:[UINavigationController class]])
        {
            vc = [(UINavigationController *)vc visibleViewController];
        }
        else if ([vc isKindOfClass:[UITabBarController class]])
        {
            vc = [(UITabBarController *)vc selectedViewController];
        }
    }
    return vc;
}

@end
