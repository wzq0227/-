//  VRPlayerControlBar.h
//  GosIPCs
//
//  Create by daniel.hu on 2018/12/6.
//  Copyright © 2018年 goscam. All rights reserved.

#import <UIKit/UIKit.h>
#import "VRPlayerControlBarDelegate.h"

typedef NS_ENUM(NSInteger, VRPlayerControlBarVRType) {
    VRPlayerControlBarVRTypeLive,
    VRPlayerControlBarVRType360,
    VRPlayerControlBarVRType180,
};
NS_ASSUME_NONNULL_BEGIN

/**
 VR Player 控制bar——声音，巡航，安装模式，显示模式，回放，清晰度，录像，对讲，截图
 */
@interface VRPlayerControlBar : UIView
/// VRPlayerControlBarDelegate代理 参见VRPlayerControlBarDelegate.h 处理响应回调
@property (nonatomic, weak) id<VRPlayerControlBarDelegate> vrControlBarDelegate;

@property (nonatomic, assign) VRPlayerControlBarVRType vrType;


/// button Enable状态
/// 截图
- (void)setupSnapshotButtonState:(BOOL)state;
/// 录像
- (void)setupRecordButtonState:(BOOL)state;
/// 对讲
- (void)setupSpeakButtonState:(BOOL)state;
/// 设置所有中间的Nemu按钮可用
- (void)setupNemuButtonEnable:(BOOL)enable;

/// button isSelect 状态
/// 声音反馈
- (void)setupVoiceButtonState:(BOOL)state;
/// 巡航
- (void)setupCruiseButtonState:(BOOL)state;
/// 安装模式
- (void)setupMountingModeButtonState:(BOOL)state;
/// 显示模式
- (void)setupDisplayModeButtonState:(VRPlayerControlBarDisplayMode)mode;
/// 回放
- (void)setupPlaybackButtonState:(BOOL)state;
/// 清晰度
- (void)setupDefinitionButtonState:(BOOL)state;



/**
 设置录像按钮样式(录像为红，不录像为白)
 
 @param isSelect YES 为选中  NO 为不选中
 */
- (void)configRecordSelect:(BOOL)isSelect;

@end

NS_ASSUME_NONNULL_END
