//  PlaybackControlHandler.m
//  GosIPCs
//
//  Create by daniel.hu on 2019/1/22.
//  Copyright © 2019年 goscam. All rights reserved.

#import "PlaybackControlHandler.h"
#import "PlaybackBaseControl.h"
#import "GosTimeAxis.h"
#import "GosCalendarView.h"
#import "PlaybackMaskControl.h"

@interface PlaybackControlHandler () <GosTimeAxisDelegate, GosCalendarViewDelegate>
/// 静音、剪切、截图
@property (nonatomic, readwrite, strong) PlaybackBaseControl *baseControl;
/// 日历
@property (nonatomic, readwrite, strong) GosCalendarView *calendarView;
/// 时间轴
@property (nonatomic, readwrite, strong) GosTimeAxis *timeAxisControl;
/// 遮罩
@property (nonatomic, readwrite, strong) PlaybackMaskControl *maskControl;
/// 显示状态
@property (nonatomic, assign) PlaybackControlState controlState;
/// 是否手动设置数据
@property (nonatomic, assign, getter=isManually) BOOL manually;
@end

@implementation PlaybackControlHandler

#pragma mark - public method
- (void)control_handler_seekNextDataFromTimestamp:(NSTimeInterval)fromTimestamp {
    [self.timeAxisControl seekNextDataFromTimestamp:fromTimestamp];
}

- (GosTimeAxisData *)control_handler_findDataForTimestamp:(NSTimeInterval)timestamp onlyInternal:(BOOL)onlyInternal {
    return [self.timeAxisControl findDataForTimestamp:timestamp onlyInternal:onlyInternal];
}

- (NSArray<GosTimeAxisData *> *)control_handler_findSerialDataForTimestamp:(NSTimeInterval)timestamp {
    return [self.timeAxisControl findSerialDataForTimestamp:timestamp];
}

- (void)control_handler_timeAxisUpdateWithZoomToMax {
    [self.timeAxisControl zoomToMax];
}

- (void)control_handler_timeaxisUpdateWithZoomToMin {
    [self.timeAxisControl zoomToMin];
}

/// 更新时间轴数据
- (void)control_handler_timeAxisUpdateWithDataArray:(NSArray <GosTimeAxisData *> *)dataArray {
    [self.timeAxisControl updateWithDataArray:dataArray];
}

/// 添加时间轴数据
- (void)control_handler_timeAxisAppendWithDataArray:(NSArray <GosTimeAxisData *> *)dataArray {
    [self.timeAxisControl appendWithDataArray:dataArray];
}

/// 更新事件数组
- (void)control_handler_calenderUpdateWithEventsArray:(NSArray <NSDate *> *)events {
    [self.calendarView updateEventsArray:events];
}

/// 更新日历显示时间
- (void)control_handler_calenderUpdateWithDisplayDate:(NSDate *)date {
    [self.calendarView updateDisplayDate:date];
}

/// 更新预览图视图
- (void)control_handler_maskUpdatePreviewWithImage:(UIImage *_Nullable)image
                                         timestamp:(NSTimeInterval)timestamp
                                         isLoading:(BOOL)isLoading {
    GOS_WEAK_SELF
    dispatch_async(dispatch_get_main_queue(), ^{
        GOS_STRONG_SELF
        
        if (!isLoading && !image) {
            // 隐藏预览视图
            strongSelf.maskControl.extraState = PlaybackMaskControlExtraStateDefault;
        } else if (!isLoading && image) {
            // 设置播放状态
            strongSelf.maskControl.extraState = PlaybackMaskControlExtraStatePreviewPlay;
            strongSelf.maskControl.previewImage = image;
            strongSelf.maskControl.previewTimestamp = timestamp;
        } else if (isLoading) {
            // 加载状态
            strongSelf.maskControl.extraState = PlaybackMaskControlExtraStatePreviewLoading;
        }
    });
}

- (void)control_handler_controlUpdateState:(PlaybackControlState)state {
    GOS_WEAK_SELF
    dispatch_async(dispatch_get_main_queue(), ^{
        GOS_STRONG_SELF
        strongSelf.controlState = state;
        GosLog(@"daniel: controlState: %zd", state);
    });
}

- (void)control_handler_timeAxisUpdateCurrentTimestamp:(NSTimeInterval)currentTimestamp {
    _manually = YES;
    GOS_WEAK_SELF
    dispatch_async(dispatch_get_main_queue(), ^{
        GOS_STRONG_SELF
        [strongSelf.timeAxisControl updateWithCurrentTimeInterval:currentTimestamp];
    });
}

#pragma mark - GosTimeAxisDelegate

