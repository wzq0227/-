//  AlipayCheckApiManager.m
//  CloudStoreSDK
//
//  Create by daniel.hu on 2018/12/12.
//  Copyright © 2018年 daniel. All rights reserved.

#import "AlipayCheckApiManager.h"
#import "GosMediator+CloudServiceApiMethods.h"

#pragma mark - service identifier
/// CloudPaymentService
extern NSString *const GosNetworkingCloudPaymentServiceIdentifier;
#pragma mark - 请求参数
/// alipay专用-凭据
extern NSString *const kCloudServiceApiReqKeyMemo;
/// alipay专用-结果状态
extern NSString *const kCloudServiceApiReqKeyResultStatus;
/// alipay专用-结果参数
extern NSString *const kCloudServiceApiReqKeyResult;
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


@interface AlipayCheckApiManager () <GosApiManagerValidator, GosApiManagerParamSource>
/// 签名
@property (nonatomic, copy) NSString *token;
/// 用户名
@property (nonatomic, copy) NSString *username;
/// 凭据信息
@property (nonatomic, copy) NSString *memo;
/// 结果状态
@property (nonatomic, copy) NSString *resultStatus;
/// 结果参数
@property (nonatomic, copy) NSString *result;
@end
@implementation AlipayCheckApiManager
#pragma mark - initialization
+ (NSInteger)loadDataWithMemo:(NSString *)memo result:(NSString *)result resultStatus:(NSString *)resultStatus success:(void (^)(GosApiBaseManager * _Nonnull))successCallback fail:(void (^)(GosApiBaseManager * _Nonnull))failCallback {
    AlipayCheckApiManager *api = [[AlipayCheckApiManager alloc] init];
    api.successBlock = successCallback;
    api.failBlock = failCallback;
    return [api loadDataWithMemo:memo result:result resultStatus:resultStatus];
}
- (instancetype)init {
    if (self = [super init]) {
        self.validator = self;
        self.paramSource = self;
    }
    return self;
}

#pragma mark - public method
- (NSInteger)loadDataWithMemo:(NSString *)memo result:(NSString *)result resultStatus:(NSString *)resultStatus {
    self.memo = memo;
    self.resultStatus = resultStatus;
    self.result = result;
    return [self loadData];
}

#pragma mark - GosApiManager
- (NSString *)methodName {
    return @"alipay/payment/check";
}
- (GosApiManagerRequestType)requestType {
    return GosApiManagerRequestTypePost;
}
- (NSString *)serviceIdentifier {
    return GosNetworkingCloudPaymentServiceIdentifier;
}
- (NSDictionary *)reformParams:(NSDictionary *)params {
    NSMutableDictionary *temp = [params mutableCopy];
    if (self.memo) {
        [temp addEntriesFromDictionary:@{kCloudServiceApiReqKeyMemo:self.memo}];
    }
    if (self.resultStatus) {
        [temp addEntriesFromDictionary:@{kCloudServiceApiReqKeyResultStatus:self.resultStatus}];
    }
    NSString *encodeResult = [self urlValueEncode:self.result];
    if (encodeResult) {
        [temp addEntriesFromDictionary:@{kCloudServiceApiReqKeyResult:encodeResult}];
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

#pragma mark - private method
- (NSString *)urlValueEncode:(NSString *)url {
    NSString *encodedUrl = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)url, NULL, CFSTR("!$*'();:@&=+-$,./?%#[]_~"), kCFStringEncodingUTF8));
    
    // 优化方法——需要验证输出是否一样，暂时用原来的
//    NSString *charactersToEscape = @"!$*'();:@&=+-$,./?%#[]_~";
//    NSCharacterSet *allowedCharacters = [[NSCharacterSet characterSetWithCharactersInString:charactersToEscape] invertedSet];
//    NSString *encodedUrl1 = [url stringByAddingPercentEncodingWithAllowedCharacters:allowedCharacters];
//    GosLog(@"\n%@\n%@",encodedUrl,encodeUrl1);
    return encodedUrl;
}

#pragma mark - GosApiManagerValidator
- (GosApiManagerErrorType)manager:(GosApiBaseManager *)manager isCorrectWithParamsData:(NSDictionary *)data {
    if ([manager isKindOfClass:[self class]]) {
        if ([data objectForKey:kCloudServiceApiReqKeyToken]
            && [data objectForKey:kCloudServiceApiReqKeyUsername]
            && [data objectForKey:kCloudServiceApiReqKeyMemo]
            && [data objectForKey:kCloudServiceApiReqKeyResultStatus]
            && [data objectForKey:kCloudServiceApiReqKeyResult]
            && [data count] == 5) {
            // 必须只存在 token, username, memo, result, resultStatus
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
