//  VRPlayerControlBar.m
//  GosIPCs
//
//  Create by daniel.hu on 2018/12/6.
//  Copyright © 2018年 goscam. All rights reserved.

#import "VRPlayerControlBar.h"
#import "VRPlayerScrollControlBar.h"
#import "PlayerBaseControl.h"
#import "VRPlayerControlBarDelegate.h"
#import "UIButton+PlayerBaseControlButtonHelper.h"

@interface VRPlayerControlBar () <VRPlayerScrollControlBarDelegate>
/// 包含录像，对讲，截图
@property (nonatomic, strong) PlayerBaseControl *baseControl;
/// 包含声音，巡航，安装模式，显示模式，回放，清晰度
@property (nonatomic, strong) VRPlayerScrollControlBar *scrollControl;

@end

@implementation VRPlayerControlBar
#pragma mark - initialization
- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self commonConfig];
    }
    return self;
}
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self commonConfig];
    }
    return self;
}

- (void)commonConfig {
    [self addSubview:self.scrollControl];
    [self addSubview:self.baseControl];
    
    [self.scrollControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.mas_left);
        make.right.mas_equalTo(self.mas_right);
        make.top.mas_equalTo(self.mas_top);
        make.height.mas_equalTo(64);
    }];
    
    [self.baseControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.scrollControl.mas_bottom);
        make.left.mas_equalTo(self.mas_left);
        make.right.mas_equalTo(self.mas_right);
        make.bottom.mas_equalTo(self.mas_bottom);
    }];
}
#pragma mark - public method
/// button Enable state
/// 截图
- (void)setupSnapshotButtonState:(BOOL)state {
    GosLog(@"%s", __PRETTY_FUNCTION__);
    GOS_WEAK_SELF
    dispatch_async(dispatch_get_main_queue(), ^{
        GOS_STRONG_SELF
        strongSelf.baseControl.rightButton.enabled = state;
    });
}
/// 录像
- (void)setupRecordButtonState:(BOOL)state {
    GosLog(@"%s", __PRETTY_FUNCTION__);
    GOS_WEAK_SELF
    dispatch_async(dispatch_get_main_queue(), ^{
        GOS_STRONG_SELF
        strongSelf.baseControl.leftButton.enabled = state;
    });
}
/// 对讲
- (void)setupSpeakButtonState:(BOOL)state {
    GosLog(@"%s", __PRETTY_FUNCTION__);
    GOS_WEAK_SELF
    dispatch_async(dispatch_get_main_queue(), ^{
        GOS_STRONG_SELF
        strongSelf.baseControl.centerButton.enabled = state;
    });
}

/// 设置所有中间的Nemu按钮可用
- (void)setupNemuButtonEnable:(BOOL)enable{
    [self.scrollControl setupNemuButtonEnable:enable];
}


/// button Select state
/// 声音反馈
- (void)setupVoiceButtonState:(BOOL)state {
    GosLog(@"%s", __PRETTY_FUNCTION__);
    [self.scrollControl setupButtonStateWithTag:VRPlayerScrollControlBarButtonTagTypeVoice select:state];
}
/// 巡航
- (void)setupCruiseButtonState:(BOOL)state {
    GosLog(@"%s", __PRETTY_FUNCTION__);
    [self.scrollControl setupButtonStateWithTag:VRPlayerScrollControlBarButtonTagTypeCruise select:state];
}
/// 安装模式
- (void)setupMountingModeButtonState:(BOOL)state {
    GosLog(@"%s ", __PRETTY_FUNCTION__);
    [self.scrollControl setupButtonStateWithTag:VRPlayerScrollControlBarButtonTagTypeMountingMode select:state];
}
/// 显示模式
- (void)setupDisplayModeButtonState:(VRPlayerControlBarDisplayMode)mode {
    GosLog(@"%s 选择显示模式模式: %zd", __PRETTY_FUNCTION__, mode);
    [self.scrollControl setupDisplayModeButtonWithDisplayMode:[self convertFromControlBarDisplayMode:mode]];
}
/// 回放
- (void)setupPlaybackButtonState:(BOOL)state {
    GosLog(@"%s", __PRETTY_FUNCTION__);
    [self.scrollControl setupButtonStateWithTag:VRPlayerScrollControlBarButtonTagTypePlayback select:state];
}
/// 清晰度
- (void)setupDefinitionButtonState:(BOOL)state {
    GosLog(@"%s", __PRETTY_FUNCTION__);
    [self.scrollControl setupButtonStateWithTag:VRPlayerScrollControlBarButtonTagTypeDefinition select:state];
}

