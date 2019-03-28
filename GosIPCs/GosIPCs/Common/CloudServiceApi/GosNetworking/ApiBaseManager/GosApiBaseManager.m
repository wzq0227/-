//  GosApiBaseManager.m
//  CloudStoreSDK
//
//  Create by daniel.hu on 2018/12/11.
//  Copyright © 2018年 daniel. All rights reserved.

#import "GosApiBaseManager.h"
#import "GosApiProxy.h"
#import "GosServiceFactory.h"
#import "NSURLRequest+GosNetworkingMethod.h"
#import "GosApiProxy.h"
#import "GosMediator+GosAppContext.h"
#import "GosNetworkingLogger.h"

NSString * const kCTUserTokenInvalidNotification = @"kCTUserTokenInvalidNotification";
NSString * const kCTUserTokenIllegalNotification = @"kCTUserTokenIllegalNotification";

NSString * const kCTUserTokenNotificationUserInfoKeyManagerToContinue = @"kCTUserTokenNotificationUserInfoKeyManagerToContinue";
NSString * const kGosApiBaseManagerRequestID = @"kGosApiBaseManagerRequestID";


@interface GosApiBaseManager ()
/// 获取原数据
@property (nonatomic, strong, readwrite) id fetchedRawData;
/// 是否正在加载
@property (nonatomic, assign, readwrite, getter=isLoading) BOOL loading;
/// 错误信息
@property (nonatomic, copy, readwrite) NSString *errorMessage;
/// 请求ID
@property (nonatomic, strong) NSMutableArray *requestIdList;
/// 错误类型
@property (nonatomic, readwrite) GosApiManagerErrorType errorType;

@end

@implementation GosApiBaseManager
#pragma mark - initialization
- (instancetype)init {
    if (self = [super init]) {
        _delegate = nil;
        _validator = nil;
        _paramSource = nil;
        _fetchedRawData = nil;
        _errorMessage = nil;
        _errorType = GosApiManagerErrorTypeDefault;
        if ([self conformsToProtocol:@protocol(GosApiManager) ]) {
            self.child = (id<GosApiManager>)self;
        } else {
            NSAssert(NO, @"必须遵循代理GosApiManager");
        }
    }
    return self;
}
#pragma mark - NSCopying
- (id)copyWithZone:(NSZone *)zone {
    return self;
}

#pragma mark - public method
- (void)cancelAllRequests {
    [[GosApiProxy sharedInstance] cancelRequestWithRequestIdList:self.requestIdList];
    [self.requestIdList removeAllObjects];
}
- (void)cancelRequestWithRequestId:(NSInteger)requestId {
    [self removeRequestIdWithRequestId:requestId];
    [[GosApiProxy sharedInstance] cancelRequestWithRequestId:@(requestId)];
}
- (id)fetchDataWithReformer:(id<GosApiManagerDataReformer>)reformer {
    id resultData = nil;
    if ([reformer respondsToSelector:@selector(manager:reformData:)]) {
        resultData = [reformer manager:self reformData:self.fetchedRawData];
    } else {
        resultData = [self.fetchedRawData mutableCopy];
    }
    return resultData;
}
- (void)cleanData {
    self.fetchedRawData = nil;
    self.errorType = GosApiManagerErrorTypeDefault;
}

#pragma mark - calling api
- (NSInteger)loadData {
    NSDictionary *params = [self.paramSource paramsForApi:self];
    NSInteger requestId = [self loadDataWithParams:params];
    return requestId;
}
+ (NSInteger)loadDataWithParams:(NSDictionary *)params success:(void(^)(GosApiBaseManager *))successCallback fail:(void(^)(GosApiBaseManager *))failCallback {
    return [[[self alloc] init] loadDataWithParams:params success:successCallback fail:failCallback];
}
- (NSInteger)loadDataWithParams:(NSDictionary *)params success:(void(^)(GosApiBaseManager *))successCallback fail:(void(^)(GosApiBaseManager *))failCallback {
    self.successBlock = successCallback;
    self.failBlock = failCallback;
    
    return [self loadDataWithParams:params];
}

