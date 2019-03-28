//  GosNetworkingLogger.m
//  Goscom
//
//  Create by daniel.hu on 2018/12/24.
//  Copyright © 2018年 goscam. All rights reserved.

#import "GosNetworkingLogger.h"
#import "GosMediator+GosAppContext.h"
#import "NSURLRequest+GosNetworkingMethod.h"
#import "NSObject+ApiProxyNetworkingMethods.h"

@implementation GosNetworkingLogger
+ (NSString *)logDebugInfoWithRequest:(NSURLRequest *)request apiName:(NSString *)apiName service:(id <GosServiceProtocol>)service
{
    NSMutableString *logString = nil;
#ifdef DEBUG
    if ([GosMediator sharedInstance].GosAppContextNetworkingShouldPrintNetworkingLog == NO) {
        return @"";
    }
    
    GosServiceApiEnvironment enviroment = request.service.apiEnvironment;
    NSString *enviromentString = nil;
    if (enviroment == GosServiceApiEnvironmentDevelop) {
        enviromentString = @"Develop";
    }
    if (enviroment == GosServiceApiEnvironmentReleaseCandidate) {
        enviromentString = @"Pre Release";
    }
    if (enviroment == GosServiceApiEnvironmentRelease) {
        enviromentString = @"Release";
    }
    
    logString = [NSMutableString stringWithString:@"\n\n********************************************************\nRequest Start\n********************************************************\n\n"];
    
    [logString appendFormat:@"API Name:\t\t%@\n", [apiName gos_defaultValue:@"N/A"]];
    [logString appendFormat:@"Method:\t\t\t%@\n", request.HTTPMethod];
    [logString appendFormat:@"Service:\t\t%@\n", [service class]];
    [logString appendFormat:@"Status:\t\t\t%@\n", enviromentString];
    [logString appendURLRequest:request];
    
    [logString appendFormat:@"\n\n********************************************************\nRequest End\n********************************************************\n\n\n\n"];
    GosLog(@"%@", logString);
#endif
    return logString;
}

+ (NSString *)logDebugInfoWithResponse:(NSHTTPURLResponse *)response responseObject:(id)responseObject responseString:(NSString *)responseString request:(NSURLRequest *)request error:(NSError *)error
{
    NSMutableString *logString = nil;
#ifdef DEBUG
    if ([GosMediator sharedInstance].GosAppContextNetworkingShouldPrintNetworkingLog == NO) {
        return @"";
    }
    
    BOOL isSuccess = error ? NO : YES;
    
    logString = [NSMutableString stringWithString:@"\n\n=========================================\nAPI Response\n=========================================\n\n"];
    
    [logString appendFormat:@"Status:\t%ld\t(%@)\n\n", (long)response.statusCode, [NSHTTPURLResponse localizedStringForStatusCode:response.statusCode]];
    [logString appendFormat:@"Content:\n\t%@\n\n", responseString];
    [logString appendFormat:@"Request URL:\n\t%@\n\n", request.URL];
    [logString appendFormat:@"Request Data:\n\t%@\n\n",request.originRequestParams.gos_jsonString];
    if ([responseObject isKindOfClass:[NSData class]]) {
        [logString appendFormat:@"Raw Response String:\n\t%@\n\n", [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]];
    } else {
        [logString appendFormat:@"Raw Response String:\n\t%@\n\n", responseObject];
    }
    [logString appendFormat:@"Raw Response Header:\n\t%@\n\n", response.allHeaderFields];
    if (isSuccess == NO) {
        [logString appendFormat:@"Error Domain:\t\t\t\t\t\t\t%@\n", error.domain];
        [logString appendFormat:@"Error Domain Code:\t\t\t\t\t\t%ld\n", (long)error.code];
        [logString appendFormat:@"Error Localized Description:\t\t\t%@\n", error.localizedDescription];
        [logString appendFormat:@"Error Localized Failure Reason:\t\t\t%@\n", error.localizedFailureReason];
        [logString appendFormat:@"Error Localized Recovery Suggestion:\t%@\n\n", error.localizedRecoverySuggestion];
    }
    
    [logString appendString:@"\n---------------  Related Request Content  --------------\n"];
    
    [logString appendURLRequest:request];
    
    [logString appendFormat:@"\n\n=========================================\nResponse End\n=========================================\n\n"];
    
    GosLog(@"%@", logString);
#endif
    
    return logString;
}

