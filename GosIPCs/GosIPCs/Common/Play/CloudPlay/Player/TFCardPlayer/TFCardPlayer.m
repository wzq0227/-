//  TFCardPlayer.m
//  GosIPCs
//
//  Create by daniel.hu on 2019/2/19.
//  Copyright © 2019年 goscam. All rights reserved.

#import "TFCardPlayer.h"
#import "PlaybackControlHandler.h"
#import "TFCardPlayerHandler.h"
#import "PlaybackOrientationHandler.h"
#import "GosTimeAxisData.h"
#import "NSDate+GosDateExtension.h"
#import "GosPhotoHelper.h"

@interface TFCardPlayer () <PlaybackControlHandlerDelegate, TFCardPlayerHandlerDelegate, PlaybackOrientationHandlerDelegate>
#pragma mark - handler
/// 控制 控制者
@property (nonatomic, strong) PlaybackControlHandler *controlHandler;
/// 播放 控制者
@property (nonatomic, strong) TFCardPlayerHandler *playerHandler;
/// 旋转 控制者
@property (nonatomic, strong) PlaybackOrientationHandler *orientationHandler;

#pragma mark - signal parameters
/// 处理的时间戳
@property (nonatomic, assign) NSTimeInterval processTimestamp;
/// 正在播放的时间戳
@property (nonatomic, assign) NSTimeInterval processPlayingTimestamp;
/// 是否正在处理滚动
@property (nonatomic, assign, getter=isProcessScrolling) BOOL processScrolling;
/// 是否更改日期
@property (nonatomic, assign, getter=isChangedDate) BOOL changedDate;

#pragma mark - orientation parameters
/// 播放视图 竖屏时的布局
@property (nonatomic, assign) CGRect playerViewFrameInPortrait;
/// 播放视图 竖屏时的父视图
@property (nonatomic, weak) UIView *playerViewParentViewInPortrait;

#pragma mark - other parameters
/// 设备id
@property (nonatomic, copy) NSString *deviceId;

@end

@implementation TFCardPlayer
#pragma mark - initialization
- (instancetype)initWithDeviceId:(NSString *)deviceId {
    if (self = [super init]) {
        _deviceId = deviceId;
        
        _processPlayingTimestamp = 0;
        _processTimestamp = [[NSDate date] timeIntervalSince1970];
        _processScrolling = NO;
        _changedDate = NO;
        
        [self orientationHandler];
    }
    return self;
}


#pragma mark - public method
- (void)tf_player_startPlayWithStartTimestamp:(NSTimeInterval)startTimestamp {
    // 查找数据
    GosTimeAxisData *data = [self.controlHandler control_handler_findDataForTimestamp:startTimestamp onlyInternal:NO];
    NSTimeInterval playStartTimestamp = data ? data.startTimeInterval : startTimestamp;
    
    // 加载ing
    [self.controlHandler control_handler_controlUpdateState:PlaybackControlStateLoading];
    // 开始播放
    [self.playerHandler player_handler_startPlayWithStartTimestamp:playStartTimestamp];
}

- (void)tf_player_startClipWithFileName:(NSString *)fileName
                         startTimestamp:(NSTimeInterval)startTimestamp
                               duration:(NSUInteger)duration {
    [self.playerHandler player_handler_startClipWithFileName:fileName
                                              startTimestamp:startTimestamp
                                                    duration:duration];
}

- (void)tf_player_updateTimeAxisWithDataArray:(NSArray *)dataArray {
    _changedDate = NO;
    [self.controlHandler control_handler_timeAxisUpdateWithDataArray:dataArray];
}

- (void)tf_player_appendTimeAxisDataArray:(NSArray *)dataArray {
    [self.controlHandler control_handler_timeAxisAppendWithDataArray:dataArray];
}

- (void)tf_player_updateCalenderWithEventsArray:(NSArray <NSDate *> *)events {
    [self.controlHandler control_handler_calenderUpdateWithEventsArray:events];
}

- (void)tf_player_updateWithCurrentTimestamp:(NSTimeInterval)currentTimestamp {
    [self.controlHandler control_handler_timeAxisUpdateCurrentTimestamp:currentTimestamp];
    [self.controlHandler control_handler_calenderUpdateWithDisplayDate:[NSDate dateWithTimeIntervalSince1970:currentTimestamp]];
}

- (void)tf_player_resizeWithOrientation:(UIDeviceOrientation)orientation {
    if (UIDeviceOrientationLandscapeLeft == orientation
        || UIDeviceOrientationLandscapeRight == orientation) {
        // 横屏
        [self.playerHandler player_handler_resizePlayViewSize:CGSizeMake(GOS_SCREEN_H, GOS_SCREEN_W)];
    } else {
        // 竖屏
        [self.playerHandler player_handler_resizePlayViewSize:CGSizeMake(GOS_SCREEN_W, GOS_SCREEN_W * GOS_VIDEO_H_W_SCALE)];
    }
}

