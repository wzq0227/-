//  VideoSlicesApiManager.m
//  GosIPCs
//
//  Create by daniel.hu on 2018/12/24.
//  Copyright © 2018年 goscam. All rights reserved.

#import "VideoSlicesApiManager.h"
#import "NSObject+YYModel.h"
#import "VideoSlicesApiRespModel.h"
#import "GosMediator+CloudServiceApiMethods.h"

#pragma mark - service identifier
/// CloudStoreService
extern NSString *const GosNetworkingCloudStoreServiceIdentifier;
#pragma mark - 请求参数
/// 令牌
extern NSString *const kCloudServiceApiReqKeyToken;
/// 用户名
extern NSString *const kCloudServiceApiReqKeyUsername;
/// 设备id
extern NSString *const kCloudServiceApiReqKeyDeviceId;
/// 开始时间
extern NSString *const kCloudServiceApiReqKeyStartTime;
/// 结束时间
extern NSString *const kCloudServiceApiReqKeyEndTime;

#pragma mark - 响应参数
/// 数据
extern NSString *const kCloudServiceApiRespKeyData;
/// 标记代码
extern NSString *const kCloudServiceApiRespKeyCode;
/// 错误信息
extern NSString *const kCloudServiceApiRespKeyMessage;

@interface VideoSlicesApiManager () <GosApiManagerValidator, GosApiManagerParamSource>
/// 签名
@property (nonatomic, copy) NSString *token;
/// 用户名
@property (nonatomic, copy) NSString *username;
/// 设备id
@property (nonatomic, copy) NSString *deviceId;
/// 开始时间
@property (nonatomic, assign) NSTimeInterval startTime;
/// 结束时间
@property (nonatomic, assign) NSTimeInterval endTime;
/// 方法类型——决定methodName的值
@property (nonatomic, assign) VideoSlicesApiManagerMethodType apiManagerMethodType;

@end
@implementation VideoSlicesApiManager
#pragma mark - public method
+ (NSInteger)loadAlarmDataWithDeviceId:(NSString *)deviceId startTime:(NSTimeInterval)startTime endTime:(NSTimeInterval)endTime success:(void (^)(GosApiBaseManager * _Nonnull))successCallback fail:(void (^)(GosApiBaseManager * _Nonnull))failCallback {
    VideoSlicesApiManager *manager = [[VideoSlicesApiManager alloc] initWithApiMethodType:VideoSlicesApiManagerMethodTypeAlarm];
    manager.successBlock = successCallback;
    manager.failBlock = failCallback;
    return [manager loadDataWithDeviceId:deviceId startTime:startTime endTime:endTime];
}

+ (NSInteger)loadNormalDataWithDeviceId:(NSString *)deviceId startTime:(NSTimeInterval)startTime endTime:(NSTimeInterval)endTime success:(void (^)(GosApiBaseManager * _Nonnull))successCallback fail:(void (^)(GosApiBaseManager * _Nonnull))failCallback {
    VideoSlicesApiManager *manager = [[VideoSlicesApiManager alloc] initWithApiMethodType:VideoSlicesApiManagerMethodTypeNormal];
    manager.successBlock = successCallback;
    manager.failBlock = failCallback;
    return [manager loadDataWithDeviceId:deviceId startTime:startTime endTime:endTime];
}

- (instancetype)initWithApiMethodType:(VideoSlicesApiManagerMethodType)apiType {
    if (self = [self init]) {
        self.apiManagerMethodType = apiType;
    }
    return self;
}

- (NSInteger)loadDataWithDeviceId:(NSString *)deviceId startTime:(NSTimeInterval)startTime endTime:(NSTimeInterval)endTime {
    self.deviceId = deviceId;
    // 自动优化处理
    self.startTime = MIN(startTime, endTime);
    self.endTime = MAX(startTime, endTime);
    
    return [self loadData];
}

#pragma mark - initialization
- (instancetype)init {
    if (self = [super init]) {
        self.validator = self;
        self.paramSource = self;
        
        self.startTime = 0.0f;
        self.endTime = 0.0f;
    }
    return self;
}

#pragma mark - GosApiManager
- (NSString *)methodName {
    return self.apiManagerMethodType == VideoSlicesApiManagerMethodTypeAlarm ? @"move-video/time-line" : @"move-video/time-line/details";
}
- (GosApiManagerRequestType)requestType {
    return GosApiManagerRequestTypeGet;
}
- (NSString *)serviceIdentifier {
    return GosNetworkingCloudStoreServiceIdentifier;
}
- (NSDictionary *)reformParams:(NSDictionary *)params {
    NSMutableDictionary *temp = [params mutableCopy];
    if (self.deviceId) {
        [temp addEntriesFromDictionary:@{kCloudServiceApiReqKeyDeviceId:self.deviceId}];
    }
    if (self.startTime > 0) {
        [temp addEntriesFromDictionary:@{kCloudServiceApiReqKeyStartTime:@(self.startTime)}];
    }
    if (self.endTime > 0) {
        [temp addEntriesFromDictionary:@{kCloudServiceApiReqKeyEndTime:@(self.endTime)}];
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
            && [data objectForKey:kCloudServiceApiReqKeyStartTime]
            && [data objectForKey:kCloudServiceApiReqKeyEndTime]
            && [data count] == 5) {
            // 必须只存在 token, username, device_id, start_time, end_time
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
        [result addObject:[VideoSlicesApiRespModel yy_modelWithDictionary:dict]];
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