- (NSInteger)loadDataWithParams:(NSDictionary *)params {
    NSInteger requestId = 0;
    // 取一次参数
    NSDictionary *reformedParams = [self reformParams:params];
    if (reformedParams == nil) {
        reformedParams = @{};
    }
        
    if ([self shouldCallApiWithParams:params]) {
        // 验证参数是否正确
        GosApiManagerErrorType errorType = self.validator?[self.validator manager:self isCorrectWithParamsData:reformedParams]:GosApiManagerErrorTypeNoError;
        if (errorType == GosApiManagerErrorTypeNoError) {
            GosURLResponse *response = nil;
            // FIXME: 先检查是否有内存缓存
            
            // FIXME: 再检查是否有磁盘缓存
            
            
            
            if (response != nil) {
                [self successedOnCallingApi:response];
                return 0;
            }
            
            // 实际的网络请求
            if ([self isReachable]) {
                self.loading = YES;
                
                id <GosServiceProtocol> service = [[GosServiceFactory sharedInstance] serviceWithIdentifier:self.child.serviceIdentifier];
                // 构建请求
                NSURLRequest *request = [service requestWithParams:reformedParams methodName:self.child.methodName requestType:self.child.requestType];
                request.service = service;
                request.uploadProcess = [self.child respondsToSelector:@selector(uploadProcess)]?self.child.uploadProcess:nil;
                request.downloadProcess = [self.child respondsToSelector:@selector(downloadProcess)]?self.child.downloadProcess:nil;
                request.destination = [self.child respondsToSelector:@selector(destination)]?self.child.destination:nil;
                
                // 打印
                [GosNetworkingLogger logDebugInfoWithRequest:request apiName:self.child.methodName service:service];
                
                __weak typeof(self) weakself = self;
                NSNumber *requestId = [[GosApiProxy sharedInstance] callApiWithRequest:request success:^(GosURLResponse * _Nonnull response) {
                    // 成功
                    [weakself successedOnCallingApi:response];
                } fail:^(GosURLResponse * _Nonnull response) {
                    // 失败
                    GosApiManagerErrorType errorType = GosApiManagerErrorTypeDefault;
                    switch (response.status) {
                        case GosURLResponseStatusErrorCancel:
                            errorType = GosApiManagerErrorTypeCanceled;
                            break;
                        case GosURLResponseStatusErrorTimeout:
                            errorType = GosApiManagerErrorTypeTimeout;
                            break;
                        case GosURLResponseStatusErrorNoNetwork:
                            errorType = GosApiManagerErrorTypeNoNetWork;
                            break;
                        case GosURLResponseStatusErrorServerFailed:
                            errorType = GosApiManagerErrorTypeServerFailed;
                            break;
                        default:
                            break;
                    }
                    [weakself failedOnCallingApi:response withErrorType:errorType];
                }];
                
                [self.requestIdList addObject:requestId];
                NSMutableDictionary *params = [reformedParams mutableCopy];
                params[kGosApiBaseManagerRequestID] = requestId;
                [self afterCallingApiWithParams:params];
                return [requestId integerValue];
                
            } else {
                // 网络不可达
                [self failedOnCallingApi:nil withErrorType:GosApiManagerErrorTypeNoNetWork];
                return requestId;
            }
        } else {
            // validator isCorrectWithParamsData callback errorType
            [self failedOnCallingApi:nil withErrorType:errorType];
            return requestId;
        }
        
    }
    return requestId;
}
#pragma mark - api callbacks
- (void)successedOnCallingApi:(GosURLResponse *)response {
    self.loading = NO;
    // 响应回调数据
    self.response = response;
    // 获取原数据
    if (response.content) {
        self.fetchedRawData = [response.content copy];
    } else {
        self.fetchedRawData = [response.responseData copy];
    }
    // 清除请求id
    [self removeRequestIdWithRequestId:response.requestId];
    // 验证回调是否正确
    GosApiManagerErrorType errorType = self.validator?[self.validator manager:self isCorrectWithCallBackData:response.content]:GosApiManagerErrorTypeNoError;
    if (errorType == GosApiManagerErrorTypeNoError) {
        // 缓存
        
        // 中断
        
        // 执行成功前的最后处理
        if ([self beforePerformSuccessWithResponse:response]) {
            if ([self.delegate respondsToSelector:@selector(managerCallApiDidSuccess:)]) {
                [self.delegate managerCallApiDidSuccess:self];
            }
            if (self.successBlock) {
                self.successBlock(self);
            }
        }
        // 执行成功后的最后处理
        [self afterPerformSuccessWithResponse:response];
    } else {
        // 验证失败
        [self failedOnCallingApi:response withErrorType:errorType];
    }
    
}
- (void)failedOnCallingApi:(GosURLResponse *)response withErrorType:(GosApiManagerErrorType)errorType {
    self.loading = NO;
    // 响应回调数据
    if (response) {
        self.response = response;
    }
    self.errorType = errorType;
    
    [self removeRequestIdWithRequestId:response.requestId];
    
    // 自动处理的错误
    
    // 丢给响应者处理的错误
    id<GosServiceProtocol> service = [[GosServiceFactory sharedInstance] serviceWithIdentifier:self.child.serviceIdentifier];
    BOOL shouldContinue = [service handleCommonErrorWithResponse:response manager:self errorType:errorType];
    if (shouldContinue == NO) {
        return ;
    }
    
    // 常规错误
    if (errorType == GosApiManagerErrorTypeNoNetWork) {
        self.errorMessage = @"无网络连接，请检查网络";
    }
    if (errorType == GosURLResponseStatusErrorTimeout) {
        self.errorMessage = @"请求超时";
    }
    if (errorType == GosApiManagerErrorTypeCanceled) {
        self.errorMessage = @"您已取消";
    }
    if (errorType == GosApiManagerErrorTypeDownGrade) {
        self.errorMessage = @"网络拥塞";
    }
    if (errorType == GosApiManagerErrorTypeServerFailed) {
        self.errorMessage = response.errorMessage;
    }
    
    // 其他错误
    __weak typeof(self) weakself = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([weakself.interceptor respondsToSelector:@selector(manager:didReceiveResponse:)]) {
            [weakself.interceptor manager:self didReceiveResponse:response];
        }
        if ([weakself beforePerformFailWithResponse:response]) {
            [weakself.delegate managerCallApiDidFailed:weakself];
        }
        if (weakself.failBlock) {
            weakself.failBlock(weakself);
        }
        [weakself afterPerformFailWithResponse:response];
        
    });
}



