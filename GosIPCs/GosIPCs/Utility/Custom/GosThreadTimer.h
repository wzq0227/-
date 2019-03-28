//
//  GosThreadTimer.h
//  GosIPCs
//
//  Created by shenyuanluo on 2018/12/3.
//  Copyright © 2018 goscam. All rights reserved.
//

/*
 创建子线程定时器类
 */

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface GosThreadTimer : NSObject

/*
 创建（子线程）定时器实例对象
 
 @param interval 定时器时间间隔
 @param selector 定时器执行方法
 @param mode 子线程 RunLoop 运行模式
 @param name 子线程名
 @param target 定时器执行方法所在的 ‘target’
 */
- (instancetype)initWithInterval:(NSTimeInterval)interval
                       forAction:(SEL)selector
                        forModl:(NSRunLoopMode)mode
                        withName:(NSString *)name
                        onTarget:(id)target;

/*
 暂停（子线程）定时器
 */
- (void)pause;

/*
 恢复（子线程）定时器
 */
- (void)resume;

/*
 销毁（子线程）定时器实例对象（必须执行，否则内存泄露）
 */
- (void)destroy;

@end

NS_ASSUME_NONNULL_END
