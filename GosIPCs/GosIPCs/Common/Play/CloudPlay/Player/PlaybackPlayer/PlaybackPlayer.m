//  PlaybackPlayer.m
//  GosIPCs
//
//  Create by daniel.hu on 2019/1/22.
//  Copyright © 2019年 goscam. All rights reserved.

#import "PlaybackPlayer.h"
#import "PlaybackControlHandler.h"
#import "PlaybackPlayerHandler.h"
#import "PlaybackOrientationHandler.h"
#import "VideoSlicesApiRespModel.h"
#import "GosTimeAxisData.h"
#import "NSDate+GosDateExtension.h"
#import "GosPhotoHelper.h"

@interface PlaybackPlayer () <PlaybackControlHandlerDelegate, PlaybackPlayerHandlerDelegate, PlaybackOrientationHandlerDelegate>
#pragma mark - handler
/// 控制 控制者
@property (nonatomic, strong) PlaybackControlHandler *controlHandler;
/// 播放 控制者
@property (nonatomic, strong) PlaybackPlayerHandler *playerHandler;
/// 旋转 控制者
@property (nonatomic, strong) PlaybackOrientationHandler *orientationHandler;

/// 设备id
@property (nonatomic, copy) NSString *deviceId;

#pragma mark - signal parameters
/// 处理的时间戳
@property (nonatomic, assign) NSTimeInterval processTimestamp;
/// 播放中的时间戳
@property (nonatomic, assign) NSTimeInterval processPlayingTimestamp;
/// 是否正在处理剪切
@property (nonatomic, assign, getter=isProcessClip) BOOL processClip;
/// 是否正在处理滚动
@property (nonatomic, assign, getter=isProcessScrolling) BOOL processScrolling;
/// 是否更改日期
@property (nonatomic, assign, getter=isChangedDate) BOOL changedDate;

#pragma mark - orientation parameters
/// 播放视图 竖屏时的布局
@property (nonatomic, assign) CGRect playerViewFrameInPortrait;
/// 播放视图 竖屏时的父视图
@property (nonatomic, weak) UIView *playerViewParentViewInPortrait;

@end

@implementation PlaybackPlayer
- (instancetype)initWithDeviceId:(NSString *)deviceId {
    if (self = [super init]) {
        _deviceId = deviceId;
        [self orientationHandler];
    }
    return self;
}


#pragma mark - public method
- (void)pb_player_startPlayWithStartTimestamp:(NSTimeInterval)startTimestamp {
    // 查找数据
    GosTimeAxisData *data = [self.controlHandler control_handler_findDataForTimestamp:startTimestamp onlyInternal:NO];
    
    // 加载ing
    [self.controlHandler control_handler_controlUpdateState:PlaybackControlStateLoading];
    // 开始播放
    [self.playerHandler player_handler_startPlayWithVideoModel:data.extraData];
    
}

- (void)pb_player_startClipWithVideos:(NSArray <VideoSlicesApiRespModel *> *)videos
                             fileName:(NSString *)fileName
                            startTime:(NSUInteger)startTime
                             duration:(NSUInteger)duration {
    [self.playerHandler player_handler_startClipWithVideos:videos
                                                  fileName:fileName
                                                 startTime:startTime
                                                  duration:duration];
}

- (void)pb_player_updateTimeAxisWithDataArray:(NSArray *)dataArray {
    self.changedDate = NO;
    [self.controlHandler control_handler_timeAxisUpdateWithDataArray:dataArray];
}

- (void)pb_player_appendTimeAxisDataArray:(NSArray *)dataArray {
    [self.controlHandler control_handler_timeAxisAppendWithDataArray:dataArray];
}

- (void)pb_player_updateCalenderWithEventsArray:(NSArray <NSDate *> *)events {
    [self.controlHandler control_handler_calenderUpdateWithEventsArray:events];
}