- (void)tf_player_initialPlayer {
    _processScrolling = NO;
    _changedDate = NO;
    
    [self.playerHandler player_handler_initialPlayer];
}

- (void)tf_player_destoryPlayer {
    [self.playerHandler player_handler_destoryPlayer];
}


#pragma mark - private method
- (void)delayCancelScrollingProcess {
    _processScrolling = NO;
}


#pragma mark - TFCardPlayerHandlerDelegate
/// 设备在线状态、连接状态改变
- (void)player_handler:(TFCardPlayerHandler *)handler didChangedDeviceStateAndConnectState:(TFPHDeviceStateAndConnectState)deviceStateAndConnectState {
    if (deviceStateAndConnectState == TFPHDeviceStateAndConnectStateNotOnline) {
        // 非连接状态 显示离线
        [self.controlHandler control_handler_controlUpdateState:PlaybackControlStateDevOffline];
    } else if (deviceStateAndConnectState == TFPHDeviceStateAndConnectStateOnlineAndConnected) {
        // 在线并连接成功 啥都不显示
        [self.controlHandler control_handler_controlUpdateState:PlaybackControlStateDefault];
    } else {
        // 其他情况就loading
        [self.controlHandler control_handler_controlUpdateState:PlaybackControlStateLoading];
    }
}

/// 获取预览图成功
- (void)player_handler:(TFCardPlayerHandler *)handler didSucceedFetchedPreviewImage:(UIImage *)previewImage startTimestamp:(NSTimeInterval)startTimestamp {
    // 非当前处理时间就不给视频
    if (_processTimestamp == startTimestamp) {
        // 显示可播放的预览图
        [self.controlHandler control_handler_maskUpdatePreviewWithImage:previewImage timestamp:startTimestamp isLoading:NO];
    }
}

/// 获取预览图失败
- (void)player_handler:(TFCardPlayerHandler *)handler didFailedFetchedPreviewImageFromImageFilePath:(NSString *)imageFilePath startTimestamp:(NSTimeInterval)startTimestamp {
    GosLog(@"预览图加载失败");
#ifdef DEBUG
    [GosHUD showProcessHUDErrorWithStatus:@"预览图加载失败"];
#endif
    // 没有获取到预览图，就取消预览图的显示
    [self.controlHandler control_handler_maskUpdatePreviewWithImage:nil timestamp:GOS_TIME_STAMP_NULL isLoading:NO];
}

