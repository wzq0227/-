//  GosMediator+GosAppContext.h
//  CloudStoreSDK
//
//  Create by daniel.hu on 2018/12/11.
//  Copyright © 2018年 daniel. All rights reserved.

#import "GosMediator.h"

NS_ASSUME_NONNULL_BEGIN

@interface GosMediator (GosAppContext)
- (BOOL)GosAppContextNetworkingIsReachable;
- (BOOL)GosAppContextNetworkingShouldPrintNetworkingLog;
@end

NS_ASSUME_NONNULL_END
