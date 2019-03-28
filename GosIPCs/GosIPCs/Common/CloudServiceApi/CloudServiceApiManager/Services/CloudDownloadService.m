//  CloudDownloadService.m
//  GosIPCs
//
//  Create by daniel.hu on 2019/1/3.
//  Copyright © 2019年 goscam. All rights reserved.

#import "CloudDownloadService.h"
#import "AFNetworking.h"
#import "GosNetworkingDefines.h"
#import "GosLoggedInUserInfo+SDKExtension.h"

extern NSString *const kGosApiProxyValidateResultKeyResponseObject;
extern NSString *const kGosApiProxyValidateResultKeyResponseString;

@interface CloudDownloadService ()

@property (nonatomic, strong) AFHTTPRequestSerializer *httpRequestSerializer;

@end

@implementation CloudDownloadService
@synthesize apiTaskType;
@synthesize apiEnvironment;
@synthesize apiArea;

#pragma mark - public method
- (NSURLRequest *)requestWithParams:(NSDictionary *)params methodName:(NSString *)methodName requestType:(GosApiManagerRequestType)requestType {
    
    NSString *urlString = [self joinParamsForURLString:methodName params:params];
//    NSString *method = [self methodGeneratingRuleByRequestType:requestType];
    
//    NSMutableURLRequest *request = [self.httpRequestSerializer requestWithMethod:method URLString:urlString parameters:nil error:nil];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
//                             [self.httpRequestSerializer requestWithMethod:method URLString:urlString parameters:nil error:nil].URL];
    return request;
}

- (NSDictionary *)resultWithResponseObject:(id)responseObject response:(NSURLResponse *)response request:(NSURLRequest *)request error:(NSError * _Nullable __autoreleasing *)error {
    // 不用处理响应数据
    return @{};
}

- (BOOL)handleCommonErrorWithResponse:(GosURLResponse *)response manager:(GosApiBaseManager *)manager errorType:(GosApiManagerErrorType)errorType {
    // 处理共同错误，然后以通知发出去
    return YES;
}


#pragma mark - private method
+ (NSString *)encodeURL:(NSString *)url {
    NSMutableString *output = [NSMutableString string];
    const unsigned char *source = (const unsigned char *)[url UTF8String];
    NSUInteger sourceLen = strlen((const char *)source);
    for (int i = 0; i < sourceLen; ++i) {
        const unsigned char thisChar = source[i];
        if (thisChar == ' ') {
            [output appendString:@"+"];
        } else if (thisChar == '.' || thisChar == '-' || thisChar == '_' || thisChar == '~' ||
                   (thisChar >= 'a' && thisChar <= 'z') ||
                   (thisChar >= 'A' && thisChar <= 'Z') ||
                   (thisChar >= '0' && thisChar <= '9')) {
            [output appendFormat:@"%c", thisChar];
        } else {
            [output appendFormat:@"%%%02X", thisChar];
        }
    }
    return output;
}

+ (NSString *)trimmingString:(NSString *)str {
    return [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (NSString *)joinParamsForURLString:(NSString *)urlString params:(NSDictionary *_Nullable)params {
    
    if (params) {
        __block NSMutableArray *temp = [NSMutableArray arrayWithCapacity:params.count];
        [params enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
             [temp addObject:[NSString stringWithFormat:@"%@=%@", key, obj]];
//            NSString * keyStr = [CloudDownloadService encodeURL:[CloudDownloadService trimmingString:key]];
//            NSString * valueStr = [CloudDownloadService encodeURL:[CloudDownloadService trimmingString:obj]];
//            if ([valueStr length] == 0) {
//                [temp addObject:keyStr];
//            } else {
//                [temp addObject:[NSString stringWithFormat:@"%@=%@", keyStr, valueStr]];
//            }
        }];
        NSString *result = [urlString stringByAppendingFormat:@"?%@", [temp componentsJoinedByString:@"&"]];
        return result;
    }
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

- (AFHTTPRequestSerializer *)httpRequestSerializer {
    if (_httpRequestSerializer == nil) {
        _httpRequestSerializer = [AFHTTPRequestSerializer serializer];
//        [_httpRequestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        _httpRequestSerializer.timeoutInterval = 30;
        
    }
    return _httpRequestSerializer;
}

- (AFHTTPSessionManager *)sessionManager {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    // 允许http
//    manager.securityPolicy = [AFSecurityPolicy defaultPolicy];
//    manager.securityPolicy.allowInvalidCertificates = YES;
//    manager.securityPolicy.validatesDomainName = YES;
//    manager.requestSerializer = self.httpRequestSerializer;
    
    return manager;
}

- (GosServiceApiTaskType)apiTaskType {
    return GosServiceApiTaskTypeDownload;
}
@end
