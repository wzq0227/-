//  GosTimeAxisLayerRenderer.m
//  GosIPCs
//
//  Create by daniel.hu on 2018/11/28.
//  Copyright © 2018年 goscam. All rights reserved.

#import "GosTimeAxisLayerRenderer.h"
#import "GosTimeAxisRule.h"
#import "GosTimeAxisBaseLine.h"
#import "GosTimeAxisBackground.h"
#import "GosTimeAxisSegments.h"
#import "GosTimeAxisData.h"

@interface GosTimeAxisLayerRenderer ()
@property (nonatomic, strong) CAShapeLayer *ruleLayer;
@property (nonatomic, strong) CAShapeLayer *segmentsLayer;
@end

@implementation GosTimeAxisLayerRenderer

/// 通用访问方法
- (void)visitTimeAxis:(id<GosTimeAxisModel>)aTimeAxis {
    
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
    [self visitTimeAxis:aTimeAxisData];
    // 画数据线条
    CGContextMoveToPoint(_context, (aTimeAxisData.startTimeInterval - _minTimeInVisible) * _aSecondOfPixel, [[aTimeAxisData.drawAttributes objectForKey:GosStrokeSizeAttributeName] floatValue]/2.0);
    CGContextAddLineToPoint(_context, (aTimeAxisData.endTimeInterval - _minTimeInVisible) * _aSecondOfPixel, [[aTimeAxisData.drawAttributes objectForKey:GosStrokeSizeAttributeName] floatValue]/2.0);
    CGContextStrokePath(_context);
    
}
/// 访问刻度线
- (void)visitTimeAxisRule:(GosTimeAxisRule *)aTimeAxisRule {
    [super visitTimeAxisRule:aTimeAxisRule];
    
    [self.ruleLayer removeFromSuperlayer];
    self.ruleLayer.strokeColor = [[aTimeAxisRule.drawAttributes objectForKey:GosStrokeColorAttributeName] CGColor];
    self.ruleLayer.fillColor = [[aTimeAxisRule.drawAttributes objectForKey:GosStrokeColorAttributeName] CGColor];
    self.ruleLayer.lineWidth = [[aTimeAxisRule.drawAttributes objectForKey:GosStrokeSizeAttributeName] floatValue];
    
    // 画线
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, aTimeAxisRule.fixedOffset, 0);
    CGPathAddLineToPoint(path, NULL, aTimeAxisRule.fixedOffset, _viewSize.height);
    
    self.ruleLayer.path = path;
    CGPathRelease(path);
    
    [self.rendererView.layer addSublayer:self.ruleLayer];
}
/// 访问数字与分割线
- (void)visitTimeAxisSegments:(GosTimeAxisSegments *)aTimeAxisSegments {
    [super visitTimeAxisSegments:aTimeAxisSegments];
    
    
    CGFloat aSecondWidth = _aSecondOfPixel; // 每秒代表的像素宽度
    CGFloat aHourWidth = aSecondWidth * 3600.0;// 每小时代表的像素宽度
    CGFloat ruleOffset = _ruleFixedOffset;  // 刻度尺偏移
    CGFloat baseLineOffset = 0;         // 基线偏移
    NSInteger currentHour = _integerHour;   // 当前时间戳的整时
    CGFloat maxWidth = _viewSize.width; // 视图宽度
    
    // 计算当前时间的所在的整点小时时间的差值
    NSTimeInterval diffTime = _integerHourDifference;// 当前时间距离正点的差值
    
    CGFloat tempX = ruleOffset - diffTime * aSecondWidth;
    
    // 计算最左边的小时数，一般要画到视图外多一个小时
    NSInteger count = 1;
    while ((tempX -= aHourWidth) > 0) {
        count++;
    }
    NSInteger minHour = currentHour - count;
    CGFloat minHourPosition = ruleOffset - (diffTime+60*60*count) * aSecondWidth;
    
    // 计算最右边的小时数，一般要画到视图外多一个小时
    count = 1;
    while ((tempX += aHourWidth) < maxWidth) {
        count++;
    }
    CGFloat maxHourPosition = ruleOffset + (diffTime+60*60*count) * aSecondWidth;
    
    // 开始画刻度
    CGFloat tempHourPosition = minHourPosition;
    NSInteger tempHour = minHour;
    
    // 设置渲染颜色与尺寸
    [self visitTimeAxis:aTimeAxisSegments];
    CGFloat hourHeight = 20.0;
    CGFloat minuteHeight = 10.0;
    CGFloat digitalHeight = 20.0;
    
    // 移除layer
    [self.segmentsLayer removeFromSuperlayer];
    self.segmentsLayer.strokeColor = [[aTimeAxisSegments.hourScaleDrawAttributes objectForKey:GosStrokeColorAttributeName] CGColor];
    self.segmentsLayer.fillColor = [[aTimeAxisSegments.hourScaleDrawAttributes objectForKey:GosStrokeColorAttributeName] CGColor];
    self.segmentsLayer.lineWidth = [[aTimeAxisSegments.hourScaleDrawAttributes objectForKey:GosStrokeSizeAttributeName] floatValue];
    
    CGMutablePathRef path = CGPathCreateMutable();// 绘制路径
    
    while (tempHourPosition <= maxHourPosition) {
        CGPoint point = CGPointMake(tempHourPosition, baseLineOffset);
        // 文字显示
        NSString *time = [NSString stringWithFormat:@"%02zd:00",tempHour > 23 ? tempHour-24 : (tempHour < 0 ? tempHour + 24: tempHour)];
        [time drawInRect:CGRectMake(point.x-13, point.y+hourHeight+5, 40, digitalHeight) withAttributes:aTimeAxisSegments.displayTimeDrawAttributes];
        
        // 大刻度线(小时)
        CGPathMoveToPoint(path, NULL, point.x-.5, point.y);
        CGPathAddLineToPoint(path, NULL, point.x-.5, point.y+hourHeight);
        
        // 小刻度线(60/piece分钟)
        int piece = 2;
        for (int i = 1; i < piece; i++) {
            CGPoint point = CGPointMake(aHourWidth/piece*i+tempHourPosition, baseLineOffset);
            CGPathMoveToPoint(path, NULL, point.x-.5, point.y);
            CGPathAddLineToPoint(path, NULL, point.x-.5, point.y+minuteHeight);
        }
        tempHourPosition += aHourWidth;
        tempHour++;
    }
    
    self.segmentsLayer.path = path;
    CGPathRelease(path);
    
    [self.rendererView.layer addSublayer:self.segmentsLayer];
}
/// 访问背景
- (void)visitTimeAxisBackground:(GosTimeAxisBackground *)aTimeAxisBackground {
    
}
/// 访问基线
- (void)visitTimeAxisBaseLine:(GosTimeAxisBaseLine *)aTimeAxisBaseLine {
    
}



- (CAShapeLayer *)ruleLayer {
    if (!_ruleLayer) {
        _ruleLayer = [CAShapeLayer layer];
        _ruleLayer.lineCap = kCALineCapSquare;
    }
    return _ruleLayer;
}
- (CAShapeLayer *)segmentsLayer {
    if (!_segmentsLayer) {
        _segmentsLayer = [CAShapeLayer layer];
        _segmentsLayer.lineCap = kCALineCapSquare;
    }
    return _segmentsLayer;
}
@end
