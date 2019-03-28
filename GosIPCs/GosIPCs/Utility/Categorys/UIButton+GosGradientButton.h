//  UIButton+GosGradientButton.h
//  Goscom
//
//  Create by daniel.hu on 2018/12/7.
//  Copyright © 2018年 goscam. All rights reserved.

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/* 渐变方向类型 */
typedef NS_ENUM(NSInteger, GosGradientType) {
    GosGradientTopToBottom              = 0,    // 从上到下渐变
    GosGradientLeftToRight              = 1,    // 从左到右渐变
    GosGradientTopLeftToBottomRight     = 2,    // 从左上到右下
    GosGradientBottomLeftToTopRight     = 3,    // 从左下到右上
    
};

/**
 给按钮设置渐变色背景，基于高度设置圆角
 */
@interface UIButton (GosGradientButton)
/**
 设置渐变色效果以及圆角
 
 @param startColor 渐变起始颜色
 @param endColor 渐变终止颜色
 @param cornerRadiusFromHeightRatio 基于高度比例的圆角半径（取值范围0.0~1.0）
 @param direction 渐变方式，参见‘GosGradientType’
 */
- (void)setupGradientStartColor:(UIColor *)startColor
                       endColor:(UIColor *)endColor
    cornerRadiusFromHeightRatio:(CGFloat)cornerRadiusFromHeightRatio
                      direction:(GosGradientType)direction;
/**
 设置渐变色效果
 注：不设置圆角
 @param startColor 渐变起始颜色
 @param endColor 渐变终止颜色
 @param direction 渐变方式，参见‘GosGradientType’
 */
- (void)setupGradientStartColor:(UIColor *)startColor
                       endColor:(UIColor *)endColor
                      direction:(GosGradientType)direction;


/**
 设置渐变色效果及圆角
 startColor:        GOSCOM_THEME_START_COLOR
 endColor:          GOSCOM_THEME_END_COLOR
 GosGradientType:   GosGradientLeftToRight
 cornerRadiusFromHeightRatio: @(0.5)
 */
- (void)setupGradientWithBlueColorAndHalfHeightAndLeftToRightDirection;

/// 基于高度比例的圆角（取值范围0.0~1.0）
@property (nonatomic, copy) NSNumber *cornerRadiusFromHeightRatio;
@end

NS_ASSUME_NONNULL_END
