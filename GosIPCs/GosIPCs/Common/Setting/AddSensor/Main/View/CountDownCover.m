//
//  CountDownCover.m
//  ULife3.5
//
//  Created by shenyuanluo on 2018/5/17.
//  Copyright © 2018年 GosCam. All rights reserved.
//

#import "CountDownCover.h"

#define COUNT_DONW_VIEW_W 100
#define COUNT_DONW_VIEW_H 100
//#define RING_COLOR [UIColor colorWithRed:88.0/255.0f green:169.0/255.0f blue:80.0/255.0f alpha:1.0f]
#define RING_COLOR [UIColor whiteColor]

@interface CountDownCover()

@property (nonatomic, readwrite, strong) UIWindow *cdWindow;
@property (nonatomic, readwrite, strong) UIView *cdCover;
@property (nonatomic, readwrite, strong) NSTimer *cdTimer;
@property (nonatomic, readwrite, assign) NSInteger totalTime;
@property (nonatomic, readwrite, assign) NSInteger countDown;
@property (nonatomic, readwrite, copy) FinishBlock finishBlock;

@end

@implementation CountDownCover

#pragma mark - Public
+ (void)showTime:(NSInteger)cdDuration
          finish:(FinishBlock)block
{
    [[self shareCover] showCountDown:cdDuration
                              finish:^(BOOL isTimeEnd)
    {
        if (block)
        {
            block(isTimeEnd);
        }
    }];
}

+ (void)dismiss
{
    [[self shareCover] dismissCover:NO];
}

#pragma mark - Private
+ (instancetype)shareCover
{
    static CountDownCover *g_cdCover = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        if (nil == g_cdCover)
        {
            g_cdCover = [[CountDownCover alloc] init];
        }
    });
    return g_cdCover;
}


- (instancetype)init
{
    if (self = [super init])
    {
        CGRect cvFrame   = CGRectMake(0, 0, COUNT_DONW_VIEW_W, COUNT_DONW_VIEW_H);
//        UIColor *bgColor = [UIColor colorWithRed:70.0f/255.0f
//                                           green:68.0f/255.0f
//                                            blue:67.0f/255.0f
//                                           alpha:1.0f];
        UIColor * bgColor = [UIColor clearColor];
        self.frame               = cvFrame;
        self.backgroundColor     = bgColor;
        self.center              = self.cdWindow.center;
        self.layer.cornerRadius  = 10.0f;
        self.layer.masksToBounds = YES;
        
        self.cdTimer = [NSTimer scheduledTimerWithTimeInterval:0.1f
                                                        target:self
                                                      selector:@selector(updateTimeStr)
                                                      userInfo:nil
                                                       repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:self.cdTimer
                                  forMode:NSDefaultRunLoopMode];
        [self pauseTimer];
    }
    return self;
}

- (void)dealloc
{
    [self stopTimer];
}

- (UIWindow *)cdWindow
{
    if (!_cdWindow)
    {
        _cdWindow = [UIApplication sharedApplication].keyWindow;
    }
    return _cdWindow;
}

- (UIView *)cdCover
{
    if (!_cdCover)
    {
        _cdCover                 = [UIView new];
        _cdCover.frame           = self.cdWindow.bounds;
        _cdCover.backgroundColor = [UIColor blackColor];
        _cdCover.alpha           = 0.65f;
    }
    return _cdCover;
}

- (void)pauseTimer
{
    if (!self.cdTimer.isValid)
    {
        return;
    }
    [self.cdTimer setFireDate:[NSDate distantFuture]];
}

- (void)resumeTimer
{
    if (!self.cdTimer.isValid)
    {
        return;
    }
    [self.cdTimer setFireDate:[NSDate date]];
}

- (void)stopTimer
{
    if (self.cdTimer)
    {
        [self.cdTimer invalidate];
        self.cdTimer = nil;
    }
}


- (void)showCountDown:(NSInteger)cdDuration
               finish:(FinishBlock)block
{
    self.finishBlock = nil;
    self.finishBlock = block;
    self.totalTime   = cdDuration * 10;
    self.countDown   = cdDuration * 10;
    
    [self show];    
    [self resumeTimer];
}

- (void)updateTimeStr
{
    if (0 >= self.countDown)
    {
        [self dismissCover:YES];
    }
    [self setNeedsDisplay];
    self.countDown--;
}

- (void)show
{
    __weak typeof(self)weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        
        __strong typeof(weakSelf)strongSelf = weakSelf;
        if (!strongSelf)
        {
            return ;
        }
        [strongSelf.cdWindow addSubview:strongSelf.cdCover];
        [strongSelf.cdWindow addSubview:strongSelf];
    });
}

- (void)dismissCover:(BOOL)isTimeEnd
{
    [self pauseTimer];
    
    __weak typeof(self)weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        
        __strong typeof(weakSelf)strongSelf = weakSelf;
        if (!strongSelf)
        {
            return ;
        }
        [strongSelf.cdCover removeFromSuperview];
        [strongSelf removeFromSuperview];
        if (strongSelf.finishBlock)
        {
            strongSelf.finishBlock(isTimeEnd);
        }
    });
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    [self drawText];
    [self drawProgress:context];
}

-(void)drawText
{
    CGFloat strW    = 80;
    CGFloat strH    = 40;
    CGFloat originX = (COUNT_DONW_VIEW_W - strW) * 0.5;
    CGFloat originY = (COUNT_DONW_VIEW_H - strH) * 0.5;
    NSString *str   = [NSString stringWithFormat:@"%lds", (long)(self.countDown/10 + 1)];
    CGRect rect     = CGRectMake(originX, originY, strW, strH);
    UIFont *font    = [UIFont systemFontOfSize:28];
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];   
    NSTextAlignment align          = NSTextAlignmentCenter;
    style.alignment                = align;
    NSDictionary *attrib =  @{
                              NSFontAttributeName:font,
                              NSForegroundColorAttributeName:RING_COLOR,
                              NSParagraphStyleAttributeName:style
                              };
    [str drawInRect:rect withAttributes:attrib];
}

- (void)drawProgress:(CGContextRef)context
{
    CGFloat lineW      = 6.0f;
    CGFloat margin     = 30.0f;
    CGFloat radius     = (MIN(COUNT_DONW_VIEW_W, COUNT_DONW_VIEW_H) - lineW * 2.0 - margin * 0.5f) * 0.5f;
    CGFloat centerX    = COUNT_DONW_VIEW_W * 0.5f;;
    CGFloat centerY    = COUNT_DONW_VIEW_H * 0.5f;
    CGPoint center     = CGPointMake(centerX, centerY);
    CGFloat decrease   = 2.0f * M_PI / self.totalTime;
    CGFloat startAngle = 1.5 * M_PI;
    CGFloat endAngle   = startAngle + decrease * (self.totalTime - self.countDown);
    
    
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:center
                                                        radius:radius
                                                    startAngle:startAngle
                                                      endAngle:endAngle
                                                     clockwise:NO];
    CGContextAddPath(context, path.CGPath);
    CGContextSetStrokeColorWithColor(context, RING_COLOR.CGColor);
    CGContextSetFillColorWithColor(context, RING_COLOR.CGColor);
    CGContextSetLineWidth(context, lineW);
    CGContextStrokePath(context);
}

@end
