//
//  UIButton+GosTitleAndImg.m
//  GosIPCs
//
//  Created by shenyuanluo on 2018/11/15.
//  Copyright © 2018 shenyuanluo. All rights reserved.
//

#import "UIButton+GosTitleAndImg.h"

@implementation UIButton (GosTitleAndImg)

- (void)configImageLocation:(GosBtnImgLocation)location
               withInterval:(CGFloat)interval
{
    [self layoutIfNeeded];
    
    CGRect titleFrame        = self.titleLabel.frame;
    CGRect imageFrame        = self.imageView.frame;
    CGFloat titleOriginX     = titleFrame.origin.x;
    CGFloat imageOriginX     = imageFrame.origin.x;
    CGFloat titleWidth       = titleFrame.size.width;
    CGFloat titleHeight      = titleFrame.size.height;
    CGFloat imageWidth       = imageFrame.size.width;
    CGFloat imageHeight      = imageFrame.size.height;
    CGFloat horizontalSpace  = titleOriginX - imageOriginX;     // 水平移动距离
    CGFloat halfInterval     = interval * 0.5f;
    CGFloat halfTitleWidth   = titleWidth * 0.5f;
    CGFloat halfTitleHeight  = titleHeight * 0.5f;
    CGFloat halfImageWidth   = imageWidth * 0.5f;
    CGFloat halfImageHeight  = imageHeight * 0.5f;
    UIEdgeInsets titleInsets = UIEdgeInsetsZero;
    UIEdgeInsets imageInsets = UIEdgeInsetsZero;
    
    switch (location)
    {
        case GosBtnImgLeft:
        {
            titleInsets = UIEdgeInsetsMake(0, halfInterval, 0, -halfInterval);
            imageInsets = UIEdgeInsetsMake(0, -halfInterval, 0, halfInterval);
        }
            break;
            
        case GosBtnImgRight:
        {
            titleInsets = UIEdgeInsetsMake(0, -(horizontalSpace + halfInterval), 0, horizontalSpace + halfInterval);
            imageInsets = UIEdgeInsetsMake(0, titleWidth + halfInterval, 0, -(titleWidth + halfInterval));
        }
            break;
            
        case GosBtnImgTop:
        {
            titleInsets = UIEdgeInsetsMake(halfImageHeight + halfInterval, -halfImageWidth, -(halfImageHeight + halfInterval), halfImageWidth);
            imageInsets = UIEdgeInsetsMake(-(halfTitleHeight + halfInterval), halfTitleWidth, halfTitleHeight + halfInterval, -halfTitleWidth);
        }
            break;
            
        case GosBtnImgBottom:
        {
            titleInsets = UIEdgeInsetsMake(-(halfImageHeight + halfInterval), -halfImageWidth, halfImageHeight + halfInterval, halfImageWidth);
            imageInsets = UIEdgeInsetsMake(halfTitleHeight + halfInterval, halfTitleWidth, -(halfTitleHeight + halfInterval), -halfTitleWidth);
        }
            break;
            
        default:
            break;
    }
    [self setImageEdgeInsets:imageInsets];
    [self setTitleEdgeInsets:titleInsets];
}

@end
