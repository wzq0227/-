//
//  GosLock.m
//  GosIPCs
//
//  Created by shenyuanluo on 2018/12/29.
//  Copyright © 2018 goscam. All rights reserved.
//

#import "GosLock.h"

@interface GosLock()
{
    dispatch_semaphore_t m_mutex;   // 信号量
}
@end

@implementation GosLock

- (instancetype)init
{
    if (self = [super init])
    {
        m_mutex      = dispatch_semaphore_create(1);
        self.timeout = 0;
    }
    return self;
}

#pragma mark -- 上锁
- (void)lock
{
    dispatch_semaphore_wait(m_mutex, 0 < self.timeout ? self.timeout : DISPATCH_TIME_FOREVER);
}

#pragma mark -- 解锁
- (void)unLock
{
    dispatch_semaphore_signal(m_mutex);
}

@end
