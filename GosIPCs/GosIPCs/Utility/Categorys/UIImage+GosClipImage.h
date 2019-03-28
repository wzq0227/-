//  UIImage+GosClipImage.h
//  GosIPCs
//
//  Create by daniel.hu on 2018/11/29.
//  Copyright © 2018年 goscam. All rights reserved.

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 裁减图片分类
 */
@interface UIImage (GosClipImage)

/**
 裁减至圆形图片

 @param imageRect 尺寸
 @return UIImage
 */
- (UIImage *)clipToRoundImageWithRect:(CGRect)imageRect;
@end

NS_ASSUME_NONNULL_END
