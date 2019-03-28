//  UIView+GosClipView.m
//  GosIPCs
//
//  Create by daniel.hu on 2018/12/7.
//  Copyright © 2018年 goscam. All rights reserved.

#import "UIView+GosClipView.h"

@implementation UIView (GosClipView)
- (void)clipCorners:(UIRectCorner)corners radius:(CGFloat)radius {
    // 圆角路径
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:corners cornerRadii:CGSizeMake(radius, radius)];
    // 创建 蒙版layer
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = self.bounds;
    maskLayer.path = maskPath.CGPath;
    // 覆盖蒙版图层到自身
    self.layer.mask = maskLayer;
}
@end
