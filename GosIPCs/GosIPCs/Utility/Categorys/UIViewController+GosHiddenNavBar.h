//
//  UIViewController+GosHiddenNavBar.h
//  GosIPCs
//
//  Created by shenyuanluo on 2018/11/22.
//  Copyright © 2018 goscam. All rights reserved.
//

/*
 设置单页面 NavigationBar 隐藏 类
 用法：在需要隐藏 navigationBar 的 UIViewController 里这样写:(不需要隐藏的就不用管)
  self.navigationController.delegate = self;    // 设置代理即可
 */

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIViewController (GosHiddenNavBar) <UINavigationControllerDelegate>

@end

NS_ASSUME_NONNULL_END
