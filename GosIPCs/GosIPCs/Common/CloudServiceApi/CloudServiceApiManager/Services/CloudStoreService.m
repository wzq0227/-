//  CloudStoreService.m
//  CloudStoreSDK
//
//  Create by daniel.hu on 2018/12/11.
//  Copyright © 2018年 daniel. All rights reserved.

#import "CloudStoreService.h"
#import "AFNetworking.h"
#import "GosNetworkingDefines.h"
#import "GosLoggedInUserInfo+SDKExtension.h"

extern NSString *const kGosApiProxyValidateResultKeyResponseObject;
extern NSString *const kGosApiProxyValidateResultKeyResponseString;

@interface CloudStoreService ()

@property (nonatomic, strong) NSString *baseHost;
@property (nonatomic, strong) NSString *baseUrl;
@property (nonatomic, strong) AFHTTPRequestSerializer *httpRequestSerializer;

@end

@implementation CloudStoreService
@synthesize apiTaskType;
@synthesize apiEnvironment;
@synthesize apiArea;

#pragma mark - public method
- (NSURLRequest *)requestWithParams:(NSDictionary *)params methodName:(NSString *)methodName requestType:(GosApiManagerRequestType)requestType {
    
    NSString *urlString = [self joinParamsForURLString:[self urlGeneratingRuleByMethodName:methodName] params:params];
    NSString *method = [self methodGeneratingRuleByRequestType:requestType];
    
    NSMutableURLRequest *request = [self.httpRequestSerializer requestWithMethod:method URLString:urlString parameters:nil error:nil];
    
    return request;
}

- (NSDictionary *)resultWithResponseObject:(id)responseObject response:(NSURLResponse *)response request:(NSURLRequest *)request error:(NSError * _Nullable __autoreleasing *)error {
    NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
    // 如果反馈有错误，就直接返回
    if (*error) {
        return result;
    }
    
    if (!responseObject) {
        // 服务器没有反馈数据时，就模拟服务器返回失败数据
        NSDictionary *temp = @{
                               @"code":@"-1",
                               @"message":@"Request error"
                               };
        // 空数据异常
        NSDictionary *errorUserInfo = @{
                                        NSLocalizedFailureReasonErrorKey:[temp objectForKey:@"message"]?:@"Unknow reason",
                                        NSLocalizedDescriptionKey:@"Server response empty data error "
                                        };
        *error = [NSError errorWithDomain:[request.URL absoluteString] code:[[temp objectForKey:@"code"]?:@"-1" integerValue] userInfo:errorUserInfo];
        
        result[kGosApiProxyValidateResultKeyResponseString] = [NSString stringWithFormat:@"%@", temp];
        result[kGosApiProxyValidateResultKeyResponseObject] = temp;
        
    } else if ([responseObject isKindOfClass:[NSData class]]) {
        // 服务器返回正常且可解析数据
        NSDictionary *temp = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:NULL];
        // 如果服务返回的数据里code = 0说明是请求正常，非零则是失败
        if ([[temp objectForKey:@"code"] integerValue] != 0) {
            // 请求异常——结果失败
            NSDictionary *errorUserInfo = @{
                                            NSLocalizedFailureReasonErrorKey:[temp objectForKey:@"message"]?:@"Unknow reason",
                                            NSLocalizedDescriptionKey:@"Server response failed error "
                                           };
            *error = [NSError errorWithDomain:[request.URL absoluteString] code:[[temp objectForKey:@"code"]?:@"-1" integerValue] userInfo:errorUserInfo];
        }
        
        result[kGosApiProxyValidateResultKeyResponseString] = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        result[kGosApiProxyValidateResultKeyResponseObject] = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:NULL];
        
    } else if ([responseObject isKindOfClass:[NSDictionary class]]) {
        // 服务器返回正常且可解析数据
        NSDictionary *temp = responseObject;
        // 如果服务返回的数据里code = 0说明是请求正常，非零则是失败
        if ([[temp objectForKey:@"code"] integerValue] != 0) {
            // 请求异常——结果失败
            NSDictionary *errorUserInfo = @{
                                            NSLocalizedFailureReasonErrorKey:[temp objectForKey:@"message"]?:@"Unknow reason",
                                            NSLocalizedDescriptionKey:@"Server response failed error "
                                            };
            *error = [NSError errorWithDomain:[request.URL absoluteString] code:[[temp objectForKey:@"code"]?:@"-1" integerValue] userInfo:errorUserInfo];
        }
        
        result[kGosApiProxyValidateResultKeyResponseString] = [NSString stringWithFormat:@"%@", responseObject];
        result[kGosApiProxyValidateResultKeyResponseObject] = responseObject;
        
    } else {
        // 进入此处说明返回的数据异常——即数据不为空、不为NSData、不为NSString
        GosLog(@"理论上不应该进入此处，一旦进入说明服务器返回数据类型异常 - respnseObject [%@]:%@", NSStringFromClass([responseObject class]), responseObject);
        // 未知数据异常
        NSDictionary *errorUserInfo = @{
                                        NSLocalizedFailureReasonErrorKey:@"Unknow reason",
                                        NSLocalizedDescriptionKey:@"Server response unknow data error "
                                        };
        *error = [NSError errorWithDomain:[request.URL absoluteString] code:[@"-1" integerValue] userInfo:errorUserInfo];
        
        result[kGosApiProxyValidateResultKeyResponseString] = responseObject;
        result[kGosApiProxyValidateResultKeyResponseObject] = responseObject;
    }
    
    return result;
}

