//
//  GosReadWriteLock.h
//  GosIPCs
//
//  Created by shenyuanluo on 2018/12/29.
//  Copyright © 2018 goscam. All rights reserved.
//

/*
 自定义可以’异线程‘上锁/解锁 读-写锁 类
 ‘写’操作互斥；
 ‘读’操作支持并发
 */

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface GosReadWriteLock : NSObject
/** '读'超时时间（Default：DISPATCH_TIME_FOREVER）*/
@property (nonatomic, readwrite, assign) NSTimeInterval readTimeout;
/** '写'超时时间（Default：DISPATCH_TIME_FOREVER）*/
@property (nonatomic, readwrite, assign) NSTimeInterval writeTimeout;

/*
 ’读‘操作上锁
 */
- (void)lockRead;

/*
 ’读‘操作解锁
 */
- (void)unLockRead;

/*
 ’写‘操作上锁
 */
- (void)lockWrite;

/*
 ’写‘操作解锁
 */
- (void)unLockWrite;

@end

NS_ASSUME_NONNULL_END
