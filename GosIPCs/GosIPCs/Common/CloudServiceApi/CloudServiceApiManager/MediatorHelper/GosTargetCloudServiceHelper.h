//  GosTargetCloudServiceHelper.h
//  CloudStoreSDK
//
//  Create by daniel.hu on 2018/12/18.
//  Copyright © 2018年 daniel. All rights reserved.

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface GosTargetCloudServiceHelper : NSObject
/// 获取CloudServiceApi的Token参数
- (NSString *)gos_apiToken:(NSDictionary *)params;
/// 获取CloudServiceApi的Username参数
- (NSString *)gos_apiUsername:(NSDictionary *)params;
@end

NS_ASSUME_NONNULL_END