#pragma mark - events response
/// 截图
- (void)snapshotButtonDidClick:(id)sender {
    GosLog(@"%s", __PRETTY_FUNCTION__);
    if (self.vrControlBarDelegate && [self.vrControlBarDelegate respondsToSelector:@selector(controlBar:snapshotDidClick:)]) {
        [self.vrControlBarDelegate controlBar:self snapshotDidClick:sender];
    }
}
/// 录像
- (void)recordButtonDidClick:(id)sender {
    GosLog(@"%s", __PRETTY_FUNCTION__);
    if (self.vrControlBarDelegate && [self.vrControlBarDelegate respondsToSelector:@selector(controlBar:recordDidClick:)]) {
        [self.vrControlBarDelegate controlBar:self recordDidClick:sender];
    }
}
/// 对讲
//- (void)speakButtonDidClick:(id)sender {
//    GosLog(@"%s", __PRETTY_FUNCTION__);
//    if (self.vrControlBarDelegate && [self.vrControlBarDelegate respondsToSelector:@selector(controlBar:speakDidClick:)]) {
//        [self.vrControlBarDelegate controlBar:self speakDidClick:sender];
//    }
//}
// 对讲  按下(touchup Inside)
- (void)speakBtnTouchDown:(id)sender{
    GosLog(@"%s", __PRETTY_FUNCTION__);
    if (self.vrControlBarDelegate && [self.vrControlBarDelegate respondsToSelector:@selector(controlBar:speakDidTouchDown:)]) {
            [self.vrControlBarDelegate controlBar:self speakDidTouchDown:sender];
    }
}
- (void)speakBtnTouchDragExit:(id)sender{
    GosLog(@"%s", __PRETTY_FUNCTION__);
    if (self.vrControlBarDelegate && [self.vrControlBarDelegate respondsToSelector:@selector(controlBar:speakDidTouchDragExit:)]) {
        [self.vrControlBarDelegate controlBar:self speakDidTouchDragExit:sender];
    }
}
- (void)speakBtnTouchUpInside:(id)sender{
    GosLog(@"%s", __PRETTY_FUNCTION__);
    if (self.vrControlBarDelegate && [self.vrControlBarDelegate respondsToSelector:@selector(controlBar:speakDidTouchUpInside:)]) {
        [self.vrControlBarDelegate controlBar:self speakDidTouchUpInside:sender];
    }
}

/// 声音反馈
- (void)voiceButtonDidClick:(id)sender {
    GosLog(@"%s", __PRETTY_FUNCTION__);
    if (self.vrControlBarDelegate && [self.vrControlBarDelegate respondsToSelector:@selector(controlBar:voiceDidClick:)]) {
        [self.vrControlBarDelegate controlBar:self voiceDidClick:sender];
    }
}
/// 巡航
- (void)cruiseButtonDidClick:(id)sender {
    GosLog(@"%s", __PRETTY_FUNCTION__);
    if (self.vrControlBarDelegate && [self.vrControlBarDelegate respondsToSelector:@selector(controlBar:cruiseDidClick:)]) {
        [self.vrControlBarDelegate controlBar:self cruiseDidClick:sender];
    }
}
/// 安装模式
- (void)mountingModeButtonDidClick:(id)sender {
    GosLog(@"%s ", __PRETTY_FUNCTION__);
    if (self.vrControlBarDelegate && [self.vrControlBarDelegate respondsToSelector:@selector(controlBar:mountingModeDidClick:)]) {
        [self.vrControlBarDelegate controlBar:self mountingModeDidClick:sender];
    }
}
/// 显示模式
- (void)displayModeButtonDidClick:(id)sender mode:(VRPlayerScrollControlBarDisplayModeType)mode {
    GosLog(@"%s 选择显示模式模式: %zd", __PRETTY_FUNCTION__, mode);
    if (self.vrControlBarDelegate && [self.vrControlBarDelegate respondsToSelector:@selector(controlBar:displayModeDidChanged:)]) {
        [self.vrControlBarDelegate controlBar:self displayModeDidChanged:[self convertFromScrollBarDisplayMode:mode]];
    }
}
/// 回放
- (void)playbackButtonDidClick:(id)sender {
    GosLog(@"%s", __PRETTY_FUNCTION__);
    if (self.vrControlBarDelegate && [self.vrControlBarDelegate respondsToSelector:@selector(controlBar:playbackDidClick:)]) {
        [self.vrControlBarDelegate controlBar:self playbackDidClick:sender];
    }
}
/// 清晰度
- (void)definitionButtonDidClick:(id)sender {
    GosLog(@"%s", __PRETTY_FUNCTION__);
    if (self.vrControlBarDelegate && [self.vrControlBarDelegate respondsToSelector:@selector(controlBar:definitionDidClick:)]) {
        [self.vrControlBarDelegate controlBar:self definitionDidClick:sender];
    }
}

