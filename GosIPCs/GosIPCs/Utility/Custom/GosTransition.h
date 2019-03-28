//
//  GosTransition.h
//  GosIPCs
//
//  Created by shenyuanluo on 2018/12/29.
//  Copyright © 2018 goscam. All rights reserved.
//

/*
 自定义动画类
 */

#import <QuartzCore/QuartzCore.h>

NS_ASSUME_NONNULL_BEGIN

/** 过度动画类型枚举 */
typedef NS_ENUM(NSInteger, GosTranAnimationType) {
    GosTranAnimat_push                    = 1,    // 推挤
    GosTranAnimat_reveal                  = 2,    // 揭开
    GosTranAnimat_cube                    = 3,    // 立方体
    GosTranAnimat_suckEffect              = 4,    // 吮吸
    GosTranAnimat_oglFlip                 = 5,    // 翻转
    GosTranAnimat_rippleEffect            = 6,    // 波纹
    GosTranAnimat_pageCurl                = 7,    // 翻页
    GosTranAnimat_pageUnCurl              = 8,    // 反翻页
    GosTranAnimat_cameraIrisHollowOpen    = 9,    // 开镜头
    GosTranAnimat_cameraIrisHollowClose   = 10,   // 关镜头
};

@interface GosTransition : CATransition

- (instancetype)initWithType:(GosTranAnimationType)aType
                     subType:(NSString * __nullable)subType
                    duration:(NSTimeInterval)animatDuration;

@end

NS_ASSUME_NONNULL_END
