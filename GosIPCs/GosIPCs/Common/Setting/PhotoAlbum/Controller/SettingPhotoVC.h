//
//  SettingPhotoVC.h
//  Goscom
//
//  Created by 匡匡 on 2018/11/20.
//  Copyright © 2018 goscam. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PhotoAlbumModel;
@interface SettingPhotoVC : UIViewController
/// 数据模型
@property (nonatomic, strong) PhotoAlbumModel * dataModel;
/// 图片数组
@property (nonatomic, strong) NSMutableArray <PhotoAlbumModel*>* photoMutArr;
@end
