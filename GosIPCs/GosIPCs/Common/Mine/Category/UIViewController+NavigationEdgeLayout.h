//  UIViewController+NavigationEdgeLayout.h
//  GosIPCs
//
//  Create by daniel.hu on 2018/11/21.
//  Copyright © 2018年 goscam. All rights reserved.

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 扩展存在导航栏时的偏移显示
 */
@interface UIViewController (NavigationEdgeLayout)
/// 调整
- (void)adjustDisplay;
/// 恢复调整
- (void)resumeAdjustDisplay;
@end

NS_ASSUME_NONNULL_END