+(NSString *)logDebugInfoWithCachedResponse:(GosURLResponse *)response methodName:(NSString *)methodName service:(id <GosServiceProtocol>)service params:(NSDictionary *)params
{
    NSMutableString *logString = nil;
#ifdef DEBUG
    if ([GosMediator sharedInstance].GosAppContextNetworkingShouldPrintNetworkingLog == NO) {
        return @"";
    }
    
    logString = [NSMutableString stringWithString:@"\n\n=========================================\nCached Response                             \n=========================================\n\n"];
    
    [logString appendFormat:@"API Name:\t\t%@\n", [methodName gos_defaultValue:@"N/A"]];
    [logString appendFormat:@"Service:\t\t%@\n", [service class]];
    [logString appendFormat:@"Method Name:\t%@\n", methodName];
    [logString appendFormat:@"Params:\n%@\n\n", params];
    [logString appendFormat:@"Origin Params:\n%@\n\n", response.originRequestParams];
    [logString appendFormat:@"Actual Params:\n%@\n\n", response.acturlRequestParams];
    [logString appendFormat:@"Content:\n\t%@\n\n", response.contentString];
    
    [logString appendFormat:@"\n\n=========================================\nResponse End\n=========================================\n\n"];
    GosLog(@"%@", logString);
#endif
    
    return logString;
}

@end


@implementation NSMutableString (GosNetworkingLoggerMStringMethods)

- (void)appendURLRequest:(NSURLRequest *)request
{
    [self appendFormat:@"\n\nHTTP URL:\n\t%@", request.URL];
    [self appendFormat:@"\n\nHTTP Header:\n%@", request.allHTTPHeaderFields ? request.allHTTPHeaderFields : @"\t\t\t\t\tN/A"];
    [self appendFormat:@"\n\nHTTP Origin Params:\n\t%@", request.originRequestParams.gos_jsonString];
    [self appendFormat:@"\n\nHTTP Actual Params:\n\t%@", request.actualRequestParams.gos_jsonString];
    [self appendFormat:@"\n\nHTTP Body:\n\t%@", [[[NSString alloc] initWithData:request.HTTPBody encoding:NSUTF8StringEncoding] gos_defaultValue:@"\t\t\t\tN/A"]];
    
    NSMutableString *headerString = [[NSMutableString alloc] init];
    [request.allHTTPHeaderFields enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSString * _Nonnull obj, BOOL * _Nonnull stop) {
        NSString *header = [NSString stringWithFormat:@" -H \"%@: %@\"", key, obj];
        [headerString appendString:header];
    }];
    
    [self appendString:@"\n\nCURL:\n\t curl"];
    [self appendFormat:@" -X %@", request.HTTPMethod];
    
    if (headerString.length > 0) {
        [self appendString:headerString];
    }
    if (request.HTTPBody.length > 0) {
        [self appendFormat:@" -d '%@'", [[[NSString alloc] initWithData:request.HTTPBody encoding:NSUTF8StringEncoding] gos_defaultValue:@"\t\t\t\tN/A"]];
    }
    
    [self appendFormat:@" %@", request.URL];
}

@end


@implementation NSArray (GosNetworkingLoggerArrayMethods)

/** 字母排序之后形成的参数字符串 */
- (NSString *)gos_paramsString
{
    NSMutableString *paramString = [[NSMutableString alloc] init];
    
    NSArray *sortedParams = [self sortedArrayUsingSelector:@selector(compare:)];
    [sortedParams enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([paramString length] == 0) {
            [paramString appendFormat:@"%@", obj];
        } else {
            [paramString appendFormat:@"&%@", obj];
        }
    }];
    
    return paramString;
}

/** 数组变json */
- (NSString *)gos_jsonString
{
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self options:NSJSONWritingPrettyPrinted error:NULL];
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}


@end


@implementation NSDictionary (GosNetworkingLoggerDictionaryMethods)

- (NSString *)gos_jsonString
{
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self options:NSJSONWritingPrettyPrinted error:NULL];
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}
@end
