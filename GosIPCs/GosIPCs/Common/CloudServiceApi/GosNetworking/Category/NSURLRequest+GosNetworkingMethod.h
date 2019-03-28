//  NSURLRequest+GosNetworkingMethod.h
//  CloudStoreSDK
//
//  Create by daniel.hu on 2018/12/11.
//  Copyright © 2018年 daniel. All rights reserved.

#import <Foundation/Foundation.h>
#import "GosServiceProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface NSURLRequest (GosNetworkingMethod)
@property (nonatomic, copy) NSDictionary *actualRequestParams;
@property (nonatomic, copy) NSDictionary *originRequestParams;
@property (nonatomic, strong) id<GosServiceProtocol> service;
@property (nonatomic, copy, nullable) void (^uploadProcess) (NSProgress *_Nonnull progress);
@property (nonatomic, copy, nullable) void (^downloadProcess) (NSProgress *_Nonnull progress);
@property (nonatomic, copy, nullable) NSURL *_Nonnull (^destination) (NSURL *_Nonnull targetPath, NSURLResponse *_Nonnull response);
@end

NS_ASSUME_NONNULL_END
