//  GosTargetServiceGenerator.m
//  CloudStoreSDK
//
//  Create by daniel.hu on 2018/12/11.
//  Copyright © 2018年 daniel. All rights reserved.

#import "GosTargetServiceGenerator.h"
#import "CloudStoreService.h"
#import "CloudPaymentService.h"
#import "CloudStoreOtherService.h"
#import "CloudDownloadService.h"

NSString *const GosNetworkingCloudStoreServiceIdentifier = @"CloudStoreService";
NSString *const GosNetworkingCloudPaymentServiceIdentifier = @"CloudPaymentService";
NSString *const GosNetworkingCloudStoreOtherServiceIdentifier = @"CloudStoreOtherService";
NSString *const GosNetworkingCloudDownloadServiceIdentifier = @"CloudDownloadService";

@implementation GosTargetServiceGenerator
- (CloudStoreService *)gos_CloudStoreService:(NSDictionary *)params {
    return [[CloudStoreService alloc] init];
}
- (CloudPaymentService *)gos_CloudPaymentService:(NSDictionary *)params {
    return [[CloudPaymentService alloc] init];
}
- (CloudStoreOtherService *)gos_CloudStoreOtherService:(NSDictionary *)params {
    return [[CloudStoreOtherService alloc] init];
}
- (CloudDownloadService *)gos_CloudDownloadService:(NSDictionary *)params {
    return [[CloudDownloadService alloc] init];
}
@end
