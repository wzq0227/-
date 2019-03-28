//  UIView+GosClipView.h
//  GosIPCs
//
//  Create by daniel.hu on 2018/12/7.
//  Copyright © 2018年 goscam. All rights reserved.

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (GosClipView)

/**
 修剪视图的某些圆角

 @param corners UIRectCorner
 @param radius 半径
 */
- (void)clipCorners:(UIRectCorner)corners radius:(CGFloat)radius;
@end

NS_ASSUME_NONNULL_END
