//
//  UIViewController+CommonExtension.h
//  Goscom
//
//  Created by 匡匡 on 2018/11/30.
//  Copyright © 2018 goscam. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface UIViewController (CommonExtension)

/**
 初始化导航栏右边标题
 
 @param title 标题名
 @param font 字体
 @param titleColor 字体颜色
 */
- (void) configRightBtnTitle:(NSString *) title
                   titleFont:(UIFont *) font
                  titleColor:(UIColor *) titleColor;


/**
 初始化导航栏右边图片
 
 @param imgStr 图片名
 */
- (void) configRightBtnImg:(NSString *) imgStr;


/**
 暴露点击事件
 */
- (void) rightBtnClicked;
@end


