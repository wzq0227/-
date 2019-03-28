//  GosTargetAppContext.m
//  CloudStoreSDK
//
//  Create by daniel.hu on 2018/12/11.
//  Copyright © 2018年 daniel. All rights reserved.

#import "GosTargetAppContext.h"
#import "AFNetworkReachabilityManager.h"
@implementation GosTargetAppContext
- (BOOL)gos_isReachable:(NSDictionary *)params {
//    // FIXME: 实时监控
    GosLog(@"gos_isReachable -- %d", [[AFNetworkReachabilityManager manager] isReachable]);
    return YES;
}
- (BOOL)gos_shouldPrintNetworkingLog:(NSDictionary *)params {
    return YES;
}
- (void)notFound:(NSDictionary *)params {
    GosLog(@"notfoundMethod: %@", params);
}
@end
