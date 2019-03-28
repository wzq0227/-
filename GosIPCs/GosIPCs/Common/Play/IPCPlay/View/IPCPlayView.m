//
//  IPCPlayView.m
//  GosIPCs
//
//  Created by shenyuanluo on 2018/12/8.
//  Copyright © 2018 goscam. All rights reserved.
//

#import "IPCPlayView.h"


#define GOS_PTZ_BTN_SCALE                   0.462f   // 控制按钮(高/宽)比例因子
#define GOS_PTZ_VIEW_WIDTH_DIAMETER_SCALE   0.5f     // (控制按钮圆直径/控制View宽)比例因子
#define GOS_PTZ_BTN_WIDTH_DIAMETER_SCALE    0.75f    // (控制按钮宽/控制员直径)比例因子
#define GOS_PTZ_MARGIN_SCALE                0.48f     // '控制按钮中心偏移控制按钮圆中心'比例因子

static CGFloat s_showViewWidth;
static CGFloat s_showViewHeight;
static CGFloat s_ptzCtrlViewOrignY;
static CGFloat s_ptzCtrlViewWidth;
static CGFloat s_ptzCtrlViewHeight;
static CGFloat s_ptzDiameter;
static CGFloat s_ptzMargin;
static CGFloat s_ptzBtnWidth;
static CGFloat s_ptzBtnHeight;
static CGFloat s_ptzTriangleOffset;
static CGFloat s_ptzTriangleWidth;
static CGFloat s_ptzTriangleHeight;
static CGPoint s_ptzCenterShow;
static CGPoint s_ptzCenterHidden;
static CGFloat s_leadingWidth;        //  适配小屏手机声音按钮和拍照按钮距离边框距离

@interface IPCPlayView()
{
    BOOL m_isPTZShowing;
    BOOL m_isCenterCtrlViewShoing;
}
/** 中间控制 View */
@property (nonatomic, readwrite, strong) UIView *centerCtrlView;
/** 底部云台控制 View */
@property (nonatomic, readwrite, strong) UIView *ptzCtrlView;
/** PT - Left 按钮 */
@property (nonatomic, readwrite, strong) EnlargeClickButton *ptzLeftBtn;
/** PT - Right 按钮 */
@property (nonatomic, readwrite, strong) EnlargeClickButton *ptzRightBtn;
/** PT - Up 按钮 */
@property (nonatomic, readwrite, strong) EnlargeClickButton *ptzUpBtn;
/** PT - Down 按钮 */
@property (nonatomic, readwrite, strong) EnlargeClickButton *ptzDownBtn;
/** PT - Left ‘三角形’按钮 */
@property (nonatomic, readwrite, strong) UIImageView *ptzTriangleLeftImgView;
/** PT - Right ‘三角形’按钮 */
@property (nonatomic, readwrite, strong) UIImageView *ptzTriangleRightImgView;
/** PT - Up ‘三角形’按钮 */
@property (nonatomic, readwrite, strong) UIImageView *ptzTriangleUpImgView;
/** PT - Down ‘三角形’按钮 */
@property (nonatomic, readwrite, strong) UIImageView *ptzTriangleDownImgView;
@end

@implementation IPCPlayView

+ (void)load
{
    s_showViewWidth     = GOS_SCREEN_W;
    s_showViewHeight    = s_showViewWidth * GOS_VIDEO_H_W_SCALE;
    s_ptzCtrlViewWidth  = s_showViewWidth;
    s_ptzCtrlViewHeight = GOS_SCREEN_H - s_showViewHeight;
    s_ptzCtrlViewOrignY = s_showViewWidth * GOS_VIDEO_H_W_SCALE + s_ptzCtrlViewHeight;
    s_ptzDiameter       = MIN(s_ptzCtrlViewWidth, s_ptzCtrlViewHeight) * GOS_PTZ_VIEW_WIDTH_DIAMETER_SCALE;
    s_ptzBtnWidth       = s_ptzDiameter * GOS_PTZ_BTN_WIDTH_DIAMETER_SCALE;
    s_ptzBtnHeight      = GOS_PTZ_BTN_SCALE * s_ptzBtnWidth;
    s_ptzMargin         = s_ptzBtnWidth * GOS_PTZ_MARGIN_SCALE;
    s_ptzTriangleOffset = s_ptzBtnHeight * 0.1f;
    s_ptzTriangleWidth  = s_ptzBtnHeight * 0.3f;
    s_ptzTriangleHeight = s_ptzTriangleWidth;
    s_ptzCenterShow     = CGPointMake(s_ptzCtrlViewWidth * 0.5f, s_ptzCtrlViewOrignY - s_ptzCtrlViewHeight * 0.5f);
    s_ptzCenterHidden   = CGPointMake(s_ptzCtrlViewWidth * 0.5f, s_ptzCtrlViewOrignY + s_ptzCtrlViewHeight * 0.5f);;
    s_leadingWidth      = GOS_SCREEN_W == 320?18:38;
}


- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        self.backgroundColor = GOS_VC_BG_COLOR;
        
        [self initParam];
        
        [self addShowView];
        [self addPreImgView];
        [self addOffLineLabel];
        [self addLoadingIndicator];
        [self addRecordingView];
        [self addRecordingLabel];
        [self addLullabyBtn];
        
        [self addCenterCtrlView];
        [self addTalkbackBtn];
        [self addAudioBtn];
        [self addSnapshotBtn];
        
        [self addPTZCtrlView];
        [self addPTZLeftBtn];
        [self addPTZRightBtn];
        [self addPTZUpBtn];
        [self addPTZDownBtn];
    }
    return self;
}

- (void)dealloc
{
    GosLog(@"---------- IPCPlayView dealloc ----------");
}

- (void)initParam
{
    m_isPTZShowing           = NO;
    m_isCenterCtrlViewShoing = NO;
}


#pragma mark -- 设置显示中间控制视图
- (void)showCenterCtrlView
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [NSObject cancelPreviousPerformRequestsWithTarget:self
                                                 selector:@selector(centerCtrlViewDismiss)
                                                   object:nil];
        [self centerCtrlViewShow];
        
        [self performSelector:@selector(centerCtrlViewDismiss)
                   withObject:nil
                   afterDelay:CENTER_VIEW_SHOW_INTERVAL];
    });
}

#pragma mark -- 设置声音按钮 Icon
- (void)configSoundBtnIcon:(BOOL)isOpen
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (NO == isOpen)
        {
            [self.audioBtn setBackgroundImage:GOS_IMAGE(@"icon_mute_normal")
                                     forState:UIControlStateNormal];
            [self.audioBtn setBackgroundImage:GOS_IMAGE(@"icon_mute_pressed")
                                     forState:UIControlStateHighlighted];
            [self.audioBtn setBackgroundImage:GOS_IMAGE(@"icon_mute_disabled")
                                     forState:UIControlStateDisabled];
        }
        else
        {
            [self.audioBtn setBackgroundImage:GOS_IMAGE(@"icon_sound_on_normal")
                                     forState:UIControlStateNormal];
            [self.audioBtn setBackgroundImage:GOS_IMAGE(@"icon_sound_on_pressed")
                                     forState:UIControlStateHighlighted];
            [self.audioBtn setBackgroundImage:GOS_IMAGE(@"icon_sound_on_disabled")
                                     forState:UIControlStateDisabled];
        }
    });
}

#pragma mark -- 显示中间控制 View
- (void)centerCtrlViewShow
{
    if (YES == m_isCenterCtrlViewShoing)
    {
        return;
    }
    GOS_WEAK_SELF;
    [UIView animateWithDuration:0.25f
                     animations:^{
                         
                         GOS_STRONG_SELF;
                         [strongSelf.centerCtrlView mas_remakeConstraints:^(MASConstraintMaker *make) {
                             
                             make.left.right.mas_equalTo(strongSelf.videoShowView);
                             make.bottom.mas_equalTo(strongSelf.videoShowView.mas_bottom);
                             make.height.mas_equalTo(@(40));
                         }];
                         strongSelf.centerCtrlView.hidden = NO;
                     }
                     completion:nil];
    m_isCenterCtrlViewShoing = YES;
}

#pragma mark -- 隐藏中间控制 View
- (void)centerCtrlViewDismiss
{
    if (NO == m_isCenterCtrlViewShoing)
    {
        return;
    }
    GOS_WEAK_SELF;
    [UIView animateWithDuration:0.25f
                     animations:^{
                         
                         GOS_STRONG_SELF;
                         strongSelf.centerCtrlView.hidden = YES;
                         [strongSelf.centerCtrlView mas_remakeConstraints:^(MASConstraintMaker *make) {
                             
                             make.left.right.mas_equalTo(strongSelf.videoShowView);
                             make.bottom.mas_equalTo(strongSelf.videoShowView.mas_bottom).offset(40.f);
                             make.height.mas_equalTo(@(40));
                         }];
                     }
                     completion:nil];
    m_isCenterCtrlViewShoing = NO;
}


#pragma mark -- 设置云台控制视图是否隐藏
- (void)configPTZViewHidden:(BOOL)isHidden
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (NO == isHidden)
        {
            [self ptzShow];
        }
        else
        {
            [self ptzDismiss];
        }
    });
}

#pragma mark -- 显示 PTZ
- (void)ptzShow
{
    if (YES == m_isPTZShowing)
    {
        return;
    }
    GOS_WEAK_SELF;
    [UIView animateWithDuration:0.25f
                     animations:^{
                         
                         GOS_STRONG_SELF;
                         strongSelf.ptzCtrlView.center = s_ptzCenterShow;
                     }
                     completion:nil];
    m_isPTZShowing = YES;
}

