//
//  GosHUDView.m
//  GosIPCs
//
//  Created by shenyuanluo on 2018/11/22.
//  Copyright © 2018 goscam. All rights reserved.
//

#import "GosHUDView.h"

#define HUD_VIEW_DEFAULT_FRAME    CGRectMake(0, 0, GOS_SCREEN_W, GOS_SCREEN_H)
#define CONTENT_VIEW_W      200
#define CONTENT_VIEW_H      120
#define IMG_VIEW_W          54
#define IMG_VIEW_H          54

#define ANIMATION_DURATION  0.3f
#define HUD_VIEW_SHOW_DURATION 1.5   // 显示时长（单位：秒）
#define SCALE_DIVISOR       1.5f    // 缩放比例因子

@interface GosHUDView()
{
    BOOL m_isShowing;
}

@property (nonatomic, readwrite, strong) UIView *contentView;
@property (nonatomic, readwrite, strong) UIImageView *imgView;
@property (nonatomic, readwrite, strong) UILabel *statusLabel;
@property (nonatomic, readwrite, strong) UIImage *successImg;
@property (nonatomic, readwrite, strong) UIImage *errorImg;
@end

@implementation GosHUDView

+ (void)showSuccessWithStatus:(NSString *)status
{
    if (IS_EMPTY_STRING(status))
    {
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [[GosHUDView sharedHudView] showWithStatus:status
                                             image:[GosHUDView sharedHudView].successImg];
    });
}

+ (void)showErrorWithStatus:(NSString *)status
{
    if (IS_EMPTY_STRING(status))
    {
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [[GosHUDView sharedHudView] showWithStatus:status
                                             image:[GosHUDView sharedHudView].errorImg];
    });
}

+ (instancetype)sharedHudView
{
    static GosHUDView *g_hudView;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        if (!g_hudView)
        {
            g_hudView = [[GosHUDView alloc] init];
        }
    });
    return g_hudView;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:HUD_VIEW_DEFAULT_FRAME])
    {
        self.backgroundColor   = GOS_COLOR_RGBA(0, 0, 0, 0.5);
        [self.contentView addSubview:self.imgView];
        [self.contentView addSubview:self.statusLabel];
        [self addSubview:self.contentView];
    }
    return self;
}

#pragma mark -- 显示
- (void)showWithStatus:(NSString *)status
                 image:(UIImage *)img
{
    if (IS_EMPTY_STRING(status))
    {
        return;
    }
    if (YES == m_isShowing)
    {
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        
        self.imgView.image         = img;
        self.statusLabel.text      = status;
        self.contentView.transform = CGAffineTransformScale(self.contentView.transform, SCALE_DIVISOR, SCALE_DIVISOR);
        UIWindow *rootWindow  = [UIApplication sharedApplication].keyWindow;
        [rootWindow addSubview:self];
        [rootWindow bringSubviewToFront:self];
    });
    
    __weak typeof(self)weakSelf = self;

    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:ANIMATION_DURATION
                              delay:0
                            options:(UIViewAnimationOptions) (UIViewAnimationOptionAllowUserInteraction | UIViewAnimationCurveEaseIn | UIViewAnimationOptionBeginFromCurrentState)
                         animations:^{
                             __strong typeof(weakSelf)strongSelf = weakSelf;
                             if (!strongSelf)
                             {
                                 return ;
                             }
                             strongSelf.contentView.alpha = 1.0f;
                             strongSelf.contentView.transform = CGAffineTransformScale(strongSelf.contentView.transform, 1/SCALE_DIVISOR, 1/SCALE_DIVISOR);
                         }
                         completion:^(BOOL finished) {
                             __strong typeof(weakSelf)strongSelf = weakSelf;
                             if (!strongSelf)
                             {
                                 return ;
                             }
                             if (YES == finished)
                             {
                                 [strongSelf performSelector:@selector(dismissHudView)
                                                  withObject:nil
                                                  afterDelay:HUD_VIEW_SHOW_DURATION];
                             }
                         }];

    });
    [self setNeedsDisplay];
    m_isShowing = YES;
}

#pragma mark -- 隐藏
- (void)dismissHudView
{
    if (NO == m_isShowing)
    {
        return;
    }
    __weak typeof(self)weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:ANIMATION_DURATION
                              delay:0
                            options:(UIViewAnimationOptions) (UIViewAnimationOptionAllowUserInteraction | UIViewAnimationCurveEaseOut | UIViewAnimationOptionBeginFromCurrentState)
                         animations:^{
                             __strong typeof(weakSelf)strongSelf = weakSelf;
                             if (!strongSelf)
                             {
                                 return ;
                             }
                             strongSelf.contentView.transform = CGAffineTransformScale(strongSelf.contentView.transform, 1/SCALE_DIVISOR, 1/SCALE_DIVISOR);
                             strongSelf.contentView.alpha = 0.0f;
                         }
                         completion:^(BOOL finished) {
                             
                             __strong typeof(weakSelf)strongSelf = weakSelf;
                             if (!strongSelf)
                             {
                                 return ;
                             }
                             if (YES == finished)
                             {
                                 strongSelf.contentView.transform = CGAffineTransformScale(strongSelf.contentView.transform, SCALE_DIVISOR, SCALE_DIVISOR);
                                 [strongSelf removeFromSuperview];
                                 
                             }
                         }];

    });
    
    m_isShowing = NO;
}

#pragma mark - 懒加载
- (UIView *)contentView
{
    if (!_contentView)
    {
        CGRect cvFrame                   = CGRectMake(0, 0, CONTENT_VIEW_W, CONTENT_VIEW_H);
        _contentView                     = [[UIView alloc] initWithFrame:cvFrame];
        _contentView.center              = self.center;
        _contentView.backgroundColor     = GOS_WHITE_COLOR;
        _contentView.layer.cornerRadius  = 8;
        _contentView.layer.masksToBounds = YES;
    }
    return _contentView;
}

- (UIImageView *)imgView
{
    if (!_imgView)
    {
        CGRect imgvFrame = CGRectMake(73, 12, IMG_VIEW_W, IMG_VIEW_H);
        _imgView = [[UIImageView alloc] initWithFrame:imgvFrame];
    }
    return _imgView;
}

- (UILabel *)statusLabel
{
    if (!_statusLabel)
    {
        CGRect slFrame             = CGRectMake(0, IMG_VIEW_W + 12, CONTENT_VIEW_W, CONTENT_VIEW_H - IMG_VIEW_W - 12);
        _statusLabel               = [[UILabel alloc] initWithFrame:slFrame];
        _statusLabel.font          = GOS_FONT(14);
        _statusLabel.textColor     = GOS_COLOR_RGB(0x1A1A1A);
        _statusLabel.textAlignment = NSTextAlignmentCenter;
        _statusLabel.numberOfLines = 0;
    }
    return _statusLabel;
}

- (UIImage *)successImg
{
    if (!_successImg)
    {
        _successImg = GOS_IMAGE(@"icon_register_success");
    }
    return _successImg;
}

- (UIImage *)errorImg
{
    if (!_errorImg)
    {
        _errorImg = GOS_IMAGE(@"icon_register_fail");
    }
    return _errorImg;
}

@end
