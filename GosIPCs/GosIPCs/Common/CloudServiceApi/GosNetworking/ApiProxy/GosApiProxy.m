//  GosApiProxy.m
//  CloudStoreSDK
//
//  Create by daniel.hu on 2018/12/11.
//  Copyright © 2018年 daniel. All rights reserved.

#import "GosApiProxy.h"
#import "AFNetworking.h"
#import "NSURLRequest+GosNetworkingMethod.h"
#import "GosURLResponse.h"
#import "GosNetworkingLogger.h"

static NSString * const kAXApiProxyDispatchItemKeyCallbackSuccess = @"kAXApiProxyDispatchItemCallbackSuccess";
static NSString * const kAXApiProxyDispatchItemKeyCallbackFail = @"kAXApiProxyDispatchItemCallbackFail";

NSString * const kGosApiProxyValidateResultKeyResponseObject = @"kGosApiProxyValidateResultKeyResponseObject";
NSString * const kGosApiProxyValidateResultKeyResponseString = @"kGosApiProxyValidateResultKeyResponseString";




@interface GosApiProxy ()

/// (requestId, NSURLSessionDataTask)
@property (nonatomic, strong) NSMutableDictionary *dispatchTable;

@property (nonatomic, strong) NSNumber *recordedRequestId;

@end

@implementation GosApiProxy
#pragma mark - shared instance class method
+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static GosApiProxy *sharedInstance = nil;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[GosApiProxy alloc] init];
    });
    return sharedInstance;
}

#pragma mark - public method
- (void)cancelRequestWithRequestId:(NSNumber *)requestId {
    NSURLSessionTask *requestOperation = self.dispatchTable[requestId];
    [requestOperation cancel];
    [self.dispatchTable removeObjectForKey:requestId];
}

- (void)cancelRequestWithRequestIdList:(NSArray *)requestIdList {
    for (NSNumber *requestId in requestIdList) {
        [self cancelRequestWithRequestId:requestId];
    }
}

- (NSNumber *)callApiWithRequest:(NSURLRequest *)request
                         success:(ApiProxyCallBack)success
                            fail:(ApiProxyCallBack)fail {
    if (request.service.apiTaskType == GosServiceApiTaskTypeGeneral) {
        // get, post, put, delete
        return [self callApiForGeneralWithRequest:request
                                    uploadProcess:request.uploadProcess
                                  downloadProcess:request.downloadProcess
                                          success:success
                                             fail:fail];
    } else {
        // download
        return [self callApiForDownloadWithRequest:request
                                   downloadProcess:request.downloadProcess
                                       destination:request.destination
                                           success:success
                                              fail:fail];
    }
}


#pragma mark - private method
- (NSNumber *)callApiForDownloadWithRequest:(NSURLRequest *)request
                            downloadProcess:(ApiProxyProcessBlock)downloadProcess
                                destination:(ApiProxyDestinationBlock)destination
                                    success:(ApiProxyCallBack)success
                                       fail:(ApiProxyCallBack)fail {
    
    __block NSURLSessionDownloadTask *downloadTask = nil;
    __weak typeof(self) weakself = self;
    downloadTask = [[self sessionManagerWithService:request.service] downloadTaskWithRequest:request progress:downloadProcess destination:destination completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        // 请求完成后从列表中移除请求id
        NSNumber *requestID = @([downloadTask taskIdentifier]);
        [weakself.dispatchTable removeObjectForKey:requestID];
        
        // 输出返回数据
        GosURLResponse *gosResponse = [[GosURLResponse alloc] initWithFilePath:filePath requestId:requestID request:request error:error];
        
        // 打印
        gosResponse.logString = [GosNetworkingLogger logDebugInfoWithResponse:(NSHTTPURLResponse *)response responseObject:@"" responseString:@"" request:request error:error];
        
        if (error) {
            fail?fail(gosResponse):nil;
        } else {
            success?success(gosResponse):nil;
        }
    }];
    
    NSNumber *requestId = @([downloadTask taskIdentifier]);
    
    self.dispatchTable[requestId] = downloadTask;
    [downloadTask resume];
    
    return requestId;
}

- (NSNumber *)callApiForGeneralWithRequest:(NSURLRequest *)request
                             uploadProcess:(ApiProxyProcessBlock)uploadProcess
                           downloadProcess:(ApiProxyProcessBlock)downloadProcess
                                   success:(ApiProxyCallBack)success
                                      fail:(ApiProxyCallBack)fail {
    
    __block NSURLSessionDataTask *dataTask = nil;
    __weak typeof(self) weakself = self;
    dataTask = [[self sessionManagerWithService:request.service] dataTaskWithRequest:request uploadProgress:uploadProcess downloadProgress:downloadProcess completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        // 请求完成后从列表中移除请求id
        NSNumber *requestID = @([dataTask taskIdentifier]);
        [weakself.dispatchTable removeObjectForKey:requestID];
        
        NSDictionary *result = [request.service resultWithResponseObject:responseObject response:response request:request error:&error];
        
        // 输出返回数据
        GosURLResponse *gosResponse = [[GosURLResponse alloc] initWithResponseString:result[kGosApiProxyValidateResultKeyResponseString] requestId:requestID request:request responseObject:result[kGosApiProxyValidateResultKeyResponseObject] error:error];
        
        // 打印
        gosResponse.logString = [GosNetworkingLogger logDebugInfoWithResponse:(NSHTTPURLResponse *)response responseObject:responseObject responseString:result[kGosApiProxyValidateResultKeyResponseString] request:request error:error];
        
        if (error) {
            fail?fail(gosResponse):nil;
        } else {
            success?success(gosResponse):nil;
        }
    }];
    
    NSNumber *requestId = @([dataTask taskIdentifier]);
    
    self.dispatchTable[requestId] = dataTask;
    [dataTask resume];
    
    return requestId;
    
}


#pragma mark - getters
- (AFHTTPSessionManager *)sessionManagerWithService:(id<GosServiceProtocol>)service {
    
    AFHTTPSessionManager *sessionManager = nil;
    // 每个service可以有自己特殊的sessionManager，针对不同需求设定
    if ([service respondsToSelector:@selector(sessionManager)]) {
        sessionManager = service.sessionManager;
    }
    if (!sessionManager) {
        sessionManager = [AFHTTPSessionManager manager];
    }
    return sessionManager;
}
- (NSMutableDictionary *)dispatchTable {
    if (!_dispatchTable) {
        _dispatchTable = [[NSMutableDictionary alloc] init];
    }
    return _dispatchTable;
}
@end