#pragma mark -- 隐藏 PTZ
- (void)ptzDismiss
{
    if (NO == m_isPTZShowing)
    {
        return;
    }
    GOS_WEAK_SELF;
    [UIView animateWithDuration:0.25f
                     animations:^{
                         
                         GOS_STRONG_SELF;
                         strongSelf.ptzCtrlView.center = s_ptzCenterHidden;
                     }
                     completion:nil];
    m_isPTZShowing = NO;
}


#pragma mark -- 设置录像按钮样式(录像为红，不录像为白)
- (void)configRecordSelect:(BOOL)isSelect
{
    GOS_WEAK_SELF;
    dispatch_async(dispatch_get_main_queue(), ^{
        
        GOS_STRONG_SELF;
        if (isSelect) {
            [strongSelf.recordVideoBtn setBackgroundImage:GOS_IMAGE(@"icon_video_selected")
                                                 forState:UIControlStateNormal];
        }else{
            [strongSelf.recordVideoBtn setBackgroundImage:GOS_IMAGE(@"icon_video")
                                                 forState:UIControlStateNormal];
        }
    });
}


#pragma mark -- 录像时REG文字显示
- (void)configRecoringLabeHidden:(BOOL)isHidden
{
    GOS_WEAK_SELF;
    dispatch_async(dispatch_get_main_queue(), ^{
        
        GOS_STRONG_SELF;
        strongSelf.recordingLabel.hidden = isHidden;
    });
}


#pragma mark -- 是否有云台控制能力集
- (void)configHasPTZ:(BOOL)hasPTZ{
    GOS_WEAK_SELF;
    dispatch_async(dispatch_get_main_queue(), ^{
        
        GOS_STRONG_SELF;
        strongSelf.ptzViewBtn.hidden = !hasPTZ;
    });
}
#pragma mark -- 添加视频渲染 View
- (void)addShowView
{
    _videoShowView = [[SYFullScreenView alloc] initWithFrame:CGRectMake(0, 0, s_showViewWidth, s_showViewHeight)];
    _videoShowView.backgroundColor = [UIColor blackColor];
    [self addSubview:_videoShowView];
    
    // 添加单击手势
    UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                             action:@selector(showCenterCtrlView)];
    [_videoShowView addGestureRecognizer:tapGes];
}

#pragma mark -- 添加视频预加载 imageView
- (void)addPreImgView
{
    _previewImgView = [[UIImageView alloc] init];
    _previewImgView.contentMode = UIViewContentModeScaleAspectFit;
    [self.videoShowView addSubview:_previewImgView];
    
    GOS_WEAK_SELF;
    [_previewImgView mas_makeConstraints:^(MASConstraintMaker *make)
     {
         GOS_STRONG_SELF;
         make.left.right.top.bottom.mas_equalTo(strongSelf.videoShowView);
     }];
}

#pragma mark -- 添加设备离线提示 Label
- (void)addOffLineLabel
{
    _offlineTipsLabel = [[UILabel alloc] init];
    _offlineTipsLabel.numberOfLines = 0;
    _offlineTipsLabel.textColor = GOS_WHITE_COLOR;
    _offlineTipsLabel.font = GOS_FONT(17);
    _offlineTipsLabel.textAlignment = NSTextAlignmentCenter;
    [self.videoShowView addSubview:_offlineTipsLabel];
    
    GOS_WEAK_SELF;
    [_offlineTipsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        GOS_STRONG_SELF;
        make.centerX.mas_equalTo(strongSelf.videoShowView.mas_centerX);
        make.centerY.mas_equalTo(strongSelf.videoShowView.mas_centerY);
    }];
}

#pragma mark -- 添加加载指示 View
- (void)addLoadingIndicator
{
    _loadingIndicator = [[UIActivityIndicatorView alloc] init];
    _loadingIndicator.color = GOS_WHITE_COLOR;
    [self.videoShowView addSubview:_loadingIndicator];
    
    GOS_WEAK_SELF;
    [_loadingIndicator mas_makeConstraints:^(MASConstraintMaker *make) {
        
        GOS_STRONG_SELF;
        make.centerX.mas_equalTo(strongSelf.videoShowView.mas_centerX);
        make.centerY.mas_equalTo(strongSelf.videoShowView.mas_centerY);
    }];
}

#pragma mark -- 录像提示红点 View
- (void)addRecordingView
{
    _recordingView = [[UIView alloc] init];
    _recordingView.backgroundColor = GOS_COLOR_RGB(0xFF2424);
    _recordingView.layer.cornerRadius = 5.0f;
    _recordingView.layer.masksToBounds = YES;
    [self.videoShowView addSubview:_recordingView];
    
    GOS_WEAK_SELF;
    [_recordingView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        GOS_STRONG_SELF;
        make.top.mas_equalTo(strongSelf.videoShowView.mas_top).offset(10.0f);
        make.right.mas_equalTo(strongSelf.videoShowView.mas_right).offset(-38.0f);
        make.width.height.mas_equalTo(@(10));
    }];
}

