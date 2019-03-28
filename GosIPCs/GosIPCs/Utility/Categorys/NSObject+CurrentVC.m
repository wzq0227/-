//
//  NSObject+CurrentVC.m
//  GosIPCs
//
//  Created by shenyuanluo on 2018/12/18.
//  Copyright © 2018 goscam. All rights reserved.
//

#import "NSObject+CurrentVC.h"

@implementation NSObject (CurrentVC)

#pragma mark -- 获取当前屏幕显示的控制器
- (UIViewController *)getCurrentVC
{
    UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    
    UIViewController *currentVC = [self getCurrentVCFrom:rootViewController];
    
    return currentVC;
}

- (UINavigationController *)getCurNavigationVC
{
    UIViewController *rootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
    UINavigationController *curNavVC = [self getCurNavigationVCFrom:rootVC];
    
    return curNavVC;
}

- (UIViewController *)getCurrentVCFrom:(UIViewController *)rootVC
{
    UIViewController *currentVC;
    
    if ([rootVC presentedViewController])   // 视图是被presented出来的
    {
        rootVC = [rootVC presentedViewController];
    }
    
    if ([rootVC isKindOfClass:[UITabBarController class]])  // 根视图为 UITabBarController
    {
        currentVC = [self getCurrentVCFrom:[(UITabBarController *)rootVC selectedViewController]];
        
    }
    else if ([rootVC isKindOfClass:[UINavigationController class]]) // 根视图为 UINavigationController
    {
        currentVC = [self getCurrentVCFrom:[(UINavigationController *)rootVC visibleViewController]];
        
    }
    else    // 根视图为非导航类
    { 
        currentVC = rootVC;
    }
    
    return currentVC;
}

- (UINavigationController *)getCurNavigationVCFrom:(UIViewController *)rootVC
{
    UIViewController *curNavVC;
    
//    if ([rootVC presentedViewController])   // 视图是被presented出来的
//    {
//        rootVC = [rootVC presentedViewController];
//    }
    
    if ([rootVC isKindOfClass:[UITabBarController class]])  // 根视图为 UITabBarController
    {
        curNavVC = [self getCurNavigationVCFrom:[(UITabBarController *)rootVC selectedViewController]];
        
    }
    else if ([rootVC isKindOfClass:[UINavigationController class]]) // 根视图为 UINavigationController
    {
        curNavVC = rootVC;
        
    }
    else    // 根视图为非导航类
    {
        curNavVC = rootVC;
    }
    
    return (UINavigationController *)curNavVC;
}

@end
