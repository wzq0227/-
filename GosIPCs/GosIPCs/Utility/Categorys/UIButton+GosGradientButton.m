//  UIButton+GosGradientButton.m
//  Goscom
//
//  Create by daniel.hu on 2018/12/7.
//  Copyright © 2018年 goscam. All rights reserved.

#import "UIButton+GosGradientButton.h"
#import <objc/runtime.h>
@interface UIButton ()
/// 渐变色数组
@property (nonatomic, copy) NSArray *gradientColorArray;
/// 渐变色方向类型
@property (nonatomic, assign) GosGradientType gradientPointType;
/// 渐变色图层
@property (nonatomic, weak) CAGradientLayer *gradientLayer;
@end
@implementation UIButton (GosGradientButton)

+ (void)load {
    method_exchangeImplementations(class_getInstanceMethod(self.class, @selector(layoutSubviews)),
                                   class_getInstanceMethod(self.class, @selector(gradient_layoutSubviews)));
}
#pragma mark - 替换系统layoutSubviews方法
- (void)gradient_layoutSubviews {
    
    [self gradient_layoutSubviews];
    
    // 如果存在的渐变色数组
    if (self.gradientColorArray) {
        // 如果渐变色图层已经被添加，需要移除
        if ([self.gradientLayer superlayer]) {
            [self.gradientLayer removeFromSuperlayer];
        }
        CGRect layerFrame = {CGPointZero, self.bounds.size};
        CAGradientLayer *gradientLayer = [[CAGradientLayer alloc] init];
        // 渐变颜色数组
        gradientLayer.colors = self.gradientColorArray;
        // 起点和终点表示的坐标系位置，(0,0)表示左上角，(1,1)表示右下角
        switch (self.gradientPointType) {
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
        gradientLayer.frame = layerFrame;
        self.gradientLayer = gradientLayer;
        // 添加到self.layer图层中去
        [self.layer insertSublayer:gradientLayer
                           atIndex:0];
        
    }
    
    // 设置圆角
    if (self.cornerRadiusFromHeightRatio) {
        self.layer.cornerRadius = self.bounds.size.height * [self.cornerRadiusFromHeightRatio floatValue];
        self.layer.masksToBounds = YES;
    }
}


#pragma mark - 设置方法
- (void)setupGradientWithBlueColorAndHalfHeightAndLeftToRightDirection {
    [self setupGradientStartColor:GOSCOM_THEME_START_COLOR
                         endColor:GOSCOM_THEME_END_COLOR
      cornerRadiusFromHeightRatio:0.5
                        direction:GosGradientLeftToRight];
}
- (void)setupGradientStartColor:(UIColor *)startColor
                       endColor:(UIColor *)endColor
                      direction:(GosGradientType)direction {
    self.gradientColorArray = @[
                                (__bridge id)startColor.CGColor,
                                (__bridge id)endColor.CGColor
                                ];
    self.gradientPointType = direction;
}
- (void)setupGradientStartColor:(UIColor *)startColor
                       endColor:(UIColor *)endColor
    cornerRadiusFromHeightRatio:(CGFloat)cornerRadiusFromHeightRatio
                      direction:(GosGradientType)direction {
    self.gradientColorArray = @[
                                (__bridge id)startColor.CGColor,
                                (__bridge id)endColor.CGColor
                                ];
    self.cornerRadiusFromHeightRatio = @(cornerRadiusFromHeightRatio);
    self.gradientPointType = direction;
}

#pragma mark - getters and setters
- (void)setGradientColorArray:(NSArray *)gradientColorArray {
    objc_setAssociatedObject(self, @selector(gradientColorArray), gradientColorArray, OBJC_ASSOCIATION_COPY_NONATOMIC);
}
- (NSArray *)gradientColorArray {
    return objc_getAssociatedObject(self, _cmd);
}
- (void)setCornerRadiusFromHeightRatio:(NSNumber *)cornerRadiusFromHeightRatio {
    // 限制在0.0~1.0之内
    if ([cornerRadiusFromHeightRatio floatValue] > 1.0) {
        cornerRadiusFromHeightRatio = @(1.0);
    } else if ([cornerRadiusFromHeightRatio floatValue] < 0.0) {
        cornerRadiusFromHeightRatio = @(0.0);
    }
    objc_setAssociatedObject(self, @selector(cornerRadiusFromHeightRatio), cornerRadiusFromHeightRatio, OBJC_ASSOCIATION_COPY_NONATOMIC);
}
- (NSNumber *)cornerRadiusFromHeightRatio {
    return objc_getAssociatedObject(self, _cmd);
}
- (void)setGradientPointType:(GosGradientType)gradientPointType {
    objc_setAssociatedObject(self, @selector(gradientPointType), @(gradientPointType), OBJC_ASSOCIATION_COPY_NONATOMIC);
}
- (GosGradientType)gradientPointType {
    return [objc_getAssociatedObject(self, _cmd) integerValue];
}
- (CAGradientLayer *)gradientLayer {
    return objc_getAssociatedObject(self, _cmd);
}
- (void)setGradientLayer:(CAGradientLayer *)gradientLayer {
    objc_setAssociatedObject(self, @selector(gradientLayer), gradientLayer, OBJC_ASSOCIATION_ASSIGN);
}
@end
