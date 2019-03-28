//  PayPackageTypesApiManager.m
//  CloudStoreSDK
//
//  Create by daniel.hu on 2018/12/11.
//  Copyright © 2018年 daniel. All rights reserved.

#import "PayPackageTypesApiManager.h"
#import "YYModel.h"
#import "PayPackageTypesApiRespModel.h"
#import "GosMediator+CloudServiceApiMethods.h"

#pragma mark - service identifier
/// CloudStoreService
extern NSString *const GosNetworkingCloudStoreServiceIdentifier;

#pragma mark - 请求参数
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


@interface PayPackageTypesApiManager () <GosApiManagerValidator, GosApiManagerParamSource>
/// 签名
@property (nonatomic, copy) NSString *token;
/// 用户名
@property (nonatomic, copy) NSString *username;

@end
@implementation PayPackageTypesApiManager
#pragma mark - initialization
+ (NSInteger)loadDataWithSuccess:(void (^)(GosApiBaseManager * _Nonnull))successCallback fail:(void (^)(GosApiBaseManager * _Nonnull))failCallback {
    PayPackageTypesApiManager *api = [[PayPackageTypesApiManager alloc] init];
    api.successBlock = successCallback;
    api.failBlock = failCallback;
    return [api loadData];
}
- (instancetype)init {
    if (self = [super init]) {
        self.validator = self;
        self.paramSource = self;
    }
    return self;
}
#pragma mark - public method
- (NSInteger)loadData {
    return [super loadData];
}
#pragma mark - GosApiManager
- (NSString *)methodName {
    return @"plan";
}
- (GosApiManagerRequestType)requestType {
    return GosApiManagerRequestTypePost;
}
- (NSString *)serviceIdentifier {
    return GosNetworkingCloudStoreServiceIdentifier;
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
            && [data count] == 2) {
            // 必须只存在 token, username
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
    NSArray *temp = [data objectForKey:kCloudServiceApiRespKeyData];
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:temp.count];
    for (NSDictionary *dict in temp) {
        [result addObject:[PayPackageTypesApiRespModel yy_modelWithDictionary:dict]];
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