#pragma mark -- 录像提示 Label
- (void)addRecordingLabel
{
    _recordingLabel               = [[UILabel alloc] init];
    _recordingLabel.numberOfLines = 0;
    _recordingLabel.textColor     = GOS_WHITE_COLOR;
    _recordingLabel.font          = GOS_FONT(10);
    _recordingLabel.text          = @"REG";
    _recordingLabel.textAlignment = NSTextAlignmentLeft;
    _recordingLabel.hidden        = YES;
    [self.videoShowView addSubview:_recordingLabel];
    
    GOS_WEAK_SELF;
    [_recordingLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        GOS_STRONG_SELF;
        make.centerY.mas_equalTo(strongSelf.recordingView.mas_centerY);
        make.leading.mas_equalTo(strongSelf.recordingView.mas_trailing).offset(5.0f);
    }];
}

#pragma mark -- 摇篮曲按钮
- (void)addLullabyBtn
{
    _lullabyBtn = [EnlargeClickButton buttonWithType:UIButtonTypeCustom];
    [_lullabyBtn setBackgroundImage:GOS_IMAGE(@"icon_music_off")
                           forState:UIControlStateNormal];
    [_lullabyBtn addTarget:self
                    action:@selector(lullabyBtnClick)
          forControlEvents:UIControlEventTouchUpInside];
    [self.videoShowView addSubview:_lullabyBtn];
    
    GOS_WEAK_SELF;
    [_lullabyBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        GOS_STRONG_SELF;
        make.top.mas_equalTo(strongSelf.recordingView.mas_bottom).offset(10.0f);
        make.centerX.mas_equalTo(strongSelf.recordingView.mas_centerX);
        make.width.height.mas_equalTo(@(22));
    }];
}


#pragma mark - 中间控制 View
#pragma mark -- 添加中间控制 View
- (void)addCenterCtrlView
{
    _centerCtrlView = [[UIView alloc] init];
    _centerCtrlView.backgroundColor = GOS_COLOR_RGBA(0, 0, 0, 0.6);
    [self.videoShowView addSubview:_centerCtrlView];
    _centerCtrlView.hidden = YES;
    
    GOS_WEAK_SELF;
    [_centerCtrlView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        GOS_STRONG_SELF;
        make.left.right.mas_equalTo(strongSelf.videoShowView);
        make.bottom.mas_equalTo(strongSelf.videoShowView.mas_bottom).offset(40.0f);
        make.height.mas_equalTo(@(40));
    }];
    
    [self addRecordVideoBtn];
    [self addPTZViewBtn];
    [self addVideoQualityBtn];
    [self addTempImgView];
    [self addTempLabel];
}

#pragma mark -- 添加录像按钮
- (void)addRecordVideoBtn
{
    _recordVideoBtn = [EnlargeClickButton buttonWithType:UIButtonTypeCustom];
    [_recordVideoBtn setBackgroundImage:GOS_IMAGE(@"icon_video")
                               forState:UIControlStateNormal];
    [_recordVideoBtn addTarget:self
                        action:@selector(recordVideoBtnClick)
              forControlEvents:UIControlEventTouchUpInside];
    [self.centerCtrlView addSubview:_recordVideoBtn];
    
    GOS_WEAK_SELF;
    [_recordVideoBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        GOS_STRONG_SELF;
        make.centerY.mas_equalTo(strongSelf.centerCtrlView.mas_centerY);
        make.centerX.mas_equalTo(strongSelf.centerCtrlView.mas_centerX).multipliedBy(0.4f);
        make.width.height.mas_equalTo(@(22));
    }];
}

#pragma mark -- 添加控制台View 显示 按钮
- (void)addPTZViewBtn
{
    _ptzViewBtn = [EnlargeClickButton buttonWithType:UIButtonTypeCustom];
    [_ptzViewBtn setBackgroundImage:GOS_IMAGE(@"icon_direction")
                           forState:UIControlStateNormal];
    [_ptzViewBtn addTarget:self
                    action:@selector(ptzViewBtnClick)
          forControlEvents:UIControlEventTouchUpInside];
    [self.centerCtrlView addSubview:_ptzViewBtn];
    
    GOS_WEAK_SELF;
    [_ptzViewBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        GOS_STRONG_SELF;
        make.centerY.mas_equalTo(strongSelf.centerCtrlView.mas_centerY);
        make.centerX.mas_equalTo(strongSelf.centerCtrlView.mas_centerX).multipliedBy(0.8f);
        make.width.height.mas_equalTo(@(22));
    }];
}

