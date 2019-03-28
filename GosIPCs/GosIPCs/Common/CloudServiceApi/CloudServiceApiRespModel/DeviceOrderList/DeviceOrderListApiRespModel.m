//  DeviceOrderListApiRespModel.m
//  CloudStoreSDK
//
//  Create by daniel.hu on 2018/12/18.
//  Copyright © 2018年 daniel. All rights reserved.

#import "DeviceOrderListApiRespModel.h"
#import "ClousServiceApiRespHelper.h"
#import "YYModel.h"
@interface DeviceOrderListApiRespModel ()
/// 转换后的状态
@property (nonatomic, readwrite, assign) CloudServicePackageStatusType cloudServicePackageStatusType;
@end
@implementation DeviceOrderListApiRespModel
- (void)setStatus:(NSString *)status {
    _status = status;
    
    _cloudServicePackageStatusType = [ClousServiceApiRespHelper convertPackageStatusFromString:status];
}
+ (nullable NSDictionary<NSString *, id> *)modelCustomPropertyMapper {
    return @{@"ID":@"id"};
}
@end
