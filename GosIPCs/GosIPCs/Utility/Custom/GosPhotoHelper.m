//  GosPhotoHelper.m
//  GosIPCs
//
//  Create by daniel.hu on 2019/2/19.
//  Copyright © 2019年 goscam. All rights reserved.

#import "GosPhotoHelper.h"
#import <Photos/Photos.h>

@implementation GosPhotoHelper

#pragma mark - public class method
/// 保存图片到 系统默认App名的相册夹中
+ (void)saveImageToCustomAblumWithImage:(UIImage *)image
                                success:(void(^)(void))success
                                   fail:(void(^)(void))fail  {
    // 将图片保存到系统的【相机胶卷】中---调用刚才的方法
    PHFetchResult<PHAsset *> *assets = [GosPhotoHelper synchronousSaveImageWithPhotosWithImage:image];
    [GosPhotoHelper saveMediaWithResutl:assets success:success fail:fail];
}

/// 保存视频到 系统默认App名的相册夹中
+ (void)saveVideoToCustomAblumWithVideoPath:(NSString *)videoPath
                                    success:(void(^)(void))success
                                       fail:(void(^)(void))fail{
    // 将图片保存到系统的【相机胶卷】中---调用刚才的方法
    PHFetchResult<PHAsset *> *assets = [GosPhotoHelper synchronousSaveVideoWithVideoPath:videoPath];
    [GosPhotoHelper saveMediaWithResutl:assets success:success fail:fail];
}

#pragma mark - private class method
/// 统一保存媒体方法
+ (void)saveMediaWithResutl:(PHFetchResult<PHAsset *> *)assets
                    success:(void(^)(void))success
                       fail:(void(^)(void))fail {
    if (assets == nil) {
        GosLog(@"保存失败");
        if (fail) fail();
        return;
    }
    // 拥有自定义相册（与 APP 同名，如果没有则创建）--调用刚才的方法
    PHAssetCollection *assetCollection = [GosPhotoHelper getAssetCollectionWithAppNameAndCreateCollection];
    if (assetCollection == nil) {
        GosLog(@"相册创建失败");
        if (fail) fail();
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
        if (fail) fail();
        return;
    }
    
    GosLog(@"保存图片到系统相册成功");
    if (success) success();
}

/// 获取自定义相册
+ (PHAssetCollection *)getAssetCollectionWithAppNameAndCreateCollection {
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

/// 先同步保存图片到【相机胶卷】然后取出返回
+ (PHFetchResult<PHAsset *> *)synchronousSaveImageWithPhotosWithImage:(UIImage *)image {
    __block NSString *createdAssetId = nil;
    
    // 添加图片到【相机胶卷】
    [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
        createdAssetId = [PHAssetChangeRequest creationRequestForAssetFromImage:image].placeholderForCreatedAsset.localIdentifier;
    } error:nil];
    
    if (createdAssetId == nil) return nil;
    
    // 在保存完毕后取出图片
    return [PHAsset fetchAssetsWithLocalIdentifiers:@[createdAssetId] options:nil];
}

/// 先同步保存视频到【相机胶卷】然后取出返回
+ (PHFetchResult<PHAsset *> *)synchronousSaveVideoWithVideoPath:(NSString *)videoPath {
    __block NSString *createdAssetId = nil;
    NSURL * fileUrl = [NSURL URLWithString:videoPath];
    
    // 添加视频到【相机胶卷】
    [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
        createdAssetId = [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:fileUrl].placeholderForCreatedAsset.localIdentifier;
    } error:nil];
    
    if (createdAssetId == nil) return nil;
    
    // 在保存完毕后取出视频
    return [PHAsset fetchAssetsWithLocalIdentifiers:@[createdAssetId] options:nil];
}

@end
