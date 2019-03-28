//  PhotoAlbumViewModel.h
//  Goscom
//
//  Create by 匡匡 on 2018/12/12.
//  Copyright © 2018 goscam. All rights reserved.

#import <Foundation/Foundation.h>
@class PhotoAlbumModel;
@class DevDataModel;
NS_ASSUME_NONNULL_BEGIN

@interface PhotoAlbumViewModel : NSObject

/**
 获取默认视频文件

 @param dataModel 设备模型
 @return 默认视频文件数组
 */
+ (NSMutableArray<PhotoAlbumModel *> *)getDefaultVideoTableArr:(DevDataModel *) dataModel;

/**
 获取默认图片文件

 @param dataModel 设备模型
 @return 默认图片文件数组
 */
+ (NSMutableArray<PhotoAlbumModel *> *)getDefaultPhotoTableArr:(DevDataModel *) dataModel;


/**
 改变编辑状态(捎带选中)

 @param tableDataArray 原始tableArr
 @param editing 是否编辑
 @param selected 是否选中
 */
+ (void)modifyEditWithDataArray:(NSMutableArray<PhotoAlbumModel *> *) tableDataArray
                        editing:(BOOL)editing
                       selected:(BOOL)selected;


/**
 改变全选中状态

 @param tableDataArray 原始TableArr
 @param selectd 是否选中
 */
+ (void)modifySelectStateWithDataArray:(NSMutableArray<PhotoAlbumModel *> *) tableDataArray
                               selectd:(BOOL) selectd;


/**
 检查是否有删除项

 @param tableDataArray 原始TableArr
 @return YES 有删除  NO 无删除
 */
+ (BOOL)checkIsExistDeletableWithDataArray:(NSMutableArray<PhotoAlbumModel *> *) tableDataArray;

/**
 判断是否全选

 @param dataArray 原始TableArr
 @return YES 全选  NO 非
 */
+ (BOOL)checkIsAllBeingSelectedWithDataArray:(NSMutableArray<PhotoAlbumModel *> *)dataArray;


/**
 删除选中的media数组

 @param deleteArray 需要删除的媒体Arr
 */
+ (void)deleteDataWithArray:(NSMutableArray<PhotoAlbumModel *> *) deleteArray;


/**
 删除单个media数据

 @param dataModel 单个媒体模型
 @param tableDataArr 原始TableArr
 */
+ (void)deleteDataWithModel:(PhotoAlbumModel *) dataModel
                tableDataArr:(NSMutableArray<PhotoAlbumModel *> *) tableDataArr;
@end

NS_ASSUME_NONNULL_END
