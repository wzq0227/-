//  NSDate+GosDateExtension.h
//  GosIPCs
//
//  Create by daniel.hu on 2019/1/4.
//  Copyright © 2019年 goscam. All rights reserved.

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSDate (GosDateExtension)

/// 取得NSDate当天的起始时间戳与结束时间戳
- (void)dayInBeginTimestamp:(NSTimeInterval *)begin endTimeStamp:(NSTimeInterval *)end;
/// 判断时间戳是否属于当天
- (BOOL)validateTimestampIsBelongToToday:(NSTimeInterval)timestamp;
/// 判断日期是否属于当天
- (BOOL)validateDateIsBelongToToday:(NSDate *)date;
/// 切换day间隔的零点日期
- (NSDate *)switchDateByDay:(NSInteger)day;
/// 当日0点日期
- (NSDate *)nowadayDate;
/// 当日起始的时间戳
- (NSTimeInterval)nowadayStartTimestamp;
/// 得到当月的某天日期
- (NSDate *)dateWithDay:(NSUInteger)day;
/// 得到当月的天数
- (NSInteger)monthDays;
/// 日改变，是：加一天，否：减一天
- (NSDate *)dateInDayChanged:(BOOL)isForward;
/// 月份改变，是：加一个月，否：减一个月
- (NSDate *)dateInMonthChanged:(BOOL)isForward;
/// 获取当月开始的第一天是星期几，1 是周日，2是周一 以此类推
- (NSInteger)weekStartAtMonth;
/// 是否存在日期数组中是否存在是同一天的数据
- (BOOL)isDateExistSameDayIn:(NSArray <NSDate *> *)dateArray;
/// 判断是否是同一天
- (BOOL)isTheSameDayAsDate:(NSDate *)date;
/// 判断日期是否超过系统当前日期
- (BOOL)isDateGreaterThanNowaday;
/// 判断日期是否超过目标当月最后一天
- (BOOL)isDateGreaterThanLimitMonthWithDate:(NSDate *)date;
/// 判断日期是否低于目标当月第一天
- (BOOL)isDateLessThanLimitMonthWithDate:(NSDate *)date;
/// 加减天数
- (NSDate *)dateByAppendingDay:(NSInteger)day;
@end

NS_ASSUME_NONNULL_END
