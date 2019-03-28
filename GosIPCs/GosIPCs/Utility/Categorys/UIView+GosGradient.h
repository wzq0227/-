//
//  UIView+GosGradient.h
//  Goscom
//
//  Created by shenyuanluo on 2018/11/21.
//  Copyright © 2018 goscam. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/* 渐变方向类型 */
typedef NS_ENUM(NSInteger, GosGradientType) {
    GosGradientTopToBottom              = 0,    // 从上到下渐变
    GosGradientLeftToRight              = 1,    // 从左到右渐变
    GosGradientTopLeftToBottomRight     = 2,    // 从左上到右下
    GosGradientBottomLeftToTopRight     = 3,    // 从左下到右上
    
};

@interface UIView (GosGradient)

/**
 设置 View 颜色渐变效果（建议在 ‘viewWillLayoutSubviews’ 方法里面调用，或者 View bounds 已确定的情况下，否则会绘制不准确（如 在 'viewDidLoad' 方法里面调用））
 
 @param startColor 渐变起始颜色
 @param endColor 渐变终止颜色
 @param radius 图层圆角半径
 @param direction 渐变方式，参见‘GosGradientType’
 */
-(void)gradientStartColor:(UIColor *)startColor
                 endColor:(UIColor *)endColor
             cornerRadius:(CGFloat)radius
                direction:(GosGradientType)direction;




@end

NS_ASSUME_NONNULL_END
