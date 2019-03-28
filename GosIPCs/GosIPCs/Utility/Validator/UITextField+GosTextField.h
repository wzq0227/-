//  UITextField+GosTextField.h
//  GosIPCs
//
//  Create by daniel.hu on 2018/11/23.
//  Copyright © 2018年 goscam. All rights reserved.

#import <UIKit/UIKit.h>
#import "InputValidator.h"

NS_ASSUME_NONNULL_BEGIN

@interface UITextField (GosTextField)
/// 输入验证参数
@property (nonatomic, strong) IBOutlet InputValidator *inputValidator;
/// 统一验证方法
- (BOOL)validate;
@end

NS_ASSUME_NONNULL_END
