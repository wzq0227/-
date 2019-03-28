//
//  UIAlertController+AddDeviceTip.m
//  ULife3.5
//
//  Created by 罗乐 on 2018/9/17.
//  Copyright © 2018年 GosCam. All rights reserved.
//

#import "UIAlertController+AddDeviceTip.h"
#import "CheckNetworkViewController.h"
#import "AddDeviceFirstViewController.h"
#import "ChooseAddMethodViewController.h"

@implementation UIAlertController (AddDeviceTip)

+ (void)setAlertUI:(UIAlertController *)alertVC message:(NSString *)message {
    UIView *subView1 = alertVC.view.subviews[0];
    UIView *subView2 = subView1.subviews[0];
    UIView *subView3 = subView2.subviews[0];
    UIView *subView4 = subView3.subviews[0];
    UIView *subView5 = subView4.subviews[0];
    UILabel *messageLab = subView5.subviews[1];
    
    if ([messageLab.text isEqualToString:message]) {
        messageLab.textAlignment = NSTextAlignmentLeft;
    } else if (subView5.subviews.count >= 3) {
        UILabel *messageLab1 = subView5.subviews[2];
        if ([messageLab1.text isEqualToString:message]) {
            messageLab1.textAlignment = NSTextAlignmentLeft;
        }
    }
    
//    alertVC.view.tintColor = [UIColor blackColor];
}

+ (instancetype)AddFailedAlertControllerWithNavigationController:(UINavigationController *)navigationController {
    UIAlertController *alertVC =
    [UIAlertController alertControllerWithTitle:DPLocalizedString(@"AddDEV_addFailed")
                                        message:DPLocalizedString(@"AddDEV_addFailed_tip")
                                 preferredStyle:UIAlertControllerStyleAlert];
//    alertVC.view.backgroundColor = [UIColor whiteColor];
    
    UIAlertAction *networkCheck =
        [UIAlertAction actionWithTitle:DPLocalizedString(@"AddDEV_networkCheck")
                                 style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * _Nonnull action)
        {
            CheckNetworkViewController *checkVC = [[CheckNetworkViewController alloc] init];
            checkVC.loginAgain = NO;
            [navigationController pushViewController:checkVC animated:YES];
        }];
    UIAlertAction *otherMethodAdd =
        [UIAlertAction actionWithTitle:DPLocalizedString(@"AddDEV_otherMethodAdd")
                                 style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * _Nonnull action)
        {
            NSMutableArray *tempArr = [NSMutableArray arrayWithArray:navigationController.viewControllers];
            for (int i = 0; i < tempArr.count; i++) {
                UIViewController *vc = tempArr[i];
                if ([vc isKindOfClass: [AddDeviceFirstViewController class]]) {
                    AddDeviceFirstViewController *firstVC = (AddDeviceFirstViewController *)vc;
                    ChooseAddMethodViewController *chooseVC = [firstVC getChooseAddMethodViewController];
                    [tempArr insertObject:chooseVC atIndex:i+1];
                    [navigationController setViewControllers:tempArr];
                    [navigationController popToViewController:chooseVC animated:YES];
                    break;
                }
            }
        }];
    [alertVC addAction:networkCheck];
    [alertVC addAction:otherMethodAdd];
    
    NSString *message = DPLocalizedString(@"AddDEV_addFailed_tip");
    //message 居左
    [self setAlertUI:alertVC message:message];
    return alertVC;
}

+ (instancetype)NoSoundAlertController {
    NSString *message = DPLocalizedString(@"AddDEV_NoSoundText");
    UIAlertController *alertVC =
    [UIAlertController alertControllerWithTitle:DPLocalizedString(@"AddDEV_NoSoundTitle")
                                        message:message
                                 preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:DPLocalizedString(@"GosComm_Confirm")
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * _Nonnull action) {}];
    [alertVC addAction:cancelAction];
    //message 居左
    [self setAlertUI:alertVC message:message];
    return alertVC;
}

@end
