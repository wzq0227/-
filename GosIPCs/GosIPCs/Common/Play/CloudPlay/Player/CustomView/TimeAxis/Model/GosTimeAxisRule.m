//  GosTimeAxisRule.m
//  GosIPCs
//
//  Create by daniel.hu on 2018/11/27.
//  Copyright © 2018年 goscam. All rights reserved.

#import "GosTimeAxisRule.h"

@implementation GosTimeAxisRule
- (instancetype)init {
    if (self = [super init]) {
        _currentTimeInterval = [[NSDate date] timeIntervalSince1970];
        _axisDirection = GosTimeAxisDirectionHorizontal;
    }
    return self;
}
- (void)acceptVisitor:(id<GosTimeAxisVisitor>)visitor {
    [visitor visitTimeAxisRule:self];
}

- (NSDictionary *)drawAttributes {
    if (!_drawAttributes) {
        _drawAttributes = [NSDictionary dictionary];
    }
    return _drawAttributes;
}
@end


@implementation NSDate (GosTimeAxisRuleDateExtension)

/**
 距离当前整点的时差
 
 @param timeInterval 时间戳
 @return 时差
 */
+ (NSTimeInterval)integerHourDifferenceValueFromTimeInterval:(NSTimeInterval)timeInterval {
    NSDateComponents *dateComponent = [[NSCalendar currentCalendar] components:NSCalendarUnitMinute|NSCalendarUnitSecond fromDate:[NSDate dateWithTimeIntervalSince1970:timeInterval]];
    return [dateComponent minute]  * 60 + [dateComponent second];
}

/**
 当前整点
 
 @param timeInterval 时间戳
 @return 小时
 */
+ (NSInteger)intergerHourWithTimeInterval:(NSTimeInterval)timeInterval {
    return [[NSCalendar currentCalendar] component:NSCalendarUnitHour fromDate:[NSDate dateWithTimeIntervalSince1970:timeInterval]];;
}

@end
