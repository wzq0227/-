//  PackageValidTimeApiRespModel.m
//  GosIPCs
//
//  Create by daniel.hu on 2018/12/24.
//  Copyright © 2018年 goscam. All rights reserved.

#import "PackageValidTimeApiRespModel.h"
#import "ClousServiceApiRespHelper.h"
#import "YYModel.h"
@interface PackageValidTimeApiRespModel ()
/// 转换后的状态
@property (nonatomic, readwrite, assign) CloudServicePackageStatusType cloudServicePackageStatusType;
@end
@implementation PackageValidTimeApiRespModel
- (void)setStatus:(NSString *)status {
    _status = status;
    
    _cloudServicePackageStatusType = [ClousServiceApiRespHelper convertPackageStatusFromString:status];
}
+ (nullable NSDictionary<NSString *, id> *)modelCustomPropertyMapper {
    return @{@"ID":@"id"};
}
@end
