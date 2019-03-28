//
//  GosLock.h
//  GosIPCs
//
//  Created by shenyuanluo on 2018/12/29.
//  Copyright © 2018 goscam. All rights reserved.
//

/*
 自定义可以’异线程‘上锁/解锁 互斥锁 类
 */

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface GosLock : NSObject
/** 超时时间（Default：DISPATCH_TIME_FOREVER）*/
@property (nonatomic, readwrite, assign) NSTimeInterval timeout;

/*
 上锁
 */
- (void)lock;

/*
 解锁
 */
- (void)unLock;

@end

NS_ASSUME_NONNULL_END
