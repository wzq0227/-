//  GosTargetAppContext.h
//  CloudStoreSDK
//
//  Create by daniel.hu on 2018/12/11.
//  Copyright © 2018年 daniel. All rights reserved.

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface GosTargetAppContext : NSObject
/// 网络是否可达
- (BOOL)gos_isReachable:(NSDictionary *)params;
/// 是否打印网络日志
- (BOOL)gos_shouldPrintNetworkingLog:(NSDictionary *)params;

@end

NS_ASSUME_NONNULL_END
