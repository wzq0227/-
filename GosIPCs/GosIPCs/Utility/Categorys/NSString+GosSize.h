//
//  NSString+GosSize.h
//  GosIPCs
//
//  Created by shenyuanluo on 2018/11/15.
//  Copyright © 2018 shenyuanluo. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (GosSize)

/**
 计算给定字符串大小
 
 @pragma str 需要计算的字符串
 @pragma font 字符串字体
 @pragma size 字符串最大尺寸
 
 @return 字符串大小
 */
+ (CGSize)sizeWithString:(NSString*)str
                    font:(UIFont*)font
              forMaxSize:(CGSize)size;

@end

NS_ASSUME_NONNULL_END
