//  FreeOrderApiManager.m
//  CloudStoreSDK
//
//  Create by daniel.hu on 2018/12/11.
//  Copyright © 2018年 daniel. All rights reserved.

#import "FreeOrderApiManager.h"
#import "YYModel.h"
#import "FreeOrderApiRespModel.h"
#import "GosMediator+CloudServiceApiMethods.h"

#pragma mark - service identifier
/// CloudPaymentService
extern NSString *const GosNetworkingCloudPaymentServiceIdentifier;
#pragma mark - 请求参数
/// 套餐Id
extern NSString *const kCloudServiceApiReqKeyPlanId;
/// 设备id
extern NSString *const kCloudServiceApiReqKeyDeviceId;
/// 令牌
extern NSString *const kCloudServiceApiReqKeyToken;
/// 用户名
extern NSString *const kCloudServiceApiReqKeyUsername;

#pragma mark - 响应参数
/// 数据
extern NSString *const kCloudServiceApiRespKeyData;
/// 标记代码
extern NSString *const kCloudServiceApiRespKeyCode;
/// 错误信息
extern NSString *const kCloudServiceApiRespKeyMessage;

@interface FreeOrderApiManager () <GosApiManagerValidator, GosApiManagerParamSource>
/// 签名
@property (nonatomic, copy) NSString *token;
/// 用户名
@property (nonatomic, copy) NSString *username;
/// 设备id
@property (nonatomic, copy) NSString *deviceId;
/// 套餐id
@property (nonatomic, copy) NSString *planId;

@end
@implementation FreeOrderApiManager
#pragma mark - initialization
+ (NSInteger)loadDataWithDeviceId:(NSString *)deviceId planId:(NSString *)planId success:(void (^)(GosApiBaseManager * _Nonnull))successCallback fail:(void (^)(GosApiBaseManager * _Nonnull))failCallback {
    FreeOrderApiManager *api = [[FreeOrderApiManager alloc] init];
    api.successBlock = successCallback;
    api.failBlock = failCallback;
    return [api loadDataWithDeviceId:deviceId planId:planId];
}
- (instancetype)init {
    if (self = [super init]) {
        self.validator = self;
        self.paramSource = self;
    }
    return self;
}

#pragma mark - public method
- (NSInteger)loadDataWithDeviceId:(NSString *)deviceId planId:(NSString *)planId {
    self.deviceId = deviceId;
    self.planId = planId;
    return [self loadData];
}
#pragma mark - GosApiManager
- (NSString *)methodName {
    return @"inland/cloudstore/free-order/create";
}
- (GosApiManagerRequestType)requestType {
    return GosApiManagerRequestTypePost;
}
- (NSString *)serviceIdentifier {
    return GosNetworkingCloudPaymentServiceIdentifier;
}
- (NSDictionary *)reformParams:(NSDictionary *)params {
    NSMutableDictionary *temp = [params mutableCopy];
    if (self.deviceId) {
        [temp addEntriesFromDictionary:@{kCloudServiceApiReqKeyDeviceId:self.deviceId}];
    }
    if (self.planId) {
        [temp addEntriesFromDictionary:@{kCloudServiceApiReqKeyPlanId:self.planId}];
    }

    return [temp copy];
}

#pragma mark - GosApiManagerParamSource
- (NSDictionary *)paramsForApi:(GosApiBaseManager *)manager {
    // 每个api都需要token, username
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (self.token) {
        [params addEntriesFromDictionary:@{kCloudServiceApiReqKeyToken:self.token}];
    }
    if (self.username) {
        [params addEntriesFromDictionary:@{kCloudServiceApiReqKeyUsername:self.username}];
    }
    return [params copy];
}

#pragma mark - GosApiManagerValidator
- (GosApiManagerErrorType)manager:(GosApiBaseManager *)manager isCorrectWithParamsData:(NSDictionary *)data {
    if ([manager isKindOfClass:[self class]]) {
        if ([data objectForKey:kCloudServiceApiReqKeyToken]
            && [data objectForKey:kCloudServiceApiReqKeyUsername]
            && [data objectForKey:kCloudServiceApiReqKeyDeviceId]
            && [data objectForKey:kCloudServiceApiReqKeyPlanId]
            && [data count] == 4) {
            // 必须只存在 token, username, device_id, plan_id
            return GosApiManagerErrorTypeNoError;
        }
        return GosApiManagerErrorTypeParamsError;
    }
    return GosApiManagerErrorTypeNoError;
}
- (GosApiManagerErrorType)manager:(GosApiBaseManager *)manager isCorrectWithCallBackData:(NSDictionary *)data {
    // 校验返回参数
    if ([manager isKindOfClass:[self class]]) {
        if (![data objectForKey:kCloudServiceApiRespKeyCode] &&
            (![data objectForKey:kCloudServiceApiRespKeyData]
             && ![data objectForKey:kCloudServiceApiRespKeyMessage])) {
                // code必须有，data与message必须有其一
                return GosApiManagerErrorTypeNoContent;
            }
        return GosApiManagerErrorTypeNoError;
    }
    return GosApiManagerErrorTypeNoError;
}

#pragma mark - GosApiManagerDataReformer
- (id)manager:(GosApiBaseManager *)manager reformData:(NSDictionary *)data {
    return [FreeOrderApiRespModel yy_modelWithDictionary:[data objectForKey:kCloudServiceApiRespKeyData]];
}

#pragma mark - getters and setters
- (NSString *)token {
    if (!_token) {
        _token = [[GosMediator sharedInstance] cloudServiceApiToken];
    }
    return _token;
}
- (NSString *)username {
    if (!_username) {
        _username = [[GosMediator sharedInstance] cloudServiceApiUsername];
    }
    return _username;
}
@end
