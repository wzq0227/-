//  GosTimeAxis+Generator.h
//  GosIPCs
//
//  Create by daniel.hu on 2018/11/27.
//  Copyright © 2018年 goscam. All rights reserved.

#import "GosTimeAxis.h"

//NS_ASSUME_NONNULL_BEGIN

@interface GosTimeAxis (Generator)

/**
 通过GosTimeAxisGenerator更新外观属性

 @param generator GosTimeAxisGenerator
 @param timeAxisRule 刻度尺
 @param timeAxisSegments 数字分割线
 @return 外观数组——用于GosTimeAxisView
 */
- (NSArray *)updateAppearanceArrayWithGenerator:(GosTimeAxisGenerator *)generator
                                   timeAxisRule:(GosTimeAxisRule *__strong*)timeAxisRule
                        timeAxisSegments:(GosTimeAxisSegments *__strong*)timeAxisSegments;

/**
 通过GosTimeAxisGenerator更新数据额外属性

 @param dataArray 数据数组
 @param generator GosTimeAxisGenerator
 */
- (void)updateTimeAxisDataWithDataArray:(NSArray <GosTimeAxisData *>*)dataArray
                              generator:(GosTimeAxisGenerator *)generator;
@end

//NS_ASSUME_NONNULL_END
