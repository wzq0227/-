//  PlaybackControlHandler.h
//  GosIPCs
//
//  Create by daniel.hu on 2019/1/22.
//  Copyright © 2019年 goscam. All rights reserved.

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, PlaybackControlState) {
    PlaybackControlStateDefault,    // 默认状态
    PlaybackControlStatePlaying,    // 播放状态
    PlaybackControlStateCutting,    // 剪切状态
    PlaybackControlStateLoading,    // 加载状态
    PlaybackControlStateBuffing,    // 缓冲状态
    PlaybackControlStateDevOffline, // 设备离线
    
};

/// 未知时间戳
#define GOS_TIME_STAMP_NULL 0

@class GosTimeAxisData;
@class GosTimeAxis;
@class PlaybackControlHandler;
@class GosCalendarView;
@protocol PlaybackControlHandlerDelegate <NSObject>

/// 静音反馈
- (void)control_handler:(PlaybackControlHandler *)handler muteDidClick:(UIButton *)sender;
/// 剪切
- (void)control_handler:(PlaybackControlHandler *)handler cutDidClick:(UIButton *)sender;
/// 截图
- (void)control_handler:(PlaybackControlHandler *)handler snapshotDidClick:(UIButton *)sender;
/// 预览图点击播放
- (void)control_handler:(PlaybackControlHandler *)handler previewPlayDidClick:(UIButton *)sender startTimestamp:(NSTimeInterval)startTimestamp;
/// 选择日期已经改变
- (void)control_handler:(PlaybackControlHandler *)handler calendarSelectedDateDidChanged:(NSDate *)sender;
/// 显示详细日历所需信息
- (void)control_handler:(PlaybackControlHandler *)handler calendarView:(GosCalendarView *)calendarView displayDetailViewInView:(UIView **)view frame:(CGRect *)frame;
/// 更新当前时间
- (void)control_handler:(PlaybackControlHandler *)handler didChangedTimeInterval:(NSTimeInterval)currentTimeInterval;
/// 更新放缩比例
- (void)control_handler:(PlaybackControlHandler *)handler didChangedScale:(CGFloat)currentScale;
/// 停止的位置存在数据orNot
- (void)control_handler:(PlaybackControlHandler *)handler didEndedAtDataSection:(GosTimeAxisData *_Nullable)aAxisData positionTimestamp:(NSTimeInterval)positionTimestamp;
/// 从指定位置开始查找数据结束，aAxisData存在即找到，不存在即未找到
- (void)control_handler:(PlaybackControlHandler *)handler didSeekedNextDataSection:(GosTimeAxisData *_Nullable)aAxisData fromTimestamp:(NSTimeInterval)fromTimestamp;
/// 开始滚动
- (void)control_handler:(PlaybackControlHandler *)handler timeAxisDidBeginScrolling:(GosTimeAxis *)timeAxis;
///// 结束滚动
//- (void)control_handler:(PlaybackControlHandler *)handler timeAxisDidEndScrolling:(GosTimeAxis *)timeAxis;
///// 开始捏合手势
//- (void)control_handler:(PlaybackControlHandler *)handler timeAxisDidBeginPinching:(GosTimeAxis *)timeAxis;
///// 结束捏合手势
//- (void)control_handler:(PlaybackControlHandler *)handler timeAxisDidEndPinching:(GosTimeAxis *)timeAxis;


@end


NS_ASSUME_NONNULL_BEGIN


@class PlaybackBaseControl;
@class GosCalendarView;
@class GosTimeAxis;
@class PlaybackMaskControl;
/**
 提供控制的输入输出
 */
@interface PlaybackControlHandler : NSObject

@property (nonatomic, weak) id<PlaybackControlHandlerDelegate> delegate;

/// 静音(Normal静音, Select声音)、剪切、截图
@property (nonatomic, readonly, strong) PlaybackBaseControl *baseControl;
/// 日历
@property (nonatomic, readonly, strong) GosCalendarView *calendarView;
/// 时间轴
@property (nonatomic, readonly, strong) GosTimeAxis *timeAxisControl;
/// 遮罩
@property (nonatomic, readonly, strong) PlaybackMaskControl *maskControl;

/// 更新时间轴数据
- (void)control_handler_timeAxisUpdateWithDataArray:(NSArray <GosTimeAxisData *> * _Nullable)dataArray;
/// 添加时间轴数据
- (void)control_handler_timeAxisAppendWithDataArray:(NSArray <GosTimeAxisData *> * _Nullable)dataArray;
/// 更新事件数组
- (void)control_handler_calenderUpdateWithEventsArray:(NSArray <NSDate *> *)events;
/// 更新日历显示时间
- (void)control_handler_calenderUpdateWithDisplayDate:(NSDate *)date;
/// 更新预览图视图
- (void)control_handler_maskUpdatePreviewWithImage:(UIImage *_Nullable)image
                                         timestamp:(NSTimeInterval)timestamp
                                         isLoading:(BOOL)isLoading;
/// 更新状态
- (void)control_handler_controlUpdateState:(PlaybackControlState)state;
/// 更新时间戳
- (void)control_handler_timeAxisUpdateCurrentTimestamp:(NSTimeInterval)currentTimestamp;
/// 放到最大
- (void)control_handler_timeAxisUpdateWithZoomToMax;
/// 缩到最小
- (void)control_handler_timeaxisUpdateWithZoomToMin;
/// 查找下一项数据
- (void)control_handler_seekNextDataFromTimestamp:(NSTimeInterval)fromTimestamp;
/// 查找当前时间戳对应的数据
- (GosTimeAxisData *)control_handler_findDataForTimestamp:(NSTimeInterval)timestamp onlyInternal:(BOOL)onlyInternal;
/// 查找当前时间戳连续的一组数据
- (NSArray <GosTimeAxisData *> *)control_handler_findSerialDataForTimestamp:(NSTimeInterval)timestamp;
@end

NS_ASSUME_NONNULL_END
