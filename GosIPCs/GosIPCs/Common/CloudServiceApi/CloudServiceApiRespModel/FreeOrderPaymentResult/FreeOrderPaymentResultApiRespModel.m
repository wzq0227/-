//  FreeOrderPaymentResultApiRespModel.m
//  CloudStoreSDK
//
//  Create by daniel.hu on 2018/12/18.
//  Copyright © 2018年 daniel. All rights reserved.

#import "FreeOrderPaymentResultApiRespModel.h"
#import "ClousServiceApiRespHelper.h"

@interface FreeOrderPaymentResultApiRespModel ()

@property (nonatomic, readwrite, assign) CloudServicePaymentStatusType cloudServicePaymentStatusType;
@end
@implementation FreeOrderPaymentResultApiRespModel
- (void)setStatus:(NSString *)status {
    _status = status;
    _cloudServicePaymentStatusType = [ClousServiceApiRespHelper convertPaymentStatusFromString:status];
}
@end
