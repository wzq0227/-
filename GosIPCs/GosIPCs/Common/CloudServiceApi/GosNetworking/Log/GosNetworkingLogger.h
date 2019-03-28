//  GosNetworkingLogger.h
//  Goscom
//
//  Create by daniel.hu on 2018/12/24.
//  Copyright © 2018年 goscam. All rights reserved.

#import <Foundation/Foundation.h>
#import "GosServiceProtocol.h"
#import "GosURLResponse.h"

NS_ASSUME_NONNULL_BEGIN

@interface GosNetworkingLogger : NSObject
+ (NSString *)logDebugInfoWithRequest:(NSURLRequest *)request apiName:(NSString *)apiName service:(id <GosServiceProtocol>)service;
+ (NSString *)logDebugInfoWithResponse:(NSHTTPURLResponse *)response responseObject:(id)responseObject responseString:(NSString *)responseString request:(NSURLRequest *)request error:(NSError *)error;
+ (NSString *)logDebugInfoWithCachedResponse:(GosURLResponse *)response methodName:(NSString *)methodName service:(id <GosServiceProtocol>)service params:(NSDictionary *)params;
@end

@interface NSMutableString (GosNetworkingLoggerMStringMethods)
- (void)appendURLRequest:(NSURLRequest *)request;
@end

@interface NSArray (GosNetworkingLoggerArrayMethods)

- (NSString *)gos_paramsString;
- (NSString *)gos_jsonString;

@end

@interface NSDictionary (GosNetworkingLoggerDictionaryMethods)
- (NSString *)gos_jsonString;
@end
NS_ASSUME_NONNULL_END