- (void)pb_player_updateWithCurrentTimestamp:(NSTimeInterval)currentTimestamp {
    [self.controlHandler control_handler_timeAxisUpdateCurrentTimestamp:currentTimestamp];
    [self.controlHandler control_handler_calenderUpdateWithDisplayDate:[NSDate dateWithTimeIntervalSince1970:currentTimestamp]];
}

- (void)pb_player_resizeWithOrientation:(UIDeviceOrientation)orientation {
    if (UIDeviceOrientationLandscapeLeft == orientation
        || UIDeviceOrientationLandscapeRight == orientation) {
        // 横屏
        [self.playerHandler player_handler_resizePlayViewSize:CGSizeMake(GOS_SCREEN_H, GOS_SCREEN_W)];
    } else {
        // 竖屏
        [self.playerHandler player_handler_resizePlayViewSize:CGSizeMake(GOS_SCREEN_W, GOS_SCREEN_W * GOS_VIDEO_H_W_SCALE)];
    }
}

- (void)pb_player_initialPlayer {
    _processClip = NO;
    _processScrolling = NO;
    _changedDate = NO;
    
    [self.playerHandler player_handler_initialPlayer];
}

- (void)pb_player_destoryPlayer {
    [self.playerHandler player_handler_destoryPlayer];
}


#pragma mark - private method
- (void)delayCancelScrollingProcess {
    _processScrolling = NO;
}

- (void)fetchFromVideos:(NSArray <GosTimeAxisData *> *)videos
            atTimestamp:(NSTimeInterval)timestamp
      forStartTimestamp:(NSTimeInterval *)startTimestamp
              startTime:(NSUInteger *)startTime
               duration:(NSUInteger *)duration {
    NSUInteger retDuration = 0;
    NSUInteger retStartTime = 0;
    NSTimeInterval retStartTimestamp = [videos firstObject].startTimeInterval;
    
    for (int i = 0; i < [videos count]; i++) {
        GosTimeAxisData *model = [videos objectAtIndex:i];
        NSTimeInterval st = model.startTimeInterval;
        NSTimeInterval et = model.endTimeInterval;
        
        // 开始时间 = 前面数据的总时间+(目标时间戳-数据起始时间戳)
        if (st <= timestamp && et >= timestamp) {
            retStartTime = retDuration + (NSUInteger)(timestamp - st);
        }
        // 获取最小的时间戳
        if (st < retStartTimestamp) {
            retStartTimestamp = st;
        }
        
        // 每个总时间的总和
        retDuration += (NSUInteger)ABS(et - st);
    }
    
    *startTime = retStartTime;
    *duration = retDuration;
    *startTimestamp = retStartTimestamp;
}


#pragma mark - PlaybackPlayerHandlerDelegate
- (void)player_handler:(PlaybackPlayerHandler *)handler didSucceedFetchedPreviewImage:(UIImage *)previewImage startTimestamp:(NSTimeInterval)startTimestamp onTime:(NSUInteger)onTime {
    
    // 如果当前时间戳与处理中的时间戳相等时 才更新预览图状态
    if ((NSUInteger)_processTimestamp == (startTimestamp + onTime)) {
        [self.controlHandler control_handler_maskUpdatePreviewWithImage:previewImage
                                                              timestamp:(startTimestamp + onTime)
                                                              isLoading:NO];
    }
}

- (void)player_handler:(PlaybackPlayerHandler *)handler didFailedFetchedPreviewImageFromImageFilePath:(NSString *)imageFilePath startTimestamp:(NSTimeInterval)startTimestamp onTime:(NSUInteger)onTime {
    // 没有获取到预览图，就取消预览图的显示
    [self.controlHandler control_handler_maskUpdatePreviewWithImage:nil timestamp:GOS_TIME_STAMP_NULL isLoading:NO];
}

