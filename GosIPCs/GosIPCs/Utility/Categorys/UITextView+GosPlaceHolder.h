//  UITextView+GosPlaceHolder.h
//  GosIPCs
//
//  Create by daniel.hu on 2018/11/24.
//  Copyright © 2018年 goscam. All rights reserved.

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UITextView (GosPlaceHolder)
/// 占位符
@property (nonatomic, copy) NSString *gosPlaceHolder;
/// 占位符颜色
@property (nonatomic, copy) UIColor *gosPlaceHolderColor;
/// 字符限制数量
@property (nonatomic, assign) NSInteger textMaxLimit;
/// 字符限制数量颜色
@property (nonatomic, copy) UIColor *textLimitColor;
@end

NS_ASSUME_NONNULL_END
