//  UIColor+GosColor.m
//  GosIPCs
//
//  Create by daniel.hu on 2018/11/21.
//  Copyright © 2018年 goscam. All rights reserved.

#import "UIColor+GosColor.h"

@implementation UIColor (GosColor)
+ (UIColor *)gosGrayColor {
    return GOS_COLOR_RGB(0xF7F7F7);
}
+ (UIColor *)gosWhiteColor {
    return GOS_COLOR_RGB(0xFFFFFF);
}
+ (UIColor *)gosLightGrayColor {
    return GOS_COLOR_RGB(0xCCCCCC);
}
@end
