//  GosTimeAxisModel.h
//  GosIPCs
//
//  Create by daniel.hu on 2018/11/27.
//  Copyright © 2018年 goscam. All rights reserved.

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "GosTimeAxisVisitor.h"
/// 定义属性名键值
typedef NSString * GosAttributeNameKey;
/// 绘制颜色
static GosAttributeNameKey const GosStrokeColorAttributeName = @"kGosStrokeColorAttributeName";
/// 绘制尺寸
static GosAttributeNameKey const GosStrokeSizeAttributeName = @"kGosStrokeSizeAttributeName";
/// 绘制线条长度
static GosAttributeNameKey const GosStrokeLineWidthAttributeName = @"kGosStrokeLineWidthAttributeName";

/// 方向，设置响应在renderer类中，不然单设置此属性无效
typedef NS_ENUM(NSUInteger, GosTimeAxisDirection) {
    GosTimeAxisDirectionHorizontal, // 水平
    GosTimeAxisDirectionVertical,   // 垂直
};

NS_ASSUME_NONNULL_BEGIN

@protocol GosTimeAxisModel <NSObject>
@optional
/// 最小比例
@property (nonatomic, readonly, assign) CGFloat minimumScale;
/// 最大比例
@property (nonatomic, readonly, assign) CGFloat maximumScale;
/// 当前放大比例
@property (nonatomic, assign) CGFloat currentScale;

/// 当前时间戳
@property (nonatomic, assign) NSTimeInterval currentTimeInterval;
/// 开始时间戳
@property (nonatomic, assign) NSTimeInterval startTimeInterval;
/// 结束时间戳
@property (nonatomic, assign) NSTimeInterval endTimeInterval;
/// 时长
@property (nonatomic, readonly, assign) NSTimeInterval duration;

/// 绘制的属性，参考GosAttributeNameKey
@property (nonatomic, copy) NSDictionary *drawAttributes;
/// 方向
@property (nonatomic, assign) GosTimeAxisDirection axisDirection;

/// 额外附带数据
@property (nonatomic, strong, nullable) id extraData;


/**
 访问者 响应方法
 
 @param visitor id<AxisVisitor>访问者
 */
- (void)acceptVisitor:(id<GosTimeAxisVisitor>)visitor;

@end

NS_ASSUME_NONNULL_END
