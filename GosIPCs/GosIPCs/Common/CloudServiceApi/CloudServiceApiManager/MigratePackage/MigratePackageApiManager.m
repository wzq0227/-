//  MigratePackageApiManager.m
//  CloudStoreSDK
//
//  Create by daniel.hu on 2018/12/11.
//  Copyright © 2018年 daniel. All rights reserved.

#import "MigratePackageApiManager.h"
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
/// 原设备id
extern NSString *const kCloudServiceApiReqKeyOriginDeviceId;
/// 目标设备id
extern NSString *const kCloudServiceApiReqKeyDestinationDeviceId;

#pragma mark - 响应参数
/// 数据
extern NSString *const kCloudServiceApiRespKeyData;
/// 标记代码
extern NSString *const kCloudServiceApiRespKeyCode;
/// 错误信息
extern NSString *const kCloudServiceApiRespKeyMessage;

@interface MigratePackageApiManager () <GosApiManagerValidator, GosApiManagerParamSource>
/// 签名
@property (nonatomic, copy) NSString *token;
/// 用户名
@property (nonatomic, copy) NSString *username;
/// 原设备Id
@property (nonatomic, copy) NSString *originDeviceId;
/// 目标设备Id
@property (nonatomic, copy) NSString *destinationDeviceId;
@end

@implementation MigratePackageApiManager
#pragma mark - initialization
+ (NSInteger)loadDataWithOriginDeviceId:(NSString *)origin destinationDeviceId:(NSString *)destination success:(void (^)(GosApiBaseManager * _Nonnull))successCallback fail:(void (^)(GosApiBaseManager * _Nonnull))failCallback {
    MigratePackageApiManager *api = [[MigratePackageApiManager alloc] init];
    api.successBlock = successCallback;
    api.failBlock = failCallback;
    
    return [api loadDataWithOriginDeviceId:origin destinationDeviceId:destination];
}
- (instancetype)init {
    if (self = [super init]) {
        self.validator = self;
        self.paramSource = self;
    }
    return self;
}
#pragma mark - public method
- (NSInteger)loadDataWithOriginDeviceId:(NSString *)origin destinationDeviceId:(NSString *)destination {
    self.originDeviceId = origin;
    self.destinationDeviceId = destination;
    return [self loadData];
}
#pragma mark - GosApiManager
- (NSString *)methodName {
    return @"manage/device/migrate";
}
- (GosApiManagerRequestType)requestType {
    return GosApiManagerRequestTypePost;
}
- (NSString *)serviceIdentifier {
    return GosNetworkingCloudStoreServiceIdentifier;
}
- (NSDictionary *)reformParams:(NSDictionary *)params {
    NSMutableDictionary *temp = [params mutableCopy];
    [temp addEntriesFromDictionary:@{kCloudServiceApiReqKeyVersion:@(1.0)}];
    if (self.originDeviceId) {
        [temp addEntriesFromDictionary:@{kCloudServiceApiReqKeyOriginDeviceId:self.originDeviceId}];
    }
    if (self.destinationDeviceId) {
        [temp addEntriesFromDictionary:@{kCloudServiceApiReqKeyDestinationDeviceId:self.destinationDeviceId}];
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
            && [data objectForKey:kCloudServiceApiReqKeyOriginDeviceId]
            && [data objectForKey:kCloudServiceApiReqKeyDestinationDeviceId]
            && [data objectForKey:kCloudServiceApiReqKeyVersion]
            && [data count] == 5) {
            // 必须只存在 token, username, ori_device, dest_device, version
            return GosApiManagerErrorTypeNoError;
        }
        return GosApiManagerErrorTypeParamsError;
    }
    return GosApiManagerErrorTypeNoError;
}
- (GosApiManagerErrorType)manager:(GosApiBaseManager *)manager isCorrectWithCallBackData:(NSDictionary *)data {
    return GosApiManagerErrorTypeNoError;
}

#pragma mark - GosApiManagerDataReformer
- (id)manager:(GosApiBaseManager *)manager reformData:(NSDictionary *)data {
    if ([[data objectForKey:kCloudServiceApiRespKeyCode] integerValue] == 0) {
        return @(YES);
    }
    return @(NO);
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

