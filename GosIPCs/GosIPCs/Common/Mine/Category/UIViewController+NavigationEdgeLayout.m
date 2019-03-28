//  UIViewController+NavigationEdgeLayout.m
//  GosIPCs
//
//  Create by daniel.hu on 2018/11/21.
//  Copyright © 2018年 goscam. All rights reserved.

#import "UIViewController+NavigationEdgeLayout.h"
#import <objc/runtime.h>
#import "GosHUD.h"

@implementation UIViewController (NavigationEdgeLayout)
//+ (void)load {
//    // 交换即将消失的方法
//    Method originDidDisappear = class_getInstanceMethod(self, @selector(viewDidDisappear:));
//    Method swizzleDidDisappear = class_getInstanceMethod(self, @selector(swizzle_viewDidDisappear:));
//    method_exchangeImplementations(originDidDisappear, swizzleDidDisappear);
//}
//- (void)swizzle_viewDidDisappear:(BOOL)animated {
//    [self swizzle_viewDidDisappear:animated];
//
//    [GosHUD dismiss];
//}
/// 调整
- (void)adjustDisplay {
    // 只对上偏移
    self.edgesForExtendedLayout = UIRectEdgeBottom;
    self.automaticallyAdjustsScrollViewInsets = NO;
}
/// 恢复调整
- (void)resumeAdjustDisplay {
    self.edgesForExtendedLayout = UIRectEdgeAll;
    self.automaticallyAdjustsScrollViewInsets = YES;
}
@end
