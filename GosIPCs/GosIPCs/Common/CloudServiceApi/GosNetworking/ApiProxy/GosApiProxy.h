//  GosApiProxy.h
//  CloudStoreSDK
//
//  Create by daniel.hu on 2018/12/11.
//  Copyright © 2018年 daniel. All rights reserved.

#import <Foundation/Foundation.h>
#import "GosURLResponse.h"

NS_ASSUME_NONNULL_BEGIN
/// 成功或失败回调
typedef void (^ApiProxyCallBack) (GosURLResponse *response);
/// 进程回调
typedef void (^ApiProxyProcessBlock) (NSProgress *_Nonnull progress);
/// 目标位置回调
typedef NSURL *_Nonnull (^ApiProxyDestinationBlock) (NSURL *_Nonnull targetPath, NSURLResponse *_Nonnull response);

@interface GosApiProxy : NSObject
/// 单例
+ (instancetype)sharedInstance;

/// 取消请求
- (void)cancelRequestWithRequestId:(NSNumber *)requestId;
/// 取消请求列表
- (void)cancelRequestWithRequestIdList:(NSArray *)requestIdList;
/// 请求
- (NSNumber *)callApiWithRequest:(NSURLRequest *)request
                         success:(ApiProxyCallBack)success
                            fail:(ApiProxyCallBack)fail;

@end

NS_ASSUME_NONNULL_END
