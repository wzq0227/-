//  PhotoAlbumModel.h
//  Goscom
//
//  Create by 匡匡 on 2018/12/11.
//  Copyright © 2018 goscam. All rights reserved.

#import "MediaManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface PhotoAlbumModel : MediaFileModel
/// 是否编辑状态
@property (nonatomic, assign,getter=isEdit) BOOL edit;
/// 文件大小转字符串
@property (nonatomic, copy) NSString * fileSizeStr;

@end

NS_ASSUME_NONNULL_END
