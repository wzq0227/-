//  PhotoAlbumViewModel.m
//  Goscom
//
//  Create by 匡匡 on 2018/12/12.
//  Copyright © 2018 goscam. All rights reserved.

#import "PhotoAlbumViewModel.h"
#import "MediaManager.h"
#import "iOSConfigSDKModel.h"
#import "PhotoAlbumModel.h"
@implementation PhotoAlbumViewModel
#pragma mark - 获取默认视频文件
+ (NSMutableArray<PhotoAlbumModel *> *)getDefaultVideoTableArr:(DevDataModel *) dataModel{
    NSMutableArray<MediaFileModel *> * mutArr = [MediaManager mediaListWithDevId:dataModel.DeviceId
                                                                       mediaType:GosMediaRecord
                                                                      deviceType:(GosDeviceType)dataModel.DeviceType
                                                                        position:PositionMain];
    
    NSMutableArray<PhotoAlbumModel *> * returnMutArr = [[NSMutableArray alloc] init];
    for (int i=0; i<mutArr.count; i++) {
        MediaFileModel * model = mutArr[i];
        PhotoAlbumModel * newModel = [[PhotoAlbumModel alloc] init];
        newModel.edit = NO;
        newModel.createTime = model.createTime;
        newModel.fileName = model.fileName;
        newModel.fileSize = model.fileSize;
        newModel.fileSizeStr = [PhotoAlbumViewModel formatFileSize:model.fileSize];
        newModel.filePath = model.filePath;
        newModel.selected = model.selected;
        [returnMutArr addObject:newModel];
    }
    return returnMutArr;
}
#pragma mark - 获取默认图片文件
+ (NSMutableArray<PhotoAlbumModel *> *)getDefaultPhotoTableArr:(DevDataModel *) dataModel{
    NSMutableArray<MediaFileModel *> * mutArr = [MediaManager mediaListWithDevId:dataModel.DeviceId
                                                                       mediaType:GosMediaSnapshot
                                                                      deviceType:(GosDeviceType)dataModel.DeviceType
                                                                        position:PositionMain];
    NSMutableArray<PhotoAlbumModel *> * returnMutArr = [[NSMutableArray alloc] init];
    for (int i=0; i<mutArr.count; i++) {
        MediaFileModel * model = mutArr[i];
        PhotoAlbumModel * newModel = [[PhotoAlbumModel alloc] init];
        newModel.edit = NO;
        newModel.createTime = model.createTime;
        newModel.fileName = model.fileName;
        newModel.fileSize = model.fileSize;
        newModel.fileSizeStr = [PhotoAlbumViewModel formatFileSize:model.fileSize];
        newModel.filePath = model.filePath;
        newModel.selected = model.selected;
        [returnMutArr addObject:newModel];
    }
    return returnMutArr;
}

#pragma mark - 文件大小转换
+ (NSString *)formatFileSize:(long long)fileSize;
{
    if (0 > fileSize)
    {
        return nil;
    }
    NSString *measureUnit = nil;
    double measureSize    = 0;
    if (kMeasureSizeGB <= fileSize) // GB
    {
        measureUnit = @"GB";
        measureSize = (double)fileSize/(double)kMeasureSizeGB;
    }
    else if (kMeasureSizeGB > fileSize && kMeasureSizeMB <= fileSize)   // MB
    {
        measureUnit = @"MB";
        measureSize = (double)fileSize/(double)kMeasureSizeMB;
    }
    else if (kMeasureSizeMB > fileSize && kMeasureSizeKB <= fileSize)   // KB
    {
        measureUnit = @"KB";
        measureSize = (double)fileSize/(double)kMeasureSizeKB;
    }
    else
    {
        measureUnit = @"B";
        measureSize = fileSize;
    }
    NSString *sizeStr = [NSString stringWithFormat:@"%.2f%@", measureSize, measureUnit];
    return sizeStr;
}


