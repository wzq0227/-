//
//  NSDate+GosDiff.h
//  GosIPCs
//
//  Created by shenyuanluo on 2018/11/14.
//  Copyright © 2018 shenyuanluo. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSDate (GosDiff)

/**
 计算时间差
 
 @param startTimeStr 起始时间字符串
 @param endTimeStr 结束时间字符串
 @param formatterStr 格式（例如：yyyy-MM-dd HH:mm:ss）
 
 @return 时间差
*/
- (NSTimeInterval)intervalWithStart:(NSString *)startTimeStr
                            endTime:(NSString *)endTimeStr
                          formatter:(NSString *)formatterStr;

@end

NS_ASSUME_NONNULL_END
