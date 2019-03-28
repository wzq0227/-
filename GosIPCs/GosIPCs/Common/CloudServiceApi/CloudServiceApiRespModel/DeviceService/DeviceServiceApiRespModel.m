//  DeviceServiceApiRespModel.m
//  GosIPCs
//
//  Create by daniel.hu on 2018/12/25.
//  Copyright © 2018年 goscam. All rights reserved.

#import "DeviceServiceApiRespModel.h"
#import "ClousServiceApiRespHelper.h"
#import "YYModel.h"

@interface DeviceServiceApiRespModel ()
/// 转换后的状态
@property (nonatomic, readwrite, assign) CloudServicePackageStatusType cloudServicePackageStatusType;
@end
@implementation DeviceServiceApiRespModel
- (void)setStatus:(NSString *)status {
    _status = status;
    
    _cloudServicePackageStatusType = [ClousServiceApiRespHelper convertPackageStatusFromString:status];
}
+ (nullable NSDictionary<NSString *, id> *)modelCustomPropertyMapper {
    return @{@"ID":@"id"};
}
@end
