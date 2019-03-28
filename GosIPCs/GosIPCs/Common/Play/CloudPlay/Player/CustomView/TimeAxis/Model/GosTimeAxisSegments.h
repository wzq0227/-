//  GosTimeAxisSegments.h
//  GosIPCs
//
//  Create by daniel.hu on 2018/11/27.
//  Copyright © 2018年 goscam. All rights reserved.

#import "GosTimeAxisModel.h"

/// 分段显示时间类型
typedef NS_OPTIONS(NSUInteger, SegmentDisplayTimeType) {
    /// 小时
    SegmentDisplayTimeTypeHour      = 1 << 0,
    /// 分钟
    SegmentDisplayTimeTypeMinute    = 1 << 1,
    /// 秒
    SegmentDisplayTimeTypeSecond    = 1 << 2,
    /// 小时与分钟
    SegmentDisplayTimeTypeHourAndMinute = SegmentDisplayTimeTypeHour|SegmentDisplayTimeTypeMinute,
    /// 全部显示
    SegmentDisplayTimeTypeAll       = SegmentDisplayTimeTypeHour|SegmentDisplayTimeTypeMinute|SegmentDisplayTimeTypeSecond,
};


NS_ASSUME_NONNULL_BEGIN
/// 分段信息模型
@class SegmentInfoModel;

/**
 分段数据——绘制小时刻度、分钟刻度以及时间
 */
@interface GosTimeAxisSegments : NSObject <GosTimeAxisModel>
#pragma mark - 基本属性
/// 当前比例，默认为1.0
@property (nonatomic, assign) CGFloat currentScale;
/// 最小比例，默认为1.0
@property (nonatomic, readonly, assign) CGFloat minimumScale;
/// 最大比例
@property (nonatomic, readonly, assign) CGFloat maximumScale;
/// 1.0比例下 可见视图内能容下最多的小时数 单位：小时 可见视图尺寸 / visibleOfMaxHoursInOneScale = 每小时对应的像素宽度 (像素/小时)
@property (nonatomic, assign) CGFloat visibleOfMaxHoursInOneScale;
/// 是否无限，否：超过24时就不再绘制
@property (nonatomic, assign, getter=isInfinitely) BOOL infinitely;

#pragma mark - 分段属性
/**
 分段信息数组，默认存在1.0比例的模型
 由此信息并结合currentScale 将得到以下信息
 minimumScale, maximumScale, anHourOfSegments, segmentOfScale, segmentInTimeType
 */
@property (nonatomic, copy) NSArray <SegmentInfoModel *> *segmentInfoArray;
/// 分段代表的秒数
@property (nonatomic, readonly, assign) NSUInteger segmentOfSecond;
/// 分段比例
@property (nonatomic, readonly, assign) CGFloat segmentOfScale;
/// 分段对应的显示类型
@property (nonatomic, readonly, assign) SegmentDisplayTimeType segmentOfTimeType;

#pragma mark - 外观属性
/// 显示数字属性  参考NSAttributedStringKey
@property (nonatomic, copy) NSDictionary *displayTimeDrawAttributes;
/// 时刻度绘制属性 参考GosAttributeNameKey
@property (nonatomic, copy) NSDictionary *hourScaleDrawAttributes;
/// 秒刻度绘制属性 参考GosAttributeNameKey
@property (nonatomic, copy) NSDictionary *secondScaleDrawAttributes;

#pragma mark - visitor method
- (void)acceptVisitor:(id<GosTimeAxisVisitor>)visitor;

#pragma mark - calculate method
/**
 时间一秒所对应的像素  单位：点/秒
 
 @param width 水平时指高度，垂直时指高度
 @return 像素
 */
- (CGFloat)pixelOfASecondWithViewWidth:(CGFloat)width;

/**
 优化比例
 
 @param scale 比例
 */
- (void)optimiseScale:(CGFloat *)scale;


/**
 优化时间显示
 
 @param hour 时
 @param minute 分
 @return NSString
 */
- (NSString *)optimiseTimeStringDisplayFromHour:(NSInteger)hour minute:(NSInteger)minute;
@end


#pragma mark - SegmentInfoModel 分段信息模型
/// 一小时的秒数
#define MAX_SECONDS_IN_AN_HOUR 3600.0

/**
 分段信息模型——分段对应的比例、一段代表的秒数以及时间显示样式
 */
@interface SegmentInfoModel : NSObject

/**
 比例对应的一分段的秒数
 (scale, seconds)
 scale取值范围 (0<~无穷);
 seconds取值范围 (0<~<=MAX_SECONDS_IN_HOUR)
 */
@property (nonatomic, assign) CGPoint scaleMatchASegmentOfSeconds;
/// 分段显示的类型，默认为SegmentDisplayTimeTypeHourAndMinute
@property (nonatomic, assign) SegmentDisplayTimeType displayTimeType;

#pragma mark - class method
/// 1.0比例默认模型
+ (SegmentInfoModel *)oneScaleInfoModel;
/// 初始化方法
+ (SegmentInfoModel *)segmentInfoModelWithScale:(CGFloat)scale seconds:(CGFloat)seconds displayTimeType:(SegmentDisplayTimeType)displayTimeType;
#pragma mark - compare method
/**
 比较方法
 
 @param otherModel SegmentInfoModel
 @return NSComparisonResult
 */
- (NSComparisonResult)compare:(SegmentInfoModel *)otherModel;
@end

NS_ASSUME_NONNULL_END
