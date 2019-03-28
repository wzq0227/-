//  DeviceOrderListApiManager.m
//  CloudStoreSDK
//
//  Create by daniel.hu on 2018/12/11.
//  Copyright © 2018年 daniel. All rights reserved.

#import "DeviceOrderListApiManager.h"
#import "NSObject+YYModel.h"
#import "DeviceOrderListApiRespModel.h"
#import "GosMediator+CloudServiceApiMethods.h"

#pragma mark - service identifier
/// CloudStoreService
extern NSString *const GosNetworkingCloudStoreServiceIdentifier;
#pragma mark - 请求参数
/// 令牌
extern NSString *const kCloudServiceApiReqKeyToken;
/// 用户名
extern NSString *const kCloudServiceApiReqKeyUsername;
/// 版本
extern NSString *const kCloudServiceApiReqKeyVersion;
/// 设备id
extern NSString *const kCloudServiceApiReqKeyDeviceId;
#pragma mark - 响应参数
/// 数据
extern NSString *const kCloudServiceApiRespKeyData;
/// 标记代码
extern NSString *const kCloudServiceApiRespKeyCode;
/// 错误信息
extern NSString *const kCloudServiceApiRespKeyMessage;

@interface DeviceOrderListApiManager () <GosApiManagerValidator, GosApiManagerParamSource>
/// 签名
@property (nonatomic, copy) NSString *token;
/// 用户名
@property (nonatomic, copy) NSString *username;
/// 设备id
@property (nonatomic, copy) NSString *deviceId;

@end
@implementation DeviceOrderListApiManager
#pragma mark - initialization
+ (NSInteger)loadDataWithDeviceId:(NSString *_Nonnull)deviceId success:(void (^ _Nullable)(GosApiBaseManager * _Nonnull apiManager))successCallback fail:(void (^ _Nullable)(GosApiBaseManager * _Nonnull apiManager))failCallback {
    DeviceOrderListApiManager *api = [[DeviceOrderListApiManager alloc] init];
    api.successBlock = successCallback;
    api.failBlock = failCallback;
    return [api loadDataWithDeviceId:deviceId];
}
- (instancetype)init {
    if (self = [super init]) {
        self.validator = self;
        self.paramSource = self;
    }
    return self;
}

#pragma mark - public method
- (NSInteger)loadDataWithDeviceId:(NSString *)deviceId {
    self.deviceId = deviceId;
    return [self loadData];
}

#pragma mark - GosApiManager
- (NSString *)methodName {
    return @"service/list";
}
- (GosApiManagerRequestType)requestType {
    return GosApiManagerRequestTypeGet;
}
- (NSString *)serviceIdentifier {
    return GosNetworkingCloudStoreServiceIdentifier;
}
- (NSDictionary *)reformParams:(NSDictionary *)params {
    NSMutableDictionary *temp = [params mutableCopy];
    [temp addEntriesFromDictionary:@{kCloudServiceApiReqKeyVersion:@(1.0)}];
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
        
        if ([data objectForKey:kCloudServiceApiReqKeyDeviceId]
            && [data objectForKey:kCloudServiceApiReqKeyUsername]
            && [data objectForKey:kCloudServiceApiReqKeyToken]
            && [data objectForKey:kCloudServiceApiReqKeyVersion]
            && [data count] == 4) {
            // 必须只存在 token, username, version, device_id
            return GosApiManagerErrorTypeNoError;
        }
        return GosApiManagerErrorTypeParamsError;
    }
    // 非此validator能处理的，理论上不会来这里
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
    NSArray *temp = [data objectForKey:kCloudServiceApiRespKeyData];
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:temp.count];
    
    // 字典转模型
    for (NSDictionary *dict in temp) {
        [result addObject:[DeviceOrderListApiRespModel yy_modelWithDictionary:dict]];
    }
    return [result copy];
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
