//  PasswordInputValidator.h
//  GosIPCs
//
//  Create by daniel.hu on 2018/11/23.
//  Copyright © 2018年 goscam. All rights reserved.

#import "InputValidator.h"



NS_ASSUME_NONNULL_BEGIN

/**
 密码验证
 */
@interface PasswordInputValidator : InputValidator

- (instancetype)initWithDefaultString:(NSString *)defaultString;

- (BOOL)validateInput:(UITextField *)input error:(NSError *__autoreleasing  _Nullable *)error;
@end

NS_ASSUME_NONNULL_END
