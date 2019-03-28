//  NSString+GosFormatDate.m
//  GosIPCs
//
//  Create by daniel.hu on 2018/12/7.
//  Copyright © 2018年 goscam. All rights reserved.

#import "NSString+GosFormatDate.h"

@implementation NSString (GosFormatDate)

+ (NSString *)stringWithDate:(NSDate *)date format:(GosDateFormatString *)format {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = format;
    return [dateFormatter stringFromDate:date];
}

+ (NSString *)stringWithTimestamp:(NSTimeInterval)timestamp format:(GosDateFormatString *)format {
    return [NSString stringWithDate:[NSDate dateWithTimeIntervalSince1970:timestamp] format:format];
}

+ (NSDate *)dateFromString:(NSString *)string format:(GosDateFormatString *)format {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    // 这东西会有时差
//    dateFormatter.timeZone = [NSTimeZone timeZoneWithName:@"GMT"];
//    dateFormatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US"];
    dateFormatter.dateFormat = format;
    
    return [dateFormatter dateFromString:string];
}

@end
