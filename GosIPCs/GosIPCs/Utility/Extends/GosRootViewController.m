//
//  GosRootViewController.m
//  Goscom
//
//  Created by shenyuanluo on 2018/11/21.
//  Copyright © 2018 goscam. All rights reserved.
//

#import "GosRootViewController.h"
#import "UIView+GosGradient.h"

@interface GosRootViewController () <
                                        UINavigationControllerDelegate,
                                        UIGestureRecognizerDelegate
                                    >

@end

@implementation GosRootViewController

+ (void)initialize
{
    [self configNavigationBar];
}

#pragma mark -- 设置导航栏背景
+ (void)configNavigationBar
{
    UINavigationBar *navigationBar = [UINavigationBar appearance];
    // 设置导航栏背景
    [navigationBar setBackgroundImage:[self navBGimage]
                        forBarMetrics:UIBarMetricsDefault];
    // 设置导航栏标题
    navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: GOS_WHITE_COLOR,
                                          NSFontAttributeName : GOS_FONT(17)};
    
}

+ (UIImage *)navBGimage
{
    CGRect layerFrame = CGRectMake(0, 0, GOS_SCREEN_W, 64);;
    CAGradientLayer *gradientLayer = [[CAGradientLayer alloc] init];
    // 渐变颜色数组
    gradientLayer.colors = @[(__bridge id)GOSCOM_THEME_START_COLOR.CGColor,
                             (__bridge id)GOSCOM_THEME_END_COLOR.CGColor];
    // 起点和终点表示的坐标系位置，(0,0)表示左上角，(1,1)表示右下角
    gradientLayer.startPoint = CGPointMake(0.0, 0.0);
    gradientLayer.endPoint   = CGPointMake(1.0, 0.0);
    gradientLayer.frame = layerFrame;
    
    return [self imageFromLayer:gradientLayer];
}

#pragma mark -- 根据 Layer 生成 Image
+ (UIImage *)imageFromLayer:(CALayer *)layer
{
    UIGraphicsBeginImageContext(layer.frame.size);
    [layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *retImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return retImage;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // 添加系统的右滑返回
    if ([self respondsToSelector:@selector(interactivePopGestureRecognizer)])
    {
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;  // 启用侧滑手势
        self.interactivePopGestureRecognizer.delegate = self;
    }
    self.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // 状态栏字体颜色：白色
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
}

// 此方法无法监听边缘侧滑手势是否真的返回还是滑动一半又取消的情况
//- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
//{
//    if ([gestureRecognizer isKindOfClass:[UIScreenEdgePanGestureRecognizer class]]) // 监听侧滑手势
//    {
////        [self configTabBarHiddenOrShow];
//    }
//    return YES;
//}
- (void)navigationController:(UINavigationController *)navigationController
      willShowViewController:(UIViewController *)viewController
                    animated:(BOOL)animated
{
    if (!self.isHiddenNavigationBar) {
        return ;
    }
    if(viewController == [navigationController.viewControllers firstObject])
    {
        [navigationController setNavigationBarHidden:YES
                                            animated:YES];
    }
    else
    {
        [navigationController setNavigationBarHidden:NO
                                            animated:YES];
    }
}

- (void)navigationController:(UINavigationController *)navigationController
       didShowViewController:(UIViewController *)viewController
                    animated:(BOOL)animated
{
    [self configTabBarHiddenOrShow];
}

#pragma mark 创建返回按钮
-(UIBarButtonItem *)createBackButtonItem
{
    UIImage *backImg = [[UIImage imageNamed:@"nav_icon_back"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    return [[UIBarButtonItem alloc] initWithImage:backImg
                                            style:UIBarButtonItemStylePlain
                                           target:self
                                           action:@selector(backToLastViewController)];
}


- (void)pushViewController:(UIViewController *)viewController
                  animated:(BOOL)animated
{
    if ([self.viewControllers count]) {
        viewController.hidesBottomBarWhenPushed = YES;
    }
    
    [super pushViewController:viewController animated:YES];
    
    if (1 < self.viewControllers.count)
    {
        if (nil == viewController.navigationItem.leftBarButtonItem)
        {
            viewController.navigationItem.leftBarButtonItem = [self createBackButtonItem];
        }
    }
    else
    {
        viewController.navigationItem.leftBarButtonItem = nil;
    }
}

#pragma mark -- 返回上层控制器
-(void)backToLastViewController
{
    [self popViewControllerAnimated:YES];
    
    [self configTabBarHiddenOrShow];
}

#pragma mark - 设置 TabBar 隐藏/显示
- (void)configTabBarHiddenOrShow
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (1 >= self.viewControllers.count)
        {
            self.tabBarController.tabBar.hidden = NO;
        }
        else
        {
            self.tabBarController.tabBar.hidden = YES;
        }
    });
}

@end
