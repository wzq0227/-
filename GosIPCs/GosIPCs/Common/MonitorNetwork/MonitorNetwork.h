//
//  MonitorNetwork.h
//  GosIPCs
//
//  Created by shenyuanluo on 2019/1/12.
//  Copyright © 2019 goscam. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MonitorNetwork : NSObject

/**
 开启网络监控（只运行一次）
 */
+ (void)startMonitor;

+ (CurNetworkStatus)currentStatus;

@end

NS_ASSUME_NONNULL_END
