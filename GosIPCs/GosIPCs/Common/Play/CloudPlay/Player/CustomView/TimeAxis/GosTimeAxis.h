//  GosTimeAxis.h
//  GosIPCs
//
//  Create by daniel.hu on 2018/11/27.
//  Copyright © 2018年 goscam. All rights reserved.

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "GosTimeAxisRule.h"
#import "GosTimeAxisSegments.h"
#import "GosTimeAxisData.h"
#import "GosTimeAxisRenderer.h"
#import "GosTimeAxisGenerator.h"

@class GosTimeAxis;
@protocol GosTimeAxisDelegate <NSObject>
@optional
/// 更新当前时间
- (void)timeAxis:(GosTimeAxis *)timeAxis didChangedTimeInterval:(NSTimeInterval)currentTimeInterval;
/// 更新放缩比例
- (void)timeAxis:(GosTimeAxis *)timeAxis didChangedScale:(CGFloat)currentScale;
/// 停止的位置存在数据
- (void)timeAxis:(GosTimeAxis *)timeAxis didEndedAtDataSection:(GosTimeAxisData *)aAxisData positionTimestamp:(NSTimeInterval)positionTimestamp;
/// 停止的位置不存在数据
- (void)timeAxis:(GosTimeAxis *)timeAxis didEndedAtPostionWithoutData:(NSTimeInterval)positionTimestamp;
/// 从指定位置找到下一个数据
- (void)timeAxis:(GosTimeAxis *)timeAxis didSeekedNextDataSection:(GosTimeAxisData *)aAxisData fromPositionTimestamp:(NSTimeInterval)positionTimestamp;
/// 从指定位置开始未找到下一个数据
- (void)timeAxis:(GosTimeAxis *)timeAxis didNotSeekNextDataFromPositionTimestamp:(NSTimeInterval)positionTimestamp;

/// 开始滚动
- (void)timeAxisDidBeginScrolling:(GosTimeAxis *)timeAxis;
/// 结束滚动
- (void)timeAxisDidEndScrolling:(GosTimeAxis *)timeAxis;
/// 开始捏合手势
- (void)timeAxisDidBeginPinching:(GosTimeAxis *)timeAxis;
/// 结束捏合手势
- (void)timeAxisDidEndPinching:(GosTimeAxis *)timeAxis;

/**
 外部模型 转为 GosTimeAxisData

 @param extraModel 外部模型
 @return GosTimeAxisData
 */
- (nonnull GosTimeAxisData *)convertExtraDataModel:(id)extraModel;
@end


NS_ASSUME_NONNULL_BEGIN

@interface GosTimeAxis <__covariant ObjectType> : UIControl
/// GosTimeAxisDelegate
@property (nonatomic, weak) id<GosTimeAxisDelegate> delegate;
/// 是否无限滚动，否：24小时内滚动
@property (nonatomic, assign, getter=isInfinitely) BOOL infinitely;

/// 当前时间戳
@property (nonatomic, readonly, assign) NSTimeInterval currentTimeInterval;
/// 当前比例
@property (nonatomic, readonly, assign) CGFloat currentScale;

/// 移动手势状态
@property (nonatomic, readonly, assign, getter=isPaning) BOOL paning;
/// 捏合手势状态
@property (nonatomic, readonly, assign, getter=isPinching) BOOL pinching;

/// 渲染类
@property (nonatomic, strong) GosTimeAxisRenderer *timeAxisRenderer;
/// 生产类
@property (nonatomic, strong) GosTimeAxisGenerator *timeAxisGenerator;

/**
 外部驱动时间轴移动更新
 
 @param currentTimeInterval 当前时间戳
 */
- (void)updateWithCurrentTimeInterval:(NSTimeInterval)currentTimeInterval;

/**
 更新时间段数据
 
 @param dataArray 段数据
 */
- (void)updateWithDataArray:(NSArray <GosTimeAxisData *>*)dataArray;

/**
 添加时间段数据

 @param dataArray 段数据
 */
- (void)appendWithDataArray:(NSArray <GosTimeAxisData *> *)dataArray;

/**
 从外部模型更新数据，并提供元素转化GosTimeAxisData的方法

 @param dataArray 外部数据数组
 @param convertMethod 元素转化GosTimeAxisData的方法
 */
- (void)updateWithExtraDataArray:(NSArray <__kindof ObjectType>*)dataArray
                   convertMethod:(GosTimeAxisData *(^)(ObjectType t))convertMethod;

/**
 从外部模型更新数据
 元素转化方法从代理实现

 @param dataArray 外部数据数组
 */
- (void)updateWithExtraDataArray:(NSArray <__kindof ObjectType>*)dataArray;

/// 更新刻度线的绘制属性
- (void)updateWithRuleAttribute:(NSDictionary <GosAttributeNameKey, id> *_Nullable)attribute;

/**
 更新数字/时线/秒线的绘制属性
 
 @param hourAttr 时属性
 @param secondAttr 秒属性
 @param displayTimeAttr 文字属性
 */
- (void)updateWithSegementHourAttribute:(NSDictionary <GosAttributeNameKey, id> *_Nullable)hourAttr
                        secondAttribute:(NSDictionary <GosAttributeNameKey, id> *_Nullable)secondAttr
                   displayTimeAttribute:(NSDictionary <NSAttributedStringKey, id> *_Nullable)displayTimeAttr;

/**
 从指定时间戳开始查找下一个数据

 @param timestamp 指定时间戳
 */
- (void)seekNextDataFromTimestamp:(NSTimeInterval)timestamp;

/**
 查找当前时间戳对应的数据

 @param timestamp 指定时间戳
 @param onlyInternal 是否限定区间内，如否，将可筛选第一个大于timestamp的数据
 @return GosTimeAxisData
 */
- (GosTimeAxisData *)findDataForTimestamp:(NSTimeInterval)timestamp onlyInternal:(BOOL)onlyInternal;

/**
 查找当前时间戳连续的数据

 @param timestamp 指定时间戳
 @return GosTimeAxisData
 */
- (NSArray <GosTimeAxisData *> *)findSerialDataForTimestamp:(NSTimeInterval)timestamp;

/** 放大到最大 */
- (void)zoomToMax;

/** 缩小到最小 */
- (void)zoomToMin;

@end

NS_ASSUME_NONNULL_END
