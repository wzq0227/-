//  GosTargetCloudServiceHelper.m
//  CloudStoreSDK
//
//  Create by daniel.hu on 2018/12/18.
//  Copyright © 2018年 daniel. All rights reserved.

#import "GosTargetCloudServiceHelper.h"
#import "GosLoggedInUserInfo.h"

@implementation GosTargetCloudServiceHelper
- (NSString *)gos_apiToken:(NSDictionary *)params {
    return [GosLoggedInUserInfo userToken];
}
- (NSString *)gos_apiUsername:(NSDictionary *)params {
    return [GosLoggedInUserInfo account];
}
@end
