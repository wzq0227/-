//  InputValidator.m
//  GosIPCs
//
//  Create by daniel.hu on 2018/11/23.
//  Copyright © 2018年 goscam. All rights reserved.

#import "InputValidator.h"

@implementation InputValidator
- (BOOL)validateInput:(UITextField *)input error:(NSError * _Nullable __autoreleasing *)error {
    if (error) {
        *error = nil;
    }
    return NO;
}
@end
