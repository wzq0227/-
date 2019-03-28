//  GosTimeAxisRenderer.m
//  GosIPCs
//
//  Create by daniel.hu on 2018/11/27.
//  Copyright © 2018年 goscam. All rights reserved.

#import "GosTimeAxisRenderer.h"
#import "GosTimeAxisRule.h"
#import "GosTimeAxisBaseLine.h"
#import "GosTimeAxisBackground.h"
#import "GosTimeAxisSegments.h"

@interface GosTimeAxisRenderer ()
/// 视图内可见最小时间戳
@property (nonatomic, assign) NSTimeInterval minTimeInVisible;
/// 视图内可见最大时间戳
@property (nonatomic, assign) NSTimeInterval maxTimeInVisible;
/// 当前时间戳距离整时的偏差
@property (nonatomic, assign) NSTimeInterval integerHourDifference;
/// 当前时间戳所在的整时数
@property (nonatomic, assign) NSInteger integerHour;
/// 当前时间戳
@property (nonatomic, assign) NSTimeInterval currentTimeInterval;
/// 刻度尺固定偏移
@property (nonatomic, assign) CGFloat ruleFixedOffset;
/// 基线固定偏移
@property (nonatomic, assign) CGFloat baseLineFixedOffset;
/// 背景尺寸
@property (nonatomic, assign) CGFloat backgroundSize;
/// 表示一秒所占像素数
@property (nonatomic, assign) CGFloat aSecondOfPixel;
/// 方向
@property (nonatomic, assign) GosTimeAxisDirection axisDirection;
@end
@implementation GosTimeAxisRenderer

@synthesize context = _context;
@synthesize viewSize = _viewSize;
@synthesize minTimeInVisible = _minTimeInVisible;
@synthesize maxTimeInVisible = _maxTimeInVisible;
@synthesize currentTimeInterval = _currentTimeInterval;
@synthesize integerHourDifference = _integerHourDifference;
@synthesize integerHour = _integerHour;
@synthesize ruleFixedOffset = _ruleFixedOffset;
@synthesize baseLineFixedOffset = _baseLineFixedOffset;
@synthesize backgroundSize = _backgroundSize;
@synthesize aSecondOfPixel = _aSecondOfPixel;
@synthesize axisDirection = _axisDirection;


#pragma mark - initialization
- (id<GosTimeAxisVisitor>)initWithSize:(CGSize)aSize {
    if (self = [super init]) {
        [self setViewSize:aSize];
    }
    return self;
}
- (id<GosTimeAxisVisitor>)initWithSize:(CGSize)aSize context:(CGContextRef)context rendererView:(nullable UIView *)rendererView {
    if (self = [self initWithSize:aSize]) {
        [self setContext:context];
        [self setRendererView:rendererView];
    }
    return self;
}
#pragma mark - public method
/// 通用访问方法
- (void)visitTimeAxis:(id<GosTimeAxisModel>)aTimeAxis {
}
/// 访问数据
- (void)visitTimeAxisData:(GosTimeAxisData *)aTimeAxisData {
    
}
/// 访问刻度线
- (void)visitTimeAxisRule:(GosTimeAxisRule *)aTimeAxisRule {
    [self setupParametersWithTimeAxisRule:aTimeAxisRule];
}
/// 访问数字与分割线
- (void)visitTimeAxisSegments:(GosTimeAxisSegments *)aTimeAxisSegments {
    [self setupParametersWithTimeAxisSegments:aTimeAxisSegments];
}
/// 访问背景
- (void)visitTimeAxisBackground:(GosTimeAxisBackground *)aTimeAxisBackground {
    [self setupParametersWithTimeAxisBackground:aTimeAxisBackground];
}
/// 访问基线
- (void)visitTimeAxisBaseLine:(GosTimeAxisBaseLine *)aTimeAxisBaseLine {
    [self setupParametersWithTimeAxisBaseLine:aTimeAxisBaseLine];
}

#pragma mark - setup property method
- (void)setupParametersWithTimeAxisRule:(GosTimeAxisRule *)aTimeAxisRule {
    _currentTimeInterval = aTimeAxisRule.currentTimeInterval;
    _ruleFixedOffset = aTimeAxisRule.fixedOffset;
    _integerHourDifference = [NSDate integerHourDifferenceValueFromTimeInterval:aTimeAxisRule.currentTimeInterval];
    _integerHour = [NSDate intergerHourWithTimeInterval:aTimeAxisRule.currentTimeInterval];
    _axisDirection = aTimeAxisRule.axisDirection;
}
- (void)setupParametersWithTimeAxisBaseLine:(GosTimeAxisBaseLine *)aTimeAxisBaseLine {
    
    _baseLineFixedOffset = aTimeAxisBaseLine.fixedOffset;
}
- (void)setupParametersWithTimeAxisSegments:(GosTimeAxisSegments *)aTimeAxisSegments {
    
    CGFloat width = _axisDirection == GosTimeAxisDirectionHorizontal ? self.viewSize.width : self.viewSize.height;
    _aSecondOfPixel = [aTimeAxisSegments pixelOfASecondWithViewWidth:width];
    
    if (!aTimeAxisSegments.isInfinitely) {
        /// 当日日期
        NSTimeInterval dayInBegin =  [[[NSCalendar currentCalendar] dateFromComponents:[[NSCalendar currentCalendar] components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:[NSDate dateWithTimeIntervalSince1970:_currentTimeInterval]]] timeIntervalSince1970];
        NSTimeInterval dayInEnd = _minTimeInVisible + 24*60*60-1;
        NSTimeInterval tempMinInVisible = _currentTimeInterval - _ruleFixedOffset/_aSecondOfPixel ;
        NSTimeInterval tempMaxInVisible = _currentTimeInterval + (width - _ruleFixedOffset)/_aSecondOfPixel;
        _minTimeInVisible = tempMinInVisible < dayInBegin ? dayInBegin : tempMinInVisible;
        _maxTimeInVisible = tempMaxInVisible > dayInEnd ? dayInEnd : tempMaxInVisible;
        
    } else {
        // 可见最小时间 = 当前时间(s) - 刻度线偏移位置(像素)/每秒对应的宽度(像素/s)
        _minTimeInVisible = _currentTimeInterval - _ruleFixedOffset/_aSecondOfPixel;
        // 可见最大时间 = 当前时间(s) + （可见视图宽度(像素) - 刻度线偏移位置(像素))/每秒对应的宽度(像素/s)
        _maxTimeInVisible = _currentTimeInterval + (width - _ruleFixedOffset)/_aSecondOfPixel;
    }
}
- (void)setupParametersWithTimeAxisBackground:(GosTimeAxisBackground *)aTimeAxisBackground {
    _backgroundSize = [[aTimeAxisBackground.drawAttributes objectForKey:GosStrokeSizeAttributeName] floatValue];
}

@end
