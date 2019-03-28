//  UIView+GosAnimation.m
//  GosIPCs
//
//  Create by daniel.hu on 2018/11/29.
//  Copyright © 2018年 goscam. All rights reserved.

#import "UIView+GosAnimation.h"

@implementation UIView (GosAnimation)
- (void)infiniteRotateAnimation {
    [self.layer removeAllAnimations];
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    animation.fromValue           = @(0);
    animation.toValue             = @(2 * M_PI);
    animation.repeatCount         = MAXFLOAT;
    animation.duration            = 7.2;
    animation.removedOnCompletion = NO;
    
    [self.layer addAnimation:animation
                       forKey:@"transform.rotation.z"];
}
@end
