//
//  AppDelegate+Jump.m
//  GosIPCs
//
//  Created by shenyuanluo on 2018/11/15.
//  Copyright © 2018 shenyuanluo. All rights reserved.
//

#import "AppDelegate+Jump.h"
#import "CYLTabBarController.h"
// View Controllers
#import "GosRootViewController.h"
#import "DeviceListViewController.h"
#import "GosMallViewController.h"
#import "MineViewController.h"

@implementation AppDelegate (Jump)

#pragma mark --  设置 Root ViewController
+ (void)setUpMainTabBarVCOnWindow:(UIWindow *)rootWindow
                      isAutoLogin:(BOOL)autoLogin
                       hasNetwork:(BOOL)hasNetwork
{
    // 创建CYLTabBarController的对象
    CYLTabBarController *CYLtabVC = [[CYLTabBarController alloc] init];
    
    //设置CYLTabBarController对象的标签栏属性按钮
    CYLtabVC.tabBarItemsAttributes = [self createTabBarItemsAttributes];
    
    //设置CYLTabBarController对象的标签栏子控制器数组
    CYLtabVC.viewControllers = [self createTabBarViewControllers:autoLogin
                                                      hasNetwork:hasNetwork];
    
    //设置CYLTabBarController的对象的根控制器
    [rootWindow setRootViewController:CYLtabVC];
    [rootWindow makeKeyAndVisible];
}

#pragma mark -- 创建标签栏子控制器数组
+ (NSArray *)createTabBarViewControllers:(BOOL)isAutoLogin
                              hasNetwork:(BOOL)hasNetwork
{
    // 设备列表
    DeviceListViewController *devListVC = [[DeviceListViewController alloc] init];
    devListVC.hasNetWork                = hasNetwork;
    devListVC.isAutoLogin               = isAutoLogin;
    GosRootViewController *devListNav   = [[GosRootViewController alloc] initWithRootViewController:devListVC];
    
    // 商城
    GosMallViewController *mallVC       = [[GosMallViewController alloc] init];
    GosRootViewController *mallNav      = [[GosRootViewController alloc] initWithRootViewController:mallVC];
    
    //我的
    MineViewController *mineVC          = [[MineViewController alloc]init];
    GosRootViewController *mineNav      = [[GosRootViewController alloc] initWithRootViewController:mineVC];
    
    return @[devListNav, mallNav, mineNav];
}

#pragma mark -- 创建标签栏按钮item数组
+ (NSArray *)createTabBarItemsAttributes
{
    NSDictionary *dict1 = @{
                            CYLTabBarItemTitle          : DPLocalizedString(@"Device"),
                            CYLTabBarItemImage          : @"icon_camera_normal",
                            CYLTabBarItemSelectedImage  : @"icon_camera_selected",
                            };
    NSDictionary *dict2 = @{
                            CYLTabBarItemTitle          : DPLocalizedString(@"GosMall"),
                            CYLTabBarItemImage          : @"icon_mall_normal",
                            CYLTabBarItemSelectedImage  : @"icon_mall_selected",
                            };
    NSDictionary *dict3 = @{
                            CYLTabBarItemTitle          : DPLocalizedString(@"Mine"),
                            CYLTabBarItemImage          : @"icon_mine_default",
                            CYLTabBarItemSelectedImage  : @"icon_mine_selected",
                            };
    return @[dict1, dict2, dict3];
}

@end
