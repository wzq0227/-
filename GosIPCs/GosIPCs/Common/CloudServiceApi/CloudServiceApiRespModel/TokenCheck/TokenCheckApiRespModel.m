//  TokenCheckApiRespModel.m
//  GosIPCs
//
//  Create by daniel.hu on 2018/12/24.
//  Copyright © 2018年 goscam. All rights reserved.

#import "TokenCheckApiRespModel.h"
#import "YYModel.h"

@implementation TokenCheckApiRespModel
+ (nullable NSDictionary<NSString *, id> *)modelCustomPropertyMapper {
    return @{
             @"expiration":@"Expiration",
             @"deviceId":@"deviceid"
             };
}
@end