#pragma mark -- 添加视频质量切换按钮
- (void)addVideoQualityBtn
{
    _videoQualityBtn = [EnlargeClickButton buttonWithType:UIButtonTypeCustom];
    [_videoQualityBtn setBackgroundImage:GOS_IMAGE(@"icon_annulus")
                                forState:UIControlStateNormal];
    [_videoQualityBtn setTitle:DPLocalizedString(@"VideoQualitySD")
                      forState:UIControlStateNormal];
    _videoQualityBtn.titleLabel.font = GOS_FONT(9);
    [_videoQualityBtn addTarget:self
                         action:@selector(videoQualityBtnClick)
               forControlEvents:UIControlEventTouchUpInside];
    [self.centerCtrlView addSubview:_videoQualityBtn];
    
    GOS_WEAK_SELF;
    [_videoQualityBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        GOS_STRONG_SELF;
        make.centerY.mas_equalTo(strongSelf.centerCtrlView.mas_centerY);
        make.centerX.mas_equalTo(strongSelf.centerCtrlView.mas_centerX).multipliedBy(1.2f);
        make.width.height.mas_equalTo(@(22));
    }];
}


#pragma mark -- 添加温度指示 ImageView
- (void)addTempImgView
{
    _tempImgView = [[UIImageView alloc] initWithImage:GOS_IMAGE(@"icon_temp_green")];
    
    [self.centerCtrlView addSubview:_tempImgView];
    
    GOS_WEAK_SELF;
    [_tempImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        GOS_STRONG_SELF;
        make.centerY.mas_equalTo(strongSelf.centerCtrlView.mas_centerY);
        make.centerX.mas_equalTo(strongSelf.centerCtrlView.mas_centerX).multipliedBy(1.6f);
        make.width.height.mas_equalTo(@(22));
    }];
}

#pragma mark -- 添加温度度数 Label
- (void)addTempLabel
{
    _tempLabel               = [[UILabel alloc] init];
    _tempLabel.numberOfLines = 0;
    _tempLabel.textAlignment = NSTextAlignmentLeft;
    _tempLabel.textColor     = GOS_WHITE_COLOR;
    _tempLabel.font          = GOS_FONT(8);
    _tempLabel.text          = @"30°C";
    [self.centerCtrlView addSubview:_tempLabel];
    
    GOS_WEAK_SELF;
    [_tempLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        GOS_STRONG_SELF;
        make.top.mas_equalTo(strongSelf.tempImgView.mas_top);
        make.leading.mas_equalTo(strongSelf.tempImgView.mas_trailing).offset(-7.0f);
    }];
}


#pragma mark - 底部控制 View
#pragma mark -- 添加控制台View 显示 按钮
- (void)addTalkbackBtn
{
    _talkbackBtn = [EnlargeClickButton buttonWithType:UIButtonTypeCustom];
    [_talkbackBtn setBackgroundImage:GOS_IMAGE(@"icon_mic_noraml")
                            forState:UIControlStateNormal];
    [_talkbackBtn setBackgroundImage:GOS_IMAGE(@"icon_mic_pressed")
                            forState:UIControlStateHighlighted];
    [_talkbackBtn setBackgroundImage:GOS_IMAGE(@"icon_mic_disabled")
                            forState:UIControlStateDisabled];
    [_talkbackBtn addTarget:self
                     action:@selector(talkbackBtnTouchDown)
           forControlEvents:UIControlEventTouchDown];
    [_talkbackBtn addTarget:self
                     action:@selector(talkbackBtnTouchDragExit)
           forControlEvents:UIControlEventTouchDragExit];
    [_talkbackBtn addTarget:self
                     action:@selector(talkbackBtnClick)
           forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_talkbackBtn];
    
    GOS_WEAK_SELF;
    [_talkbackBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        GOS_STRONG_SELF;
        make.centerX.mas_equalTo(strongSelf.mas_centerX);
        make.width.height.mas_equalTo(@(100));
        make.bottom.mas_equalTo(strongSelf.mas_bottom).offset(-100.0f);
    }];
}
#pragma mark -- 添加声音按钮
- (void)addAudioBtn
{
    _audioBtn = [EnlargeClickButton buttonWithType:UIButtonTypeCustom];
    [_audioBtn addTarget:self
                  action:@selector(audioBtnClick)
        forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_audioBtn];
    [self configSoundBtnIcon:NO];
    
    GOS_WEAK_SELF;
    [_audioBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        GOS_STRONG_SELF;
        //        make.centerX.mas_equalTo(strongSelf.mas_centerX).multipliedBy(0.5f);
        make.right.mas_equalTo(strongSelf.talkbackBtn.mas_left).offset(-s_leadingWidth);
        make.width.height.mas_equalTo(@(80));
        make.centerY.mas_equalTo(strongSelf.talkbackBtn.mas_centerY);
    }];
}

