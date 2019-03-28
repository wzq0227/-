//  NSString+GosFormatDate.h
//  GosIPCs
//
//  Create by daniel.hu on 2018/12/7.
//  Copyright © 2018年 goscam. All rights reserved.

#import <Foundation/Foundation.h>

typedef NSString  GosDateFormatString;

/// 2018/8/8
static GosDateFormatString *const slashDateFormatString = @"yyyy/MM/dd";
/// 2018-8
static GosDateFormatString *const whippletreeYMDateFormatString = @"yyyy-MM";
/// 2018-8-8
static GosDateFormatString *const whippletreeDateFormatString = @"yyyy-MM-dd";
/// 8:08:08
static GosDateFormatString *const timeOnlyDateFormatString = @"HH:mm:ss";
/// 2018-8-8 8:08:08
static GosDateFormatString *const secondLevelDateFormatString = @"yyyy-MM-dd HH:mm:ss";
/// 2018-8-8-8-08-08
static GosDateFormatString *const allWhippletreeDateFormatString = @"yyyy-MM-dd-HH-mm-ss";
/// 8:08:08 2018/8/8
static GosDateFormatString *const timeSlashDateFormatString = @"HH:mm:ss yyyy/MM/dd";
/// 2018-8-8 8:08:08 Wednesday
static GosDateFormatString *const weekLevelDateFormatString = @"yyyy-MM-dd HH:mm:ss EEEE";
/// 2018-8-8 A.M. 8:08:08 Wednesday
static GosDateFormatString *const meridiemLevelDateFormatString = @"yyyy-MM-dd a HH:mm:ss EEEE";

NS_ASSUME_NONNULL_BEGIN

/**
 用于格式化日期 以及 日期字符串转换为日期
 NSString <-> NSDate
 */
@interface NSString (GosFormatDate)

/**
 日期转为固定格式的字符串

 @param date 日期NSDate
 @param format 格式字符串GosDateFormatString
 @return 日期字符串NSString
 */
+ (NSString *)stringWithDate:(NSDate *)date format:(GosDateFormatString *)format;

/**
 时间戳转为固定格式的字符串

 @param timestamp 时间戳
 @param format 格式字符串GosDateFormatString
 @return 日期字符串NSString
 */
+ (NSString *)stringWithTimestamp:(NSTimeInterval)timestamp format:(GosDateFormatString *)format;


/**
 日期字符串转化为日期

 @param string 日期字符串NSString
 @param format 日期字符串的格式GosDateFormatString
 @return 日期NSDate
 */
+ (NSDate *)dateFromString:(NSString *)string format:(GosDateFormatString *)format;

@end

NS_ASSUME_NONNULL_END
