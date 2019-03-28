//
//  AppDelegate+GosBell.m
//  GosBell
//
//  Created by shenyuanluo on 2018/11/13.
//  Copyright © 2018 shenyuanluo. All rights reserved.
//

#import "AppDelegate+GosBell.h"

@implementation AppDelegate (GosBell)

- (void)configGosBellDelegate
{
    [self configNavigationBarStyle];
    [self configTabBarStyle];
}

#pragma mark -- 设置导航栏样式
- (void)configNavigationBarStyle
{
    //设置导航栏默认颜色字体
    NSDictionary *titleAttri    = @{
                                    NSFontAttributeName:[UIFont fontWithName:@"PingFang-SC-Medium"
                                                                        size:18],
                                    NSForegroundColorAttributeName:GOS_WHITE_COLOR
                                    };
    UINavigationBar *navBar     = [UINavigationBar appearance];
    UIBarButtonItem *barBtnItem = [UIBarButtonItem appearance];
    navBar.barTintColor         = GOSBELL_THEME_COLOR;
    navBar.titleTextAttributes  = titleAttri;
    navBar.barStyle             = UIStatusBarStyleLightContent;
    
    // 普通状态下的文字属性
    NSDictionary *normalAttri = @{
                                  NSForegroundColorAttributeName:GOS_WHITE_COLOR
                                  };
    // 高亮状态下的文字属性
    NSDictionary *selectedAttri = @{
                                    NSForegroundColorAttributeName:GOS_WHITE_COLOR
                                    };
    // 设置文字属性
    [barBtnItem setTitleTextAttributes:normalAttri
                              forState:UIControlStateNormal];
    [barBtnItem setTitleTextAttributes:selectedAttri
                              forState:UIControlStateHighlighted];
}

#pragma mark -- 设置 TabBar 样式
- (void)configTabBarStyle
{
    // 普通状态下的文字属性
    NSDictionary *normalAttri = @{
                                  NSFontAttributeName:[UIFont fontWithName:@"PingFang-SC-Medium"
                                                                      size:12],
                                  NSForegroundColorAttributeName:GOS_COLOR_RGB(0x4D4D4D)
                                  };
    // 选中状态下的文字属性
    NSDictionary *selectedAttri = @{
                                    NSFontAttributeName:[UIFont fontWithName:@"PingFang-SC-Medium"
                                                                        size:12],
                                    NSForegroundColorAttributeName:GOS_COLOR_RGB(0x55AFFC)
                                    };
    // 设置文字属性
    UITabBarItem *tabBar = [UITabBarItem appearance];
    [tabBar setTitleTextAttributes:normalAttri
                          forState:UIControlStateNormal];
    [tabBar setTitleTextAttributes:selectedAttri
                          forState:UIControlStateSelected];
    
    UIViewController *rootVC = [[UIApplication sharedApplication].keyWindow rootViewController];
    if ([rootVC isKindOfClass:[UITabBarController class]])
    {
        UITabBarController *tabVC = (UITabBarController *)rootVC;
        NSArray <UITabBarItem*>*tbItemArray = tabVC.tabBar.items;
        
        // 设置图片属性
        for (int i = 0; i < tbItemArray.count; i++)
        {
            NSString *tbTitle    = nil;
            UIImage *normalImg   = nil;     // 普通状态下的图片
            UIImage *selectedImg = nil;     // 选中h状态下的图片
            if (i < [self tbTitleStrings].count)
            {
                tbTitle = [self tbTitleStrings][i];
            }
            if (i < [self tbNormalImgNames].count)
            {
                normalImg = GOS_IMAGE([self tbNormalImgNames][i]);
            }
            if (i < [self tbSelectedImgNames].count)
            {
                selectedImg = GOS_IMAGE([self tbSelectedImgNames][i]);
            }
            tbItemArray[i].title         = tbTitle;
            tbItemArray[i].image         = normalImg;
            tbItemArray[i].selectedImage = selectedImg;
        }
    }
}

#pragma mark -- TabBar 标题
- (NSArray<NSString *>*)tbTitleStrings
{
    return @[
             DPLocalizedString(@"Device"),      // 设备列表
             DPLocalizedString(@"GosMall"),     // 商城
             DPLocalizedString(@"Mine")         // 我的
             ];
}

#pragma mark -- TabBar 普通状态下图片
- (NSArray<NSString *>*)tbNormalImgNames
{
    return @[
             @"DeviceListNormal",               // 设备列表
             @"GosMallNormal",                  // 商城
             @"MineNormal",                     // 我的
             ];
}

#pragma mark -- TabBar 选择状态下图片
- (NSArray<NSString *>*)tbSelectedImgNames
{
    return @[
             @"DeviceListSelected",             // 设备列表
             @"GosMallSelected",                // 商城
             @"MineSelected",                   // 我的
             ];
}

@end