/// 截图成功
- (void)player_handler:(TFCardPlayerHandler *)handler didSucceedSnapshotWithImageFilePath:(NSString *)imageFilePath {
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

/// 截图失败
- (void)player_handler:(TFCardPlayerHandler *)handler didFailedSnapshotWithImageFilePath:(NSString *)imageFilePath {
    // 截图成功
    [GosHUD showProcessHUDErrorWithStatus:@"photo_SaveToSystemFail"];
}

/// 播放失败
- (void)player_handler:(TFCardPlayerHandler *)handler didFailedPlayAtStartTimestamp:(NSTimeInterval)startTimestamp {
    GosLog(@"播放失败");
}

/// 开始播放
- (void)player_handler:(TFCardPlayerHandler *)handler didStartPlayAtStartTimestamp:(NSTimeInterval)startTimestamp {
    // 播放状态
    [self.controlHandler control_handler_controlUpdateState:PlaybackControlStatePlaying];
}

/// 播放中
- (void)player_handler:(TFCardPlayerHandler *)handler didPlayingAtTimestamp:(NSTimeInterval)playingTimestamp startTimestamp:(NSTimeInterval)startTimestamp {
    
    _processPlayingTimestamp = playingTimestamp;
    
    // 更改日期时不操作
    if (self.changedDate) return ;
    // 开始滚动就取消操作
    if (self.isProcessScrolling) return ;
    
    // 更新时间轴
    [self.controlHandler control_handler_timeAxisUpdateCurrentTimestamp:playingTimestamp];
    // 更新日历显示
    [self.controlHandler control_handler_calenderUpdateWithDisplayDate:[NSDate dateWithTimeIntervalSince1970:playingTimestamp]];
}

/// 结束播放
- (void)player_handler:(TFCardPlayerHandler *)handler didEndedPlayAtStartTimestamp:(NSTimeInterval)startTimestamp {
    GosLog(@"daniel: 结束播放");
    // 这时候是没有的数据的
    [self.controlHandler control_handler_controlUpdateState:PlaybackControlStateDefault];
}

/// 播放缓存中
- (void)player_handler:(TFCardPlayerHandler *)handler playStartLoadingAtStartTimestamp:(NSTimeInterval)startTimestamp {
    [self.controlHandler control_handler_controlUpdateState:PlaybackControlStateBuffing];
}

/// 播放结束缓存
- (void)player_handler:(TFCardPlayerHandler *)handler playEndedLoadingAtStartTimestamp:(NSTimeInterval)startTimestamp {
    [self.controlHandler control_handler_controlUpdateState:PlaybackControlStatePlaying];
}

/// 剪切成功
- (void)player_handler:(TFCardPlayerHandler *)handler didSucceedClipAtVideoFilePath:(NSString *)videoFilePath startTimestamp:(NSTimeInterval)startTimestamp duration:(NSUInteger)duration {
    if (_delegate && [_delegate respondsToSelector:@selector(tf_player:didSucceedClipAtVideoFilePath:startTimestamp:duration:)]) {
        [_delegate tf_player:self didSucceedClipAtVideoFilePath:videoFilePath startTimestamp:startTimestamp duration:duration];
    }
}

/// 剪切失败
- (void)player_handler:(TFCardPlayerHandler *)handler didFailedClipAtVideoFilePath:(NSString *)videoFilePath startTimestamp:(NSTimeInterval)startTimestamp duration:(NSUInteger)duration {
    if (_delegate && [_delegate respondsToSelector:@selector(tf_player:didFailedClipAtVideoFilePath:startTimestamp:duration:)]) {
        [_delegate tf_player:self didFailedClipAtVideoFilePath:videoFilePath startTimestamp:startTimestamp duration:duration];
    }
}


#pragma mark - PlaybackControlHandlerDelegate
/// 静音反馈(Normal关闭声音，Select打开声音)
- (void)control_handler:(PlaybackControlHandler *)handler muteDidClick:(UIButton *)sender {
    GOS_WEAK_SELF
    dispatch_async(dispatch_get_main_queue(), ^{
        GOS_STRONG_SELF
        sender.selected = !sender.isSelected;
        
        if (sender.isSelected) {
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
    NSTimeInterval startTimeStamp = _processPlayingTimestamp;
    // 理论上肯定找的到，但是一旦找不到，就使用获取时间戳的
    GosTimeAxisData *currentDealData = [handler control_handler_findDataForTimestamp:startTimeStamp onlyInternal:YES];
    if (!currentDealData) {
        GosLog(@"时间戳%.0f下未能找到数据", startTimeStamp);
        return ;
    }
    // 剪切时长
    NSUInteger duration = (NSUInteger)ABS(currentDealData.endTimeInterval - startTimeStamp);
    NSString *deviceId = _deviceId;
    // 发出代理
    if (_delegate && [_delegate respondsToSelector:@selector(tf_player:clipDidClick:deviceId:startTimestamp:duration:)]) {
        [_delegate tf_player:self
                clipDidClick:sender
                    deviceId:deviceId
              startTimestamp:startTimeStamp
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
    // 先清除时间轴数据
    [self.controlHandler control_handler_timeaxisUpdateWithZoomToMin];
    [self.controlHandler control_handler_timeAxisUpdateWithDataArray:nil];
    
    // 设定时间戳为date的零点
    NSTimeInterval dateStartTimestamp = [date nowadayStartTimestamp];
    [self.controlHandler control_handler_timeAxisUpdateCurrentTimestamp:dateStartTimestamp];
    
    
    if (_delegate && [_delegate respondsToSelector:@selector(tf_player:calendarSelectedDateDidChanged:)]) {
        [_delegate tf_player:self calendarSelectedDateDidChanged:date];
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
    // 记录处理的时间戳
    _processTimestamp = positionTimestamp;
    
    if (aAxisData) {
        // 预览图loading
        [self.controlHandler control_handler_maskUpdatePreviewWithImage:nil timestamp:GOS_TIME_STAMP_NULL isLoading:YES];
        // 获取预览图
        [self.playerHandler player_handler_fetchPreviewAtTimestamp:positionTimestamp];
        
    } else {
        // 没有数据
        // 隐藏预览图
        [self.controlHandler control_handler_maskUpdatePreviewWithImage:nil timestamp:GOS_TIME_STAMP_NULL isLoading:NO];
    }
}

/// 获取详细日历显示时 需要的数据
- (void)control_handler:(PlaybackControlHandler *)handler calendarView:(GosCalendarView *)calendarView displayDetailViewInView:(UIView *__autoreleasing *)view frame:(CGRect *)frame {
    if (_delegate && [_delegate respondsToSelector:@selector(tf_player:calendarView:displayDetailViewInView:frame:)]) {
        [_delegate tf_player:self calendarView:(UIView *)calendarView displayDetailViewInView:view frame:frame];
    }
}

/// 预览图的播放按钮点击响应
- (void)control_handler:(PlaybackControlHandler *)handler previewPlayDidClick:(UIButton *)sender startTimestamp:(NSTimeInterval)startTimestamp {
    // 预览图点击开始播放，去除预览图
    [self.controlHandler control_handler_maskUpdatePreviewWithImage:nil timestamp:GOS_TIME_STAMP_NULL isLoading:NO];
    // 时间轴放到最大
    [self.controlHandler control_handler_timeAxisUpdateWithZoomToMax];
    // 加载
    [self.controlHandler control_handler_controlUpdateState:PlaybackControlStateLoading];
    // 开始播放
    [self.playerHandler player_handler_startPlayWithStartTimestamp:startTimestamp];
}

/// 查找下一个的数据
- (void)control_handler:(PlaybackControlHandler *)handler didSeekedNextDataSection:(GosTimeAxisData *)aAxisData fromTimestamp:(NSTimeInterval)fromTimestamp {
    if (aAxisData) {
        // 加载
        [self.controlHandler control_handler_controlUpdateState:PlaybackControlStateLoading];
        // 播放
        [self.playerHandler player_handler_startPlayWithStartTimestamp:aAxisData.startTimeInterval];

    } else {
        // 未找到怎么办
        [self.controlHandler control_handler_controlUpdateState:PlaybackControlStateDefault];
    }
}

/// 时间轴开始滑动
- (void)control_handler:(PlaybackControlHandler *)handler timeAxisDidBeginScrolling:(GosTimeAxis *)timeAxis {
    // 标记正在滚动
    _processScrolling = YES;
    // 延迟取消标记
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
                         self.tf_playerViewProxy.transform = CGAffineTransformMakeRotation(angle);
                         
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
    _playerViewParentViewInPortrait = self.tf_playerViewProxy.superview;
    _playerViewFrameInPortrait = self.tf_playerViewProxy.frame;
    // 将playerView移至keyWindow上
    [self.tf_playerViewProxy removeFromSuperview];
    [[UIApplication sharedApplication].keyWindow addSubview:self.tf_playerViewProxy];
    
    // 全屏尺寸
    CGRect landscapeFrame = CGRectMake(0, 0, GOS_SCREEN_H, GOS_SCREEN_W);
    [self.playerHandler player_handler_resizePlayViewSize:landscapeFrame.size];
    self.tf_playerViewProxy.frame = landscapeFrame;
    
    // 执行动画
    [UIView animateWithDuration:0.35
                     animations:^{
                         
                         self.tf_playerViewProxy.transform = CGAffineTransformMakeRotation(angle);
                         self.tf_playerViewProxy.bounds    = CGRectMake(0, 0, MAX(GOS_SCREEN_W, GOS_SCREEN_H), MIN(GOS_SCREEN_W, GOS_SCREEN_H));
                         self.tf_playerViewProxy.center = CGPointMake(CGRectGetMidX([UIScreen mainScreen].bounds),
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
                         self.tf_playerViewProxy.transform = CGAffineTransformIdentity;
                         self.tf_playerViewProxy.frame = self.playerViewFrameInPortrait;
                         // 将playerView移至竖屏状态的父类上
                         [self.tf_playerViewProxy removeFromSuperview];
                         self.tf_playerViewProxy.frame = self.playerViewFrameInPortrait;
                         [self.playerViewParentViewInPortrait addSubview:self.tf_playerViewProxy];
                         shouldRefreshStatusBar();
                         
                     }
                     completion:^(BOOL finished) {
                         [self.playerViewParentViewInPortrait insertSubview:self.tf_playerViewProxy belowSubview:self.tf_maskViewProxy];
                         completion();
                     }];
}



#pragma mark - getters and setters
- (PlaybackControlHandler *)controlHandler {
    if (!_controlHandler) {
        _controlHandler = [[PlaybackControlHandler alloc] init];
        _controlHandler.delegate = self;
    }
    return _controlHandler;
}

- (TFCardPlayerHandler *)playerHandler {
    if (!_playerHandler) {
        _playerHandler = [[TFCardPlayerHandler alloc] initWithDeviceId:_deviceId];
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

- (UIView *)tf_playerViewProxy {
    return (UIView *)self.playerHandler.playerView;
}

- (UIView *)tf_basicViewProxy {
    return (UIView *)self.controlHandler.baseControl;
}

- (UIView *)tf_calenderViewProxy {
    return (UIView *)self.controlHandler.calendarView;
}

- (UIView *)tf_timeAxisViewProxy {
    return (UIView *)self.controlHandler.timeAxisControl;
}
- (UIView *)tf_maskViewProxy {
    return (UIView *)self.controlHandler.maskControl;
}

@end
