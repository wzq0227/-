//  TFCardPlayer.h
//  GosIPCs
//
//  Create by daniel.hu on 2019/2/19.
//  Copyright © 2019年 goscam. All rights reserved.

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@protocol TFCardPlayerDelegate;
@class GosTimeAxisData;

@interface TFCardPlayer : NSObject
@property (nonatomic, weak) id<TFCardPlayerDelegate> delegate;
/// 傀儡播放器
@property (nonatomic, readonly, strong) UIView *tf_playerViewProxy;
/// 傀儡日历
@property (nonatomic, readonly, strong) UIView *tf_calenderViewProxy;
/// 傀儡基本设置
@property (nonatomic, readonly, strong) UIView *tf_basicViewProxy;
/// 傀儡时间轴
@property (nonatomic, readonly, strong) UIView *tf_timeAxisViewProxy;
/// 傀儡遮罩
@property (nonatomic, readonly, strong) UIView *tf_maskViewProxy;

/// 初始化
- (instancetype)initWithDeviceId:(NSString *)deviceId;
/// 开始播放
- (void)tf_player_startPlayWithStartTimestamp:(NSTimeInterval)startTimestamp;
/// 开始剪切
- (void)tf_player_startClipWithFileName:(NSString *)fileName startTimestamp:(NSTimeInterval)startTimestamp duration:(NSUInteger)duration;
/// 更新时间轴数据
- (void)tf_player_updateTimeAxisWithDataArray:(NSArray <GosTimeAxisData *> *)dataArray;
/// 添加时间轴数据
- (void)tf_player_appendTimeAxisDataArray:(NSArray <GosTimeAxisData *> *)dataArray;
/// 通知日历需要更新时间数据
- (void)tf_player_updateCalenderWithEventsArray:(NSArray <NSDate *> *)events;
/// 更新界面
- (void)tf_player_updateWithCurrentTimestamp:(NSTimeInterval)currentTimestamp;
/// 初始化播放器
- (void)tf_player_initialPlayer;
/// 销毁播放器
- (void)tf_player_destoryPlayer;

@end

@protocol TFCardPlayerDelegate <NSObject>

@optional
- (void)tf_player:(TFCardPlayer *)player clipDidClick:(UIButton *)sender deviceId:(NSString *)deviceId startTimestamp:(NSTimeInterval)startTimestamp duration:(NSUInteger)duration;

- (void)tf_player:(TFCardPlayer *)player didSucceedClipAtVideoFilePath:(NSString *)videoFilePath startTimestamp:(NSTimeInterval)startTimestamp duration:(NSUInteger)duration;

- (void)tf_player:(TFCardPlayer *)player didFailedClipAtVideoFilePath:(NSString *)videoFilePath startTimestamp:(NSTimeInterval)startTimestamp duration:(NSUInteger)duration;


- (void)tf_player:(TFCardPlayer *)player calendarView:(UIView *)calendarView displayDetailViewInView:(UIView *__autoreleasing *)view frame:(CGRect *)frame;
- (void)tf_player:(TFCardPlayer *)player calendarSelectedDateDidChanged:(NSDate *)sender;
@end

NS_ASSUME_NONNULL_END
