//  PlaybackMaskControl.h
//  GosIPCs
//
//  Create by daniel.hu on 2019/1/22.
//  Copyright © 2019年 goscam. All rights reserved.

#import <UIKit/UIKit.h>
/** 主要显示状态 */
typedef NS_ENUM(NSInteger, PlaybackMaskControlMainState) {
    /// 默认全隐藏
    PlaybackMaskControlMainStateDefault,
    /// 中间loading
    PlaybackMaskControlMainStateLoading,
    /// 中间显示状态
    PlaybackMaskControlMainStateShowingState,
};

/** 额外控件的显示状态 */
typedef NS_ENUM(NSUInteger, PlaybackMaskControlExtraState) {
    /// 默认全隐藏
    PlaybackMaskControlExtraStateDefault,
    /// 预览图loading
    PlaybackMaskControlExtraStatePreviewLoading,
    /// 预览图play
    PlaybackMaskControlExtraStatePreviewPlay,
};

NS_ASSUME_NONNULL_BEGIN
@class PlaybackMaskControlPreview;
/**
 控制playerView的遮罩
 */
@interface PlaybackMaskControl : UIView
/// 播放
@property (nonatomic, readonly, strong) UIButton *previewPlayButton;
/// 显示时间的时间戳
@property (nonatomic, assign) NSTimeInterval previewTimestamp;
/// 预览图
@property (nonatomic, copy) UIImage *previewImage;
/// 中间详情
@property (nonatomic, copy) NSString *centerDetailString;

/// 主要显示状态
@property (nonatomic, assign) PlaybackMaskControlMainState mainState;
/// 额外控件的显示状态
@property (nonatomic, assign) PlaybackMaskControlExtraState extraState;
@end


NS_ASSUME_NONNULL_END
