//
//  NSDate+GosDiff.m
//  GosIPCs
//
//  Created by shenyuanluo on 2018/11/14.
//  Copyright © 2018 shenyuanluo. All rights reserved.
//

#import "NSDate+GosDiff.h"

@implementation NSDate (GosDiff)

- (NSTimeInterval)intervalWithStart:(NSString *)startTimeStr
                            endTime:(NSString *)endTimeStr
                          formatter:(NSString *)formatterStr
{
    if (IS_EMPTY_STRING(startTimeStr) || IS_EMPTY_STRING(endTimeStr))
    {
        GosLog(@"无法计算时间差！");
        return DBL_MAX; // 无法计算，返回一个最大值
    }
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    if (IS_EMPTY_STRING(formatterStr))
    {
        formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    }
    else
    {
        formatter.dateFormat = formatterStr;
    }
    NSDate *startDate = [formatter dateFromString:startTimeStr];
    NSDate *endDate   = [formatter dateFromString:endTimeStr];
    
    NSTimeInterval timeBetween = [endDate timeIntervalSinceDate:startDate];
    
    return timeBetween;
}

@end