- (BOOL)handleCommonErrorWithResponse:(GosURLResponse *)response manager:(GosApiBaseManager *)manager errorType:(GosApiManagerErrorType)errorType {
    // 处理共同错误，然后以通知发出去
    return YES;
}
#pragma mark - private method
- (NSString *)joinParamsForURLString:(NSString *)urlString params:(NSDictionary *_Nullable)params {
    if (params) {
        __block NSMutableArray *temp = [NSMutableArray arrayWithCapacity:params.count];
        [params enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            [temp addObject:[NSString stringWithFormat:@"%@=%@", key, obj]];
        }];
        NSString *result = [urlString stringByAppendingFormat:@"?%@", [temp componentsJoinedByString:@"&"]];
        return result;
    }
    return urlString;
}
- (NSString *)urlGeneratingRuleByMethodName:(NSString *)methodName {
    NSString *urlString = [NSString stringWithFormat:@"%@/%@/%@", self.baseHost, self.baseUrl, methodName];
    return urlString;
}
- (NSString *)methodGeneratingRuleByRequestType:(GosApiManagerRequestType)requestType {
    switch (requestType) {
        case GosApiManagerRequestTypeGet:
            return @"GET";
        case GosApiManagerRequestTypePost:
            return @"POST";
        case GosApiManagerRequestTypePut:
            return @"PUT";
        case GosApiManagerRequestTypeDelete:
            return @"DELETE";
        default:
            break;
    }
    return @"GET";
}
#pragma mark - getters and setters
- (NSString *)baseHost
{
    switch (self.apiArea) {
        case GosServiceApiAreaDomestic:
            // 国内
            return @"http://cn-css.ulifecam.com";
        case GosServiceApiAreaOverseas:
            // 国外
            return @"http://css.ulifecam.com";
        default:
            break;
    }
    return @"http://cn-css.ulifecam.com";
    // 119.23.124.137:9998
}
- (NSString *)baseUrl {
    return @"api/cloudstore/cloudstore-service";
}
- (GosServiceApiArea)apiArea {
    ServerAreaType area = [GosLoggedInUserInfo sdkServerArea];
    GosServiceApiArea result = GosServiceApiAreaDomestic;
    switch (area) {
        case ServerArea_domestic:
            result = GosServiceApiAreaDomestic;
            break;
        case ServerArea_overseas:
            result = GosServiceApiAreaOverseas;
            break;
        default:
            break;
    }
    return result;
}
- (GosServiceApiEnvironment)apiEnvironment {
    return GosServiceApiEnvironmentRelease;
}

- (AFHTTPRequestSerializer *)httpRequestSerializer
{
    if (_httpRequestSerializer == nil) {
        _httpRequestSerializer = [AFHTTPRequestSerializer serializer];
        [_httpRequestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    }
    return _httpRequestSerializer;
}
- (AFHTTPSessionManager *)sessionManager {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    // 允许http
    manager.securityPolicy = [AFSecurityPolicy defaultPolicy];
    manager.securityPolicy.allowInvalidCertificates = YES;
    manager.securityPolicy.validatesDomainName = YES;
    manager.requestSerializer = self.httpRequestSerializer;
    
    return manager;
}
- (GosServiceApiTaskType)apiTaskType {
    return GosServiceApiTaskTypeGeneral;
}
@end
