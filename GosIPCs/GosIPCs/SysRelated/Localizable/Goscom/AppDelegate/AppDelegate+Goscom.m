//
//  AppDelegate+Goscom.m
//  Goscom
//
//  Created by shenyuanluo on 2018/11/13.
//  Copyright © 2018 shenyuanluo. All rights reserved.
//

#import "AppDelegate+Goscom.h"
#import "DHGuidePageHUD.h"

@implementation AppDelegate (Goscom)

- (void)configGoscomDelegate
{
    [self configNavigationBarStyle];
    [self configTabBarStyle];

    if ([self isNewVersion])    // 新版本，显示引导页
    {
        [self setupLauchGuidePages];
    }
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
    navBar.barTintColor         = GOSCOM_THEME_START_COLOR;
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
    
    //SVProgress设置
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
}

#pragma mark -- 设置 TabBar 样式
- (void)configTabBarStyle
{
    // 普通状态下的文字属性
    NSDictionary *normalAttri = @{
                                  NSFontAttributeName:GOS_FONT(12),
                                  NSForegroundColorAttributeName:GOS_COLOR_RGB(0x4D4D4D)
                                  };
    // 选中状态下的文字属性
    NSDictionary *selectedAttri = @{
                                    NSFontAttributeName:GOS_FONT(12),
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
             @"icon_camera_normal",             // 设备列表
             @"icon_mall_normal",               // 商城
             @"icon_mine_default",              // 我的
             ];
}

#pragma mark -- TabBar 选择状态下图片
- (NSArray<NSString *>*)tbSelectedImgNames
{
    return @[
             @"icon_camera_selected",           // 设备列表
             @"icon_mall_selected",             // 商城
             @"icon_mine_selected",             // 我的
             ];
}

#pragma mark -- 设置启动引导页
- (void)setupLauchGuidePages
{
    // 启动引导页图片
    NSArray *imageNameArray = @[
                                @"img_guide_page1",
                                @"img_guide_page2",
                                @"img_guide_page3",
                                ];
    CGRect gpVieframe = CGRectMake(0, 0, GOS_SCREEN_W, GOS_SCREEN_H);
    DHGuidePageHUD *guidePage = [[DHGuidePageHUD alloc] dh_initWithFrame:gpVieframe
                                                          imageNameArray:imageNameArray
                                                          buttonIsHidden:NO];
//    guidePage.slideInto = YES;  // 是否滑动进入
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [window addSubview:guidePage];
    [window bringSubviewToFront:guidePage];
}

@end
