//
//  DHGuidePageHUD.m
//  DHGuidePageHUD
//
//  Created by Apple on 16/7/14.
//  Copyright © 2016年 dingding3w. All rights reserved.
//

#import "DHGuidePageHUD.h"
#import "DHGifImageOperation.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVKit/AVKit.h>
#import "NSString+GosSize.h"

#define DDHidden_TIME   3.0
#define DDScreenW   [UIScreen mainScreen].bounds.size.width
#define DDScreenH   [UIScreen mainScreen].bounds.size.height
#define START_BTN_W 120
#define START_BTN_H 30

@interface DHGuidePageHUD ()<UIScrollViewDelegate>
@property (nonatomic, strong) NSArray                 *imageArray;
@property (nonatomic, strong) UIPageControl           *imagePageControl;
@property (nonatomic, assign) NSInteger               slideIntoNumber;
@property (nonatomic, strong) MPMoviePlayerController *playerController;
@end

@implementation DHGuidePageHUD

- (instancetype)dh_initWithFrame:(CGRect)frame imageNameArray:(NSArray<NSString *> *)imageNameArray buttonIsHidden:(BOOL)isHidden {
    if ([super initWithFrame:frame]) {
        self.slideInto = NO;
        if (isHidden == YES) {
            self.imageArray = imageNameArray;
        }
        
        // 设置引导视图的scrollview
        UIScrollView *guidePageView = [[UIScrollView alloc]initWithFrame:frame];
        [guidePageView setBackgroundColor:[UIColor lightGrayColor]];
        [guidePageView setContentSize:CGSizeMake(DDScreenW*imageNameArray.count, DDScreenH)];
        [guidePageView setBounces:NO];
        [guidePageView setPagingEnabled:YES];
        [guidePageView setShowsHorizontalScrollIndicator:NO];
        [guidePageView setDelegate:self];
        [self addSubview:guidePageView];
        
        // 设置引导页上的跳过按钮
        UIButton *skipButton = [[UIButton alloc]initWithFrame:CGRectMake(DDScreenW*0.8, DDScreenW*0.1, 50, 25)];
        [skipButton setTitle:@"跳过" forState:UIControlStateNormal];
        [skipButton.titleLabel setFont:[UIFont systemFontOfSize:14.0]];
        [skipButton setBackgroundColor:[UIColor grayColor]];
        // [skipButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [skipButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        // [skipButton.layer setCornerRadius:5.0];
        [skipButton.layer setCornerRadius:(skipButton.frame.size.height * 0.5)];
        [skipButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        //        [self addSubview:skipButton];
        
        // 添加在引导视图上的多张引导图片
        for (int i=0; i<imageNameArray.count; i++) {
            UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(DDScreenW*i, 0, DDScreenW, DDScreenH)];
            if ([[DHGifImageOperation dh_contentTypeForImageData:[NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:imageNameArray[i] ofType:nil]]] isEqualToString:@"gif"]) {
                NSData *localData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:imageNameArray[i] ofType:nil]];
                imageView = (UIImageView *)[[DHGifImageOperation alloc] initWithFrame:imageView.frame gifImageData:localData];
                [guidePageView addSubview:imageView];
            } else {
                imageView.image = [UIImage imageNamed:imageNameArray[i]];
                [guidePageView addSubview:imageView];
            }
            
            CGRect tipsFrame        = CGRectMake((DDScreenW - START_BTN_W) * 0.5, DDScreenH - 140, START_BTN_W, START_BTN_H);
            UILabel *tipsLabel      = [[UILabel alloc] initWithFrame:tipsFrame];
            tipsLabel.textAlignment = NSTextAlignmentCenter;
            tipsLabel.textColor     = GOS_WHITE_COLOR;
            tipsLabel.font          = [UIFont boldSystemFontOfSize:24];
            [imageView addSubview:tipsLabel];
            if (0 == i) // 第1张引导页
            {
                tipsLabel.text = DPLocalizedString(@"RealTimeView");
            }
            if (1 == i) // 第2张引导页
            {
                tipsLabel.text = DPLocalizedString(@"MultiMonitor");
            }
            // 设置在最后一张图片上显示进入体验按钮
            if (i == imageNameArray.count-1 && isHidden == NO) {
                [imageView setUserInteractionEnabled:YES];
                
                tipsLabel.text = DPLocalizedString(@"QuickInstall");
                NSString *startStr = DPLocalizedString(@"ImmediateExperience");
                CGSize startStrSize = [NSString sizeWithString:startStr
                                                          font:[UIFont systemFontOfSize:14]
                                                    forMaxSize:CGSizeMake(200, 30)];
                
                CGRect startBtnFrame = CGRectMake((DDScreenW - startStrSize.width - 40) * 0.5, DDScreenH - 90, startStrSize.width + 40, START_BTN_H);
                UIButton *startButton = [[UIButton alloc] initWithFrame:startBtnFrame];//CGRectMake(DDScreenW*0.3, DDScreenH*0.8, DDScreenW*0.4, DDScreenH*0.08)];
                [startButton setTitle:startStr
                             forState:UIControlStateNormal];
                [startButton setTitleColor:GOS_COLOR_RGB(0x51B1FB)
                                  forState:UIControlStateNormal];
                [startButton.titleLabel setFont:[UIFont fontWithName:@"SourceHanSansCN-Normal"
                                                                size:14]];
                [startButton setBackgroundColor:GOS_WHITE_COLOR];
                startButton.layer.cornerRadius = 4;
                startButton.layer.masksToBounds = YES;
                //                [startButton setBackgroundImage:[UIImage imageNamed:@"GuideImage.bundle/guideImage_button_backgound"]
                //                                       forState:UIControlStateNormal];
                [startButton addTarget:self
                                action:@selector(buttonClick:)
                      forControlEvents:UIControlEventTouchUpInside];
                [imageView addSubview:startButton];
            }
        }
        
        // 设置引导页上的页面控制器
        self.imagePageControl = [[UIPageControl alloc]initWithFrame:CGRectMake(DDScreenW*0.0, DDScreenH - 30, DDScreenW*1.0, 10)];
        self.imagePageControl.currentPage = 0;
        self.imagePageControl.numberOfPages = imageNameArray.count;
