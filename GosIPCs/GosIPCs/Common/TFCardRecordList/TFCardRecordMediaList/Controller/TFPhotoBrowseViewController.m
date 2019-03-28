//
//  TFPhotoBrowseViewController.m
//  GosIPCs
//
//  Created by shenyuanluo on 2019/1/4.
//  Copyright © 2019 goscam. All rights reserved.
//

#import "TFPhotoBrowseViewController.h"
#import "GosTransition.h"
#import "TFDownloadManager.h"

@interface TFPhotoBrowseViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *photoImgView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *downloadActivity;
@property (nonatomic, readwrite, strong) TFCRMediaModel *curPhoto;
/** 左滑手势 */
@property (nonatomic, readwrite, strong) UISwipeGestureRecognizer *swipToLeft;
/** 右滑手势 */
@property (nonatomic, readwrite, strong) UISwipeGestureRecognizer *swipToRight;
/** 下张图片切换动画 */
@property (nonatomic, readwrite, strong) GosTransition *nextPhotoAnimation;
/** 上张图片切换动画 */
@property (nonatomic, readwrite, strong) GosTransition *prePhotoAnimation;

@end

@implementation TFPhotoBrowseViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initParam];
    [self configUI];
    [self.view addGestureRecognizer:self.swipToRight];
    [self.view addGestureRecognizer:self.swipToLeft];
    [self addDownloadSuccessNotify];
    [self addDownloadFailureNotify];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self resetParam];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    GosLog(@"---------- TFPhotoBrowseViewController dealloc ----------");
}

- (void)initParam
{
    if (self.photoList.count > self.curPhotoIndex)
    {
        self.curPhoto = self.photoList[self.curPhotoIndex];
    }
}

- (void)resetParam
{
    
}

#pragma mark -- 设置相关 UI
- (void)configUI
{
    [self loadPhoto];
    if (NO == self.curPhoto.hasDownload)
    {
        [self configActiviyHidden:NO];
    }
    else
    {
        [self configActiviyHidden:YES];
    }
}

- (void)configActiviyHidden:(BOOL)isHidden
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (NO == isHidden)
        {
            self.downloadActivity.hidden = NO;
            [self.downloadActivity startAnimating];
        }
        else
        {
            [self.downloadActivity stopAnimating];
            self.downloadActivity.hidden = YES;
        }
    });
}

#pragma mark -- 添加图片下载成功通知
- (void)addDownloadSuccessNotify
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(downloadSuccess:)
                                                 name:kTFMediaDownloadSuccessNotify
                                               object:nil];
}

- (void)downloadSuccess:(NSNotification *)notify
{
    NSDictionary *dict = (NSDictionary *)notify.object;
    if (!dict || NO == [[dict allKeys] containsObject:kTFMediaKey])
    {
        return;
    }
    TFCRMediaModel *media  = dict[kTFMediaKey];
    for (int i = 0; i < self.photoList.count; i++)
    {
        if (NO == [media isEqual:self.photoList[i]])
        {
            continue;
        }
        self.photoList[i].hasDownload = YES;
        if (self.curPhotoIndex == i)    // 在当前页，直接更新
        {
            [self loadPhoto];
            [self configActiviyHidden:YES];
        }
        break;
    }
}

#pragma mark -- 添加图片下载失败通知
- (void)addDownloadFailureNotify
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(downloadFailure:)
                                                 name:kTFMediaDownloadFailureNotify
                                               object:nil];
}

- (void)downloadFailure:(NSNotification *)notify
{
    NSDictionary *dict = (NSDictionary *)notify.object;
    if (!dict || NO == [[dict allKeys] containsObject:kTFMediaKey])
    {
        return;
    }
    TFCRMediaModel *media  = dict[kTFMediaKey];
    for (int i = 0; i < self.photoList.count; i++)
    {
        if (NO == [media isEqual:self.photoList[i]])
        {
            continue;
        }
        self.photoList[i].hasDownload = NO;
        if (self.curPhotoIndex == i)    // 在当前页，直接更新
        {
            [SVProgressHUD showErrorWithStatus:DPLocalizedString(@"TFCR_DownloadFalure")];
            [self configActiviyHidden:YES];
        }
        break;
    }
}

