//
//  GosGradualBrightness.h
//  GosIPCs
//
//  Created by shenyuanluo on 2018/11/14.
//  Copyright © 2018 shenyuanluo. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 亮度渐变设置类
 */
@interface GosGradualBrightness : NSObject

/**
 保存默认亮度
 */
+ (void)sySaveDefaultBrightness;


/**
 逐步设置亮度
 
 @param brightness 目标亮度值
 */
+ (void)syConfigBrightness:(CGFloat)brightness;


/**
 逐步恢复亮度
 */
+ (void)syResumeBrightness;

@end

NS_ASSUME_NONNULL_END
