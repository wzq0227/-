//
//  GosReadWriteLock.m
//  GosIPCs
//
//  Created by shenyuanluo on 2018/12/29.
//  Copyright © 2018 goscam. All rights reserved.
//

#import "GosReadWriteLock.h"
#import "GosLock.h"

@interface GosReadWriteLock()
/** ‘读’操作锁 */
@property (nonatomic, readwrite, strong) GosLock *readLock;
/** ’写‘操作锁 */
@property (nonatomic, readwrite, strong) GosLock *writeLock;
/** '优先级‘锁（用于提高’写‘操作优先级，防止大量的’读‘操作发生时而导致的’写‘操作饥饿） */
@property (nonatomic, readwrite, strong) GosLock *priorityLock;;
/** 读操作数 */
@property (nonatomic, readwrite, assign) NSUInteger readCount;

@end


@implementation GosReadWriteLock

- (instancetype)init
{
    if (self = [super init])
    {
        _readLock     = [[GosLock alloc] init];
        _writeLock    = [[GosLock alloc] init];
        _priorityLock = [[GosLock alloc] init];
        _readCount    = 0;
        _readTimeout  = 0;
        _writeTimeout = 0;
    }
    return self;
}

- (void)setReadTimeout:(NSTimeInterval)readTimeout
{
    if (_readTimeout == readTimeout)
    {
        return;
    }
    if (0 >= readTimeout)  // 默认：DISPATCH_TIME_FOREVER
    {
        _readTimeout = DISPATCH_TIME_FOREVER;
    }
    else
    {
        _readTimeout = readTimeout;
    }
    self.readLock.timeout = _readTimeout;
}

- (void)setWriteTimeout:(NSTimeInterval)writeTimeout
{
    if (_writeTimeout == writeTimeout)
    {
        return;
    }
    if (0 >= writeTimeout)  // 默认：DISPATCH_TIME_FOREVER
    {
        _writeTimeout = DISPATCH_TIME_FOREVER;
    }
    else
    {
        _writeTimeout = writeTimeout;
    }
    self.writeLock.timeout = _writeTimeout;
}

#pragma mark -- '读’上锁
- (void)lockRead
{
    [self.priorityLock lock];
    [self.readLock lock];
    self.readCount++;
    if (1 == self.readCount)
    {
        [self.writeLock lock];
    }
    [self.readLock unLock];
    [self.priorityLock unLock];
}

#pragma mark -- '读’解锁
- (void)unLockRead
{
    [self.readLock lock];
    self.readCount--;
    if (0 == self.readCount)
    {
        [self.writeLock unLock];
    }
    [self.readLock unLock];
}

#pragma mark -- '写’上锁
- (void)lockWrite
{
    [self.priorityLock lock];
    [self.writeLock lock];
}

#pragma mark -- '写’解锁
- (void)unLockWrite
{
    [self.writeLock unLock];
    [self.priorityLock unLock];
}


@end
