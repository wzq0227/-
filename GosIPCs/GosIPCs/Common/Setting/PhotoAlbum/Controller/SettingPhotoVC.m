//
//  SettingPhotoVC.m
//  Goscom
//
//  Created by 匡匡 on 2018/11/20.
//  Copyright © 2018 goscam. All rights reserved.
//

#import "SettingPhotoVC.h"
#import "MediaManager.h"
#import "PhotoAlbumModel.h"
#import "GosTransition.h"
#import <Photos/Photos.h>
#import "GosPhotoHelper.h"

// 滑动方向
typedef NS_ENUM(NSInteger,swipDirection) {
    swipDirection_unKnow,   //  未知
    swipDirection_left,     //  向左
    swipDirection_right,    //  向右
};
#define CHANGE_ANIMAT_DURATION 0.5f     // 切换消息动画时长（单位：秒）
@interface SettingPhotoVC ()
@property (weak, nonatomic) IBOutlet UIImageView *photoImg;
/// 翻转方向
@property (nonatomic, assign) swipDirection swipDirection;
/** 下条消息切换动画 */
@property (nonatomic, readwrite, strong) GosTransition *nextMsgAnimation;
/** 上条消息切换动画 */
@property (nonatomic, readwrite, strong) GosTransition *preMsgAnimation;
/// <#describtion#>
@property (nonatomic, strong) PHAssetCollection *createCollection;
@end

@implementation SettingPhotoVC{
    /// 手势对象
    UISwipeGestureRecognizer * recognizer;;
}

#pragma mark -- lifestyle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self configImgAddTap];
}

- (void)setDataModel:(PhotoAlbumModel *)dataModel{
    _dataModel = dataModel;
    GOS_WEAK_SELF;
    dispatch_async(dispatch_get_main_queue(), ^{
        GOS_STRONG_SELF;
        strongSelf.title = strongSelf.dataModel.fileName;
        strongSelf.photoImg.image = [UIImage imageWithContentsOfFile:dataModel.filePath];
    });
    
    if (self.swipDirection == swipDirection_left) {
        dispatch_async(dispatch_get_main_queue(), ^{
            GOS_STRONG_SELF;
            [strongSelf.photoImg.layer addAnimation:strongSelf.nextMsgAnimation
                                             forKey:@"animation"];
        });
    }else if(self.swipDirection == swipDirection_right){
        dispatch_async(dispatch_get_main_queue(), ^{
            GOS_STRONG_SELF;
            [strongSelf.photoImg.layer addAnimation:strongSelf.preMsgAnimation
                                             forKey:@"animation"];
        });
    }
    
}

#pragma mark -- config
- (void)configImgAddTap{
    self.photoImg.userInteractionEnabled = YES;
    recognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(handleSwipeFrom:)];
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionRight)];
    [self.photoImg addGestureRecognizer:recognizer];
    
    recognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(handleSwipeFrom:)];
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionLeft)];
    [self.photoImg addGestureRecognizer:recognizer];
    
}
#pragma mark -- function
#pragma mark - 处理左右滑动图片
- (void)handleSwipeFrom:(UISwipeGestureRecognizer *)recognizer{
    if(recognizer.direction == UISwipeGestureRecognizerDirectionLeft) {
        GosLog(@"swipe left");
        self.swipDirection = swipDirection_left;
        [self.photoMutArr enumerateObjectsUsingBlock:^(PhotoAlbumModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (([self.dataModel isEqual:obj]&&
                 idx>0 && idx<self.photoMutArr.count-1)||
                ([self.dataModel isEqual:obj] && idx == 0) ) {
                [self setDataModel:self.photoMutArr[idx+1]];
                *stop = YES;
            }
        }];
    }
    if(recognizer.direction == UISwipeGestureRecognizerDirectionRight) {
        GosLog(@"swipe right");
        self.swipDirection = swipDirection_right;
        [self.photoMutArr enumerateObjectsUsingBlock:^(PhotoAlbumModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (([self.dataModel isEqual:obj] &&
                 idx>0 && idx<self.photoMutArr.count-1) ||
                ([self.dataModel isEqual:obj] && idx == self.photoMutArr.count -1)) {
                [self setDataModel:self.photoMutArr[idx-1]];
                *stop = YES;
            }
        }];
    }
}