#pragma mark -- 添加拍照按钮
- (void)addSnapshotBtn
{
    _snapshotBtn = [EnlargeClickButton buttonWithType:UIButtonTypeCustom];
    [_snapshotBtn setBackgroundImage:GOS_IMAGE(@"icon_photo_noraml")
                            forState:UIControlStateNormal];
    [_snapshotBtn setBackgroundImage:GOS_IMAGE(@"icon_photo_presssed")
                            forState:UIControlStateHighlighted];
    [_snapshotBtn setBackgroundImage:GOS_IMAGE(@"icon_photo_disabled")
                            forState:UIControlStateDisabled];
    [_snapshotBtn addTarget:self
                     action:@selector(snapshotBtnClick)
           forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_snapshotBtn];
    
    GOS_WEAK_SELF;
    [_snapshotBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        GOS_STRONG_SELF;
        //        make.centerX.mas_equalTo(strongSelf.mas_centerX).multipliedBy(1.5f);
        make.left.mas_equalTo(strongSelf.talkbackBtn.mas_right).offset(s_leadingWidth);
        make.width.height.mas_equalTo(@(80));
        make.centerY.mas_equalTo(strongSelf.talkbackBtn.mas_centerY);
    }];
}


#pragma mark - 底部云台控制 View
- (void)addPTZCtrlView
{
    CGRect ptzvFrame = CGRectMake(0, s_ptzCtrlViewOrignY, s_ptzCtrlViewWidth, s_ptzCtrlViewHeight);
    _ptzCtrlView = [[UIView alloc] initWithFrame:ptzvFrame];
    _ptzCtrlView.backgroundColor = GOS_VC_BG_COLOR;
    [self addSubview:_ptzCtrlView];
}

#pragma mark -- 云台转‘左’按钮
- (void)addPTZLeftBtn
{
    _ptzLeftBtn = [EnlargeClickButton buttonWithType:UIButtonTypeCustom];
    [_ptzLeftBtn setBackgroundImage:GOS_IMAGE(@"btn_annulus_left")
                           forState:UIControlStateNormal];
    [_ptzLeftBtn addTarget:self
                    action:@selector(ptzLeftBtnClick)
          forControlEvents:UIControlEventTouchUpInside];
    [self.ptzCtrlView addSubview:_ptzLeftBtn];
    
    GOS_WEAK_SELF;
    [_ptzLeftBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        GOS_STRONG_SELF;
        make.centerX.mas_equalTo(strongSelf.ptzCtrlView.mas_centerX).offset(-s_ptzMargin);
        make.centerY.mas_equalTo(strongSelf.ptzCtrlView.mas_centerY);
        make.width.mas_equalTo(@(s_ptzBtnHeight));
        make.height.mas_equalTo(@(s_ptzBtnWidth));
    }];
    
    // 三角箭头
    _ptzTriangleLeftImgView = [[UIImageView alloc] initWithImage:GOS_IMAGE(@"btn_triangles_left")
                                                highlightedImage:GOS_IMAGE(@"btn_triangles_left")];
    // 添加单击手势
    UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                             action:@selector(ptzLeftBtnClick)];
    [_ptzTriangleLeftImgView addGestureRecognizer:tapGes];
    [self.ptzLeftBtn addSubview:_ptzTriangleLeftImgView];
    
    [_ptzTriangleLeftImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        GOS_STRONG_SELF;
        make.centerX.mas_equalTo(strongSelf.ptzLeftBtn.mas_centerX).offset(-s_ptzTriangleOffset);
        make.centerY.mas_equalTo(strongSelf.ptzLeftBtn.mas_centerY);
        make.width.mas_equalTo(@(s_ptzTriangleWidth));
        make.height.mas_equalTo(@(s_ptzTriangleHeight));
    }];
}

#pragma mark -- 云台转‘右’按钮
- (void)addPTZRightBtn
{
    _ptzRightBtn = [EnlargeClickButton buttonWithType:UIButtonTypeCustom];
    [_ptzRightBtn setBackgroundImage:GOS_IMAGE(@"btn_annulus_right")
                            forState:UIControlStateNormal];
    [_ptzRightBtn addTarget:self
                     action:@selector(ptzRightBtnClick)
           forControlEvents:UIControlEventTouchUpInside];
    [self.ptzCtrlView addSubview:_ptzRightBtn];
    
    GOS_WEAK_SELF;
    [_ptzRightBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        GOS_STRONG_SELF;
        make.centerX.mas_equalTo(strongSelf.ptzCtrlView.mas_centerX).offset(s_ptzMargin);
        make.centerY.mas_equalTo(strongSelf.ptzCtrlView.mas_centerY);
        make.width.mas_equalTo(@(s_ptzBtnHeight));
        make.height.mas_equalTo(@(s_ptzBtnWidth));
    }];
    
    // 三角箭头
    _ptzTriangleRightImgView = [[UIImageView alloc] initWithImage:GOS_IMAGE(@"btn_triangles_right")
                                                 highlightedImage:GOS_IMAGE(@"btn_triangles_right")];
    // 添加单击手势
    UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                             action:@selector(ptzRightBtnClick)];
    [_ptzTriangleRightImgView addGestureRecognizer:tapGes];
    [self.ptzRightBtn addSubview:_ptzTriangleRightImgView];
    
    [_ptzTriangleRightImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        GOS_STRONG_SELF;
        make.centerX.mas_equalTo(strongSelf.ptzRightBtn.mas_centerX).offset(s_ptzTriangleOffset);
        make.centerY.mas_equalTo(strongSelf.ptzRightBtn.mas_centerY);
        make.width.mas_equalTo(@(s_ptzTriangleWidth));
        make.height.mas_equalTo(@(s_ptzTriangleHeight));
    }];
}

