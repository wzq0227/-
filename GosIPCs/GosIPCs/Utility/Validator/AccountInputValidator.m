//  AccountInputValidator.m
//  GosIPCs
//
//  Create by daniel.hu on 2018/11/24.
//  Copyright © 2018年 goscam. All rights reserved.

#import "AccountInputValidator.h"
#import "NSString+GosCheck.h"

@implementation AccountInputValidator

- (BOOL)validateInput:(UITextField *)input error:(NSError * _Nullable __autoreleasing *)error {
    NSString *reason = nil;
    NSInteger code = 0;
    BOOL result = YES;
    
    if ([input text] == 0) {
        reason = @"The input cannot be empty";
        code = InputValidationErrorCodeEmpty;
        result = NO;
    } else if ([input text].length > 60) {
        // 长度大于60
//        reason = @"The input cannot greater than 60";
        reason = DPLocalizedString(@"AccountOrPwdFmtError");
        code = InputValidationErrorCodeLengthLimit;
        result = NO;
    } else if ([[input text] isMetacharacter]) {
        // 存在非法字符
//        reason = @"The input exist illegal charactor.";
        reason = DPLocalizedString(@"AccountOrPwdFmtError");
        code = InputValidationErrorCodeIllegalCharacter;
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
