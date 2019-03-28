//  PlaybackOrientationHandler.m
//  Goscom
//
//  Create by daniel.hu on 2019/2/18.
//  Copyright © 2019年 goscam. All rights reserved.

#import "PlaybackOrientationHandler.h"

@interface PlaybackOrientationHandler ()
/// 上一次屏幕方向
@property (nonatomic, assign) UIDeviceOrientation lastOrientation;

@end

@implementation PlaybackOrientationHandler
- (instancetype)init {
    if (self = [super init]) {
        
        _lastOrientation = [[UIDevice currentDevice] orientation];
        _fullScreen = NO;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationDidChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - 转屏通知响应
- (void)deviceOrientationDidChange:(NSNotification *)sender {
    // 判断是否能自动旋转
    if (_delegate && [_delegate respondsToSelector:@selector(orientation_handler_shouldAutoRotate:)]) {
        if (![_delegate orientation_handler_shouldAutoRotate:self])
            return ;
    }
    
    UIDeviceOrientation currentOrientation = [[UIDevice currentDevice] orientation];
    
    switch (currentOrientation) {
            
        case UIDeviceOrientationPortrait:       // 竖屏
            [self exitFullscreen];
            break;
            
        case UIDeviceOrientationLandscapeLeft: { // 横屏向左
        
            if (UIDeviceOrientationLandscapeRight == self.lastOrientation) {
                // 180 旋转
                [self rotateSemicircleToOrientation:UIDeviceOrientationLandscapeLeft
                                      transforAngle:M_PI_2];
            } else {
                // 90 旋转
                [self enterFullscreenOnOrientation:UIDeviceOrientationLandscapeLeft
                                     transforAngle:M_PI_2];
            }
            
            break;
        }
            
        case UIDeviceOrientationLandscapeRight: { // 横屏向右
        
            if (UIDeviceOrientationLandscapeLeft == _lastOrientation) {
                // 180 旋转
                [self rotateSemicircleToOrientation:UIDeviceOrientationLandscapeRight
                                      transforAngle:-M_PI_2];
            } else {
                // 90 旋转
                [self enterFullscreenOnOrientation:UIDeviceOrientationLandscapeRight
                                     transforAngle:-M_PI_2];
            }
            
            break;
        }

        case UIDeviceOrientationUnknown:
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            break;
        case UIDeviceOrientationFaceUp:
            break;
        case UIDeviceOrientationFaceDown:
            break;
            
        default:
            break;
    }
}


#pragma mark - private method
#pragma mark -- 全屏旋转
- (void)rotateSemicircleToOrientation:(UIDeviceOrientation)devOrientation
                        transforAngle:(CGFloat)angle {
    if (UIDeviceOrientationPortrait == self.lastOrientation
        || UIDeviceOrientationPortraitUpsideDown == self.lastOrientation
        || UIDeviceOrientationFaceUp == self.lastOrientation
        || UIDeviceOrientationFaceDown == self.lastOrientation
        || UIDeviceOrientationPortrait == devOrientation
        || UIDeviceOrientationPortraitUpsideDown == devOrientation
        || UIDeviceOrientationFaceUp == devOrientation
        || UIDeviceOrientationFaceDown == devOrientation) {
        
        self.lastOrientation = devOrientation;
        GosLog(@"当前 iOS 设备不是横屏方向，不全屏旋转！");
        return;
    }
    
    // 非大屏不处理
    if (!self.isFullScreen) { return; }
    
    if (_delegate && [_delegate respondsToSelector:@selector(orientation_handler:rotate180Angle:shouldRefreshStatusBar:completion:)]) {
        GOS_WEAK_SELF
        [_delegate orientation_handler:self rotate180Angle:angle shouldRefreshStatusBar:^{
            GOS_STRONG_SELF
            [strongSelf refreshStatusBarToOrientation:(UIInterfaceOrientation)devOrientation];
        } completion:^{
            GOS_STRONG_SELF
            strongSelf.lastOrientation = devOrientation;
            strongSelf.fullScreen = YES;
        }];
    } else {
        
//        [self refreshStatusBarToOrientation:(UIInterfaceOrientation)devOrientation];
        self.fullScreen = YES;
        self.lastOrientation = devOrientation;
    }
    
}

#pragma mark -- 进入全屏(由竖屏——>横屏时调用)
- (void)enterFullscreenOnOrientation:(UIDeviceOrientation)devOrientation
                       transforAngle:(CGFloat)angle {
    if (UIDeviceOrientationLandscapeLeft == self.lastOrientation
        || UIDeviceOrientationLandscapeRight == self.lastOrientation
        || UIDeviceOrientationPortrait == devOrientation
        || UIDeviceOrientationPortraitUpsideDown == devOrientation
        || UIDeviceOrientationFaceUp == devOrientation
        || UIDeviceOrientationFaceDown == devOrientation) {
        
        self.lastOrientation = devOrientation;
        GosLog(@"当前 iOS 设备不是横屏方向，不进入全屏模式！");
        return;
    }
    
    // 非小屏不处理
    if (self.isFullScreen) { return ; }
    
    if (_delegate && [_delegate respondsToSelector:@selector(orientation_handler:rotate90Angle:shouldRefreshStatusBar:shouldHideStatusBar:completion:)]) {
        GOS_WEAK_SELF
        [_delegate orientation_handler:self rotate90Angle:angle shouldRefreshStatusBar:^{
            GOS_STRONG_SELF
            [strongSelf refreshStatusBarToOrientation:(UIInterfaceOrientation)devOrientation];
        } shouldHideStatusBar:^{
            GOS_STRONG_SELF
            [strongSelf hiddenStatusBar];
        } completion:^{
            GOS_STRONG_SELF
            strongSelf.fullScreen = YES;
            strongSelf.lastOrientation = devOrientation;
        }];
        
    } else {
        
//        [self refreshStatusBarToOrientation:(UIInterfaceOrientation)devOrientation];
//        [self hiddenStatusBar];
        self.fullScreen = YES;
        self.lastOrientation = devOrientation;
    }
    
}


#pragma mark -- 退出全屏
- (void)exitFullscreen {
    // 非大屏不处理
    if (!self.isFullScreen) { return; }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(orientation_handler:rotateToPortraitFromLastOrientation:shouldRefreshStatusBar:completion:)]) {
        GOS_WEAK_SELF
        [self.delegate orientation_handler:self rotateToPortraitFromLastOrientation:self.lastOrientation shouldRefreshStatusBar:^{
            GOS_STRONG_SELF
            [strongSelf showStatusBar];
        } completion:^{
            GOS_STRONG_SELF
            strongSelf.fullScreen = NO;
            strongSelf.lastOrientation = UIDeviceOrientationPortrait;
        }];
        
    } else {
        
        [self showStatusBar];
        self.fullScreen = NO;
        self.lastOrientation = UIDeviceOrientationPortrait;
    }
}


#pragma mark - 状态栏位置
- (void)refreshStatusBarToOrientation:(UIInterfaceOrientation)interfaceOrientation {
    [[UIApplication sharedApplication] setStatusBarOrientation:interfaceOrientation
                                                      animated:YES];
}

/*
 在Info.plist中，添加属性 View controller-based status bar appearance，设置为 NO
 下面的方法才有效果
 */
- (void)hiddenStatusBar {
    [[UIApplication sharedApplication] setStatusBarHidden:YES
                                            withAnimation:UIStatusBarAnimationNone];
}

- (void)showStatusBar {
    [[UIApplication sharedApplication] setStatusBarHidden:NO
                                            withAnimation:UIStatusBarAnimationNone];
}
@end