#pragma mark -- 云台转’上‘按钮
- (void)addPTZUpBtn
{
    _ptzUpBtn = [EnlargeClickButton buttonWithType:UIButtonTypeCustom];
    [_ptzUpBtn setBackgroundImage:GOS_IMAGE(@"btn_annulus_up")
                         forState:UIControlStateNormal];
    [_ptzUpBtn addTarget:self
                  action:@selector(ptzUpBtnClick)
        forControlEvents:UIControlEventTouchUpInside];
    [self.ptzCtrlView addSubview:_ptzUpBtn];
    
    GOS_WEAK_SELF;
    [_ptzUpBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        GOS_STRONG_SELF;
        make.centerX.mas_equalTo(strongSelf.ptzCtrlView.mas_centerX);
        make.centerY.mas_equalTo(strongSelf.ptzCtrlView.mas_centerY).offset(-s_ptzMargin);
        make.width.mas_equalTo(@(s_ptzBtnWidth));
        make.height.mas_equalTo(@(s_ptzBtnHeight));
    }];
    
    // 三角箭头
    _ptzTriangleUpImgView = [[UIImageView alloc] initWithImage:GOS_IMAGE(@"btn_triangles_up")
                                              highlightedImage:GOS_IMAGE(@"btn_triangles_up")];
    // 添加单击手势
    UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                             action:@selector(ptzUpBtnClick)];
    [_ptzTriangleRightImgView addGestureRecognizer:tapGes];
    [self.ptzUpBtn addSubview:_ptzTriangleUpImgView];
    
    [_ptzTriangleUpImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        GOS_STRONG_SELF;
        make.centerX.mas_equalTo(strongSelf.ptzUpBtn.mas_centerX);
        make.centerY.mas_equalTo(strongSelf.ptzUpBtn.mas_centerY).offset(-s_ptzTriangleOffset);
        make.width.mas_equalTo(@(s_ptzTriangleWidth));
        make.height.mas_equalTo(@(s_ptzTriangleHeight));
    }];
}

#pragma mark -- 云台转‘下’按钮
- (void)addPTZDownBtn
{
    _ptzDownBtn = [EnlargeClickButton buttonWithType:UIButtonTypeCustom];
    [_ptzDownBtn setBackgroundImage:GOS_IMAGE(@"btn_annulus_down")
                           forState:UIControlStateNormal];
    [_ptzDownBtn addTarget:self
                    action:@selector(ptzDownBtnClick)
          forControlEvents:UIControlEventTouchUpInside];
    [self.ptzCtrlView addSubview:_ptzDownBtn];
    
    GOS_WEAK_SELF;
    [_ptzDownBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        GOS_STRONG_SELF;
        make.centerX.mas_equalTo(strongSelf.ptzCtrlView.mas_centerX);
        make.centerY.mas_equalTo(strongSelf.ptzCtrlView.mas_centerY).offset(s_ptzMargin);
        make.width.mas_equalTo(@(s_ptzBtnWidth));
        make.height.mas_equalTo(@(s_ptzBtnHeight));
    }];
    
    // 三角箭头
    _ptzTriangleDownImgView = [[UIImageView alloc] initWithImage:GOS_IMAGE(@"btn_triangles_down")
                                                highlightedImage:GOS_IMAGE(@"btn_triangles_down")];
    // 添加单击手势
    UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                             action:@selector(ptzDownBtnClick)];
    [_ptzTriangleDownImgView addGestureRecognizer:tapGes];
    [self.ptzDownBtn addSubview:_ptzTriangleDownImgView];
    
    [_ptzTriangleDownImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        GOS_STRONG_SELF;
        make.centerX.mas_equalTo(strongSelf.ptzDownBtn.mas_centerX);
        make.centerY.mas_equalTo(strongSelf.ptzDownBtn.mas_centerY).offset(s_ptzTriangleOffset);
        make.width.mas_equalTo(@(s_ptzTriangleWidth));
        make.height.mas_equalTo(@(s_ptzTriangleHeight));
    }];
}



#pragma mark - 按钮事件中心
#pragma mark -- 摇篮曲按钮事件
- (void)lullabyBtnClick
{
    if (!self.isOffLine) {
        return;
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(lullabyBtnAction)])
    {
        [self.delegate lullabyBtnAction];
    }
}

