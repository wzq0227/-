//  GosMediator+CloudServiceApiMethods.m
//  CloudStoreSDK
//
//  Create by daniel.hu on 2018/12/18.
//  Copyright © 2018年 daniel. All rights reserved.

#import "GosMediator+CloudServiceApiMethods.h"

@implementation GosMediator (CloudServiceApiMethods)
- (NSString *)cloudServiceApiToken {
    return [[GosMediator sharedInstance] performTarget:@"CloudServiceHelper" action:@"apiToken" params:nil shouldCacheTarget:YES];
}
- (NSString *)cloudServiceApiUsername {
    return [[GosMediator sharedInstance] performTarget:@"CloudServiceHelper" action:@"apiUsername" params:nil shouldCacheTarget:YES];
}
@end
