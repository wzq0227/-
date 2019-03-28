//  GosTimeAxisRenderer.h
//  GosIPCs
//
//  Create by daniel.hu on 2018/11/27.
//  Copyright © 2018年 goscam. All rights reserved.

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "GosTimeAxisVisitor.h"
#import "GosTimeAxisModel.h"

NS_ASSUME_NONNULL_BEGIN

/**
 渲染数据基类
 */
@interface GosTimeAxisRenderer : NSObject <GosTimeAxisVisitor> {
    @protected
    CGContextRef _context;
    CGSize _viewSize;
    NSTimeInterval _minTimeInVisible;
    NSTimeInterval _maxTimeInVisible;
    NSTimeInterval _currentTimeInterval;
    
    NSTimeInterval _integerHourDifference;
    NSInteger _integerHour;
    
    CGFloat _ruleFixedOffset;
    CGFloat _baseLineFixedOffset;
    CGFloat _backgroundSize;
    CGFloat _aSecondOfPixel;
    GosTimeAxisDirection _axisDirection;
}

/// 绘制上下文
@property (nonatomic, assign) CGContextRef context;
/// 视图尺寸
@property (nonatomic, assign) CGSize viewSize;
/// 绘画的控件
@property (nonatomic, weak, nullable) UIView *rendererView;

#pragma mark - setup property method
- (void)setupParametersWithTimeAxisRule:(GosTimeAxisRule *)aTimeAxisRule;
- (void)setupParametersWithTimeAxisBaseLine:(GosTimeAxisBaseLine *)aTimeAxisBaseLine;
- (void)setupParametersWithTimeAxisSegments:(GosTimeAxisSegments *)aTimeAxisSegments;
- (void)setupParametersWithTimeAxisBackground:(GosTimeAxisBackground *)aTimeAxisBackground;

#pragma mark - initialization
/// 初始化方法
- (id<GosTimeAxisVisitor>)initWithSize:(CGSize)aSize context:(CGContextRef)context rendererView:(nullable UIView *)rendererView;

#pragma mark - visitor method
/// 通用访问方法
- (void)visitTimeAxis:(id<GosTimeAxisModel>)aTimeAxis;
/// 访问数据
- (void)visitTimeAxisData:(GosTimeAxisData *)aTimeAxisData;
/// 访问刻度线
- (void)visitTimeAxisRule:(GosTimeAxisRule *)aTimeAxisRule;
/// 访问数字与分割线
- (void)visitTimeAxisSegments:(GosTimeAxisSegments *)aTimeAxisSegments;
/// 访问背景
- (void)visitTimeAxisBackground:(GosTimeAxisBackground *)aTimeAxisBackground;
/// 访问基线
- (void)visitTimeAxisBaseLine:(GosTimeAxisBaseLine *)aTimeAxisBaseLine;

@end

NS_ASSUME_NONNULL_END
