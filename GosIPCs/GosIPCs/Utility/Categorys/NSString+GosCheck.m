//
//  NSString+GosCheck.m
//  Goscom
//
//  Created by shenyuanluo on 2018/11/16.
//  Copyright © 2018 shenyuanluo. All rights reserved.
//

#import "NSString+GosCheck.h"

@implementation NSString (GosCheck)

- (BOOL)isLegalEmail
{
    NSString *regExp = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    return [self legalWithRegExp:regExp
                         forText:self];
}

- (BOOL)isMetacharacter
{
    NSString *regExp = @"^[]\\[@><#$^&*)(_+-=}{:,.?;/|\"!~`A-Za-z0-9\\u4e00-\u9fa5]+$";
    return ![self legalWithRegExp:regExp forText:self];
}


- (BOOL)isAtLessExistTwoOfNumbersLowcaseUpcase {
    // FIXME: 可能还要包含上述isMetacharacter的字符
    // @"^(?=.*[a-zA-Z0-9].*)(?=.*[a-zA-Z\\W].*)(?=.*[0-9\\W].*)"
    // @"^(?![A-Z]*$)(?![a-z]*$)(?![0-9]*$)(?![^a-zA-Z0-9]*$)\\S+$"
    NSString *regExp = @"^(?![A-Z]*$)(?![a-z]*$)(?![0-9]*$)\\S+$";
    return [self legalWithRegExp:regExp forText:self];
}

- (BOOL)isCaseInsensitiveEqualToString:(NSString *)aString
{
    if (NSOrderedSame == [self compare:aString options:NSCaseInsensitiveSearch|NSNumericSearch])
    {
        return YES;
    }
    return NO;
}

- (BOOL)legalWithRegExp:(NSString *)regExp
                forText:(NSString *)text
{
    NSPredicate * predicate = [NSPredicate predicateWithFormat: @"SELF MATCHES %@", regExp];
    
    return [predicate evaluateWithObject:text];
}

@end
