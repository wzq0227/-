//  PayOrderPaymentResultApiRespModel.m
//  CloudStoreSDK
//
//  Create by daniel.hu on 2018/12/18.
//  Copyright © 2018年 daniel. All rights reserved.

#import "PayOrderPaymentResultApiRespModel.h"
#import "ClousServiceApiRespHelper.h"

@interface PayOrderPaymentResultApiRespModel ()

@property (nonatomic, readwrite, assign) CloudServicePaymentStatusType cloudServicePaymentStatusType;
@end
@implementation PayOrderPaymentResultApiRespModel
- (void)setStatus:(NSString *)status {
    _status = status;
    _cloudServicePaymentStatusType = [ClousServiceApiRespHelper convertPaymentStatusFromString:status];
}
@end