#pragma mark -- 录像按钮事件
- (void)recordVideoBtnClick
{
    if (!self.isOffLine) {
        return;
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(recordVideoBtnAction)])
    {
        [self.delegate recordVideoBtnAction];
    }
}

#pragma mark -- 控制台View 显示按钮事件
- (void)ptzViewBtnClick
{
    if (!self.isOffLine) {
        return;
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(ptzViewBtnAction)])
    {
        [self.delegate ptzViewBtnAction];
    }
}

#pragma mark -- 视频质量切换按钮事件
- (void)videoQualityBtnClick
{
    if (!self.isOffLine) {
        return;
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(videoQualityBtnAction)])
    {
        [self.delegate videoQualityBtnAction];
    }
}

#pragma mark -- 声音按钮事件
- (void)audioBtnClick
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(audioBtnAction)])
    {
        [self.delegate audioBtnAction];
    }
}

#pragma mark -- 对讲按钮'TouchDown'事件
- (void)talkbackBtnTouchDown
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(talkbackBtnTouchDownAction)])
    {
        [self.delegate talkbackBtnTouchDownAction];
    }
}

#pragma mark -- 对讲按钮'TouchDragExit'事件
- (void)talkbackBtnTouchDragExit
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(talkbackBtnToucDragExitAction)])
    {
        [self.delegate talkbackBtnToucDragExitAction];
    }
}

#pragma mark -- 对讲按钮'TouchUpInside'事件
- (void)talkbackBtnClick
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(talkbackBtnAction)])
    {
        [self.delegate talkbackBtnAction];
    }
}

#pragma mark -- 拍照按钮事件
- (void)snapshotBtnClick
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(snapshotBtnAction)])
    {
        [self.delegate snapshotBtnAction];
    }
}

#pragma mark -- 云台转‘左’按钮事件
- (void)ptzLeftBtnClick
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(ptzBtnAction:)])
    {
        [self.delegate ptzBtnAction:GosPTZD_left];
    }
}

#pragma mark -- 云台转‘右’按钮事件
- (void)ptzRightBtnClick
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(ptzBtnAction:)])
    {
        [self.delegate ptzBtnAction:GosPTZD_right];
    }
}

#pragma mark -- 云台转‘上’按钮事件
- (void)ptzUpBtnClick
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(ptzBtnAction:)])
    {
        [self.delegate ptzBtnAction:GosPTZD_up];
    }
}

#pragma mark -- 云台转‘下’按钮事件
- (void)ptzDownBtnClick
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(ptzBtnAction:)])
    {
        [self.delegate ptzBtnAction:GosPTZD_down];
    }
}




#pragma mark -- 设置对讲按钮状态
//bykuangweiqun 2019-03-08
//@param isFullDuplex 是否是全双工
//@param isTalkingOnHalfDuplex 是否正在对讲（半双工）
//@param hasConnected 设备是否已经建立连接
- (void)configTalkBtnIcon:(BOOL)isFullDuplex
      TalkingOnHalfDuplex:(BOOL)isTalkingOnHalfDuplex
             hasConnected:(BOOL)hasConnected
{
    UIImage * normalImg = [UIImage imageNamed:@""];
    UIImage * highlighteImg = [UIImage imageNamed:@""];
    // 全双工 = NO  当前半双工
    if (NO == isFullDuplex)
    {
        // 正在对讲 = NO 当前未对讲
        if(NO == isTalkingOnHalfDuplex)
        {
            normalImg = GOS_IMAGE(@"icon_mic_noraml");
        }
        else
        {
            normalImg = GOS_IMAGE(@"icon_mic_pressed");
        }
        if (NO == hasConnected)
        {
            normalImg = GOS_IMAGE(@"icon_mic_disabled");
        }
        highlighteImg = GOS_IMAGE(@"icon_mic_pressed");
    }
    else
    {
        if (NO == isTalkingOnHalfDuplex)
        {
            normalImg = GOS_IMAGE(@"icon_hangup_normal");
            highlighteImg = GOS_IMAGE(@"icon_hangup_pressed");
            GosLog(@"全双工未在对讲");
        }
        else
        {
            normalImg = GOS_IMAGE(@"icon_hangup_pressed");
            highlighteImg = GOS_IMAGE(@"icon_on_the_line_pressed");
            GosLog(@"全双工正在对讲");
        }
        if (NO == hasConnected)
        {
            normalImg = GOS_IMAGE(@"icon_hangup_disabled");
        }
        highlighteImg = GOS_IMAGE(@"");
    }
    GOS_WEAK_SELF;
    dispatch_async(dispatch_get_main_queue(), ^{
        
        GOS_STRONG_SELF;
        [strongSelf.talkbackBtn setBackgroundImage:normalImg
                                          forState:UIControlStateNormal];
        [strongSelf.talkbackBtn setBackgroundImage:highlighteImg
                                          forState:UIControlStateHighlighted];
    });
}

@end
