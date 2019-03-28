//
//  TFPhotoBrowseViewController.h
//  GosIPCs
//
//  Created by shenyuanluo on 2019/1/4.
//  Copyright © 2019 goscam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TFCRMediaModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface TFPhotoBrowseViewController : UIViewController
/** 当前图片下标 */
@property (nonatomic, readwrite, assign) NSUInteger curPhotoIndex;
/** 图片列表 */
@property (nonatomic, readwrite, strong) NSArray<TFCRMediaModel*>*photoList;

@end

NS_ASSUME_NONNULL_END
