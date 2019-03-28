//  GosURLResponse.m
//  CloudStoreSDK
//
//  Create by daniel.hu on 2018/12/11.
//  Copyright © 2018年 daniel. All rights reserved.

#import "GosURLResponse.h"
#import "NSObject+ApiProxyNetworkingMethods.h"
#import "NSURLRequest+GosNetworkingMethod.h"


@interface GosURLResponse ()
@property (nonatomic, assign, readwrite) GosURLResponseStatus status;
@property (nonatomic, copy, readwrite) NSString *contentString;
@property (nonatomic, copy, readwrite) id content;
@property (nonatomic, copy, readwrite) NSURLRequest *request;
@property (nonatomic, assign, readwrite) NSInteger requestId;
@property (nonatomic, copy, readwrite) NSData *responseData;
@property (nonatomic, assign, readwrite) BOOL isCache;
@property (nonatomic, strong, readwrite) NSString *errorMessage;
@end

@implementation GosURLResponse
#pragma mark - initialization
- (instancetype)initWithResponseString:(NSString *)responseString
                             requestId:(NSNumber *)requestId
                               request:(NSURLRequest *)request
                        responseObject:(id)responseObject
                                 error:(NSError *)error {
    if (self = [super init]) {
        self.contentString = [responseString gos_defaultValue:@""];
        self.requestId = [requestId integerValue];
        self.request = request;
        self.acturlRequestParams = request.actualRequestParams;
        self.originRequestParams = request.originRequestParams;
        self.isCache = NO;
        self.status = [self responseStatusWithError:error];
        self.content = responseObject ?:@{};
        self.errorMessage = [NSString stringWithFormat:@"%@", error];
    }
    return self;
}
- (instancetype)initWithFilePath:(NSURL *)filePath
                       requestId:(NSNumber *)requestId
                         request:(NSURLRequest *)request
                           error:(NSError *)error {
    if (self = [super init]) {
        self.requestId = [requestId integerValue];
        self.request = request;
        self.acturlRequestParams = request.actualRequestParams;
        self.originRequestParams = request.originRequestParams;
        self.isCache = NO;
        self.status = [self responseStatusWithError:error];
        self.content = @{};
        self.filePath = filePath;
        self.errorMessage = [NSString stringWithFormat:@"%@", error];
    }
    return self;
}





#pragma mark - private methods
- (GosURLResponseStatus)responseStatusWithError:(NSError *)error
{
    if (error) {
        // 默认是服务器 返回失败了
        GosURLResponseStatus result = GosURLResponseStatusErrorServerFailed;
        
        
        if (error.code == NSURLErrorTimedOut) {
            result = GosURLResponseStatusErrorTimeout;
        }
        if (error.code == NSURLErrorCancelled) {
            result = GosURLResponseStatusErrorCancel;
        }
        if (error.code == NSURLErrorNotConnectedToInternet) {
            result = GosURLResponseStatusErrorNoNetwork;
        }
        
        return result;
    } else {
        return GosURLResponseStatusSuccess;
    }
}


#pragma mark - getters and setters
- (NSData *)responseData {
    if (!_responseData) {
        NSError *error = nil;
        _responseData = [NSJSONSerialization dataWithJSONObject:self.content options:0 error:&error];
        if (error) {
            _responseData = [@"" dataUsingEncoding:NSUTF8StringEncoding];
        }
    }
    return _responseData;
}
@end
