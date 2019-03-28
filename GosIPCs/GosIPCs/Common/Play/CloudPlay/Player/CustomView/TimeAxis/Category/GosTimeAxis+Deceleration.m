//  GosTimeAxis+Deceleration.m
//  GosIPCs
//
//  Create by daniel.hu on 2018/11/27.
//  Copyright © 2018年 goscam. All rights reserved.

#import "GosTimeAxis+Deceleration.h"
#import <objc/runtime.h>
#import "GosTimeAxisDynamicItem.h"
@implementation GosTimeAxis (Deceleration)

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    // 手动点击停止整个滚动
    [self manuallyStopDeceleratingInvokeInDeceleration];
}

/// 在此类调用的停止减速
- (void)manuallyStopDeceleratingInvokeInDeceleration {
    if (self.inertialBehavior != nil) {
        [self.animator removeBehavior:self.inertialBehavior];
        self.inertialBehavior = nil;
        
        [self manuallyStopDeceleratingContinueDealInMain];
    }
}

/// 在GosTimeAxis中调用的停止减速
- (void)manuallyStopDeceleratingInvokeInMain {
    if (self.inertialBehavior != nil) {
        [self.animator removeBehavior:self.inertialBehavior];
        self.inertialBehavior = nil;
    }
}

- (void)deceleratingAnimateWithVelocityPoint:(CGPoint)velocityPoint action:(void(^)(CGPoint deceleratingSpeedPoint, BOOL stop))action {
    if (self.inertialBehavior != nil) {
        [self.animator removeBehavior:self.inertialBehavior];
    }
    // velocity是在手势结束的时候获取的各个方向的手势速度
    GosTimeAxisDynamicItem *item = [[GosTimeAxisDynamicItem alloc] init];
    item.center = CGPointMake(0, 0);
    UIDynamicItemBehavior *inertialBehavior = [[UIDynamicItemBehavior alloc] initWithItems:@[item]];
    
    [inertialBehavior addLinearVelocity:velocityPoint forItem:item];
    // 阻尼，衰减系数
    inertialBehavior.resistance = 2.0;
    
    __weak typeof(self) weakself = self;
    inertialBehavior.action = ^{
        // 当前时刻X方向速度
        CGFloat speedX = [weakself.inertialBehavior linearVelocityForItem:item].x;
        // 当前时刻Y方向速度
        CGFloat speedY = [weakself.inertialBehavior linearVelocityForItem:item].y;
        float minLimit = 1.0;
        if ((speedX >= -minLimit && speedX <= minLimit) && (speedY >= -minLimit && speedY <= minLimit)) {
            // 速度在某一范围内就停止减速
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                action(CGPointMake(speedX, speedY), YES);
            });
            // 停止行为
            [weakself.animator removeBehavior:weakself.inertialBehavior];
            weakself.inertialBehavior = nil;
            
        } else {
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                action(CGPointMake(speedX, speedY), NO);
            });
        }
    };
    
    self.inertialBehavior = inertialBehavior;
    [self.animator addBehavior:inertialBehavior];
    
}

- (void)manuallyStopDeceleratingContinueDealInMain {
    // 在GosTimeAxis实现
}

#pragma mark - getters and setters
- (UIDynamicAnimator *)animator {
    UIDynamicAnimator *tempAnimator = objc_getAssociatedObject(self, _cmd);
    
    if (!tempAnimator) {
        tempAnimator = [[UIDynamicAnimator alloc] init];
        objc_setAssociatedObject(self, @selector(animator), tempAnimator, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return tempAnimator;
}
- (void)setAnimator:(UIDynamicAnimator *)animator {
    objc_setAssociatedObject(self, @selector(animator), animator, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (UIDynamicItemBehavior *)inertialBehavior {
    return objc_getAssociatedObject(self, _cmd);
}
- (void)setInertialBehavior:(UIDynamicItemBehavior *)inertialBehavior {
    objc_setAssociatedObject(self, @selector(inertialBehavior), inertialBehavior, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
