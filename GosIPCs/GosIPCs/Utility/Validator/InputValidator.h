//  InputValidator.h
//  GosIPCs
//
//  Create by daniel.hu on 2018/11/23.
//  Copyright © 2018年 goscam. All rights reserved.

#import <Foundation/Foundation.h>
static NSString *const InputValidationErrorDomain = @"InputValidationErrorDomain";

typedef NS_ENUM(NSInteger, InputValidationErrorCode) {
    InputValidationErrorCodeEmpty,           // 字符为空
    InputValidationErrorCodeLengthLimit,     // 长度限制
    InputValidationErrorCodeIllegalCharacter,// 存在非法字符
    InputValidationErrorCodeMismatchRuglar,  // 不匹配规则
    InputValidationErrorCodeNotMatchDefault, // 不匹配默认值
};

NS_ASSUME_NONNULL_BEGIN

/**
 输入验证
 */
@interface InputValidator : NSObject
- (BOOL)validateInput:(UITextField *)input error:(NSError * _Nullable*)error;
@end

NS_ASSUME_NONNULL_END
