//  GosTimeAxis+Deceleration.h
//  GosIPCs
//
//  Create by daniel.hu on 2018/11/27.
//  Copyright © 2018年 goscam. All rights reserved.

#import "GosTimeAxis.h"

/**
 模拟减速效果分类
 */
@interface GosTimeAxis (Deceleration)
/// 动画执行者
@property (nonatomic, strong) UIDynamicAnimator *animator;
/// 惯性行为
@property (nonatomic, strong) __block UIDynamicItemBehavior *inertialBehavior;

/**
 模拟减速动画

 @param velocityPoint 速度
 @param action 减速过程的响应事件
 */
- (void)deceleratingAnimateWithVelocityPoint:(CGPoint)velocityPoint action:(void(^)(CGPoint deceleratingSpeedPoint, BOOL stop))action;

/// 手动停止减速，在主GosTimeAxis里的调用
- (void)manuallyStopDeceleratingInvokeInMain;

/// 手动停止减速，在主GosTimeAxis里的继续处理
- (void)manuallyStopDeceleratingContinueDealInMain;
@end


