//
//  QueueManager.m
//  GosIPCs
//
//  Created by shenyuanluo on 2018/12/28.
//  Copyright © 2018 goscam. All rights reserved.
//

#import "QueueManager.h"
#import "YYDispatchQueuePool.h"

#define GOS_BG_QUEUE_COUNT 10

@interface QueueManager()
/** 后台线程池 */
@property (nonatomic, readwrite, strong) YYDispatchQueuePool *bgQueuePool;
@end

@implementation QueueManager

+ (instancetype)shareManager
{
    static QueueManager *g_manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        if (nil == g_manager)
        {
            g_manager = [[QueueManager alloc] init];
        }
    });
    return g_manager;
}

- (instancetype)init
{
    if (self = [super init])
    {
        self.bgQueuePool = [[YYDispatchQueuePool alloc] initWithName:@"GosBackGroundQueuePool"
                                                          queueCount:GOS_BG_QUEUE_COUNT
                                                                 qos:NSQualityOfServiceBackground];
    }
    return self;
}

#pragma mark - Public
+ (dispatch_queue_t)bgQueue
{
    return [[self shareManager] bgQueue];
}


#pragma mark - Private
- (dispatch_queue_t)bgQueue
{
    return [self.bgQueuePool queue];
}

@end
