//
//  GosTransition.m
//  GosIPCs
//
//  Created by shenyuanluo on 2018/12/29.
//  Copyright © 2018 goscam. All rights reserved.
//

#import "GosTransition.h"

@implementation GosTransition

- (instancetype)initWithType:(GosTranAnimationType)aType
                     subType:(NSString * __nullable)subType
                    duration:(NSTimeInterval)animatDuration
{
    GosTransition *animation = [GosTransition animation];
    animation.duration       = animatDuration;
    animation.type           = [self transitionNameWithType:aType];
    if (nil != subType)
    {
        animation.subtype = subType;
    }
    return animation;
}

#pragma mark -- 动画类型转换
- (NSString *)transitionNameWithType:(GosTranAnimationType)cmaType
{
    NSString *name = nil;
    switch (cmaType)
    {
        case GosTranAnimat_push:                  name = @"push";                 break;  // 推挤
        case GosTranAnimat_reveal:                name = @"reveal";               break;  // 揭开
        case GosTranAnimat_cube:                  name = @"cube";                 break;  // 立方体
        case GosTranAnimat_suckEffect:            name = @"suckEffect";           break;  // 吮吸
        case GosTranAnimat_oglFlip:               name = @"oglFlip";              break;  // 翻转
        case GosTranAnimat_rippleEffect:          name = @"rippleEffect";         break;  // 波纹
        case GosTranAnimat_pageCurl:              name = @"pageCurl";             break;  // 翻页
        case GosTranAnimat_pageUnCurl:            name = @"pageUnCurl";           break;  // 反翻页
        case GosTranAnimat_cameraIrisHollowOpen:  name = @"cameraIrisHollowOpen"; break;  // 开镜头
        case GosTranAnimat_cameraIrisHollowClose: name = @"cameraIrisHollowClose";break;  // 关镜头
        default:                                  name = @"pageCurl";             break;
    }
    return name;
}

@end
