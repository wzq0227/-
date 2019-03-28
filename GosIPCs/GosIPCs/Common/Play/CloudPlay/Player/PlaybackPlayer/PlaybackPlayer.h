//  PlaybackPlayer.h
//  GosIPCs
//
//  Create by daniel.hu on 2019/1/22.
//  Copyright © 2019年 goscam. All rights reserved.

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol PlaybackPlayerDelegate;
@class TokenCheckApiRespModel;
@class VideoSlicesApiRespModel;
@class GosTimeAxisData;

/**
 Playback播放器调控者
 |-player
    |-control handler
     |--scroll control
     |--base control
     |--mask control
    |-player handler
     |--player view
     |--sdk handler
     |--data handler
    |-orientation handler
 */
@interface PlaybackPlayer : NSObject
@property (nonatomic, weak) id<PlaybackPlayerDelegate> delegate;

/// 傀儡播放器
@property (nonatomic, readonly, strong) UIView *pb_playerViewProxy;
/// 傀儡日历
@property (nonatomic, readonly, strong) UIView *pb_calenderViewProxy;
/// 傀儡基本设置
@property (nonatomic, readonly, strong) UIView *pb_basicViewProxy;
/// 傀儡时间轴
@property (nonatomic, readonly, strong) UIView *pb_timeAxisViewProxy;
/// 傀儡遮罩
@property (nonatomic, readonly, strong) UIView *pb_maskViewProxy;

/// 初始化
- (instancetype)initWithDeviceId:(NSString *)deviceId;
/// 开始播放
- (void)pb_player_startPlayWithStartTimestamp:(NSTimeInterval)startTimestamp;
/// 开始剪切
- (void)pb_player_startClipWithVideos:(NSArray <VideoSlicesApiRespModel *> *)videos
                             fileName:(NSString *)fileName
                            startTime:(NSUInteger)startTime
                             duration:(NSUInteger)duration;
/// 更新时间轴数据
- (void)pb_player_updateTimeAxisWithDataArray:(NSArray <GosTimeAxisData *> *)dataArray;
/// 添加数据
- (void)pb_player_appendTimeAxisDataArray:(NSArray <GosTimeAxisData *> *)dataArray;
/// 通知日历需要更新时间数据
- (void)pb_player_updateCalenderWithEventsArray:(NSArray <NSDate *> *)events;
/// 更新界面
- (void)pb_player_updateWithCurrentTimestamp:(NSTimeInterval)currentTimestamp;
/// 初始播放器
- (void)pb_player_initialPlayer;
/// 销毁播放器
- (void)pb_player_destoryPlayer;

@end

#pragma mark - PlaybackPlayerDelegate

@protocol PlaybackPlayerDelegate <NSObject>

@optional
- (void)pb_player:(PlaybackPlayer *)player clipDidClick:(UIButton *)sender deviceId:(NSString *)deviceId videos:(NSArray <VideoSlicesApiRespModel *> *)videos startTimestamp:(NSTimeInterval)startTimestamp startTime:(NSUInteger)startTime duration:(NSUInteger)duration;

- (void)pb_player:(PlaybackPlayer *)player didSucceedClipAtVideoFilePath:(NSString *)videoFilePath;

- (void)pb_player:(PlaybackPlayer *)player didFailedClipAtVideoFilePath:(NSString *)videoFilePath;

- (void)pb_player:(PlaybackPlayer *)player calendarView:(UIView *)calendarView displayDetailViewInView:(UIView *__autoreleasing *)view frame:(CGRect *)frame;

- (void)pb_player:(PlaybackPlayer *)player calendarSelectedDateDidChanged:(NSDate *)sender;
@end

NS_ASSUME_NONNULL_END
