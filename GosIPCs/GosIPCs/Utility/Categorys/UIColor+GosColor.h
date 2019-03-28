//  UIColor+GosColor.h
//  GosIPCs
//
//  Create by daniel.hu on 2018/11/21.
//  Copyright © 2018年 goscam. All rights reserved.

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIColor (GosColor)
/// 控制器下的背景色
+ (UIColor *)gosGrayColor;
/// 白色
+ (UIColor *)gosWhiteColor;
/// 亮灰色
+ (UIColor *)gosLightGrayColor;
@end

NS_ASSUME_NONNULL_END
