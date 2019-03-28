//  UIButton+PlayerBaseControlButtonHelper.m
//  GosIPCs
//
//  Create by daniel.hu on 2019/2/13.
//  Copyright © 2019年 goscam. All rights reserved.

#import "UIButton+PlayerBaseControlButtonHelper.h"

@implementation UIButton (PlayerBaseControlButtonHelper)

- (void)configStateImageNames:(NSDictionary *)imageNames {
    if ([imageNames objectForKey:@(UIControlStateNormal)]) {
        [self setImage:GOS_IMAGE([imageNames objectForKey:@(UIControlStateNormal)])
              forState:UIControlStateNormal];
    }
    if ([imageNames objectForKey:@(UIControlStateDisabled)]) {
        [self setImage:GOS_IMAGE([imageNames objectForKey:@(UIControlStateDisabled)])
              forState:UIControlStateDisabled];
    }
    if ([imageNames objectForKey:@(UIControlStateHighlighted)]) {
        [self setImage:GOS_IMAGE([imageNames objectForKey:@(UIControlStateHighlighted)])
              forState:UIControlStateHighlighted];
    }
    if ([imageNames objectForKey:@(UIControlStateSelected)]) {
        [self setImage:GOS_IMAGE([imageNames objectForKey:@(UIControlStateSelected)])
              forState:UIControlStateSelected];
    }
    
}

/// 录制按钮图片
- (void)recordStateConfiguration {
    [self configStateImageNames:
            @{
             @(UIControlStateNormal):@"icon_video_normal",
             @(UIControlStateDisabled):@"icon_video_disabled",
             @(UIControlStateHighlighted):@"icon_video_pressed",
             @(UIControlStateSelected):@"icon_recording"
             }];
}

/// 对讲按钮图片
- (void)speakStateConfiguration {
    [self configStateImageNames:
            @{
             @(UIControlStateNormal):@"icon_mic_noraml",
             @(UIControlStateDisabled):@"icon_mic_disabled",
             @(UIControlStateHighlighted):@"icon_mic_pressed"
             }];
}

/// 截图按钮图片
- (void)snapshotStateConfiguration {
   [self configStateImageNames:
            @{
             @(UIControlStateNormal):@"icon_camera_normal_mine",
             @(UIControlStateDisabled):@"icon_camera_disabled_mine",
             @(UIControlStateHighlighted):@"icon_camera_pressed"
             }];
}

/// 裁减按钮图片
- (void)cutStateConfiguration {
    [self configStateImageNames:
            @{
             @(UIControlStateNormal):@"icon_edit_normal",
             @(UIControlStateDisabled):@"icon_edit_disabled",
             @(UIControlStateHighlighted):@"icon_edit_pressed"
             }];
}

/// 声音按钮图片
- (void)soundStateConfiguration {
    [self configStateImageNames:
            @{
             @(UIControlStateNormal):@"icon_sound_on_normal",
             @(UIControlStateNormal):@"icon_mute_normal",
             @(UIControlStateDisabled):@"icon_sound_on_disabled",
             @(UIControlStateHighlighted):@"icon_sound_on_pressed"
             }];
}

/// 静音按钮图片
- (void)muteStateConfiguration {
    [self configStateImageNames:
            @{
             @(UIControlStateNormal):@"icon_mute_normal",
             @(UIControlStateSelected):@"icon_sound_on_normal",
             @(UIControlStateDisabled):@"icon_mute_disabled",
             @(UIControlStateHighlighted):@"icon_mute_pressed"
             }];
}

/// 声音无效与高亮图片
- (void)soundDisableAndHighlightedConfiguration {
    [self configStateImageNames:
            @{
             @(UIControlStateDisabled):@"icon_sound_on_disabled",
             @(UIControlStateHighlighted):@"icon_sound_on_pressed"
             }];
}

/// 静音无效与高亮图片
- (void)muteDisableAndHighlightedConfiguration {
    [self configStateImageNames:
            @{
              @(UIControlStateDisabled):@"icon_mute_disabled",
              @(UIControlStateHighlighted):@"icon_mute_pressed"
              }];
}

@end
