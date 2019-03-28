//
//  UIButton+GosTitleAndImg.h
//  GosIPCs
//
//  Created by shenyuanluo on 2018/11/15.
//  Copyright © 2018 shenyuanluo. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/* Button image（title共存情况下） 位置类型枚举 */
typedef NS_ENUM(NSInteger,GosBtnImgLocation) {
    GosBtnImgLeft           = 0,        // Title 在右，Image 在左（默认行为）
    GosBtnImgRight          = 1,        // Title 在左，Image 在右
    GosBtnImgTop            = 2,        // Title 在下，Image 在上
    GosBtnImgBottom         = 3,        // Title 在上，Image 在下
};

@interface UIButton (GosTitleAndImg)

/**
 设置 Button 的标题和图片的位置关系以及间隔
 
 @pragma location 图片位置, 参见‘GosBtnImgLocation’
 @pragma interval 标题和图片间距
 */
- (void)configImageLocation:(GosBtnImgLocation)location
               withInterval:(CGFloat)interval;

@end

NS_ASSUME_NONNULL_END
