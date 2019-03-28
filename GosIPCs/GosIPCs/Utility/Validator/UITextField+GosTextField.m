//  UITextField+GosTextField.m
//  GosIPCs
//
//  Create by daniel.hu on 2018/11/23.
//  Copyright © 2018年 goscam. All rights reserved.

#import "UITextField+GosTextField.h"
#import "objc/runtime.h"
#import "GosHUD.h"

@implementation UITextField (GosTextField)

- (BOOL)validate {
    NSError *error = nil;
    BOOL validationResult = [self.inputValidator validateInput:self error:&error];
    
    if (!validationResult) {
        GosLog(@"输入验证失败: reason:%@", error.localizedFailureReason);
        [GosHUD showProcessHUDErrorWithStatus:error.localizedFailureReason];
    }
    return validationResult;
    
}

- (InputValidator *)inputValidator {
    return objc_getAssociatedObject(self, _cmd);
}
- (void)setInputValidator:(InputValidator *)inputValidator {
    objc_setAssociatedObject(self, @selector(inputValidator), inputValidator, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
@end
