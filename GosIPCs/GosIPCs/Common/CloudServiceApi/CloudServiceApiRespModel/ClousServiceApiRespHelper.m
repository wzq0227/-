//  ClousServiceApiRespHelper.m
//  GosIPCs
//
//  Create by daniel.hu on 2018/12/20.
//  Copyright © 2018年 goscam. All rights reserved.

#import "ClousServiceApiRespHelper.h"

@implementation ClousServiceApiRespHelper

+ (CloudServicePackageStatusType)convertPackageStatusFromString:(NSString *)string {
    CloudServicePackageStatusType status = CloudServicePackageStatusTypeExpired;
    
    switch ([string intValue]) {
        case 0:
            status = CloudServicePackageStatusTypeExpired;
            break;
        case 1:
            status = CloudServicePackageStatusTypeInUse;
            break;
        case 2:
            status = CloudServicePackageStatusTypeUnused;
            break;
        case 7:
            status = CloudServicePackageStatusTypeUnbind;
            break;
        case 9:
            status = CloudServicePackageStatusTypeForbidden;
            break;
        default:
            break;
    }
    return status;
}

+ (CloudServicePaymentStatusType)convertPaymentStatusFromString:(NSString *)string {
    CloudServicePaymentStatusType status = CloudServicePaymentStatusTypeFailed;
    switch ([string intValue]) {
        case 0:
            status = CloudServicePaymentStatusTypeProcess;
            break;
        case 1:
            status = CloudServicePaymentStatusTypeSuccess;
            break;
        case 2:
            status = CloudServicePaymentStatusTypeCanceled;
            break;
        case 4:
            status = CloudServicePaymentStatusTypeFailedWithTimeout;
            break;
        default:
            break;
    }
    return status;
}

+ (VideoSlicesAlarmType)convertAlarmTypeFromString:(NSString *)string {
    VideoSlicesAlarmType type = VideoSlicesAlarmTypeUnknow;
    switch ([string intValue]) {
        case 1:
            type = VideoSlicesAlarmTypeMotionDetection;
            break;
        case 4:
            type = VideoSlicesAlarmTypeVoiceDetection;
            break;
        case 6:
        case 7:
            type = VideoSlicesAlarmTypeTemperture;
            break;
        default:
            break;
    }
    return type;
}
@end
