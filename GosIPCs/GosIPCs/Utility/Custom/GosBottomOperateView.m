//
//  GosBottomOperateView.m
//  GosIPCs
//
//  Created by shenyuanluo on 2019/1/3.
//  Copyright © 2019 goscam. All rights reserved.
//

#import "GosBottomOperateView.h"

#define OPERATE_VIEW_HEIGHT         40
#define OPERATE_VIEW_WIDTH          GOS_SCREEN_W
#define OPERATE_VIEW_DEFAULT_FRAME  CGRectMake(0, GOS_SCREEN_H, OPERATE_VIEW_WIDTH, OPERATE_VIEW_HEIGHT)
#define SHOW_ANIMATION_DURATION     0.15f   // 显示/隐藏动画时长


@interface GosBottomOperateView()
{
    BOOL m_isShowing;
    CGPoint m_originalCenter;
}
@property (nonatomic, readwrite, weak) id<GosBottomOperateViewDelegate>delegate;
/** 左按钮 */
@property (nonatomic, readwrite, strong) UIButton *leftBtn;
/** 右按钮 */
@property (nonatomic, readwrite, strong) UIButton *rightBtn;
/** 阴影线 */
@property (nonatomic, readwrite, strong) UIView *shadowLine;
/** 分隔线 */
@property (nonatomic, readwrite, strong) UIView *seperateLine;

@end

static GosBottomOperateView *g_operateView;
@implementation GosBottomOperateView

+ (instancetype)sharedOperateView
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        if (!g_operateView)
        {
            g_operateView = [[GosBottomOperateView alloc] init];
        }
    });
    return g_operateView;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:OPERATE_VIEW_DEFAULT_FRAME])
    {
        self.backgroundColor   = GOS_WHITE_COLOR;
        self->m_originalCenter = self.center;
        [self addSubview:self.leftBtn];
        [self addSubview:self.rightBtn];
        [self addSubview:self.seperateLine];
        [self addSubview:self.shadowLine];
        UIWindow *rootWindow = [UIApplication sharedApplication].keyWindow;
        [rootWindow addSubview:self];
    }
    return self;
}


#pragma mark - Public
#pragma mark -- 代理设置
+ (void)configDelegate:(id<GosBottomOperateViewDelegate>)delegate
{
    if (!delegate)
    {
        return;
    }
    [[self sharedOperateView] configDelegate:delegate];
}

#pragma mark -- 显示
+ (void)show
{
    [[self sharedOperateView] show];
}

#pragma mark -- 隐藏
+ (void)dismiss
{
    [[self sharedOperateView] dismiss];
}

#pragma mark -- 设置‘左’按钮标题
+ (void)configLeftTitle:(NSString *)title
               forState:(UIControlState)state;
{
    if (IS_EMPTY_STRING(title))
    {
        return;
    }
    [[self sharedOperateView] configLeftTitle:title
                                     forState:state];
}

#pragma mark -- 设置‘左’按钮标题颜色
+ (void)configLeftTitleColor:(UIColor *)color
                    forState:(UIControlState)state
{
    [[self sharedOperateView] configLeftTitleColor:color
                                          forState:state];
}

#pragma mark -- 设置‘右’按钮标题
+ (void)configRightTitle:(NSString *)title
                forState:(UIControlState)state
{
    if (IS_EMPTY_STRING(title))
    {
        return;
    }
    [[self sharedOperateView] configRightTitle:title
                                      forState:state];
}

#pragma mark -- 设置‘右’按钮标题颜色
+ (void)configRightTitleColor:(UIColor *)color
                     forState:(UIControlState)state
{
    [[self sharedOperateView] configRightTitleColor:color
                                           forState:state];
}

#pragma mark - Private
#pragma mark -- 代理设置
- (void)configDelegate:(id<GosBottomOperateViewDelegate>)delegate
{
    self.delegate = delegate;
}

#pragma mark -- 显示
- (void)show
{
    if (YES == m_isShowing)
    {
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        
        UIWindow *rootWindow = [UIApplication sharedApplication].keyWindow;
        [rootWindow bringSubviewToFront:self];
        GOS_WEAK_SELF;
        [UIView animateWithDuration:SHOW_ANIMATION_DURATION
                         animations:^{
                             
                             GOS_STRONG_SELF;
                             CGPoint point = strongSelf->m_originalCenter;
                             point.y -= OPERATE_VIEW_HEIGHT;
                             strongSelf.center = point;
                         }
                         completion:nil];
        m_isShowing = YES;
    });
}