- (void)player_handler:(PlaybackPlayerHandler *)handler didSucceedSnapshotWithImageFilePath:(NSString *)imageFilePath {
    GOS_WEAK_SELF
    // 截图保存到相册
    [GosPhotoHelper saveImageToCustomAblumWithImage:[UIImage imageWithContentsOfFile:imageFilePath] success:^{
        GOS_STRONG_SELF
        [GosHUD showProcessHUDSuccessWithStatus:@"photo_SaveToSystemSuccess"];
    } fail:^{
        GOS_STRONG_SELF
        [GosHUD showProcessHUDErrorWithStatus:@"photo_SaveToSystemFail"];
    }];
}

- (void)player_handler:(PlaybackPlayerHandler *)handler didFailedSnapshotWithImageFilePath:(NSString *)imageFilePath {
    // 截图失败
    [GosHUD showProcessHUDErrorWithStatus:@"photo_SaveToSystemFail"];
}

- (void)player_handler:(PlaybackPlayerHandler *)handler didPlayedWithStartTimestamp:(NSTimeInterval)startTimestamp duration:(NSUInteger)duration {
    
    // 开始剪切时不处理
    if (self.isProcessClip) { return ; }
    
    // 播放状态
    [self.controlHandler control_handler_controlUpdateState:PlaybackControlStatePlaying];
}

- (void)player_handler:(PlaybackPlayerHandler *)handler didPlayingAtTime:(NSUInteger)playingTime startTimestamp:(NSTimeInterval)startTimestamp duration:(NSUInteger)duration {
    _processPlayingTimestamp = startTimestamp + playingTime;
    // 更改日期时就处理
    if (self.isChangedDate) return ;
    // 开始处理剪切时不处理
    if (self.isProcessClip) return ;
    // 滚动时不处理
    if (self.isProcessScrolling) return ;
    
    // 驱动时间戳
    [self.controlHandler control_handler_timeAxisUpdateCurrentTimestamp:_processPlayingTimestamp];
    // 更新日历显示
    [self.controlHandler control_handler_calenderUpdateWithDisplayDate:[NSDate dateWithTimeIntervalSince1970:_processPlayingTimestamp]];
}

- (void)player_handler:(PlaybackPlayerHandler *)handler didEndedPlayAtStartTimestamp:(NSTimeInterval)startTimestamp duration:(NSUInteger)duration {
    GosLog(@"daniel: 结束播放 %d", self.isProcessClip);
    // 结束播放
    if (self.isProcessClip) { return ; }
    
    // 加载ing
    [self.controlHandler control_handler_controlUpdateState:PlaybackControlStateLoading];
    // 查找下一个需要播放的
    NSTimeInterval endTimestamp = startTimestamp + duration;
    [self.controlHandler control_handler_seekNextDataFromTimestamp:endTimestamp];
}

- (void)player_handler:(PlaybackPlayerHandler *)handler didSucceedClipWithVideoFilePath:(nonnull NSString *)videoFilePath startTime:(NSUInteger)startTime totalTime:(NSUInteger)totalTime {
    if (_delegate && [_delegate respondsToSelector:@selector(pb_player:didSucceedClipAtVideoFilePath:)]) {
        [_delegate pb_player:self didSucceedClipAtVideoFilePath:videoFilePath];
    }
}

- (void)player_handler:(PlaybackPlayerHandler *)handler didFailedClipWithVideoFilePath:(NSString *)videoFilePath startTime:(NSUInteger)startTime totalTime:(NSUInteger)totalTime {
    if (_delegate && [_delegate respondsToSelector:@selector(pb_player:didFailedClipAtVideoFilePath:)]) {
        [_delegate pb_player:self didFailedClipAtVideoFilePath:videoFilePath];
    }
}



#pragma mark - PlaybackControlHandlerDelegate
/// 静音反馈(Normal静音关闭，Select静音开启)
- (void)control_handler:(PlaybackControlHandler *)handler muteDidClick:(UIButton *)sender {
    GOS_WEAK_SELF
    dispatch_async(dispatch_get_main_queue(), ^{
        GOS_STRONG_SELF
        sender.selected = !sender.isSelected;
        
        if (sender.selected) {
            // 开启声音
            [strongSelf.playerHandler player_handler_openVoice];
        } else {
            // 关闭声音
            [strongSelf.playerHandler player_handler_closeVoice];
        }
    });
    
}