#pragma mark - private method
/// VRPlayerScrollControlBarDisplayModeType -> VRPlayerControlBarDisplayMode
- (VRPlayerControlBarDisplayMode)convertFromScrollBarDisplayMode:(VRPlayerScrollControlBarDisplayModeType)scrollDisplayMode {
    VRPlayerControlBarDisplayMode resultMode = VRPlayerControlBarDisplayModeAsteroid;
    switch (scrollDisplayMode) {
        case VRPlayerScrollControlBarDisplayModeTypeAsteroid:
            resultMode = VRPlayerControlBarDisplayModeAsteroid;
            break;
        case VRPlayerScrollControlBarDisplayModeTypeCylinder:
            resultMode = VRPlayerControlBarDisplayModeCylinder;
            break;
        case VRPlayerScrollControlBarDisplayModeTypeTwoPicture:
            resultMode = VRPlayerControlBarDisplayModeTwoPicture;
            break;
        case VRPlayerScrollControlBarDisplayModeTypeFourPicture:
            resultMode = VRPlayerControlBarDisplayModeFourPicture;
            break;
        case VRPlayerScrollControlBarDisplayModeTypeWideAngle:
            resultMode = VRPlayerControlBarDisplayModeWideAngle;
            break;
        default:
            break;
    }
    return resultMode;
}
/// VRPlayerControlBarDisplayMode -> VRPlayerScrollControlBarDisplayModeType
- (VRPlayerScrollControlBarDisplayModeType)convertFromControlBarDisplayMode:(VRPlayerControlBarDisplayMode)displayMode {
    VRPlayerScrollControlBarDisplayModeType resultMode = VRPlayerScrollControlBarDisplayModeTypeAsteroid;
    switch (displayMode) {
        case VRPlayerControlBarDisplayModeAsteroid:
            resultMode = VRPlayerScrollControlBarDisplayModeTypeAsteroid;
            break;
        case VRPlayerControlBarDisplayModeCylinder:
            resultMode = VRPlayerScrollControlBarDisplayModeTypeCylinder;
            break;
        case VRPlayerControlBarDisplayModeTwoPicture:
            resultMode = VRPlayerScrollControlBarDisplayModeTypeTwoPicture;
            break;
        case VRPlayerControlBarDisplayModeFourPicture:
            resultMode = VRPlayerScrollControlBarDisplayModeTypeFourPicture;
            break;
        case VRPlayerControlBarDisplayModeWideAngle:
            resultMode = VRPlayerScrollControlBarDisplayModeTypeWideAngle;
            break;
        default:
            break;
    }
    return resultMode;
}

#pragma mark - getters and setters
- (PlayerBaseControl *)baseControl {
    if (!_baseControl) {
        _baseControl = [[PlayerBaseControl alloc] init];
        // 截图，录像，对讲响应
        [_baseControl.rightButton snapshotStateConfiguration];
        [_baseControl.leftButton recordStateConfiguration];
        [_baseControl.centerButton speakStateConfiguration];
        
        [_baseControl.rightButton addTarget:self action:@selector(snapshotButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
        [_baseControl.leftButton addTarget:self action:@selector(recordButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
//        [_baseControl.centerButton addTarget:self action:@selector(speakButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
        
        [_baseControl.centerButton addTarget:self
                                      action:@selector(speakBtnTouchDown:)
                          forControlEvents:UIControlEventTouchDown];
        [_baseControl.centerButton addTarget:self
                                      action:@selector(speakBtnTouchDragExit:)
                          forControlEvents:UIControlEventTouchDragExit];
        [_baseControl.centerButton addTarget:self
                                      action:@selector(speakBtnTouchUpInside:)
                          forControlEvents:UIControlEventTouchUpInside];
        
        _baseControl.leftButton.enabled = NO;
        _baseControl.centerButton.enabled = NO;
        _baseControl.rightButton.enabled = NO;
    }
    return _baseControl;
}
- (VRPlayerScrollControlBar *)scrollControl {
    if (!_scrollControl) {
        _scrollControl = [[VRPlayerScrollControlBar alloc] init];
        _scrollControl.scrollControlBarDelegate = self;
    }
    return _scrollControl;
}
- (void)setVrType:(VRPlayerControlBarVRType)vrType {
    _vrType = vrType;
    // 改变scrollControl的vr类型
    // 临时处理
    self.scrollControl.vrType = (VRPlayerScrollControlBarVRType)vrType;
//    self.scrollControl.vrType = vrType == VRPlayerControlBarVRType360 ? VRPlayerScrollControlBarVRType360 : VRPlayerScrollControlBarVRType180;
}




#pragma mark -- 设置录像按钮样式(录像为红，不录像为白)
- (void)configRecordSelect:(BOOL)isSelect
{
    GosLog(@"%s", __PRETTY_FUNCTION__);
    GOS_WEAK_SELF
    dispatch_async(dispatch_get_main_queue(), ^{
        GOS_STRONG_SELF
        strongSelf.baseControl.leftButton.selected = isSelect;
    });
}


@end
