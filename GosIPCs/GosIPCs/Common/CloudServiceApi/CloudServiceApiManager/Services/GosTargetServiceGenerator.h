//  GosTargetServiceGenerator.h
//  CloudStoreSDK
//
//  Create by daniel.hu on 2018/12/11.
//  Copyright © 2018年 daniel. All rights reserved.

#import <Foundation/Foundation.h>

/// CloudStoreService serviceIdentifier
extern NSString *const GosNetworkingCloudStoreServiceIdentifier;
/// CloudPaymentService serviceIdentifier
extern NSString *const GosNetworkingCloudPaymentServiceIdentifier;
/// CloudStoreOtherService serviceIdentifier
extern NSString *const GosNetworkingCloudStoreOtherServiceIdentifier;
/// CloudDownloadService serviceIdentifier
extern NSString *const GosNetworkingCloudDownloadServiceIdentifier;

NS_ASSUME_NONNULL_BEGIN
@class CloudStoreService;
@class CloudPaymentService;
@class CloudStoreOtherService;
@class CloudDownloadService;

/**
 此类生产Service的种类
 Service的子类初始化必须使用gos_ClassName的格式
 */
@interface GosTargetServiceGenerator : NSObject
- (CloudStoreService *)gos_CloudStoreService:(NSDictionary *)params;
- (CloudPaymentService *)gos_CloudPaymentService:(NSDictionary *)params;
- (CloudStoreOtherService *)gos_CloudStoreOtherService:(NSDictionary *)params;
- (CloudDownloadService *)gos_CloudDownloadService:(NSDictionary *)params;
@end

NS_ASSUME_NONNULL_END
