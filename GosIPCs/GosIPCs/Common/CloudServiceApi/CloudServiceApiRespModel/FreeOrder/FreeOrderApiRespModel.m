//  FreeOrderApiRespModel.m
//  CloudStoreSDK
//
//  Create by daniel.hu on 2018/12/18.
//  Copyright © 2018年 daniel. All rights reserved.

#import "FreeOrderApiRespModel.h"
#import "ClousServiceApiRespHelper.h"

@interface FreeOrderApiRespModel ()
/// 由status转化的支付状态
@property (nonatomic, readwrite, assign) CloudServicePaymentStatusType cloudServicePaymentStatusType;
@end
@implementation FreeOrderApiRespModel
- (void)setStatus:(NSString *)status {
    _status = status;
    _cloudServicePaymentStatusType = [ClousServiceApiRespHelper convertPaymentStatusFromString:status];
}
@end
