//  ConfirmInputValidator.m
//  GosIPCs
//
//  Create by daniel.hu on 2018/11/24.
//  Copyright © 2018年 goscam. All rights reserved.

#import "ConfirmInputValidator.h"
@interface ConfirmInputValidator ()
/// 指向需要验证的对象
@property (nonatomic, weak) UITextField *confirmTextField;
@end
@implementation ConfirmInputValidator
- (instancetype)initWithDestinationConfirmTextField:(UITextField *)confirmTextField {
    if (self = [super init]) {
        _confirmTextField = confirmTextField;
    }
    return self;
}
- (BOOL)validateInput:(UITextField *)input error:(NSError * _Nullable __autoreleasing *)error {
    
    NSString *reason = nil;
    NSInteger code = 0;
    BOOL result = YES;
    
    // 不匹配需要验证的项
    if (![[input text] isEqualToString:_confirmTextField.text]) {
        reason = @"The input not match other.";
        code = InputValidationErrorCodeNotMatchDefault;
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
