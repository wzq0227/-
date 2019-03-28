//
//  UIView+GosGradient.m
//  Goscom
//
//  Created by shenyuanluo on 2018/11/21.
//  Copyright © 2018 goscam. All rights reserved.
//

#import "UIView+GosGradient.h"
#import <objc/runtime.h>

@implementation UIView (GosGradient)

-(void)gradientStartColor:(UIColor *)startColor
                 endColor:(UIColor *)endColor
             cornerRadius:(CGFloat)radius
                direction:(GosGradientType)direction
{
    CGRect layerFrame = {CGPointZero, self.bounds.size};
    CAGradientLayer *gradientLayer = [[CAGradientLayer alloc] init];
    // 渐变颜色数组
    gradientLayer.colors = @[(__bridge id)startColor.CGColor,
                             (__bridge id)endColor.CGColor];
    // 起点和终点表示的坐标系位置，(0,0)表示左上角，(1,1)表示右下角
    switch (direction)
    {
        case GosGradientTopToBottom:
        {
            gradientLayer.startPoint = CGPointMake(0.0, 0.0);
            gradientLayer.endPoint   = CGPointMake(0.0, 1.0);
        }
            break;
        case GosGradientLeftToRight:
        {
            gradientLayer.startPoint = CGPointMake(0.0, 0.0);
            gradientLayer.endPoint   = CGPointMake(1.0, 0.0);
        }
            break;
            
        case GosGradientTopLeftToBottomRight:
        {
            gradientLayer.startPoint = CGPointMake(0.0, 0.0);
            gradientLayer.endPoint   = CGPointMake(1.0, 1.0);
        }
            break;
            
        case GosGradientBottomLeftToTopRight:
        {
            gradientLayer.startPoint = CGPointMake(0.0, 1.0);
            gradientLayer.endPoint   = CGPointMake(1.0, 0.0);
        }
            break;
            
        default:
            break;
    }
    GOS_WEAK_SELF;
    dispatch_async(dispatch_get_main_queue(), ^{
        
        GOS_STRONG_SELF;
        gradientLayer.frame = layerFrame;
        [strongSelf.layer insertSublayer:gradientLayer
                                 atIndex:0];
//        [strongSelf.layer addSublayer:gradientLayer];
        if (0 < radius)
        {
            gradientLayer.cornerRadius = radius;
            [strongSelf.layer masksToBounds];
        }
    });
}

@end
