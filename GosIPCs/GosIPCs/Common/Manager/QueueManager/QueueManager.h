//
//  QueueManager.h
//  GosIPCs
//
//  Created by shenyuanluo on 2018/12/28.
//  Copyright © 2018 goscam. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface QueueManager : NSObject

/*
 获取后台队列
 
 @return 后台队列实例
 */
+ (dispatch_queue_t)bgQueue;

@end

NS_ASSUME_NONNULL_END
