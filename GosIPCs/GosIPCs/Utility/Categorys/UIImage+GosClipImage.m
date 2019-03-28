//  UIImage+GosClipImage.m
//  GosIPCs
//
//  Create by daniel.hu on 2018/11/29.
//  Copyright © 2018年 goscam. All rights reserved.

#import "UIImage+GosClipImage.h"

@implementation UIImage (GosClipImage)
- (UIImage *)clipToRoundImageWithRect:(CGRect)imageRect {
    // 开启位图上下文
    UIGraphicsBeginImageContextWithOptions(imageRect.size, NO, 0);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // 设置裁剪区域
    CGContextAddEllipseInRect(context, imageRect);
    CGContextClip(context);
    
    // 绘制图片
    [self drawInRect:imageRect];
    
    // 获取当前图片
    UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // 关闭上下文
    UIGraphicsEndImageContext();
    
    return resultImage;
    
}
@end
