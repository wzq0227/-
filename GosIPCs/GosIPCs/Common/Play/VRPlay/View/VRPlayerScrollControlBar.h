//  VRPlayerScrollControlBar.h
//  GosIPCs
//
//  Create by daniel.hu on 2018/12/6.
//  Copyright © 2018年 goscam. All rights reserved.

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, VRPlayerScrollControlBarVRType) {
    VRPlayerScrollControlBarVRTypeLive,
    VRPlayerScrollControlBarVRType360,
    VRPlayerScrollControlBarVRType180,
};
/// 按钮Tag标记类型
typedef NS_ENUM(NSInteger, VRPlayerScrollControlBarButtonTagType) {
    /// 声音
    VRPlayerScrollControlBarButtonTagTypeVoice            = 2048,
    /// 巡航
    VRPlayerScrollControlBarButtonTagTypeCruise,
    /// 安装模式
    VRPlayerScrollControlBarButtonTagTypeMountingMode,
    /// 显示模式
    VRPlayerScrollControlBarButtonTagTypeDisplayMode,
    /// 回放
    VRPlayerScrollControlBarButtonTagTypePlayback,
    /// 清晰度
    VRPlayerScrollControlBarButtonTagTypeDefinition,
    
    
    /// 只用于获取个数，外部勿用
    VRPlayerScrollControlBarButtonTagTypeCount,
};

/// 显示模式类型
typedef NS_OPTIONS(NSInteger, VRPlayerScrollControlBarDisplayModeType) {
    /// 星球状 - VR-180,VR-360
    VRPlayerScrollControlBarDisplayModeTypeAsteroid     = 1 << 0,
    /// 圆柱形 - VR-360
    VRPlayerScrollControlBarDisplayModeTypeCylinder     = 1 << 1,
    /// 二画面 - VR-360
    VRPlayerScrollControlBarDisplayModeTypeTwoPicture   = 1 << 2,
    /// 四画面 - VR-360
    VRPlayerScrollControlBarDisplayModeTypeFourPicture  = 1 << 3,
    
    /// 广角 - VR-180
    VRPlayerScrollControlBarDisplayModeTypeWideAngle    = 1 << 4,
    
    /// VR-360所需显示
    VRPlayerScrollControlBarDisplayModeTypeVR360        = VRPlayerScrollControlBarDisplayModeTypeAsteroid | VRPlayerScrollControlBarDisplayModeTypeCylinder | VRPlayerScrollControlBarDisplayModeTypeTwoPicture | VRPlayerScrollControlBarDisplayModeTypeFourPicture,
    /// VR-180所需显示
    VRPlayerScrollControlBarDisplayModeTypeVR180        = VRPlayerScrollControlBarDisplayModeTypeAsteroid | VRPlayerScrollControlBarDisplayModeTypeWideAngle
};

@class VRPlayerScrollControlBar;

/**
 点击事件代理
 */
@protocol VRPlayerScrollControlBarDelegate <NSObject>

/// 声音反馈
- (void)voiceButtonDidClick:(id)sender;
/// 巡航
- (void)cruiseButtonDidClick:(id)sender;
/// 安装模式
- (void)mountingModeButtonDidClick:(id)sender;
/// 显示模式
- (void)displayModeButtonDidClick:(id)sender mode:(VRPlayerScrollControlBarDisplayModeType)mode;
/// 回放
- (void)playbackButtonDidClick:(id)sender;
/// 清晰度
- (void)definitionButtonDidClick:(id)sender;

@end


NS_ASSUME_NONNULL_BEGIN
/**
 VR Player 滚动控制bar —— 声音，巡航，安装模式，显示模式，回放，清晰度
 */
@interface VRPlayerScrollControlBar : UIView
@property (nonatomic, weak) id<VRPlayerScrollControlBarDelegate> scrollControlBarDelegate;
@property (nonatomic, assign) VRPlayerScrollControlBarVRType vrType;
/**
 外部控制按钮 选择属性状态 取反
 
 @param tag VRPlayerScrollControlBarButtonTagType
 */
- (void)setupButtonOppositeSelectStateWithTag:(VRPlayerScrollControlBarButtonTagType)tag;

/**
 外部控制按钮 选择属性状态 设定
 
 @param tag VRPlayerScrollControlBarButtonTagType
 @param select BOOL
 */
- (void)setupButtonStateWithTag:(VRPlayerScrollControlBarButtonTagType)tag select:(BOOL)select;

/**
 外部设置显示类型按钮的类型
 
 @param displayMode VRPlayerScrollControlBarDisplayModeType
 */
- (void)setupDisplayModeButtonWithDisplayMode:(VRPlayerScrollControlBarDisplayModeType)displayMode;

/**
 外部控制中间菜单按钮 是否可用(Enable)
 
 @param enable 是否可用
 */
- (void)setupNemuButtonEnable:(BOOL) enable;
@end



#pragma mark - VRPlayerScrollControlBarDisplayMode 选择显示模式类型列表


/// 回调
typedef void(^VRPlayerScrollControlBarDisplayModeViewCallBack)(VRPlayerScrollControlBarDisplayModeType selectedModeType, UIImage *image);
@interface VRPlayerScrollControlBarDisplayModeView : UIControl

/**
 展示选择显示模式类型
 
 @param attachFrame 依附控件的布局尺寸
 @param displayModeType 需要显示哪些模式类型
 @param currentDisplayModeType 当前选择的模式类型
 @param callback VRPlayerScrollControlBarDisplayModeViewCallBack回调
 */
+ (instancetype)showWithAttachFrame:(CGRect)attachFrame neededDisplayMode:(VRPlayerScrollControlBarDisplayModeType)displayModeType
                 currentDisplayMode:(VRPlayerScrollControlBarDisplayModeType)currentDisplayModeType callback:(VRPlayerScrollControlBarDisplayModeViewCallBack)callback;

/**
 根据VRPlayerScrollControlBarDisplayModeType获取展示图片
 
 @param displayMode VRPlayerScrollControlBarDisplayModeType
 @return UIImage
 */
+ (UIImage *)getImageWithScrollControlBarDisplayModeType:(VRPlayerScrollControlBarDisplayModeType)displayMode;
@end




#pragma mark - VRPlayerScrollControlBarPageControl 自定义UIPageControl
@interface VRPlayerScrollControlBarPageControl : UIPageControl
/// 设置未选择状态的图片
@property (nonatomic, copy) UIImage *vrPageIndicatorImage;
/// 设置已选择状态的图片
@property (nonatomic, copy) UIImage *vrCurrentIndicatorImage;

@end
NS_ASSUME_NONNULL_END
