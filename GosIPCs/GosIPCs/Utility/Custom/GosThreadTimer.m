//
//  GosThreadTimer.m
//  GosIPCs
//
//  Created by shenyuanluo on 2018/12/3.
//  Copyright © 2018 goscam. All rights reserved.
//

#import "GosThreadTimer.h"


@interface GosThreadTimer()
{
    SEL m_timerAction;
    id m_timerTarget;
    NSRunLoopMode m_rlMode;
    BOOL m_isPause;
}

@property (nonatomic, readwrite, strong) NSThread *subThread;
@property (nonatomic, readwrite, strong) NSTimer *timer;
@property (nonatomic, readwrite, assign) NSTimeInterval timerInterval;

@end

@implementation GosThreadTimer

#pragma mark -- 创建子线程定时器实例对象
- (instancetype)initWithInterval:(NSTimeInterval)interval
                       forAction:(SEL)selector
                         forModl:(NSRunLoopMode)mode
                        withName:(NSString *)name
                        onTarget:(id)target
{
    if (self = [super init])
    {
        m_timerAction      = selector;
        m_timerTarget      = target;
        m_rlMode           = mode;
        m_isPause          = NO;
        self.timerInterval = interval;
        self.subThread   = [[NSThread alloc] initWithTarget:self
                                                     selector:@selector(createTimer)
                                                       object:nil];
        self.subThread.name = name;
        [self.subThread start];
    }
    return self;
}

- (void)dealloc
{
    GosLog(@"---------- GosThreadTimer(name: %@) dealloc ----------", [NSThread currentThread]);
}


#pragma mark -- 暂停定时器
- (void)pause
{
    if (YES == m_isPause)
    {
        return;
    }
    if (!self.timer.isValid)
    {
        return;
    }
    m_isPause = YES;
    [self.timer setFireDate:[NSDate distantFuture]];
    GosLog(@"---------- GosThreadTimer(name: %@) pause ----------", [NSThread currentThread]);
}

#pragma mark -- 恢复定时器
- (void)resume
{
    if (NO == m_isPause)
    {
        return;
    }

    if (!self.timer.isValid)
    {
        return;
    }
    m_isPause = NO;
    [self.timer setFireDate:[NSDate date]];
    GosLog(@"---------- GosThreadTimer(name: %@) resume ----------", [NSThread currentThread]);
}

#pragma mark -- 停止定时器
- (void)stop
{
    if (self.timer)
    {
        [self.timer invalidate];
        self.timer = nil;
    }
    GosLog(@"---------- GosThreadTimer(name: %@) stop ----------", [NSThread currentThread]);
}

#pragma mark -- 销毁定时器线程
- (void)destroy
{
    [self performSelector:@selector(destoryTimerAndThread)
                 onThread:self.subThread
               withObject:nil
            waitUntilDone:YES];
}

#pragma makr -- 创建(子线程)定时器
- (void)createTimer
{
    @autoreleasepool
    {
        self.timer = [NSTimer timerWithTimeInterval:self.timerInterval
                                             target:m_timerTarget
                                           selector:m_timerAction
                                           userInfo:nil
                                            repeats:YES];
        NSRunLoop *curRunLoop = [NSRunLoop currentRunLoop];
        [curRunLoop addTimer:self.timer
                     forMode:m_rlMode];  // 添加定时器到 RunLoop
        [curRunLoop runMode:m_rlMode
                 beforeDate:[NSDate distantFuture]];    // 新创建线程中，runloop 需要手动启动
        
    }
}

#pragma mark -- 销毁定时器和线程
- (void)destoryTimerAndThread
{
    [self stop];
    m_timerAction = NULL;
    m_timerTarget = nil;
    
    [self.subThread cancel];
    self.subThread = nil;
    
    CFRunLoopStop(CFRunLoopGetCurrent());   // 强制退出当前 RunLoop
}


@end
