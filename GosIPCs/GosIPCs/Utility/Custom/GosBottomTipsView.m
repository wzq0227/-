//
//  GosBottomTipsView.m
//  GosIPCs
//
//  Created by shenyuanluo on 2018/11/22.
//  Copyright © 2018 goscam. All rights reserved.
//

#import "GosBottomTipsView.h"


#define TIPS_VIEW_MARGIN    30
#define TIPS_VIEW_HEIGHT    30
#define TIPS_VIEW_WIDTH     GOS_SCREEN_W - 2 * TIPS_VIEW_MARGIN
#define TIPS_VIEW_DEFAULT_FRAME    CGRectMake(TIPS_VIEW_MARGIN, GOS_SCREEN_H, TIPS_VIEW_WIDTH, TIPS_VIEW_HEIGHT)
#define ANIMATION_DURATION  0.5f
#define TIPS_VIEW_SHOW_DURATION 3   // 显示时长（单位：秒）


@interface GosBottomTipsView()
{
    BOOL m_isShowing;
    CGPoint m_originalCenter;
}
@property (nonatomic, readwrite, strong) UILabel *tipsLabel;
@property (nonatomic, readwrite, copy) NSString *messge;
@end

@implementation GosBottomTipsView

+ (void)showWithMessge:(NSString *)msg
{
    if (IS_EMPTY_STRING(msg))
    {
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
       
        [[GosBottomTipsView sharedTipsView] showTipsView:msg];
    });
}

+ (instancetype)sharedTipsView
{
    static GosBottomTipsView *g_tipsView;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        if (!g_tipsView)
        {
            g_tipsView = [[GosBottomTipsView alloc] init];
        }
    });
    return g_tipsView;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:TIPS_VIEW_DEFAULT_FRAME])
    {
        self.backgroundColor   = GOS_COLOR_RGBA(104, 166, 254, 0.1);
        self->m_originalCenter = self.center;
        [self addSubview:self.tipsLabel];
        UIWindow *rootWindow = [UIApplication sharedApplication].keyWindow;
        [rootWindow addSubview:self];
    }
    return self;
}

#pragma mark -- 显示
- (void)showTipsView:(NSString *)message
{
    if (IS_EMPTY_STRING(message))
    {
        return;
    }
    if (YES == m_isShowing)
    {
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        
        self.tipsLabel.text = message;
        UIWindow *rootWindow = [UIApplication sharedApplication].keyWindow;
        [rootWindow bringSubviewToFront:self];
    });
    GOS_WEAK_SELF;
    [UIView animateWithDuration:0.5f
                     animations:^{
                         
                         GOS_STRONG_SELF;
                         CGPoint point = strongSelf->m_originalCenter;
                         point.y -= TIPS_VIEW_HEIGHT;
                         strongSelf.center = point;
                     }
                     completion:^(BOOL finished) {
                         
                         GOS_STRONG_SELF;
                         if (YES == finished)
                         {
                             [strongSelf performSelector:@selector(dismissTipsView)
                                              withObject:nil
                                              afterDelay:TIPS_VIEW_SHOW_DURATION];
                         }
                     }];
    m_isShowing = YES;
}

#pragma mark -- 隐藏
- (void)dismissTipsView
{
    if (NO == m_isShowing)
    {
        return;
    }
    GOS_WEAK_SELF;
    [UIView animateWithDuration:0.25f
                     animations:^{
                         
                         GOS_STRONG_SELF;
                         CGPoint point = strongSelf->m_originalCenter;
                         point.y += TIPS_VIEW_HEIGHT;
                         strongSelf.center = point;
                     }
                     completion:^(BOOL finished) {
                         
                         GOS_STRONG_SELF;
                         if (YES == finished)
                         {
                             UIWindow *rootWindow = [UIApplication sharedApplication].keyWindow;
                             [rootWindow sendSubviewToBack:strongSelf];
                         }
                     }];
    m_isShowing = NO;
}

- (UILabel *)tipsLabel
{
    if (!_tipsLabel)
    {
        CGRect labelFrame          = CGRectMake(0, 0, TIPS_VIEW_WIDTH, TIPS_VIEW_HEIGHT);
        _tipsLabel                 = [[UILabel alloc] initWithFrame:labelFrame];
        _tipsLabel.font            = GOS_FONT(12);
        _tipsLabel.textColor       = GOS_COLOR_RGBA(85, 175, 252, 1);
        _tipsLabel.textAlignment   = NSTextAlignmentCenter;
        _tipsLabel.backgroundColor = GOS_CLEAR_COLOR;
    }
    return _tipsLabel;
}

@end
