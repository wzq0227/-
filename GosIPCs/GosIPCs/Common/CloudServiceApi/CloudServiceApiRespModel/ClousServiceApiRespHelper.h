//  ClousServiceApiRespHelper.h
//  GosIPCs
//
//  Create by daniel.hu on 2018/12/20.
//  Copyright © 2018年 goscam. All rights reserved.

#import <Foundation/Foundation.h>
#import "CloudServiceApiRespProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface ClousServiceApiRespHelper : NSObject
+ (CloudServicePackageStatusType)convertPackageStatusFromString:(NSString *)string;
+ (CloudServicePaymentStatusType)convertPaymentStatusFromString:(NSString *)string;
+ (VideoSlicesAlarmType)convertAlarmTypeFromString:(NSString *)string;
@end

NS_ASSUME_NONNULL_END
