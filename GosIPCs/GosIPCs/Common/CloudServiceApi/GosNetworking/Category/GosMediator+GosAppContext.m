//  GosMediator+GosAppContext.m
//  CloudStoreSDK
//
//  Create by daniel.hu on 2018/12/11.
//  Copyright © 2018年 daniel. All rights reserved.

#import "GosMediator+GosAppContext.h"
#import "GosMediator.h"

@implementation GosMediator (GosAppContext)
- (BOOL)GosAppContextNetworkingIsReachable {
    return [[[GosMediator sharedInstance] performTarget:@"AppContext" action:@"isReachable" params:nil shouldCacheTarget:YES] boolValue];
}
- (BOOL)GosAppContextNetworkingShouldPrintNetworkingLog {
    return [[[GosMediator sharedInstance] performTarget:@"AppContext" action:@"shouldPrintNetworkingLog" params:nil shouldCacheTarget:YES] boolValue];
}
@end