/// 剪切
- (void)control_handler:(PlaybackControlHandler *)handler cutDidClick:(UIButton *)sender {
    // 播放中的数据
    NSTimeInterval timestamp = _processPlayingTimestamp;
    NSString *deviceId = _deviceId;
    // 获取连续数据
    NSArray *videosInAxis = [handler control_handler_findSerialDataForTimestamp:timestamp];
    
    // 获取开始时间点与总时长、开始时间戳
    NSUInteger startTime = 0;
    NSUInteger duration = 0;
    NSTimeInterval startTimestamp = 0;
    [self fetchFromVideos:videosInAxis atTimestamp:timestamp forStartTimestamp:&startTimestamp startTime:&startTime duration:&duration];
    
    NSMutableArray *videos = [NSMutableArray arrayWithCapacity:videosInAxis.count];
    for (GosTimeAxisData *model in videosInAxis) {
        [videos addObject:model.extraData];
    }
    GosLog(@"daniel: 开始剪切跳转");
    _processClip = YES;
    if (_delegate && [_delegate respondsToSelector:@selector(pb_player:clipDidClick:deviceId:videos:startTimestamp:startTime:duration:)]) {
        [_delegate pb_player:self
                clipDidClick:sender
                    deviceId:deviceId
                      videos:videos
              startTimestamp:timestamp
                   startTime:startTime
                    duration:duration];
    }
}

/// 截图
- (void)control_handler:(PlaybackControlHandler *)handler snapshotDidClick:(UIButton *)sender {
    [self.playerHandler player_handler_snapshot];
}

/// 选择日期已经改变
- (void)control_handler:(PlaybackControlHandler *)handler calendarSelectedDateDidChanged:(NSDate *)date {
    _changedDate = YES;
    // TODO: 标记日期已经改变
    // 先清除时间轴数据
    [self.controlHandler control_handler_timeaxisUpdateWithZoomToMin];
    [self.controlHandler control_handler_timeAxisUpdateWithDataArray:nil];
    
    // 设定时间戳为date的零点
    NSTimeInterval dateStartTimestamp = [date nowadayStartTimestamp];
    [self.controlHandler control_handler_timeAxisUpdateCurrentTimestamp:dateStartTimestamp];
    
    
    if (_delegate && [_delegate respondsToSelector:@selector(pb_player:calendarSelectedDateDidChanged:)]) {
        [_delegate pb_player:self calendarSelectedDateDidChanged:date];
    }
}

/// 更新当前时间
- (void)control_handler:(PlaybackControlHandler *)handler didChangedTimeInterval:(NSTimeInterval)currentTimeInterval {
    // do something...
}

/// 更新放缩比例
- (void)control_handler:(PlaybackControlHandler *)handler didChangedScale:(CGFloat)currentScale {
    // do something...
}

/// 停止的位置可能存在数据
- (void)control_handler:(PlaybackControlHandler *)handler didEndedAtDataSection:(GosTimeAxisData *)aAxisData positionTimestamp:(NSTimeInterval)positionTimestamp {
    _processTimestamp = positionTimestamp;
    
    if (aAxisData) {
        
        NSUInteger seekTime = (NSUInteger)(positionTimestamp - aAxisData.startTimeInterval);
        // 预览图loading
        [self.controlHandler control_handler_maskUpdatePreviewWithImage:nil timestamp:GOS_TIME_STAMP_NULL isLoading:YES];
        // 获取预览图
        [self.playerHandler player_handler_fetchPreviewWithVideoModel:aAxisData.extraData
                                                               onTime:seekTime];
        
    } else {
        // 只是更新UI
        [self.controlHandler control_handler_maskUpdatePreviewWithImage:nil
                                                              timestamp:GOS_TIME_STAMP_NULL
                                                              isLoading:NO];
    }
}