#pragma mark - 改变编辑状态(捎带选中)
+ (void)modifyEditWithDataArray:(NSMutableArray<PhotoAlbumModel *> *) tableDataArray
                        editing:(BOOL)editing
                       selected:(BOOL)selected{
    [tableDataArray enumerateObjectsUsingBlock:^(PhotoAlbumModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.edit = editing;
        obj.selected = selected;
    }];
}
#pragma mark - 改变全选中状态
+ (void)modifySelectStateWithDataArray:(NSMutableArray<PhotoAlbumModel *> *) tableDataArray
                               selectd:(BOOL) selectd{
    [tableDataArray enumerateObjectsUsingBlock:^(PhotoAlbumModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.selected = selectd;
    }];
}

#pragma mark - 检查是否有删除项
+ (BOOL)checkIsExistDeletableWithDataArray:(NSMutableArray<PhotoAlbumModel *> *) tableDataArray{
    // 只要存在可编辑项，并且数据被选择了就可被删除
    BOOL __block result = NO;
    [tableDataArray enumerateObjectsUsingBlock:^(PhotoAlbumModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.isEdit && obj.isSelected) {
            result = YES;
            *stop = YES;
        }
    }];
    return result;
}
#pragma mark - 判断是否全选
+ (BOOL)checkIsAllBeingSelectedWithDataArray:(NSMutableArray<PhotoAlbumModel *> *)dataArray{
    // 存在的可编辑项数据未被选择就返回NO
    BOOL __block result = YES;
    [dataArray enumerateObjectsUsingBlock:^(PhotoAlbumModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.isEdit && !obj.isSelected) {
            result = NO;
        }
    }];
    return result;
}
#pragma mark - 删除选中的media数组
+ (void)deleteDataWithArray:(NSMutableArray<PhotoAlbumModel *> *) deleteArray{
    NSMutableArray<PhotoAlbumModel *>*needDelArray  = [NSMutableArray arrayWithCapacity:0];
    [deleteArray enumerateObjectsWithOptions:NSEnumerationConcurrent
                                  usingBlock:^(PhotoAlbumModel * _Nonnull obj,
                                               NSUInteger idx,
                                               BOOL * _Nonnull stop)
     {
         if ([PhotoAlbumViewModel fileIsExistOfPath:obj.filePath] && obj.isSelected)
         {
             if([PhotoAlbumViewModel removeFileOfPath:obj.filePath])
             {
                 GosLog(@"移除成功");
                 [needDelArray addObject:obj];
             }else{
                 GosLog(@"移除失败");
             }
         }else{
             GosLog(@"移除文件不存在");
         }
     }];
    [deleteArray removeObjectsInArray:needDelArray];
}
#pragma mark - 删除单个media数据
+ (void)deleteDataWithModel:(PhotoAlbumModel *) dataModel
               tableDataArr:(NSMutableArray<PhotoAlbumModel *> *) tableDataArr{
    if ([PhotoAlbumViewModel fileIsExistOfPath: dataModel.filePath]) {
        if ([PhotoAlbumViewModel removeFileOfPath:dataModel.filePath]) {
            GosLog(@"删除单个文件成功");
            [tableDataArr removeObject:dataModel];
        }
    }
}

#pragma mark - 判断文件是否存在于某个路径中
+ (BOOL)fileIsExistOfPath:(NSString *)filePath{
    BOOL flag = NO;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:filePath]) {
        flag = YES;
    } else {
        flag = NO;
    }
    return flag;
}
#pragma mark - 从某个路径中移除文件
+ (BOOL)removeFileOfPath:(NSString *)filePath{
    BOOL flag = YES;
    NSFileManager *fileManage = [NSFileManager defaultManager];
    if ([fileManage fileExistsAtPath:filePath]) {
        if (![fileManage removeItemAtPath:filePath error:nil]) {
            flag = NO;
        }
    }
    return flag;
}

@end
