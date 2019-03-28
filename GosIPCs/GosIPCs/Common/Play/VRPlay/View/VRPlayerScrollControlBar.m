//  VRPlayerScrollControlBar.m
//  GosIPCs
//
//  Create by daniel.hu on 2018/12/6.
//  Copyright © 2018年 goscam. All rights reserved.

#import "VRPlayerScrollControlBar.h"
#import "UIButton+GosTitleAndImg.h"

@interface VRPlayerScrollControlBar () <UIScrollViewDelegate>
@property (nonatomic, strong) VRPlayerScrollControlBarPageControl *controlPageControl;
/// scrollView
@property (nonatomic, strong) UIScrollView *controlScrollView;
/// contentSize中可见个数
@property (nonatomic, assign) NSInteger visibleCount;
/// 点击displayMode需要响应的视图
@property (nonatomic, assign) __block VRPlayerScrollControlBarDisplayModeType currentDisplayType;
/// 4种模式选择的底图
@property (nonatomic, strong) VRPlayerScrollControlBarDisplayModeView * displayModeView;
@end

@implementation VRPlayerScrollControlBar
#pragma mark - initialization
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // 配置scrollView
        [self addSubview:self.controlScrollView];
        [self.controlScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(UIEdgeInsetsZero);
        }];
        
        [self addSubview:self.controlPageControl];
        [self.controlPageControl mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(self.mas_bottom).offset(-3);
            make.height.mas_equalTo(4);
            make.left.mas_equalTo(self.mas_left);
            make.right.mas_equalTo(self.mas_right);
        }];
        // 默认球形
        _currentDisplayType = VRPlayerScrollControlBarDisplayModeTypeAsteroid;
        
        // 默认一行可见4个
        _visibleCount = 4;
        CGFloat btnWidth = GOS_SCREEN_W / _visibleCount * 1.0;
        
        // 构建按钮到滚动视图中
        for (NSInteger i = VRPlayerScrollControlBarButtonTagTypeVoice; i < VRPlayerScrollControlBarButtonTagTypeCount; i++) {
            UIButton *btn = [self buttonWithTagType:i];
            [self.controlScrollView addSubview:btn];
            
            [btn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(self.controlScrollView.mas_left).offset((i-VRPlayerScrollControlBarButtonTagTypeVoice) * btnWidth);
                make.centerY.mas_equalTo(self.controlScrollView.mas_centerY);
                make.height.mas_equalTo(self.controlScrollView.mas_height);
                make.width.mas_equalTo(btnWidth);
            }];
        }
        
        
    }
    return self;
}

#pragma mark - life cycle
- (void)layoutSubviews {
    [super layoutSubviews];
    // 改变contentSize
    NSInteger pageCount = ((VRPlayerScrollControlBarButtonTagTypeCount - VRPlayerScrollControlBarButtonTagTypeVoice)%_visibleCount);
    self.controlScrollView.contentSize = CGSizeMake(pageCount * self.frame.size.width, 0);
    self.controlPageControl.numberOfPages = pageCount;
}


#pragma mark - UIScrollViewDelegate
-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    //计算pagecontroll相应地页(滚动视图可以滚动的总宽度/单个滚动视图的宽度=滚动视图的页数)
    NSInteger currentPage = (int)(scrollView.contentOffset.x) / (int)(scrollView.frame.size.width);
    self.controlPageControl.currentPage = currentPage;//将上述的滚动视图页数重新赋给当前视图页数,进行分页
}

#pragma mark - public method
- (void)setupButtonOppositeSelectStateWithTag:(VRPlayerScrollControlBarButtonTagType)tag {
    UIButton *targetButton = [self fetchButtonWithTag:tag];
    if (targetButton) {
        targetButton.selected = !targetButton.isSelected;
    }
}
- (void)setupButtonStateWithTag:(VRPlayerScrollControlBarButtonTagType)tag
                         select:(BOOL)select {
    GOS_WEAK_SELF
    dispatch_async(dispatch_get_main_queue(), ^{
        GOS_STRONG_SELF
        UIButton *targetButton = [strongSelf fetchButtonWithTag:tag];
        if (targetButton) {
            targetButton.selected = select;
        }
    });
}
- (void)setupDisplayModeButtonWithDisplayMode:(VRPlayerScrollControlBarDisplayModeType)displayMode {
    UIButton *targetButton = [self fetchButtonWithTag:VRPlayerScrollControlBarButtonTagTypeDisplayMode];
    // 设置图片
    [targetButton setImage:[VRPlayerScrollControlBarDisplayModeView getImageWithScrollControlBarDisplayModeType:displayMode] forState:UIControlStateNormal];
}
/**
 外部控制按钮 是否可用(Enable)
 
 @param enable 是否可用
 */
