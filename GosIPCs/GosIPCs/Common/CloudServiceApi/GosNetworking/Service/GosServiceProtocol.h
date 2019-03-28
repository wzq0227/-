//  GosServiceProtocol.h
//  CloudStoreSDK
//
//  Create by daniel.hu on 2018/12/11.
//  Copyright © 2018年 daniel. All rights reserved.

#import <Foundation/Foundation.h>
#import "GosNetworkingDefines.h"

NS_ASSUME_NONNULL_BEGIN
@class AFHTTPSessionManager;
@protocol GosServiceProtocol <NSObject>

@property (nonatomic, assign) GosServiceApiTaskType apiTaskType;
@property (nonatomic, assign) GosServiceApiEnvironment apiEnvironment;
@property (nonatomic, assign) GosServiceApiArea apiArea;


- (NSURLRequest *)requestWithParams:(NSDictionary *)params
                         methodName:(NSString *)methodName
                        requestType:(GosApiManagerRequestType)requestType;

- (NSDictionary *)resultWithResponseObject:(nullable id)responseObject
                                  response:(NSURLResponse *)response
                                   request:(NSURLRequest *)request
                                     error:(NSError **)error;

///*
// return true means should continue the error handling process in GosApiBaseManager
// return false means stop the error handling process
// 
// 如果检查错误之后，需要继续走fail路径上报到业务层的，return YES。（例如网络错误等，需要业务层弹框）
// 如果检查错误之后，不需要继续走fail路径上报到业务层的，return NO。（例如用户token失效，此时挂起API，调用刷新token的API，成功之后再重新调用原来的API。那么这种情况就不需要继续走fail路径上报到业务。）
// */
- (BOOL)handleCommonErrorWithResponse:(GosURLResponse *)response
                              manager:(GosApiBaseManager *)manager
                            errorType:(GosApiManagerErrorType)errorType;

@optional
- (AFHTTPSessionManager *)sessionManager;
@end

NS_ASSUME_NONNULL_END
