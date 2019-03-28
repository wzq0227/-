//
//  NSString+GosSize.m
//  GosIPCs
//
//  Created by shenyuanluo on 2018/11/15.
//  Copyright © 2018 shenyuanluo. All rights reserved.
//

#import "NSString+GosSize.h"

@implementation NSString (GosSize)

+ (CGSize)sizeWithString:(NSString*)str
                    font:(UIFont*)font
              forMaxSize:(CGSize)size
{
    if (IS_EMPTY_STRING(str) || !font)
    {
        return CGSizeZero;
    }
    NSDictionary *attrs = @{
                            NSFontAttributeName: font
                            };
    return  [str boundingRectWithSize:size
                              options:NSStringDrawingUsesLineFragmentOrigin
                           attributes:attrs
                              context:nil].size;
}

@end