/// 日历详情显示所需数据
- (void)control_handler:(PlaybackControlHandler *)handler calendarView:(GosCalendarView *)calendarView displayDetailViewInView:(UIView *__autoreleasing *)view frame:(CGRect *)frame {
    [_delegate pb_player:self
            calendarView:(UIView *)calendarView
 displayDetailViewInView:view
                   frame:frame];
}

/// 预览图点击播放
- (void)control_handler:(PlaybackControlHandler *)handler previewPlayDidClick:(UIButton *)sender startTimestamp:(NSTimeInterval)startTimestamp {
    // 预览图点击开始播放
    [self.controlHandler control_handler_maskUpdatePreviewWithImage:nil timestamp:GOS_TIME_STAMP_NULL isLoading:NO];
    // 查找数据
    GosTimeAxisData *data = [self.controlHandler control_handler_findDataForTimestamp:startTimestamp onlyInternal:YES];
    // 时间轴放到最大
    [self.controlHandler control_handler_timeAxisUpdateWithZoomToMax];
    // 加载中
    [self.controlHandler control_handler_controlUpdateState:PlaybackControlStateLoading];
    // 开始播放
    [self.playerHandler player_handler_startPlayWithVideoModel:data.extraData];
}

/// 查找下一个的数据
- (void)control_handler:(PlaybackControlHandler *)handler didSeekedNextDataSection:(GosTimeAxisData *)aAxisData fromTimestamp:(NSTimeInterval)fromTimestamp {
    if (aAxisData) {
        // 滚动中就不刷新时间轴
        if (!self.isProcessScrolling) {
            // 更新时间轴
            [self.controlHandler control_handler_timeAxisUpdateCurrentTimestamp:aAxisData.startTimeInterval];
        }
        
        // 加载ing
        [self.controlHandler control_handler_controlUpdateState:PlaybackControlStateLoading];
        // 播放
        [self.playerHandler player_handler_startPlayWithVideoModel:aAxisData.extraData];
        
    } else {
        // 理论上就是最后一个视频了
        [self.controlHandler control_handler_controlUpdateState:PlaybackControlStateDefault];
        
        [GosHUD showProcessHUDInfoWithStatus:@"CSP_LastVideoPlayed"];
    }
}

/// 时间轴开始滚动
- (void)control_handler:(PlaybackControlHandler *)handler timeAxisDidBeginScrolling:(GosTimeAxis *)timeAxis {
    // 标记正在滚动
    self.processScrolling = YES;
    // 延时取消标记
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(delayCancelScrollingProcess) object:nil];
    [self performSelector:@selector(delayCancelScrollingProcess) withObject:nil afterDelay:10];
}


#pragma mark - PlaybackOrientationHandlerDelegate
- (void)orientation_handler:(PlaybackOrientationHandler *)handler
             rotate180Angle:(CGFloat)angle
     shouldRefreshStatusBar:(void(^)(void))shouldRefreshStatusBar
                 completion:(void(^)(void))completion {
    // 全屏->全屏
    [UIView animateWithDuration:0.35
                     animations:^{
                         self.pb_playerViewProxy.transform = CGAffineTransformMakeRotation(angle);
                         
                         shouldRefreshStatusBar();
                     }
                     completion:^(BOOL finished) {
                         completion();
                     }];
}