- (void)setupNemuButtonEnable:(BOOL) enable{
    GOS_WEAK_SELF
    dispatch_async(dispatch_get_main_queue(), ^{
        
        GOS_STRONG_SELF
        for (UIButton *item in self.controlScrollView.subviews) {
            item.enabled = enable;
        }
    });
}

#pragma mark - private method
- (UIButton *)fetchButtonWithTag:(VRPlayerScrollControlBarButtonTagType)tagType {
    for (UIButton *item in self.controlScrollView.subviews) {
        if (item.tag == tagType) {
            return item;
        }
    }
    return nil;
}

#pragma mark - event response
- (void)generationButtonDidClick:(UIButton *)sender {
    // 代理者不存在就不响应
    if (!_scrollControlBarDelegate) return ;
    sender.selected = !sender.isSelected;
    switch (sender.tag) {
            // 声音
        case VRPlayerScrollControlBarButtonTagTypeVoice: {
            if ([_scrollControlBarDelegate respondsToSelector:@selector(voiceButtonDidClick:)]) {
                [_scrollControlBarDelegate voiceButtonDidClick:sender];
            }
            break;
        }
            // 巡航
        case VRPlayerScrollControlBarButtonTagTypeCruise: {
            if ([_scrollControlBarDelegate respondsToSelector:@selector(cruiseButtonDidClick:)]) {
                [_scrollControlBarDelegate cruiseButtonDidClick:sender];
            }
            break;
        }
            // 安装模式
        case VRPlayerScrollControlBarButtonTagTypeMountingMode: {
            if ([_scrollControlBarDelegate respondsToSelector:@selector(mountingModeButtonDidClick:)]) {
                [_scrollControlBarDelegate mountingModeButtonDidClick:sender];
            }
            break;
        }
            // 显示模式
        case VRPlayerScrollControlBarButtonTagTypeDisplayMode: {
            // 显示选择的东西
            __weak typeof(self) weakself = self;
            
         self.displayModeView =
            [VRPlayerScrollControlBarDisplayModeView showWithAttachFrame:[self.controlScrollView convertRect:sender.frame
                                                                                                      toView:[UIApplication sharedApplication].keyWindow]
                                                       neededDisplayMode:self.vrType == VRPlayerScrollControlBarVRType180?VRPlayerScrollControlBarDisplayModeTypeVR180:VRPlayerScrollControlBarDisplayModeTypeVR360
                                                      currentDisplayMode:_currentDisplayType callback:^(VRPlayerScrollControlBarDisplayModeType selectedModeType, UIImage * _Nonnull image) {
                                                          // 更新当前的显示模式
                                                          weakself.currentDisplayType = selectedModeType;
                                                          // 更新显示模式的图片
                                                          [sender setImage:image forState:UIControlStateNormal];
                                                          // 回调给代理响应
                                                          if ([weakself.scrollControlBarDelegate respondsToSelector:@selector(displayModeButtonDidClick:mode:)]) {
                                                              [weakself.scrollControlBarDelegate displayModeButtonDidClick:sender mode:selectedModeType];
                                                          }
                                                      }];
            break;
        }
            // 回放
        case VRPlayerScrollControlBarButtonTagTypePlayback: {
            if ([_scrollControlBarDelegate respondsToSelector:@selector(playbackButtonDidClick:)]) {
                [_scrollControlBarDelegate playbackButtonDidClick:sender];
            }
            break;
        }
            // 高清
        case VRPlayerScrollControlBarButtonTagTypeDefinition: {
            if ([_scrollControlBarDelegate respondsToSelector:@selector(definitionButtonDidClick:)]) {
                [_scrollControlBarDelegate definitionButtonDidClick:sender];
            }
            break;
        }
        default:
            break;
    }
    
    
}


