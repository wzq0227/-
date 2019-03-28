//  PasswordInputValidator.m
//  GosIPCs
//
//  Create by daniel.hu on 2018/11/23.
//  Copyright © 2018年 goscam. All rights reserved.

#import "PasswordInputValidator.h"
#import "NSString+GosCheck.h"

@interface PasswordInputValidator ()
/// 默认值，需要匹配为相同的正确值
@property (nonatomic, strong) NSString *defaultString;
@end
@implementation PasswordInputValidator
- (instancetype)initWithDefaultString:(NSString *)defaultString {
    if (self = [super init]) {
        _defaultString = defaultString;
    }
    return self;
}

- (BOOL)validateInput:(UITextField *)input error:(NSError * _Nullable __autoreleasing *)error {
    NSString *reason = nil;
    NSInteger code = 0;
    BOOL result = YES;
    
    // 如果存在默认值，直接验证
    if (_defaultString) {
        if (![_defaultString isEqualToString:[input text]]) {
            reason = @"The input not match correct string";
            code = InputValidationErrorCodeNotMatchDefault;
            result = NO;
        }
    } else if ([input text] == 0) {
        // 输入空
        reason = @"The input cannot be empty";
        code = InputValidationErrorCodeEmpty;
        result = NO;
    } else if ([input text].length > 16 || [input text].length < 8) {
        // 长度小于8或者大于16
        reason = @"The input cannot greater than 16 or less than 8";
        code = InputValidationErrorCodeLengthLimit;
        result = NO;
    } else if ([[input text] isMetacharacter]) {
        // 存在非法字符
        reason = @"The input exist illegal character.";
        code = InputValidationErrorCodeIllegalCharacter;
        result = NO;
    } else if (![[input text] isAtLessExistTwoOfNumbersLowcaseUpcase]) {
        // 数字，大写字母，小写字母并没有存在两种
        reason = @"The input must have at least two types of Numbers, lowercase letters, and uppercase letters";
        code = InputValidationErrorCodeMismatchRuglar;
        result = NO;
    }
    
    // 存在错误，并结果应该是错误的
    if (error && result == NO) {
        NSString *description = DPLocalizedString(@"Input Validation Failed");
        
        NSArray *objArray = @[description, reason];
        NSArray *keyArray = @[NSLocalizedDescriptionKey, NSLocalizedFailureReasonErrorKey];
        
        NSDictionary *userInfo = [NSDictionary dictionaryWithObjects:objArray forKeys:keyArray];
        
        *error = [NSError errorWithDomain:InputValidationErrorDomain code:code userInfo:userInfo];
    }
    
    return result;
}
@end
