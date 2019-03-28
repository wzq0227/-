//  VRPlayerControlBarDelegate.h
//  GosIPCs
//
//  Create by daniel.hu on 2018/12/6.
//  Copyright © 2018年 goscam. All rights reserved.

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, VRPlayerControlBarDisplayMode) {
    VRPlayerControlBarDisplayModeAsteroid,      // 星球状 - VR-180,VR-360
    VRPlayerControlBarDisplayModeCylinder,      // 圆柱形 - VR-360
    VRPlayerControlBarDisplayModeTwoPicture,    // 二画面 - VR-360
    VRPlayerControlBarDisplayModeFourPicture,   // 四画面 - VR-360
    
    VRPlayerControlBarDisplayModeWideAngle,     // 广角 - VR-180
};

@protocol VRPlayerControlBarDelegate <NSObject>
/// 声音
- (void)controlBar:(UIView *)controlBar voiceDidClick:(UIButton *)sender;
/// 巡航
- (void)controlBar:(UIView *)controlBar cruiseDidClick:(UIButton *)sender;
/// 安装模式
- (void)controlBar:(UIView *)controlBar mountingModeDidClick:(UIButton *)sender;
/// 显示模式
- (void)controlBar:(UIView *)controlBar displayModeDidChanged:(VRPlayerControlBarDisplayMode)displayMode;
/// 回放
- (void)controlBar:(UIView *)controlBar playbackDidClick:(UIButton *)sender;
/// 清晰度
- (void)controlBar:(UIView *)controlBar definitionDidClick:(UIButton *)sender;
/// 录像
- (void)controlBar:(UIView *)controlBar recordDidClick:(UIButton *)sender;
/// 对讲
//- (void)controlBar:(UIView *)controlBar speakDidClick:(UIButton *)sender;

/// 持续按下对讲按钮
- (void)controlBar:(UIView *) controlBar speakDidTouchDown:(UIButton *)sender;
/// 离开对讲按钮
- (void)controlBar:(UIView *) controlBar speakDidTouchDragExit:(UIButton *)sender;
/// 点击对讲按钮
- (void)controlBar:(UIView *) controlBar speakDidTouchUpInside:(UIButton *)sender;



/// 截图
- (void)controlBar:(UIView *)controlBar snapshotDidClick:(UIButton *)sender;
@end