#pragma mark - button generator
/// 根据VRPlayerScrollControlBarButtonTagType生成按钮
- (UIButton *)buttonWithTagType:(VRPlayerScrollControlBarButtonTagType)extensionType {
    switch (extensionType) {
            // 声音
        case VRPlayerScrollControlBarButtonTagTypeVoice:
            return [self generateButtonNormalTitle:@"VRPlay_Voice"
                                selectedTitleColor:nil
                                   normalImageName:@"icon_sound_off_mine"
                                 selectedImageName:@"icon_sound_on_mine"
                                               tag:extensionType];
            // 巡航
        case VRPlayerScrollControlBarButtonTagTypeCruise:
            return [self generateButtonNormalTitle:@"VRPlay_Cruise"
                                selectedTitleColor:GOS_COLOR_RGB(0x55AFFC)
                                   normalImageName:@"icon_cruise_off"
                                 selectedImageName:@"icon_cruise_on"
                                               tag:extensionType];
            // 安装模式
        case VRPlayerScrollControlBarButtonTagTypeMountingMode:
            return [self generateButtonNormalTitle:@"VRPlay_MountingMode"
                                selectedTitleColor:nil
                                   normalImageName:@"icon_install_down"
                                 selectedImageName:nil
                                               tag:extensionType];
            // 显示模式
        case VRPlayerScrollControlBarButtonTagTypeDisplayMode:
            return [self generateButtonNormalTitle:@"VRPlay_DisplayMode"
                                selectedTitleColor:nil
                                   normalImageName:@"icon_display"
                                 selectedImageName:nil
                                               tag:extensionType];
            // 回放
        case VRPlayerScrollControlBarButtonTagTypePlayback:
            return [self generateButtonNormalTitle:@"VRPlay_Playback"
                                selectedTitleColor:nil
                                   normalImageName:@"icon_playback_normal"
                                 selectedImageName:nil
                                               tag:extensionType];
            // 高清
        case VRPlayerScrollControlBarButtonTagTypeDefinition:
            return [self generateButtonNormalTitle:@"VRPlay_Definition"
                                selectedTitleColor:nil
                                   normalImageName:@"icon_sd"
                                 selectedImageName:@"icon_hd"
                                               tag:extensionType];
        default:
            break;
    }
    return nil;
}
- (UIButton *)generateButtonNormalTitle:(NSString *)normalTitle
                     selectedTitleColor:(UIColor *)selectedTitleColor
                        normalImageName:(NSString *)normalImageName
                      selectedImageName:(NSString *)selectedImageName
                                    tag:(NSInteger)tag {
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom] ;
    // 重要标识
    [btn setTag:tag];
    [btn setTitle:DPLocalizedString(normalTitle) forState:UIControlStateNormal];
    // 默认属性
    [btn setTitleColor:GOS_COLOR_RGB(0x666666) forState:UIControlStateNormal];
    [btn.titleLabel setFont:GOS_FONT(10)];
    [btn setImage:GOS_IMAGE(normalImageName) forState:UIControlStateNormal];
    // 选择状态
    if (selectedTitleColor) {
        [btn setTitleColor:selectedTitleColor forState:UIControlStateSelected];
    }
    if (selectedImageName) {
        [btn setImage:GOS_IMAGE(selectedImageName) forState:UIControlStateSelected];
    }
    // 适应上图片下文字居中
    CGFloat offset = 10;
    CGSize imageSize = GOS_IMAGE(normalImageName).size;
    [btn.titleLabel sizeToFit];
    CGSize titleSize = btn.titleLabel.frame.size;
    btn.titleEdgeInsets = UIEdgeInsetsMake(0, -imageSize.width, -imageSize.height-offset/2.0, 0);
    btn.imageEdgeInsets = UIEdgeInsetsMake(-titleSize.height-offset/2.0, 0, 0, -titleSize.width);
    
    [btn addTarget:self action:@selector(generationButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
    
    return btn;
}

#pragma mark - getters and setters
- (UIScrollView *)controlScrollView {
    if (!_controlScrollView) {
        _controlScrollView = [[UIScrollView alloc] init];
        _controlScrollView.backgroundColor = [UIColor clearColor];
        _controlScrollView.bounces = YES;
        _controlScrollView.showsVerticalScrollIndicator = NO;
        _controlScrollView.showsHorizontalScrollIndicator = NO;
        _controlScrollView.pagingEnabled = YES;
        _controlScrollView.userInteractionEnabled = YES;
        _controlScrollView.delegate = self;
        _controlScrollView.layer.borderWidth = .5;
        _controlScrollView.layer.borderColor = [GOS_COLOR_RGB(0xF7F7F7) CGColor];
    }
    return _controlScrollView;
}
- (VRPlayerScrollControlBarPageControl *)controlPageControl {
    if (!_controlPageControl) {
        _controlPageControl = [[VRPlayerScrollControlBarPageControl alloc] init];
        _controlPageControl.backgroundColor = [UIColor clearColor];
        _controlPageControl.vrPageIndicatorImage = GOS_IMAGE(@"icon_circle");
        _controlPageControl.vrCurrentIndicatorImage = GOS_IMAGE(@"icon_ rounded_rectangle");
        _controlPageControl.numberOfPages = 2;
        _controlPageControl.currentPage = 0;
    }
    return _controlPageControl;
}
- (void)setVrType:(VRPlayerScrollControlBarVRType)vrType {
    _vrType = vrType;
    
    // 改变巡航的图片
    [[self fetchButtonWithTag:VRPlayerScrollControlBarButtonTagTypeMountingMode] setImage:GOS_IMAGE(vrType == VRPlayerScrollControlBarVRType180?@"icon_install_side":@"icon_install_down") forState:UIControlStateNormal];
}
@end








#pragma mark - VRPlayerScrollControlBarDisplayModeView 选择显示模式类型列表
@interface VRPlayerScrollControlBarDisplayModeView ()
/// 列表视图
@property (nonatomic, strong) UIView *contentView;
/// 回调
@property (nonatomic, copy) VRPlayerScrollControlBarDisplayModeViewCallBack callback;
@end

@implementation VRPlayerScrollControlBarDisplayModeView
#pragma mark - initialization
+ (instancetype)showWithAttachFrame:(CGRect)attachFrame
                  neededDisplayMode:(VRPlayerScrollControlBarDisplayModeType)displayModeType
                 currentDisplayMode:(VRPlayerScrollControlBarDisplayModeType)currentDisplayModeType
                           callback:(VRPlayerScrollControlBarDisplayModeViewCallBack)callback {
    
    VRPlayerScrollControlBarDisplayModeView *displayModeView = [[VRPlayerScrollControlBarDisplayModeView alloc] initWithAttachFrame:attachFrame neededDisplayMode:displayModeType currentDisplayMode:currentDisplayModeType callback:callback];
    // 添加到keywindow上
    [[UIApplication sharedApplication].keyWindow addSubview:displayModeView];
    return displayModeView;
    
}
- (instancetype)initWithAttachFrame:(CGRect)attachFrame
                  neededDisplayMode:(VRPlayerScrollControlBarDisplayModeType)displayModeType
                 currentDisplayMode:(VRPlayerScrollControlBarDisplayModeType)currentDisplayModeType
                           callback:(VRPlayerScrollControlBarDisplayModeViewCallBack)callback {
    if (self = [super initWithFrame:CGRectMake(0, 0, GOS_SCREEN_W, GOS_SCREEN_H)]) {
        [self setBackgroundColor:[UIColor clearColor]];
        // 先清除一次视图
        [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        
        self.callback = [callback copy];
        
        [self addSubview:self.contentView];
        
        // 按钮的高度
        CGFloat bHeight = 40;
        // 球形
        if (displayModeType & VRPlayerScrollControlBarDisplayModeTypeAsteroid) {
            [self contentViewAddSubviewWithDisplayMode:VRPlayerScrollControlBarDisplayModeTypeAsteroid
                                              selected:currentDisplayModeType == VRPlayerScrollControlBarDisplayModeTypeAsteroid
                                       normalImageName:@"icon_display_normal"
                                     selectedImageName:@"icon_display_selected"
                                                height:bHeight];
        }
        // 圆柱
        if (displayModeType & VRPlayerScrollControlBarDisplayModeTypeCylinder) {
            [self contentViewAddSubviewWithDisplayMode:VRPlayerScrollControlBarDisplayModeTypeCylinder
                                              selected:currentDisplayModeType == VRPlayerScrollControlBarDisplayModeTypeCylinder
                                       normalImageName:@"icon_cylinder_normal"
                                     selectedImageName:@"icon_cylinder_selected"
                                                height:bHeight];
        }
        // 二画面
        if (displayModeType & VRPlayerScrollControlBarDisplayModeTypeTwoPicture) {
            [self contentViewAddSubviewWithDisplayMode:VRPlayerScrollControlBarDisplayModeTypeTwoPicture
                                              selected:currentDisplayModeType == VRPlayerScrollControlBarDisplayModeTypeTwoPicture
                                       normalImageName:@"icon_double_screens_normal"
                                     selectedImageName:@"icon_double_screens_selected"
                                                height:bHeight];
        }
        // 四画面
        if (displayModeType & VRPlayerScrollControlBarDisplayModeTypeFourPicture) {
            [self contentViewAddSubviewWithDisplayMode:VRPlayerScrollControlBarDisplayModeTypeFourPicture
                                              selected:currentDisplayModeType == VRPlayerScrollControlBarDisplayModeTypeFourPicture
                                       normalImageName:@"icon_four_screens_normal"
                                     selectedImageName:@"icon_four_screens_selected"
                                                height:bHeight];
        }
        // 广角
        if (displayModeType & VRPlayerScrollControlBarDisplayModeTypeWideAngle) {
            [self contentViewAddSubviewWithDisplayMode:VRPlayerScrollControlBarDisplayModeTypeWideAngle
                                              selected:currentDisplayModeType == VRPlayerScrollControlBarDisplayModeTypeWideAngle
                                       normalImageName:@"icon_sector_normal"
                                     selectedImageName:@"icon_sector_selected"
                                                height:bHeight];
        }
        
        // 计算content的高度
        CGFloat cWidth = 46;
        CGFloat cHeight = ([self.contentView.subviews count] * 40);
        self.contentView.frame = CGRectMake(CGRectGetMinX(attachFrame) + CGRectGetWidth(attachFrame)/2.0 - cWidth/2.0, CGRectGetMinY(attachFrame) - cHeight, cWidth, cHeight);
    }
    return self;
}
#pragma mark - public class method
+ (UIImage *)getImageWithScrollControlBarDisplayModeType:(VRPlayerScrollControlBarDisplayModeType)displayMode {
    UIImage *image = nil;
    switch (displayMode) {
            /// 星球状 - VR-180,VR-360
        case VRPlayerScrollControlBarDisplayModeTypeAsteroid:
            image = GOS_IMAGE(@"icon_display");
            break;
            /// 圆柱形 - VR-360
        case VRPlayerScrollControlBarDisplayModeTypeCylinder:
            image = GOS_IMAGE(@"icon_cylinder");
            break;
            /// 二画面 - VR-360
        case VRPlayerScrollControlBarDisplayModeTypeTwoPicture:
            image = GOS_IMAGE(@"icon_double_screens");
            break;
            /// 四画面 - VR-360
        case VRPlayerScrollControlBarDisplayModeTypeFourPicture:
            image = GOS_IMAGE(@"icon_four_screens");
            break;
            /// 广角 - VR-180
        case VRPlayerScrollControlBarDisplayModeTypeWideAngle:
            image = GOS_IMAGE(@"icon_sector");
            break;
            
        default:
            break;
    }
    return image;
}

#pragma mark - events response
- (void)generationButtonDidClick:(UIButton *)sender {
    // 取消选择其他项，sender标记为选择
    for (UIButton *subItem in self.contentView.subviews) {
        if (subItem != sender) {
            subItem.selected = NO;
        } else {
            sender.selected = YES;
        }
    }
    // 如果需要回调
    if (self.callback) {
        self.callback(sender.tag, [VRPlayerScrollControlBarDisplayModeView getImageWithScrollControlBarDisplayModeType:sender.tag]);
    }
}
#pragma mark - private method
/// 给contentView添加子按钮方法
- (void)contentViewAddSubviewWithDisplayMode:(VRPlayerScrollControlBarDisplayModeType)displayModeType
                                    selected:(BOOL)selected
                             normalImageName:(NSString *)normalImageName
                           selectedImageName:(NSString *)selectedImageName
                                      height:(CGFloat)height {
    UIButton *btn = [self generateButtonNormalImageName:normalImageName selectedImageName:selectedImageName tag:displayModeType];
    btn.selected = selected;
    [self.contentView addSubview:btn];
    
    [btn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.contentView.mas_centerX);
        make.width.mas_equalTo(self.contentView.mas_width);
        make.height.mas_equalTo(height);
        make.top.mas_equalTo(self.contentView.mas_top).offset(([self.contentView.subviews count] - 1) * height);
    }];
}
/// 按钮生成方法
- (UIButton *)generateButtonNormalImageName:(NSString *)normalImageName
                          selectedImageName:(NSString *)selectedImageName
                                        tag:(NSInteger)tag {
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom] ;
    // 重要标识
    [btn setTag:tag];
    // 默认属性
    [btn setImage:GOS_IMAGE(normalImageName) forState:UIControlStateNormal];
    // 选择状态
    if (selectedImageName) {
        [btn setImage:GOS_IMAGE(selectedImageName) forState:UIControlStateSelected];
    }
    
    [btn addTarget:self action:@selector(generationButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
    
    return btn;
}
#pragma mark - touch method
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    // 点击contentView以外的地方就将自身移除
    [self removeFromSuperview];
}