//        self.imagePageControl.pageIndicatorTintColor = [UIColor grayColor];
//        self.imagePageControl.currentPageIndicatorTintColor = [UIColor whiteColor];
        self.imagePageControl.pageIndicatorTintColor = [UIColor clearColor];
        self.imagePageControl.currentPageIndicatorTintColor = [UIColor clearColor];
        // 设置圆点图片
//            [self.imagePageControl setValue:[UIImage imageNamed:@"img_circle"]
//                                 forKeyPath:@"pageImage"];
//            [self.imagePageControl setValue:[UIImage imageNamed:@"img_rounded_rectangle"]
//                                 forKeyPath:@"currentPageImage"];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self updateDots];
        });
        [self addSubview:self.imagePageControl];
        
    }
    return self;
}


#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollview {
    int page = scrollview.contentOffset.x / scrollview.frame.size.width;
    if (self.imageArray && page == self.imageArray.count-1 && self.slideInto == NO) {
        [self buttonClick:nil];
    }
    if (self.imageArray && page < self.imageArray.count-1 && self.slideInto == YES) {
        self.slideIntoNumber = 1;
    }
    if (self.imageArray && page == self.imageArray.count-1 && self.slideInto == YES) {
        UISwipeGestureRecognizer *swipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:nil action:nil];
        if (swipeGestureRecognizer.direction == UISwipeGestureRecognizerDirectionRight){
            self.slideIntoNumber++;
            if (self.slideIntoNumber == 3) {
                [self buttonClick:nil];
            }
        }
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    // 四舍五入,保证pageControl状态跟随手指滑动及时刷新
    [self.imagePageControl setCurrentPage:(int)((scrollView.contentOffset.x / scrollView.frame.size.width) + 0.5f)];
    [self updateDots];
}

- (void)updateDots{
    for (int i=0; i<[self.imagePageControl.subviews count]; i++) {
        CGSize contentSize = self.imagePageControl.subviews[i].frame.size;
        UIImageView *dot = [self imageViewForSubview:[self.imagePageControl.subviews objectAtIndex:i] currPage:i];
        if (i == self.imagePageControl.currentPage){
            dispatch_async(dispatch_get_main_queue(), ^{
                dot.image = [UIImage imageNamed:@"img_rounded_rectangle"];
                CGFloat iWidth = dot.image.size.width;
                CGFloat iHeight = dot.image.size.height;
                dot.frame = CGRectMake((contentSize.width - iWidth) / 2.0, (contentSize.height - iHeight) / 2.0, iWidth, iHeight);
            });
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                dot.image = [UIImage imageNamed:@"img_circle"];
                CGFloat iWidth = dot.image.size.width;
                CGFloat iHeight = dot.image.size.height;
                dot.frame = CGRectMake((contentSize.width - iWidth) / 2.0, (contentSize.height - iHeight) / 2.0, iWidth, iHeight);
            });
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

#pragma mark - EventClick
- (void)buttonClick:(UIButton *)button {
    //    [UIView animateWithDuration:DDHidden_TIME animations:^{
    //        self.alpha = 0;
    //        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(DDHidden_TIME * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    //            [self performSelector:@selector(removeGuidePageHUD) withObject:nil afterDelay:1];
    //        });
    //    }];
    [self performSelector:@selector(removeGuidePageHUD) withObject:nil afterDelay:0.1];
    GosLog(@"Guide finish!");
}

- (void)removeGuidePageHUD {
    [self removeFromSuperview];
}

/**< APP视频新特性页面(新增测试模块内容) */
- (instancetype)dh_initWithFrame:(CGRect)frame videoURL:(NSURL *)videoURL {
    if ([super initWithFrame:frame]) {
        self.playerController = [[MPMoviePlayerController alloc] initWithContentURL:videoURL];
        [self.playerController.view setFrame:frame];
        [self.playerController.view setAlpha:1.0];
        [self.playerController setControlStyle:MPMovieControlStyleNone];
        [self.playerController setRepeatMode:MPMovieRepeatModeOne];
        [self.playerController setShouldAutoplay:YES];
        [self.playerController prepareToPlay];
        [self addSubview:self.playerController.view];
        
        // 视频引导页进入按钮
        UIButton *movieStartButton = [[UIButton alloc] initWithFrame:CGRectMake(20, DDScreenH-30-40, DDScreenW-40, 40)];
        [movieStartButton.layer setBorderWidth:1.0];
        [movieStartButton.layer setCornerRadius:20.0];
        [movieStartButton.layer setBorderColor:[UIColor whiteColor].CGColor];
        [movieStartButton setTitle:DPLocalizedString(@"ImmediateExperience") forState:UIControlStateNormal];
        [movieStartButton setAlpha:0.0];
        [self.playerController.view addSubview:movieStartButton];
        [movieStartButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        [UIView animateWithDuration:DDHidden_TIME animations:^{
            [movieStartButton setAlpha:1.0];
        }];
    }
    return self;
}

@end
