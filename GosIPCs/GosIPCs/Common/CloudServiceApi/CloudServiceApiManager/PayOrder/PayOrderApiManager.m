//  PayOrderApiManager.m
//  CloudStoreSDK
//
//  Create by daniel.hu on 2018/12/11.
//  Copyright © 2018年 daniel. All rights reserved.

#import "PayOrderApiManager.h"
#import "YYModel.h"
#import "PayOrderApiRespModel.h"
#import "PayPackageTypesApiRespModel.h"
#import "GosMediator+CloudServiceApiMethods.h"

#pragma mark - service identifier
/// CloudPaymentService
extern NSString *const GosNetworkingCloudPaymentServiceIdentifier;

#pragma mark - 请求参数
/// 价格
extern NSString *const kCloudServiceApiReqKeyTotalPrice;
/// 数量
extern NSString *const kCloudServiceApiReqKeyCount;
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


@interface PayOrderApiManager () <GosApiManagerValidator, GosApiManagerParamSource>
/// 签名
@property (nonatomic, copy) NSString *token;
/// 用户名
@property (nonatomic, copy) NSString *username;
/// 设备id
@property (nonatomic, copy) NSString *deviceId;
/// 总价格
@property (nonatomic, copy) NSString *totalPrice;
/// 购买数量
@property (nonatomic, copy) NSString *count;
/// 套餐id
@property (nonatomic, copy) NSString *planId;
@end

@implementation PayOrderApiManager
#pragma mark - initialization
+ (NSInteger)loadDataWithDeviceId:(NSString *)deviceId payPackage:(PayPackageTypesApiRespModel *)payPackage success:(void (^)(GosApiBaseManager * _Nonnull))successCallback fail:(void (^)(GosApiBaseManager * _Nonnull))failCallback {
    PayOrderApiManager *api = [[PayOrderApiManager alloc] init];
    api.successBlock = successCallback;
    api.failBlock = failCallback;
    return [api loadDataWithDeviceId:deviceId payPackage:payPackage];
}
+ (NSInteger)loadDataWithDeviceId:(NSString *)deviceId totalPrice:(NSString *)totalPrice planId:(NSString *)planId count:(NSString *)count success:(void (^)(GosApiBaseManager * _Nonnull))successCallback fail:(void (^)(GosApiBaseManager * _Nonnull))failCallback {
    PayOrderApiManager *api = [[PayOrderApiManager alloc] init];
    api.successBlock = successCallback;
    api.failBlock = failCallback;
    return [api loadDataWithDeviceId:deviceId totalPrice:totalPrice planId:planId count:count];
}
- (instancetype)init {
    if (self = [super init]) {
        self.validator = self;
        self.paramSource = self;
    }
    return self;
}

#pragma mark - public method
- (NSInteger)loadDataWithDeviceId:(NSString *)deviceId payPackage:(PayPackageTypesApiRespModel *)payPackage {
    return [self loadDataWithDeviceId:deviceId totalPrice:payPackage.price planId:payPackage.planId count:@"1"];
}
- (NSInteger)loadDataWithDeviceId:(NSString *)deviceId totalPrice:(NSString *)totalPrice planId:(NSString *)planId {
    return [self loadDataWithDeviceId:deviceId totalPrice:totalPrice planId:planId count:@"1"];
}
- (NSInteger)loadDataWithDeviceId:(NSString *)deviceId totalPrice:(NSString *)totalPrice planId:(NSString *)planId count:(NSString *)count {
    self.totalPrice = totalPrice;
    self.planId = planId;
    self.deviceId = deviceId;
    self.count = count;
    return [self loadData];
}
#pragma mark - GosApiManager
- (NSString *)methodName {
    return @"inland/cloudstore/order/create";
}
- (GosApiManagerRequestType)requestType {
    return GosApiManagerRequestTypePost;
}
- (NSString *)serviceIdentifier {
    return GosNetworkingCloudPaymentServiceIdentifier;
}
- (NSDictionary *)reformParams:(NSDictionary *)params {
    NSMutableDictionary *temp = [params mutableCopy];
    if (self.count) {
        [temp addEntriesFromDictionary:@{kCloudServiceApiReqKeyCount:self.count}];
    }
    if (self.totalPrice) {
        [temp addEntriesFromDictionary:@{kCloudServiceApiReqKeyTotalPrice:self.totalPrice}];
    }
    if (self.planId) {
        [temp addEntriesFromDictionary:@{kCloudServiceApiReqKeyPlanId:self.planId}];
    }
    if (self.deviceId) {
        [temp addEntriesFromDictionary:@{kCloudServiceApiReqKeyDeviceId:self.deviceId}];
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
            && [data objectForKey:kCloudServiceApiReqKeyCount]
            && [data objectForKey:kCloudServiceApiReqKeyTotalPrice]
            && [data count] == 6) {
            // 必须只存在 token, username, device_id, plan_id, count, total_price
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
    return [PayOrderApiRespModel yy_modelWithDictionary:[data objectForKey:kCloudServiceApiRespKeyData]];
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