#pragma mark -- 隐藏
- (void)dismiss
{
    if (NO == m_isShowing)
    {
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        
        GOS_WEAK_SELF;
        [UIView animateWithDuration:SHOW_ANIMATION_DURATION
                         animations:^{
                             
                             GOS_STRONG_SELF;
                             CGPoint point = strongSelf->m_originalCenter;
                             point.y += OPERATE_VIEW_HEIGHT;
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
    });
}

#pragma mark -- 设置‘左’按钮标题
- (void)configLeftTitle:(NSString *)title
               forState:(UIControlState)state
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self.leftBtn setTitle:title
                      forState:state];
    });
}

#pragma mark -- 设置‘左’按钮标题颜色
- (void)configLeftTitleColor:(UIColor *)color
                    forState:(UIControlState)state
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self.leftBtn setTitleColor:color
                           forState:state];
    });
}

#pragma mark -- 设置‘右’按钮标题
- (void)configRightTitle:(NSString *)title
                forState:(UIControlState)state
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self.rightBtn setTitle:title
                       forState:state];
    });
}

#pragma mark -- 设置‘右’按钮标题颜色
- (void)configRightTitleColor:(UIColor *)color
                    forState:(UIControlState)state
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self.rightBtn setTitleColor:color
                            forState:state];
    });
}

#pragma mark - 懒加载
- (UIButton *)leftBtn
{
    if (!_leftBtn)
    {
        _leftBtn                 = [UIButton buttonWithType:UIButtonTypeCustom];
        _leftBtn.frame           = CGRectMake(0, 0, 0.5 * OPERATE_VIEW_WIDTH, OPERATE_VIEW_HEIGHT);
        _leftBtn.titleLabel.font = GOS_FONT(15);
        [_leftBtn setTitle:DPLocalizedString(@"GosComm_SelectAll")
                  forState:UIControlStateNormal];
        [_leftBtn setTitleColor:GOS_COLOR_RGB(0x1A1A1A)
                       forState:UIControlStateNormal];
        [_leftBtn addTarget:self
                     action:@selector(leftBtnAction:)
           forControlEvents:UIControlEventTouchUpInside];
    }
    return _leftBtn;
}

- (UIButton *)rightBtn
{
    if (!_rightBtn)
    {
        _rightBtn                 = [UIButton buttonWithType:UIButtonTypeCustom];
        _rightBtn.frame           = CGRectMake(0.5 * OPERATE_VIEW_WIDTH, 0, 0.5 * OPERATE_VIEW_WIDTH, OPERATE_VIEW_HEIGHT);
        _rightBtn.titleLabel.font = GOS_FONT(15);
        [_rightBtn setTitle:DPLocalizedString(@"GosComm_Delete")
                   forState:UIControlStateNormal];
        [_rightBtn setTitleColor:GOS_COLOR_RGBA(255.0f, 36.0f, 36.0f, 0.5f)
                        forState:UIControlStateNormal];
        [_rightBtn addTarget:self
                      action:@selector(rightBtnAction:)
            forControlEvents:UIControlEventTouchUpInside];
    }
    return _rightBtn;
}

- (UIView *)seperateLine
{
    if (!_seperateLine)
    {
        CGRect lineRect = CGRectMake(0.5 * OPERATE_VIEW_WIDTH, 5.0f, 1.0f, OPERATE_VIEW_HEIGHT - 10.0f);
        _seperateLine = [[UIView alloc] initWithFrame:lineRect];
        _seperateLine.backgroundColor = GOS_COLOR_RGBA(217.0f, 217.0f, 217.0f, 1.0f);
    }
    return _seperateLine;
}

- (UIView *)shadowLine
{
    if (!_shadowLine)
    {
        CGRect lineRect = CGRectMake(0, 0, OPERATE_VIEW_WIDTH, 0.5f);
        _shadowLine = [[UIView alloc] initWithFrame:lineRect];
        _shadowLine.backgroundColor = GOS_COLOR_RGBA(217.0f, 217.0f, 217.0f, 0.5f);
        _shadowLine.layer.shadowColor = GOS_COLOR_RGBA(217.0f, 217.0f, 217.0f, 0.5f).CGColor;
        _shadowLine.layer.shadowOpacity = 0.8f;
        _shadowLine.layer.shadowOffset = CGSizeMake(0, -2);
    }
    return _shadowLine;
}


#pragma mark - 按钮事件中心
#pragma mark -- ’左‘按钮事件
- (void)leftBtnAction:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(leftButtonAction)])
    {
        [self.delegate leftButtonAction];
    }
}

#pragma mark -- ‘右’按钮事件
- (void)rightBtnAction:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(rightButtonAction)])
    {
        [self.delegate rightButtonAction];
    }
}

@end
