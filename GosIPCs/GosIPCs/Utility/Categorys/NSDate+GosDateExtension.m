//  NSDate+GosDateExtension.m
//  GosIPCs
//
//  Create by daniel.hu on 2019/1/4.
//  Copyright © 2019年 goscam. All rights reserved.

#import "NSDate+GosDateExtension.h"

@implementation NSDate (GosDateExtension)

- (void)dayInBeginTimestamp:(NSTimeInterval *)begin
               endTimeStamp:(NSTimeInterval *)end {
    /// 当日日期
    NSDate *date = [self nowadayDate];
    GosLog(@"daniel: 当前时间: %@", date);
    *begin = [date timeIntervalSince1970];
    *end = *begin + 24*60*60-1;
    GosLog(@"结果 %.2f - %.2f", *begin, *end);
    return ;
    // FIXME: 测试时间
    NSDateComponents *comp = [[NSCalendar currentCalendar] components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:self];
    [comp setHour:15];
    [comp setMinute:47];
    [comp setSecond:0];
    /// 当日日期
    NSDate *testDate = [[NSCalendar currentCalendar] dateFromComponents:comp];
    *begin = [testDate timeIntervalSince1970];
    *end = *begin + 2*60;
}

- (NSDate *)switchDateByDay:(NSInteger)day {
    NSDateComponents *comp = [[NSCalendar currentCalendar] components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:self];
    comp.day += day;
    /// 当日日期
    return [[NSCalendar currentCalendar] dateFromComponents:comp];
}

- (NSDate *)nowadayDate {
    NSDateComponents *comp = [[NSCalendar currentCalendar] components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:self];
    /// 当日日期
    return [[NSCalendar currentCalendar] dateFromComponents:comp];
}

- (NSTimeInterval)nowadayStartTimestamp {
    return [[self nowadayDate] timeIntervalSince1970];
}

- (BOOL)validateTimestampIsBelongToToday:(NSTimeInterval)timestamp {
    return [self validateDateIsBelongToToday:[NSDate dateWithTimeIntervalSince1970:timestamp]];
}

- (BOOL)validateDateIsBelongToToday:(NSDate *)date {
    NSDate *nowaday = [self nowadayDate];
    NSDate *tomorrow = [self switchDateByDay:1];
    NSComparisonResult compareNowaday = [date compare:nowaday];
    NSComparisonResult compareTomorrow = [date compare:tomorrow];
    if ((compareNowaday == kCFCompareGreaterThan
        && compareTomorrow == kCFCompareLessThan)
        || compareNowaday == kCFCompareEqualTo) {
        return YES;
    }
    return NO;
}


/// 获取当月开始的第一天是星期几，1 是周日，2是周一 以此类推
- (NSInteger)weekStartAtMonth {
    // 1 是周日，2是周一 以此类推
    return [[NSCalendar currentCalendar] component:NSCalendarUnitWeekday
                                          fromDate:[self dateWithDay:1]];
    
}

/// 得到当月的某天日期
- (NSDate *)dateWithDay:(NSUInteger)day {
    NSDate *startDate;
    NSTimeInterval interval;
    [[NSCalendar currentCalendar] rangeOfUnit:NSCalendarUnitMonth startDate:&startDate interval:&interval forDate:self];
    
    return [startDate dateByAddingTimeInterval:(day-1) * 24 * 60 * 60];
    
}

/// 得到当月的天数
- (NSInteger)monthDays {
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian]; // 指定日历的算法
    NSRange range = [calendar rangeOfUnit:NSCalendarUnitDay
                                   inUnit:NSCalendarUnitMonth
                                  forDate:self];
    return range.length;
}

/// 加减天
- (NSDate *)dateByAppendingDay:(NSInteger)day {
    return [self dateByAddingTimeInterval:day*24*60*60];
}

/// 日改变，是：加一天，否：减一天
- (NSDate *)dateInDayChanged:(BOOL)isForward {
//    NSDateComponents *comp = [[NSCalendar currentCalendar] components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:self];
//
//    NSDateComponents *result = [[NSDateComponents alloc] init];
//    result.year = [comp year];
//    result.month = [comp month];
//    result.day = [comp day] + (isForward?1:-1);
//    result.hour = 0;
//    result.minute = 0;
//    result.second = 0;
//    return [[NSCalendar currentCalendar] dateFromComponents:result];
    
//    return [[NSCalendar currentCalendar] dateByAddingUnit:NSCalendarUnitDay value:isForward?1:-1 toDate:self options:NSCalendarWrapComponents];
    NSDateComponents *comp = [[NSDateComponents alloc] init];
    [comp setDay:isForward?1:-1];

    return [[NSCalendar currentCalendar] dateByAddingComponents:comp toDate:self options:NSCalendarWrapComponents];
}

/// 月份改变，是：加一个月，否：减一个月
- (NSDate *)dateInMonthChanged:(BOOL)isForward {
    
//    return [[NSCalendar currentCalendar] dateByAddingUnit:NSCalendarUnitMonth value:isForward?1:-1 toDate:self options:NSCalendarWrapComponents];
    
    NSDateComponents *comp = [[NSDateComponents alloc] init];
    [comp setMonth:isForward?1:-1];

    return [[NSCalendar currentCalendar] dateByAddingComponents:comp toDate:self options:0];
}

/// 是否存在日期数组中是否存在是同一天的数据
- (BOOL)isDateExistSameDayIn:(NSArray <NSDate *> *)dateArray {
    for (NSDate *date in dateArray) {
        if ([date isTheSameDayAsDate:self]) return YES;
    }
    return NO;
}

/// 判断是否同一天
- (BOOL)isTheSameDayAsDate:(NSDate *)date {
    // FIXME: 修复判断同一天的方法有问题，不同日子可能是同一天
    return [[NSCalendar currentCalendar] isDate:date inSameDayAsDate:self];
}

/// 判断日期是否超过系统当前日期
- (BOOL)isDateGreaterThanNowaday {
    if ([self compare:[NSDate date]] == NSOrderedDescending) return YES;
    
    return NO;
}

/// 判断日期是否超过目标当月最后一天
- (BOOL)isDateGreaterThanLimitMonthWithDate:(NSDate *)date {
    // 当月最后一天的最后一秒
    NSTimeInterval dateMonthLastTimestamp = [[date dateWithDay:[date monthDays]-1] timeIntervalSince1970] + 24*60*60 - 1;
    
    if ([self compare:[NSDate dateWithTimeIntervalSince1970:dateMonthLastTimestamp]] == NSOrderedDescending) return YES;
    
    return NO;
}

/// 判断日期是否低于目标当月第一天
- (BOOL)isDateLessThanLimitMonthWithDate:(NSDate *)date {
    // 当月第一天0秒
    NSTimeInterval dateMonthLastTimestamp = [[date dateWithDay:1] timeIntervalSince1970];
    
    if ([self compare:[NSDate dateWithTimeIntervalSince1970:dateMonthLastTimestamp]] == NSOrderedAscending) return YES;
    
    return NO;
}
@end