#pragma mark -- actionFunction
#pragma mark -- 下载图片到本地相册
- (IBAction)actionDownPhotoClick:(id)sender {
    UIImage * image = [UIImage imageWithContentsOfFile:self.dataModel.filePath];
    [GosPhotoHelper saveImageToCustomAblumWithImage:image success:^{
        [SVProgressHUD showSuccessWithStatus:DPLocalizedString(@"photo_SaveToSystemSuccess")];
         GosLog(@"保存图片到系统相册成功");
    } fail:^{
         [SVProgressHUD showErrorWithStatus:DPLocalizedString(@"photo_SaveToSystemFail")];
        GosLog(@"保存图片到系统相册失败");
    }];
    
//    [self saveImageToCustomAblumWithImage:image];
}
#pragma mark -- delegate

#pragma mark -- 创建系统相册保存图片到系统方法
- (void)saveImageToCustomAblumWithImage:(UIImage *)image {
    // 将图片保存到系统的【相机胶卷】中---调用刚才的方法
    PHFetchResult<PHAsset *> *assets = [self synchronousSaveImageWithPhotosWithImage:image];
    if (assets == nil) {
        GosLog(@"保存失败");
        return;
    }
    // 拥有自定义相册（与 APP 同名，如果没有则创建）--调用刚才的方法
    PHAssetCollection *assetCollection = [self getAssetCollectionWithAppNameAndCreateCollection];
    if (assetCollection == nil) {
        GosLog(@"相册创建失败");
        return;
    }
    // 将刚才保存到相机胶卷的图片添加到自定义相册中 --- 保存带自定义相册--属于增的操作，需要在PHPhotoLibrary的block中进行
    NSError *error = nil;
    [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
        //--告诉系统，要操作哪个相册
        PHAssetCollectionChangeRequest *collectionChangeRequest = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:assetCollection];
        //--添加图片到自定义相册--追加--就不能成为封面了
        //--[collectionChangeRequest addAssets:assets];
        //--插入图片到自定义相册--插入--可以成为封面
        [collectionChangeRequest insertAssets:assets atIndexes:[NSIndexSet indexSetWithIndex:0]];
    } error:&error];
    
    if (error) {
        GosLog(@"保存图片到系统相册失败");
        [SVProgressHUD showErrorWithStatus:DPLocalizedString(@"photo_SaveToSystemFail")];
        return;
    }
    [SVProgressHUD showSuccessWithStatus:DPLocalizedString(@"photo_SaveToSystemSuccess")];
    GosLog(@"保存图片到系统相册成功");
}

- (PHAssetCollection *)getAssetCollectionWithAppNameAndCreateCollection {
    NSString *titlePhotos = [NSBundle mainBundle].infoDictionary[(NSString *)kCFBundleNameKey];
    // 获得所有的自定义相册
    PHFetchResult<PHAssetCollection *> *collections = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    for (PHAssetCollection *collection in collections) {
        if ([collection.localizedTitle isEqualToString:titlePhotos]) {
            return collection;
        }
    }
    
    NSError *error = nil;
    // 代码执行到这里，说明还没有自定义相册
    __block NSString *createdCollectionId = nil;
    
    // 创建一个新的相册
    [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
        createdCollectionId = [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:titlePhotos].placeholderForCreatedAssetCollection.localIdentifier;
    } error:&error];
    
    if (error) {
        GosLog(@"创建系统相册成功");
        return nil;
    } else {
        GosLog(@"创建系统相册失败");
        // 创建完毕后再取出相册
        return [PHAssetCollection fetchAssetCollectionsWithLocalIdentifiers:@[createdCollectionId] options:nil].firstObject;
    }
}
- (PHFetchResult<PHAsset *> *)synchronousSaveImageWithPhotosWithImage:(UIImage *)image {
    __block NSString *createdAssetId = nil;
    
    // 添加图片到【相机胶卷】
    [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
        createdAssetId = [PHAssetChangeRequest creationRequestForAssetFromImage:image].placeholderForCreatedAsset.localIdentifier;
    } error:nil];
    
    if (createdAssetId == nil) return nil;
    // 在保存完毕后取出图片
    return [PHAsset fetchAssetsWithLocalIdentifiers:@[createdAssetId] options:nil];
}
#pragma mark -- lazy
- (GosTransition *)nextMsgAnimation{
    if (!_nextMsgAnimation) {
        
        _nextMsgAnimation = [[GosTransition alloc] initWithType:GosTranAnimat_pageCurl
                                                        subType:kCATransitionFromRight
                                                       duration:CHANGE_ANIMAT_DURATION];
    }
    return _nextMsgAnimation;
}
- (GosTransition *)preMsgAnimation{
    if (!_preMsgAnimation) {
        _preMsgAnimation = [[GosTransition alloc] initWithType:GosTranAnimat_pageUnCurl
                                                       subType:kCATransitionFromRight
                                                      duration:CHANGE_ANIMAT_DURATION];
    }
    return _preMsgAnimation;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
