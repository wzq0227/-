//
//  NSString+GosCheck.h
//  Goscom
//
//  Created by shenyuanluo on 2018/11/16.
//  Copyright © 2018 shenyuanluo. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (GosCheck)

/**
 验证邮箱地址是否合法
 
 @return 是否合法；YES：合法，NO：不合法
 */
- (BOOL)isLegalEmail;

/**
 验证是否包含特殊字符
 
 @return 是否合法；YES：包含，NO：不包含
 */
- (BOOL)isMetacharacter;


/**
 验证字符串是否至少存在数字、小写字母、大写字母两种以上
 
 @return YES：是；NO：否
 */
- (BOOL)isAtLessExistTwoOfNumbersLowcaseUpcase;

/**
 比较两个字符串是否相等（忽略大小写）
 
 @return YES：是；NO：否
 */
- (BOOL)isCaseInsensitiveEqualToString:(NSString *)aString;

@end

NS_ASSUME_NONNULL_END
