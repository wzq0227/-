//  GosTimeAxisData.h
//  GosIPCs
//
//  Create by daniel.hu on 2018/11/27.
//  Copyright © 2018年 goscam. All rights reserved.

#import "GosTimeAxisModel.h"



typedef NS_ENUM(NSInteger, GosTimeAxisDataAttributeStyle) {
    /// 紫色 0xBF96FF
    GosTimeAxisDataAttributeStylePurple,
    /// 橘黄色 0xFFB973
    GosTimeAxisDataAttributeStyleOrange,
    /// 青绿色 0x67D4DB
    GosTimeAxisDataAttributeStyleTurquoise,
    /// 粉红色 0xFF96CB
    GosTimeAxisDataAttributeStylePinkPinkPink,
};

NS_ASSUME_NONNULL_BEGIN

@interface GosTimeAxisData : NSObject <GosTimeAxisModel, NSCopying>
/// 时长
@property (nonatomic, readonly, assign) NSTimeInterval duration;
/// 开始时间戳
@property (nonatomic, assign) NSTimeInterval startTimeInterval;
/// 结束时间戳
@property (nonatomic, assign) NSTimeInterval endTimeInterval;
/// 额外附带的数据
@property (nonatomic, nullable) id extraData;


/// 绘制的属性，参考GosAttributeNameKey，外部仅使用GosTimeAxisDataAttributeStyle即可
@property (nonatomic, copy) NSDictionary *drawAttributes;
/// 仅为了易于使用，设置drawAttributes，默认值为GosTimeAxisDataAttributeStylePurple
@property (nonatomic, assign) GosTimeAxisDataAttributeStyle attributeStyle;

#pragma mark - visitor method
/// 通用访问方法
- (void)acceptVisitor:(id<GosTimeAxisVisitor>)visitor;

#pragma mark - NSCopying
- (id)copyWithZone:(nullable NSZone *)zone;
@end

NS_ASSUME_NONNULL_END