- (void)orientation_handler:(PlaybackOrientationHandler *)handler
              rotate90Angle:(CGFloat)angle
     shouldRefreshStatusBar:(void(^)(void))shouldRefreshStatusBar
        shouldHideStatusBar:(void(^)(void))shouldHideStatusBar
                 completion:(void(^)(void))completion {
    // 竖屏->全屏
    // 记录竖屏时的数据
    _playerViewParentViewInPortrait = self.pb_playerViewProxy.superview;
    _playerViewFrameInPortrait = self.pb_playerViewProxy.frame;
    // 将playerView移至keyWindow上
    [self.pb_playerViewProxy removeFromSuperview];
    [[UIApplication sharedApplication].keyWindow addSubview:self.pb_playerViewProxy];
    
    // 全屏尺寸
    CGRect landscapeFrame = CGRectMake(0, 0, GOS_SCREEN_H, GOS_SCREEN_W);
    [self.playerHandler player_handler_resizePlayViewSize:landscapeFrame.size];
    self.pb_playerViewProxy.frame = landscapeFrame;
    
    // 执行动画
    [UIView animateWithDuration:0.35
                     animations:^{
                         
                         self.pb_playerViewProxy.transform = CGAffineTransformMakeRotation(angle);
                         self.pb_playerViewProxy.bounds    = CGRectMake(0, 0, MAX(GOS_SCREEN_W, GOS_SCREEN_H), MIN(GOS_SCREEN_W, GOS_SCREEN_H));
                         self.pb_playerViewProxy.center = CGPointMake(CGRectGetMidX([UIScreen mainScreen].bounds),
                                     CGRectGetMidY([UIScreen mainScreen].bounds));
                         shouldRefreshStatusBar();
                         shouldHideStatusBar();
                     }
                     completion:^(BOOL finished) {
                         completion();
                     }];
}

- (void)orientation_handler:(PlaybackOrientationHandler *)handler
rotateToPortraitFromLastOrientation:(UIDeviceOrientation)lastOrientation
     shouldRefreshStatusBar:(void(^)(void))shouldRefreshStatusBar
                 completion:(void(^)(void))completion {
    // 全屏->竖屏
    // 设置回竖屏尺寸
    [self.playerHandler player_handler_resizePlayViewSize:self.playerViewFrameInPortrait.size];
    
    // 执行动画
    [UIView animateWithDuration:0.35
                     animations:^{
                         self.pb_playerViewProxy.transform = CGAffineTransformIdentity;
                         self.pb_playerViewProxy.frame = self.playerViewFrameInPortrait;
                         // 将playerView移至竖屏状态的父类上
                         [self.pb_playerViewProxy removeFromSuperview];
                         self.pb_playerViewProxy.frame = self.playerViewFrameInPortrait;
                         [self.playerViewParentViewInPortrait addSubview:self.pb_playerViewProxy];
                         shouldRefreshStatusBar();
                         
                     }
                     completion:^(BOOL finished) {
                         [self.playerViewParentViewInPortrait insertSubview:self.pb_playerViewProxy belowSubview:self.pb_maskViewProxy];
                         completion();
                     }];
}


#pragma mark - getters and setters
- (PlaybackControlHandler *)controlHandler {
    if (!_controlHandler) {
        _controlHandler = [[PlaybackControlHandler alloc] init];
        _controlHandler.delegate = self;
        
        [_controlHandler control_handler_controlUpdateState:PlaybackControlStateDefault];
    }
    return _controlHandler;
}

- (PlaybackPlayerHandler *)playerHandler {
    if (!_playerHandler) {
        _playerHandler = [[PlaybackPlayerHandler alloc] initWithDeviceId:_deviceId];
        _playerHandler.delegate = self;
    }
    return _playerHandler;
}

- (PlaybackOrientationHandler *)orientationHandler {
    if (!_orientationHandler) {
        _orientationHandler = [[PlaybackOrientationHandler alloc] init];
        _orientationHandler.delegate = self;
    }
    return _orientationHandler;
}

- (UIView *)pb_playerViewProxy {
    return (UIView *)self.playerHandler.playerView;
}

- (UIView *)pb_basicViewProxy {
    return (UIView *)self.controlHandler.baseControl;
}

- (UIView *)pb_calenderViewProxy {
    return (UIView *)self.controlHandler.calendarView;
}

- (UIView *)pb_timeAxisViewProxy {
    return (UIView *)self.controlHandler.timeAxisControl;
}
- (UIView *)pb_maskViewProxy {
    return (UIView *)self.controlHandler.maskControl;
}

@end