- (void)timeAxis:(GosTimeAxis *)timeAxis didChangedScale:(CGFloat)currentScale {
    if (_delegate && [_delegate respondsToSelector:@selector(control_handler:didChangedScale:)]) {
        [_delegate control_handler:self didChangedScale:currentScale];
    }
}

- (void)timeAxis:(GosTimeAxis *)timeAxis didChangedTimeInterval:(NSTimeInterval)currentTimeInterval {
    if (_delegate && [_delegate respondsToSelector:@selector(control_handler:didChangedTimeInterval:)]) {
        [_delegate control_handler:self didChangedTimeInterval:currentTimeInterval];
    }
}

- (void)timeAxis:(GosTimeAxis *)timeAxis didEndedAtDataSection:(GosTimeAxisData *)aAxisData positionTimestamp:(NSTimeInterval)positionTimestamp {
    if (_delegate && [_delegate respondsToSelector:@selector(control_handler:didEndedAtDataSection:positionTimestamp:)] && !self.isManually) {
        [_delegate control_handler:self didEndedAtDataSection:aAxisData positionTimestamp:positionTimestamp];
    }
}

- (void)timeAxis:(GosTimeAxis *)timeAxis didEndedAtPostionWithoutData:(NSTimeInterval)positionTimestamp {
    if (_delegate && [_delegate respondsToSelector:@selector(control_handler:didEndedAtDataSection:positionTimestamp:)] && !self.isManually) {
        [_delegate control_handler:self didEndedAtDataSection:nil positionTimestamp:positionTimestamp];
    }
}

- (void)timeAxis:(GosTimeAxis *)timeAxis didSeekedNextDataSection:(GosTimeAxisData *)aAxisData fromPositionTimestamp:(NSTimeInterval)positionTimestamp {
    if (_delegate && [_delegate respondsToSelector:@selector(control_handler:didSeekedNextDataSection:fromTimestamp:)]) {
        [_delegate control_handler:self didSeekedNextDataSection:aAxisData fromTimestamp:positionTimestamp];
    }
}

- (void)timeAxis:(GosTimeAxis *)timeAxis didNotSeekNextDataFromPositionTimestamp:(NSTimeInterval)positionTimestamp {
    if (_delegate && [_delegate respondsToSelector:@selector(control_handler:didSeekedNextDataSection:fromTimestamp:)]) {
        [_delegate control_handler:self didSeekedNextDataSection:nil fromTimestamp:positionTimestamp];
    }
}

- (void)timeAxisDidBeginScrolling:(GosTimeAxis *)timeAxis {
    self.manually = NO;
    if (_delegate && [_delegate respondsToSelector:@selector(control_handler:timeAxisDidBeginScrolling:)]) {
        [_delegate control_handler:self timeAxisDidBeginScrolling:timeAxis];
    }
}

//- (void)timeAxisDidEndScrolling:(GosTimeAxis *)timeAxis {
//    if (_delegate && [_delegate respondsToSelector:@selector(control_handler:timeAxisDidEndScrolling:)]) {
//        [_delegate control_handler:self timeAxisDidEndScrolling:timeAxis];
//    }
//}

//- (void)timeAxisDidBeginPinching:(GosTimeAxis *)timeAxis {
//    if (_delegate && [_delegate respondsToSelector:@selector(control_handler:timeAxisDidBeginPinching:)]) {
//        [_delegate control_handler:self timeAxisDidBeginPinching:timeAxis];
//    }
//}

//- (void)timeAxisDidEndPinching:(GosTimeAxis *)timeAxis {
//    if (_delegate && [_delegate respondsToSelector:@selector(control_handler:timeAxisDidEndPinching:)]) {
//        [_delegate control_handler:self timeAxisDidEndPinching:timeAxis];
//    }
//}


#pragma mark - GosCalendarViewDelegate
- (void)calendarView:(GosCalendarView *)calendarView selectedDateDidChanged:(NSDate *)selectedDate hasEvent:(BOOL)hasEvent {
    // 选择日期更改
    if (_delegate && [_delegate respondsToSelector:@selector(control_handler:calendarSelectedDateDidChanged:)]) {
        [_delegate control_handler:self calendarSelectedDateDidChanged:selectedDate];
    }
}

- (void)calendarView:(GosCalendarView *)calendarView displayDateDidChanged:(NSDate *)currentDate {
    // 显示的日期更改了
    if (_delegate && [_delegate respondsToSelector:@selector(control_handler:calendarSelectedDateDidChanged:)]) {
        [_delegate control_handler:self calendarSelectedDateDidChanged:currentDate];
    }
}

