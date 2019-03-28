//  PlaybackOrientationHandler.h
//  Goscom
//
//  Create by daniel.hu on 2019/2/18.
//  Copyright © 2019年 goscam. All rights reserved.

#import <Foundation/Foundation.h>
@class PlaybackOrientationHandler;
@protocol PlaybackOrientationHandlerDelegate <NSObject>

@optional
- (void)orientation_handler:(PlaybackOrientationHandler *)handler
             rotate180Angle:(CGFloat)angle
     shouldRefreshStatusBar:(void(^)(void))shouldRefreshStatusBar
                 completion:(void(^)(void))completion;

- (void)orientation_handler:(PlaybackOrientationHandler *)handler
              rotate90Angle:(CGFloat)angle
     shouldRefreshStatusBar:(void(^)(void))shouldRefreshStatusBar
        shouldHideStatusBar:(void(^)(void))shouldHideStatusBar
                 completion:(void(^)(void))completion;

- (void)orientation_handler:(PlaybackOrientationHandler *)handler
rotateToPortraitFromLastOrientation:(UIDeviceOrientation)lastOrientation
     shouldRefreshStatusBar:(void(^)(void))shouldRefreshStatusBar
                 completion:(void(^)(void))completion;;

- (BOOL)orientation_handler_shouldAutoRotate:(PlaybackOrientationHandler *)handler;

@end

NS_ASSUME_NONNULL_BEGIN

@interface PlaybackOrientationHandler : NSObject
@property (nonatomic, weak) id<PlaybackOrientationHandlerDelegate> delegate;

@property (nonatomic, assign, getter=isFullScreen) BOOL fullScreen;
@end

NS_ASSUME_NONNULL_END
