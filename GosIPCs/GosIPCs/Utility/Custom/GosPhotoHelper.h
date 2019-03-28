//  GosPhotoHelper.h
//  GosIPCs
//
//  Create by daniel.hu on 2019/2/19.
//  Copyright © 2019年 goscam. All rights reserved.

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface GosPhotoHelper : NSObject

/**
 保存图片到 系统默认App名的相册夹中

 @param image 图片
 @param success 成功响应
 @param fail 失败响应
 */
+ (void)saveImageToCustomAblumWithImage:(UIImage *)image
                                success:(void(^)(void))success
                                   fail:(void(^)(void))fail;

/**
 保存视频到 系统默认App名的相册夹中

 @param videoPath 视频路径
 @param success 成功响应
 @param fail 失败响应
 */
+ (void)saveVideoToCustomAblumWithVideoPath:(NSString *)videoPath
                                    success:(void(^)(void))success
                                       fail:(void(^)(void))fail;

@end

NS_ASSUME_NONNULL_END
