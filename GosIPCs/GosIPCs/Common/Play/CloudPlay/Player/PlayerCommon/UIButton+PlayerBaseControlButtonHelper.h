//  UIButton+PlayerBaseControlButtonHelper.h
//  GosIPCs
//
//  Create by daniel.hu on 2019/2/13.
//  Copyright © 2019年 goscam. All rights reserved.

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 配置基本控制的按钮图片
 */
@interface UIButton (PlayerBaseControlButtonHelper)
/// 录制按钮图片
- (void)recordStateConfiguration;
/// 对讲按钮图片
- (void)speakStateConfiguration;
/// 截图按钮图片
- (void)snapshotStateConfiguration;
/// 裁减按钮图片
- (void)cutStateConfiguration;
/// 声音按钮图片——默认声音，选择静音
- (void)soundStateConfiguration;
/// 静音按钮图片——默认静音，选择声音
- (void)muteStateConfiguration;
/// 声音无效与高亮图片
- (void)soundDisableAndHighlightedConfiguration;
/// 静音无效与高亮图片
- (void)muteDisableAndHighlightedConfiguration;
@end

NS_ASSUME_NONNULL_END
