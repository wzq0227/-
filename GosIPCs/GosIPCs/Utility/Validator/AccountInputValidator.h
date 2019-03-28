//  AccountInputValidator.h
//  GosIPCs
//
//  Create by daniel.hu on 2018/11/24.
//  Copyright © 2018年 goscam. All rights reserved.

#import "InputValidator.h"

NS_ASSUME_NONNULL_BEGIN

@interface AccountInputValidator : InputValidator
- (BOOL)validateInput:(UITextField *)input error:(NSError *__autoreleasing  _Nullable *)error;
@end

NS_ASSUME_NONNULL_END
