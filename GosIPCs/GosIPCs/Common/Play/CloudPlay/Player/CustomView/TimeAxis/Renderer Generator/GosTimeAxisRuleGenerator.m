//  GosTimeAxisRuleGenerator.m
//  GosIPCs
//
//  Create by daniel.hu on 2018/11/27.
//  Copyright © 2018年 goscam. All rights reserved.

#import "GosTimeAxisRuleGenerator.h"
#import "GosTimeAxisRule.h"
#import "GosTimeAxisBaseLine.h"
#import "GosTimeAxisBackground.h"
#import "GosTimeAxisSegments.h"
#import "GosTimeAxisData.h"

@implementation GosTimeAxisRuleGenerator
/// 通用访问方法
- (void)visitTimeAxis:(id<GosTimeAxisModel>)aTimeAxis {
    // 啥也不干
}
/// 访问数据
- (void)visitTimeAxisData:(GosTimeAxisData *)aTimeAxisData {
    NSMutableDictionary *temp = [NSMutableDictionary dictionaryWithDictionary:aTimeAxisData.drawAttributes];
    // 如果没有设置颜色
    if (![aTimeAxisData.drawAttributes objectForKey:GosStrokeColorAttributeName]) {
        [temp setObject:[GOS_COLOR_RGB(0x96DDFF) colorWithAlphaComponent:0.3] forKey:GosStrokeColorAttributeName];
    }
    // 设置尺寸
    [temp setObject:@(self.viewSize.height) forKey:GosStrokeSizeAttributeName];
    
    aTimeAxisData.drawAttributes = [temp copy];
}
/// 访问刻度线
- (void)visitTimeAxisRule:(GosTimeAxisRule *)aTimeAxisRule {
    aTimeAxisRule.axisDirection = GosTimeAxisDirectionHorizontal;
    
    NSMutableDictionary *temp = [NSMutableDictionary dictionaryWithDictionary:aTimeAxisRule.drawAttributes];
    // 如果没有设置颜色
    if (![aTimeAxisRule.drawAttributes objectForKey:GosStrokeColorAttributeName]) {
        [temp setObject:GOS_COLOR_RGB(0xFF421D) forKey:GosStrokeColorAttributeName];
    }
    // 设置尺寸
    CGFloat strokeSize = 2.0;
    if (![aTimeAxisRule.drawAttributes objectForKey:GosStrokeSizeAttributeName]) {
        [temp setObject:@(strokeSize) forKey:GosStrokeSizeAttributeName];
    } else {
        strokeSize = [[aTimeAxisRule.drawAttributes objectForKey:GosStrokeSizeAttributeName] floatValue];
    }
    aTimeAxisRule.drawAttributes = [temp copy];
    aTimeAxisRule.fixedOffset = (self.viewSize.width - strokeSize)/2.0;
}
/// 访问数字与分割线
- (void)visitTimeAxisSegments:(GosTimeAxisSegments *)aTimeAxisSegments {
    // 如果文字没有属性设置
    if ([aTimeAxisSegments.displayTimeDrawAttributes count] == 0) {
        aTimeAxisSegments.displayTimeDrawAttributes = [@{NSForegroundColorAttributeName:GOS_COLOR_RGB(0xCCCCCC), NSFontAttributeName:GOS_FONT(8)} mutableCopy];
    }
    
    
    NSMutableDictionary *tempHourAttr = [NSMutableDictionary dictionaryWithDictionary:aTimeAxisSegments.hourScaleDrawAttributes];
    // 如果时刻度线没有颜色
    if (![tempHourAttr objectForKey:GosStrokeColorAttributeName]) {
        [tempHourAttr setObject:GOS_COLOR_RGB(0xE6E6E6) forKey:GosStrokeColorAttributeName];
    }
    // 如果时刻度线没有宽度
    if (![tempHourAttr objectForKey:GosStrokeSizeAttributeName]) {
        [tempHourAttr setObject:@(1.0) forKey:GosStrokeSizeAttributeName];
    }
    // 如果时刻度线没有线宽
    if (![tempHourAttr objectForKey:GosStrokeLineWidthAttributeName]) {
        [tempHourAttr setObject:@(18.0) forKey:GosStrokeLineWidthAttributeName];
    }
    aTimeAxisSegments.hourScaleDrawAttributes = [tempHourAttr copy];
    
    
    
    
    NSMutableDictionary *tempSecondAttr = [NSMutableDictionary dictionaryWithDictionary:aTimeAxisSegments.secondScaleDrawAttributes];
    // 如果秒刻度线没有颜色
    if (![tempSecondAttr objectForKey:GosStrokeColorAttributeName]) {
        [tempSecondAttr setObject:[aTimeAxisSegments.hourScaleDrawAttributes objectForKey:GosStrokeColorAttributeName] forKey:GosStrokeColorAttributeName];
    }
    // 如果秒刻度线没有宽度
    if (![tempSecondAttr objectForKey:GosStrokeSizeAttributeName]) {
        [tempSecondAttr setObject:[aTimeAxisSegments.hourScaleDrawAttributes objectForKey:GosStrokeSizeAttributeName] forKey:GosStrokeSizeAttributeName];
    }
    // 如果秒刻度线没有高度
    if (![tempSecondAttr objectForKey:GosStrokeLineWidthAttributeName]) {
        [tempSecondAttr setObject:@(10.0) forKey:GosStrokeLineWidthAttributeName];
    }
    aTimeAxisSegments.secondScaleDrawAttributes = [tempSecondAttr copy];
    
    // 视图内最大显示6小时
    aTimeAxisSegments.visibleOfMaxHoursInOneScale = 6.0;
    aTimeAxisSegments.segmentInfoArray = @[
                                           // 30 min
                                           [SegmentInfoModel segmentInfoModelWithScale:1.0 seconds:1800 displayTimeType:SegmentDisplayTimeTypeHourAndMinute],
                                           // 10 min
                                           [SegmentInfoModel segmentInfoModelWithScale:2.0 seconds:600 displayTimeType:SegmentDisplayTimeTypeHourAndMinute],
                                           // 5 min
                                           [SegmentInfoModel segmentInfoModelWithScale:3.0 seconds:300 displayTimeType:SegmentDisplayTimeTypeHourAndMinute],
                                           // 1 min
                                           [SegmentInfoModel segmentInfoModelWithScale:4.0 seconds:60 displayTimeType:SegmentDisplayTimeTypeHourAndMinute],
                                           // 30 s
                                           [SegmentInfoModel segmentInfoModelWithScale:5.0 seconds:30 displayTimeType:SegmentDisplayTimeTypeAll],
                                           // 10 s
                                           [SegmentInfoModel segmentInfoModelWithScale:6.0 seconds:10 displayTimeType:SegmentDisplayTimeTypeAll],
                                           ];
}
/// 访问背景
- (void)visitTimeAxisBackground:(GosTimeAxisBackground *)aTimeAxisBackground {
    // 无自制背景
}
/// 访问基线
- (void)visitTimeAxisBaseLine:(GosTimeAxisBaseLine *)aTimeAxisBaseLine {
    // 无基线
}
@end