#pragma mark -- 加载图片
- (void)loadPhoto
{
    if (!_curPhoto || IS_EMPTY_STRING(_curPhoto.mediaFilePath))
    {
        GosLog(@"无法加载图片，curPhot = nil!");
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        
        UIImage *image          = [UIImage imageWithContentsOfFile:self.curPhoto.mediaFilePath];
        self.photoImgView.image = image;
        self.title              = self.curPhoto.tfmFile.showName;
    });
}


#pragma mark -- 上一图片
- (void)prePhoto
{
    if (0 == self.curPhotoIndex)
    {
        GosLog(@"已经是最新一张图片了！");
        [SVProgressHUD showInfoWithStatus:DPLocalizedString(@"TFCR_IsLatestPhoto")
                              forDuration:0.5f];
        return;
    }
    if (self.photoList.count < self.curPhotoIndex)
    {
        return;
    }
    self.curPhoto = self.photoList[--self.curPhotoIndex];
    if (NO == self.curPhoto.hasDownload)    // 还未下载，通知下载
    {
        [self configActiviyHidden:NO];
        NSDictionary *dict = @{@"DownloadTFPhotoRow" : @(self.curPhotoIndex)};
        [[NSNotificationCenter defaultCenter] postNotificationName:kStartDownloadTFPhotoNotify
                                                            object:dict];
    }
    else    // 已下载，显示
    {
        [self loadPhoto];
        [self configActiviyHidden:YES];
    }
    // 执行动画
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self.view.layer addAnimation:self.prePhotoAnimation
                               forKey:@"animation"];
    });
}

#pragma mark -- 下一图片
- (void)nextPhoto
{
    if (self.photoList.count - 1 <= self.curPhotoIndex)
    {
        GosLog(@"已经是最后一张图片了！");
        [SVProgressHUD showInfoWithStatus:DPLocalizedString(@"TFCR_IsLastPhoto")
                              forDuration:0.5f];
        return;
    }
    if (self.photoList.count < self.curPhotoIndex)
    {
        return;
    }
    self.curPhoto = self.photoList[++self.curPhotoIndex];
    if (NO == self.curPhoto.hasDownload)    // 还未下载
    {
        [self configActiviyHidden:NO];
        NSDictionary *dict = @{@"DownloadTFPhotoRow" : @(self.curPhotoIndex)};
        [[NSNotificationCenter defaultCenter] postNotificationName:kStartDownloadTFPhotoNotify
                                                            object:dict];
    }
    else    // 已下载，显示
    {
        [self loadPhoto];
        [self configActiviyHidden:YES];
    }
    // 执行动画
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self.view.layer addAnimation:self.nextPhotoAnimation
                               forKey:@"animation"];
    });
}


#pragma mark - 懒加载
- (UISwipeGestureRecognizer *)swipToLeft
{
    if (!_swipToLeft)
    {
        _swipToLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                action:@selector(nextPhoto)];
        _swipToLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    }
    return _swipToLeft;
}

- (UISwipeGestureRecognizer *)swipToRight
{
    if (!_swipToRight)
    {
        _swipToRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                 action:@selector(prePhoto)];
        _swipToRight.direction = UISwipeGestureRecognizerDirectionRight;
    }
    return _swipToRight;
}

- (GosTransition *)nextPhotoAnimation
{
    if (!_nextPhotoAnimation)
    {
        _nextPhotoAnimation = [[GosTransition alloc] initWithType:GosTranAnimat_pageCurl
                                                          subType:kCATransitionFromRight
                                                         duration:0.5f];
    }
    return _nextPhotoAnimation;
}

- (GosTransition *)prePhotoAnimation
{
    if (!_prePhotoAnimation)
    {
        _prePhotoAnimation = [[GosTransition alloc] initWithType:GosTranAnimat_pageUnCurl
                                                         subType:kCATransitionFromRight
                                                        duration:0.5f];
    }
    return _prePhotoAnimation;
}

@end
