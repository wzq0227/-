//  GosTimeAxis+Generator.m
//  GosIPCs
//
//  Create by daniel.hu on 2018/11/27.
//  Copyright © 2018年 goscam. All rights reserved.

#import "GosTimeAxis+Generator.h"
#import "GosTimeAxisRule.h"
#import "GosTimeAxisBaseLine.h"
#import "GosTimeAxisBackground.h"
#import "GosTimeAxisSegments.h"
#import "GosTimeAxisData.h"

@implementation GosTimeAxis (Generator)
- (NSArray *)updateAppearanceArrayWithGenerator:(GosTimeAxisGenerator *)generator
                                   timeAxisRule:(GosTimeAxisRule *__strong *)timeAxisRule
                        timeAxisSegments:(GosTimeAxisSegments *__strong *)timeAxisSegments {
    
    id<GosTimeAxisModel> segments = (id<GosTimeAxisModel>)[[GosTimeAxisSegments alloc] init];
    id<GosTimeAxisModel> rule = (id<GosTimeAxisModel>)[[GosTimeAxisRule alloc] init];
    id<GosTimeAxisModel> baseLine = (id<GosTimeAxisModel>)[[GosTimeAxisBaseLine alloc] init];
    id<GosTimeAxisModel> background = (id<GosTimeAxisModel>)[[GosTimeAxisBackground alloc] init];
    
    [rule acceptVisitor:generator];
    [segments acceptVisitor:generator];
    [baseLine acceptVisitor:generator];
    [background acceptVisitor:generator];
    
    *timeAxisRule = rule;
    *timeAxisSegments = segments;
    
    // 这个顺序千万别错
    return @[background, rule, baseLine, segments];
}
- (void)updateTimeAxisDataWithDataArray:(NSArray <GosTimeAxisData *>*)dataArray generator:(GosTimeAxisGenerator *)generator {
    for (GosTimeAxisData *data in dataArray) {
        // 给数据添加属性
        [data acceptVisitor:generator];
    }
}
@end