#pragma mark - getters
- (UIView *)contentView {
    if (!_contentView) {
        _contentView = [[UIView alloc] init];
        _contentView.backgroundColor = [GOS_COLOR_RGB(0x000000) colorWithAlphaComponent:0.3];
        _contentView.layer.cornerRadius = 5.0;
    }
    return _contentView;
}
-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                               duration:(NSTimeInterval)duration
{

}
@end


#pragma mark - VRPlayerScrollControlBarPageControl 自定义UIPageControl
@interface VRPlayerScrollControlBarPageControl ()

@end
@implementation VRPlayerScrollControlBarPageControl
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        self.pageIndicatorTintColor = [UIColor clearColor];
        self.currentPageIndicatorTintColor = [UIColor clearColor];
    }
    return self;
}
- (void)setCurrentPage:(NSInteger)currentPage {
    [super setCurrentPage:currentPage];
    
    [self updateDots];
}

- (void)updateDots{
    for (int i = 0; i < [self.subviews count]; i++) {
        CGSize contentSize = self.subviews[i].frame.size;
        UIImageView *dot = [self imageViewForSubview:[self.subviews objectAtIndex:i] currPage:i];
        
        if (i == self.currentPage){
            dot.image = self.vrCurrentIndicatorImage;
            CGFloat iWidth = self.vrCurrentIndicatorImage.size.width;
            CGFloat iHeight = self.vrCurrentIndicatorImage.size.height;
            dot.frame = CGRectMake((contentSize.width - iWidth) / 2.0, (contentSize.height - iHeight) / 2.0, iWidth, iHeight);
        }else{
            dot.image = self.vrPageIndicatorImage;
            
            CGFloat iWidth = self.vrPageIndicatorImage.size.width;
            CGFloat iHeight = self.vrPageIndicatorImage.size.height;
            dot.frame = CGRectMake((contentSize.width - iWidth) / 2.0, (contentSize.height - iHeight) / 2.0, iWidth, iHeight);
        }
    }
}
- (UIImageView *)imageViewForSubview:(UIView *)view currPage:(int)currPage{
    UIImageView *dot = nil;
    if ([view isKindOfClass:[UIView class]]) {
        for (UIView *subview in view.subviews) {
            if ([subview isKindOfClass:[UIImageView class]]) {
                dot = (UIImageView *)subview;
                break;
            }
        }
        
        if (dot == nil) {
            dot = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, view.frame.size.width, view.frame.size.height)];
            
            [view addSubview:dot];
        }
    }else {
        dot = (UIImageView *)view;
    }
    
    return dot;
}


@end