- (void)calendarView:(GosCalendarView *)calendarView displayDetailViewInView:(UIView *__autoreleasing *)view frame:(CGRect *)frame {
    if (_delegate && [_delegate respondsToSelector:@selector(control_handler:calendarView:displayDetailViewInView:frame:)]) {
        [_delegate control_handler:self
                      calendarView:calendarView
           displayDetailViewInView:view
                             frame:frame];
    }
}

#pragma mark - base control event response
- (void)muteDidClick:(id)sender {
    if (_delegate && [_delegate respondsToSelector:@selector(control_handler:muteDidClick:)]) {
        [_delegate control_handler:self muteDidClick:sender];
    }
}

- (void)snapshotDidClick:(id)sender {
    if (_delegate && [_delegate respondsToSelector:@selector(control_handler:snapshotDidClick:)]) {
        [_delegate control_handler:self snapshotDidClick:sender];
    }
}

- (void)cutDidClick:(id)sender {
    if (_delegate && [_delegate respondsToSelector:@selector(control_handler:cutDidClick:)]) {
        [_delegate control_handler:self cutDidClick:sender];
    }
}

- (void)previewPlayDidClick:(id)sender {
    if (_delegate && [_delegate respondsToSelector:@selector(control_handler:previewPlayDidClick:startTimestamp:)]) {
        [_delegate control_handler:self
               previewPlayDidClick:sender
                    startTimestamp:self.maskControl.previewTimestamp];
    }
}

#pragma mark - getters and setters
- (PlaybackBaseControl *)baseControl {
    if (!_baseControl) {
        _baseControl = [[PlaybackBaseControl alloc] init];
        
        [_baseControl.leftButton addTarget:self
                                    action:@selector(muteDidClick:)
                          forControlEvents:UIControlEventTouchUpInside];
        [_baseControl.rightButton addTarget:self
                                     action:@selector(snapshotDidClick:)
                           forControlEvents:UIControlEventTouchUpInside];
        [_baseControl.centerButton addTarget:self
                                      action:@selector(cutDidClick:)
                            forControlEvents:UIControlEventTouchUpInside];
        
    }
    return _baseControl;
}

- (GosTimeAxis *)timeAxisControl {
    if (!_timeAxisControl) {
        _timeAxisControl = [[GosTimeAxis alloc] initWithFrame:CGRectZero];
        _timeAxisControl.delegate = self;
    }
    return _timeAxisControl;
}

- (GosCalendarView *)calendarView {
    if (!_calendarView) {
        _calendarView = [[GosCalendarView alloc] init];
        _calendarView.delegate = self;
    }
    return _calendarView;
}

- (PlaybackMaskControl *)maskControl {
    if (!_maskControl) {
        _maskControl = [[PlaybackMaskControl alloc] init];
        [_maskControl.previewPlayButton addTarget:self action:@selector(previewPlayDidClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _maskControl;
}

- (void)setControlState:(PlaybackControlState)controlState {
    _controlState = controlState;
    
    switch (controlState) {
        case PlaybackControlStateDefault:
            self.maskControl.mainState = PlaybackMaskControlMainStateDefault;
            self.baseControl.centerButton.enabled = NO;
            self.baseControl.rightButton.enabled = NO;
            break;
        case PlaybackControlStatePlaying:
            self.maskControl.mainState = PlaybackMaskControlMainStateDefault;
            self.baseControl.centerButton.enabled = YES;
            self.baseControl.rightButton.enabled = YES;
            break;
        case PlaybackControlStateCutting:
            self.maskControl.mainState = PlaybackMaskControlMainStateDefault;
            self.baseControl.centerButton.enabled = YES;
            self.baseControl.rightButton.enabled = NO;
            break;
        case PlaybackControlStateLoading:
            self.baseControl.centerButton.enabled = NO;
            self.baseControl.rightButton.enabled = NO;
            self.maskControl.mainState = PlaybackMaskControlMainStateLoading;
            break;
        case PlaybackControlStateDevOffline:
            self.baseControl.centerButton.enabled = NO;
            self.baseControl.rightButton.enabled = NO;
            // 中间显示：设备已离线
            self.maskControl.centerDetailString = DPLocalizedString(@"Setting_DeviceOffLine");
            self.maskControl.mainState = PlaybackMaskControlMainStateShowingState;
            break;
        case PlaybackControlStateBuffing:
            self.baseControl.centerButton.enabled = YES;
            self.baseControl.rightButton.enabled = YES;
            self.maskControl.mainState = PlaybackMaskControlMainStateLoading;
            break;
        default:
            break;
    }
}

@end
