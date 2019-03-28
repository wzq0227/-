//  GosTimeAxisRuleRenderer.m
//  GosIPCs
//
//  Create by daniel.hu on 2018/11/27.
//  Copyright © 2018年 goscam. All rights reserved.

#import "GosTimeAxisRuleRenderer.h"
#import "GosTimeAxisRule.h"
#import "GosTimeAxisBaseLine.h"
#import "GosTimeAxisBackground.h"
#import "GosTimeAxisSegments.h"
#import "GosTimeAxisData.h"

@implementation GosTimeAxisRuleRenderer
#pragma mark - visitor method
/// 通用访问方法
- (void)visitTimeAxis:(id<GosTimeAxisModel>)aTimeAxis {
    // 啥也不干
}
/// 访问数据
- (void)visitTimeAxisData:(GosTimeAxisData *)aTimeAxisData {
    
    // 数据类型不对，不画
    if (![aTimeAxisData isKindOfClass:[GosTimeAxisData class]]) return ;
    
    // 不在可见区间内的时间段，不画
    if (aTimeAxisData.startTimeInterval > _maxTimeInVisible
        || aTimeAxisData.endTimeInterval < _minTimeInVisible) {
        return ;
    }
    
    // 设置渲染颜色与尺寸
    [self setupDrawAttributeWithContext:_context attribute:aTimeAxisData.drawAttributes];
     // 画数据线条
    [self drawLineWithContext:_context from:CGPointMake((aTimeAxisData.startTimeInterval - _minTimeInVisible) * _aSecondOfPixel, [[aTimeAxisData.drawAttributes objectForKey:GosStrokeSizeAttributeName] floatValue]/2.0) to:CGPointMake((aTimeAxisData.endTimeInterval - _minTimeInVisible) * _aSecondOfPixel, [[aTimeAxisData.drawAttributes objectForKey:GosStrokeSizeAttributeName] floatValue]/2.0)];
    
    
}
/// 访问刻度线
- (void)visitTimeAxisRule:(GosTimeAxisRule *)aTimeAxisRule {
    [super visitTimeAxisRule:aTimeAxisRule];
    
    // 设置渲染颜色与尺寸
    [self setupDrawAttributeWithContext:_context attribute:aTimeAxisRule.drawAttributes];
    
    [self drawLineWithContext:_context from:CGPointMake(aTimeAxisRule.fixedOffset, 0) to:CGPointMake(aTimeAxisRule.fixedOffset, _viewSize.height)];
   
}
/// 访问数字与分割线
- (void)visitTimeAxisSegments:(GosTimeAxisSegments *)aTimeAxisSegments {
    [super visitTimeAxisSegments:aTimeAxisSegments];
    // 可视宽度
    CGFloat maxWidth = _viewSize.width;
    // 每秒代表的像素宽度
    CGFloat aSecondWidth = _aSecondOfPixel;
    // 每小时代表的像素宽度
    CGFloat aHourWidth = aSecondWidth * MAX_SECONDS_IN_AN_HOUR;
    // 刻度尺的位置
    CGFloat ruleOffset = _ruleFixedOffset;
    // 基线的位置
    CGFloat baseLineOffset = 0;
    // 整时
    NSInteger currentHour = _integerHour;
    // 画布上下文
    CGContextRef context = _context;
    // 一小时的段数
    NSUInteger segmentInHour = (NSUInteger)(MAX_SECONDS_IN_AN_HOUR/(aTimeAxisSegments.segmentOfSecond * 1.0));
    // 时刻度的线长
    CGFloat hourLineWidth = [[aTimeAxisSegments.hourScaleDrawAttributes objectForKey:GosStrokeLineWidthAttributeName] floatValue];
    // 秒刻度的线长
    CGFloat secondLineWidth = [[aTimeAxisSegments.secondScaleDrawAttributes objectForKey:GosStrokeLineWidthAttributeName] floatValue];
    // 时间字符串的高度
    CGFloat timeStringHeight = 20.0;
    // 是否无限绘制
    BOOL isInfinitely = aTimeAxisSegments.isInfinitely;
    
    // 计算当前时间的所在的整点小时时间的差值
    NSTimeInterval integerHourDifferenceValue = _integerHourDifference;// 当前时间距离正点的差值
    // 左边整点的X位置
    CGFloat tempX = ruleOffset - integerHourDifferenceValue * aSecondWidth;
    // 可见最小时值
    NSInteger minHour = currentHour;
    // 可见最小时的位置
    CGFloat minHourPosition = tempX;
    // 如果左边整点的X位置大于0，说明当前小时都还没画完
    if (tempX > 0) {
        NSInteger count = 1;
        while ((tempX -= aHourWidth) > 0) {
            count++;
        }
        minHour = currentHour - count;
        minHourPosition = ruleOffset - (integerHourDifferenceValue+60*60*count) * aSecondWidth;
    }
    // 如果当前时间加上一小时的时间 超出视图范围
    NSInteger count = 1;
    while ((tempX += aHourWidth) < maxWidth) {
        count++;
    }
    // 可见的最大小时的位置
    CGFloat maxHourPosition = ruleOffset + ((3600-integerHourDifferenceValue)+60*60*(count-1)) * aSecondWidth;
    
    // 临时值
    CGFloat tempHourPosition = minHourPosition;
    NSInteger tempHour = minHour;
    CGFloat xPoint = 0;
    CGFloat yPoint = baseLineOffset;
    // 设置渲染颜色与尺寸
    while (tempHourPosition <= maxHourPosition) {
        for (int i = 0; i < segmentInHour; i++) {
            // 避免离屏绘制
            if ((xPoint = (aHourWidth/segmentInHour)*i+tempHourPosition) < 0) continue;
            if (xPoint > maxWidth) break;
            
            // 有限绘制，不在0~24小时内的不绘制
            if (!isInfinitely && ((tempHour < 0 || tempHour > 24) || (tempHour == 24 && i > 0))) break;
            
            CGPoint point = CGPointMake(xPoint, yPoint);
            
            if (i % 2 == 0) {
                // 显示刻度时间
                [[aTimeAxisSegments optimiseTimeStringDisplayFromHour:tempHour minute:aTimeAxisSegments.segmentOfSecond*i] drawInRect:CGRectMake(point.x-13, point.y+hourLineWidth+5, 40, timeStringHeight) withAttributes:aTimeAxisSegments.displayTimeDrawAttributes];
            }
            if (i == 0) {
                // 时
                [self setupDrawAttributeWithContext:context attribute:aTimeAxisSegments.hourScaleDrawAttributes];
                CGContextMoveToPoint(context, point.x-.5, point.y);
                CGContextAddLineToPoint(context, point.x-.5, point.y+hourLineWidth);
                CGContextStrokePath(context);
            } else {
                // 秒
                [self setupDrawAttributeWithContext:context attribute:aTimeAxisSegments.secondScaleDrawAttributes];
                CGContextMoveToPoint(context, point.x-.5, point.y);
                CGContextAddLineToPoint(context, point.x-.5, point.y+secondLineWidth);
                CGContextStrokePath(context);
            }
            
        }
        
        tempHourPosition += aHourWidth;
        tempHour++;
        
    }
    
}
/// 访问背景
- (void)visitTimeAxisBackground:(GosTimeAxisBackground *)aTimeAxisBackground {
    // do some draw action
    [[UIImage imageNamed:@"img_ruler"] drawInRect:CGRectMake(0, 0, _viewSize.width, _viewSize.height)];
//    self.layer.contentsScale = [UIScreen mainScreen].scale;
}
/// 访问基线
- (void)visitTimeAxisBaseLine:(GosTimeAxisBaseLine *)aTimeAxisBaseLine {
    // do some draw action
}


#pragma mark - help method
- (void)setupDrawAttributeWithContext:(CGContextRef)context attribute:(NSDictionary *)attribute {
    if ([attribute objectForKey:GosStrokeColorAttributeName]) {
        CGContextSetStrokeColorWithColor(_context, [[attribute objectForKey:GosStrokeColorAttributeName] CGColor]);
    }
    if ([attribute objectForKey:GosStrokeSizeAttributeName]) {
        CGContextSetLineWidth(_context, [[attribute objectForKey:GosStrokeSizeAttributeName] floatValue]);
    }
    
}
- (void)drawLineWithContext:(CGContextRef)context from:(CGPoint)from to:(CGPoint)to {
    CGContextMoveToPoint(context, from.x, from.y);
    CGContextAddLineToPoint(context, to.x, to.y);
    CGContextStrokePath(context);
}

@end
