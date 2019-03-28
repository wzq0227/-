//  GosTimeAxisRule.h
//  GosIPCs
//
//  Create by daniel.hu on 2018/11/27.
//  Copyright © 2018年 goscam. All rights reserved.

#import "GosTimeAxisModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface GosTimeAxisRule : NSObject <GosTimeAxisModel>


@property (nonatomic, assign) NSTimeInterval currentTimeInterval;
/// 方向
@property (nonatomic, assign) GosTimeAxisDirection axisDirection;
/// 刻度尺在视图中的固定偏移位置
@property (nonatomic, assign) CGFloat fixedOffset;

/// 绘制的属性，参考GosAttributeNameKey
@property (nonatomic, copy) NSDictionary *drawAttributes;

#pragma mark - visitor method
- (void)acceptVisitor:(id<GosTimeAxisVisitor>)visitor;

@end

#pragma mark - GosTimeAxisRuleDateExtension 扩展NSDate类方法
@interface  NSDate (GosTimeAxisRuleDateExtension)

/**
 距离当前整点的时差

 @param timeInterval 时间戳
 @return 时差
 */
+ (NSTimeInterval)integerHourDifferenceValueFromTimeInterval:(NSTimeInterval)timeInterval;

/**
 当前整点

 @param timeInterval 时间戳
 @return 小时
 */
+ (NSInteger)intergerHourWithTimeInterval:(NSTimeInterval)timeInterval;

@end

NS_ASSUME_NONNULL_END
