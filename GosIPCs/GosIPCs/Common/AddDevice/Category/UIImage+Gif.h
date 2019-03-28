//
//  UIImage+Gif.h
//  GosIPCs
//
//  Created by 罗乐 on 2018/12/6.
//  Copyright © 2018 goscam. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (Gif)
+ (UIImage *)animatedGIFWithData:(NSData *)data;
@end

NS_ASSUME_NONNULL_END