#pragma mark - method for interceptor
- (BOOL)beforePerformSuccessWithResponse:(GosURLResponse *)response {
    BOOL result = YES;
    
    self.errorType = GosApiManagerErrorTypeSuccess;
    if (self.interceptor && (NSInteger)self != (NSInteger)self.interceptor && [self.interceptor respondsToSelector:@selector(manager: beforePerformSuccessWithResponse:)]) {
        result = [self.interceptor manager:self beforePerformSuccessWithResponse:response];
    }
    return result;
}

- (void)afterPerformSuccessWithResponse:(GosURLResponse *)response {
    if (self.interceptor && (NSInteger)self != (NSInteger)self.interceptor && [self.interceptor respondsToSelector:@selector(manager:afterPerformSuccessWithResponse:)]) {
        [self.interceptor manager:self afterPerformSuccessWithResponse:response];
    }
}

- (BOOL)beforePerformFailWithResponse:(GosURLResponse *)response {
    BOOL result = YES;
    if (self.interceptor && (NSInteger)self != (NSInteger)self.interceptor && [self.interceptor respondsToSelector:@selector(manager:beforePerformFailWithResponse:)]) {
        result = [self.interceptor manager:self beforePerformFailWithResponse:response];
    }
    return result;
}

- (void)afterPerformFailWithResponse:(GosURLResponse *)response {
    if (self.interceptor && (NSInteger)self != (NSInteger)self.interceptor && [self.interceptor respondsToSelector:@selector(manager:afterPerformFailWithResponse:)]) {
        [self.interceptor manager:self afterPerformFailWithResponse:response];
    }
}

//只有返回YES才会继续调用API
- (BOOL)shouldCallApiWithParams:(NSDictionary *)params {
    if ((NSInteger)self != (NSInteger)self.interceptor && [self.interceptor respondsToSelector:@selector(manager:shouldCallApiWithParams:)]) {
        return [self.interceptor manager:self shouldCallApiWithParams:params];
    } else {
        return YES;
    }
}

- (void)afterCallingApiWithParams:(NSDictionary *)params {
    if ((NSInteger)self != (NSInteger)self.interceptor && [self.interceptor respondsToSelector:@selector(manager:afterCallingApiWithParams:)]) {
        [self.interceptor manager:self afterCallingApiWithParams:params];
    }
}


#pragma mark - method for child
- (NSDictionary *)reformParams:(NSDictionary *)params {
    IMP childIMP = [self.child methodForSelector:@selector(reformParams:)];
    IMP selfIMP = [self methodForSelector:@selector(reformParams:)];
    
    if (childIMP == selfIMP) {
        return params;
    } else {
        // 如果child是继承此类，就不会到这里
        // 如果child是另一对象，就会来此处
        NSDictionary *result = nil;
        result = [self.child reformParams:params];
        if (result) {
            return result;
        } else {
            return params;
        }
    }
    
}

#pragma mark - private method
- (void)removeRequestIdWithRequestId:(NSInteger)requestId {
    NSNumber *requestIdToRemove = nil;
    for (NSNumber *storedRequestId in self.requestIdList) {
        if ([storedRequestId integerValue] == requestId) {
            requestIdToRemove = storedRequestId;
            break;
        }
    }
    if (requestIdToRemove) {
        [self.requestIdList removeObject:requestIdToRemove];
    }
}

#pragma mark - getters and setters
- (BOOL)isReachable {
    
    BOOL isReachability = [[GosMediator sharedInstance] GosAppContextNetworkingIsReachable];
    if (!isReachability) {
        self.errorType = GosApiManagerErrorTypeNoNetWork;
    }
    return isReachability;
}
- (NSMutableArray *)requestIdList {
    if (!_requestIdList) {
        _requestIdList = [NSMutableArray array];
    }
    return _requestIdList;
}
- (BOOL)isLoading {
    if (self.requestIdList.count == 0) {
        _loading = NO;
    }
    return _loading;
}
@end

