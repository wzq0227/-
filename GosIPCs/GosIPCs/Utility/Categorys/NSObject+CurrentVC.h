//
//  NSObject+CurrentVC.h
//  GosIPCs
//
//  Created by shenyuanluo on 2018/12/18.
//  Copyright © 2018 goscam. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (CurrentVC)

/*
 获取当前屏幕显示的控制器（主线程调用）
 
 @return 当前显示的控制器
 */
- (UIViewController *)getCurrentVC;

/*
 获取当前导航控制器（主线程调用）
 
 @return 当前导航控制器
 */
- (UINavigationController *)getCurNavigationVC;

@end

NS_ASSUME_NONNULL_END
