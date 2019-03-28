//  CloudDownloadFileApiManager.m
//  GosIPCs
//
//  Create by daniel.hu on 2019/1/3.
//  Copyright © 2019年 goscam. All rights reserved.

#import "CloudDownloadFileApiManager.h"
#import "TokenCheckApiRespModel.h"
#import "VideoSlicesApiRespModel.h"
#import "MediaManager.h"

#pragma mark - service identifier
/// CloudDownloadService
extern NSString *const GosNetworkingCloudDownloadServiceIdentifier;

#pragma mark - 请求参数
/// 有效期
extern NSString *const kCloudServiceApiReqKeyExpires;
/// 允许使用秘钥
extern NSString *const kCloudServiceApiReqKeyAccessKey;
/// 签名
extern NSString *const kCloudServiceApiReqKeySignature;
/// 安全令牌
extern NSString *const kCloudServiceApiReqKeySecurityToken;

#pragma mark - NSString (CloudDownloadFileApiExtension) (Public)
@interface NSString (CloudDownloadFileApiExtension)
- (NSString *)api_encodeURL;
- (NSString *)api_trimming;
@end


#pragma mark - DownloadFileApiManager (Helper) (Public)
@interface CloudDownloadFileApiManager (Helper)
/// 生成methodName
- (NSString *)methodNameWithEndPoint:(NSString *)endPoint
                          bucketName:(NSString *)bucketName
                           bucketKey:(NSString *)bucketKey;
/// 生成signature
- (NSString *)signatureWithBucketName:(NSString *)bucketName
                            bucketKey:(NSString *)bucketKey
                  expirationTimestamp:(NSString *)expirationTimestamp
                                token:(NSString *)token
                               secret:(NSString *)secret;
/// 生成过期时间戳
- (NSString *)expiresWithDurationSeconds:(NSInteger)durationSeconds;

@end

#pragma mark - DownloadFileApiManager (Private)
@interface CloudDownloadFileApiManager () <GosApiManagerValidator>
/// 有效期——时间戳
@property (nonatomic, copy) NSString *expires;
/// 允许Key
@property (nonatomic, copy) NSString *accessKey;
/// 签名
@property (nonatomic, copy) NSString *signature;
/// 令牌
@property (nonatomic, copy) NSString *token;

/// url的端口
@property (nonatomic, copy) NSString *endPoint;
/// url的baseUrl
@property (nonatomic, copy) NSString *bucketName;
/// url的尾部
@property (nonatomic, copy) NSString *bucketKey;

/// 目标储存位置
@property (nonatomic, copy) NSURL * _Nonnull (^destinationBlock)(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response);
/// 下载进程
@property (nonatomic, copy) void (^downloadProcessBlock)(NSProgress * _Nonnull process);

@end

@implementation CloudDownloadFileApiManager
#pragma mark - initialization
- (instancetype)init {
    if (self = [super init]) {
        self.validator = self;
    }
    return self;
}


#pragma mark - public method
- (NSInteger)loadDataWithTokenModel:(TokenCheckApiRespModel *)tokenModel
                         videoModel:(VideoSlicesApiRespModel *)videoModel
               destionationFilePath:(NSURL *)destionationFilePath {
    
    return [self loadDataWithTokenModel:tokenModel videoModel:videoModel downloadProcess:^(NSProgress * _Nonnull process) {
        GosLog(@"[deviceId] %@ [st] %@ - [et] %@ download process: %.2f%%", tokenModel.deviceId, videoModel.startTime, videoModel.endTime, (1.0 * process.completedUnitCount / process.totalUnitCount) * 100);
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        return destionationFilePath;
    }];
}

- (NSInteger)loadDataWithTokenModel:(TokenCheckApiRespModel *)tokenModel
                         videoModel:(VideoSlicesApiRespModel *)videoModel
                    downloadProcess:(void (^) (NSProgress * _Nonnull process))downloadProcess
                        destination:(NSURL * _Nonnull (^)(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response))desination {
    
    [self configDataWithTokenModel:tokenModel videoModel:videoModel];
    
    self.downloadProcessBlock = downloadProcess;
    self.destinationBlock = desination;
    
    return [self loadData];
}


#pragma mark - GosApiManager
- (NSString *)methodName {
    return [self methodNameWithEndPoint:self.endPoint
                             bucketName:self.bucketName
                              bucketKey:self.bucketKey];
}

- (GosApiManagerRequestType)requestType {
    return GosApiManagerRequestTypeGet;
}

- (NSString *)serviceIdentifier {
    return GosNetworkingCloudDownloadServiceIdentifier;
}

- (void (^)(NSProgress * _Nonnull))downloadProcess {
    return self.downloadProcessBlock;
}

- (NSURL * _Nonnull (^)(NSURL * _Nonnull, NSURLResponse * _Nonnull))destination {
    return self.destinationBlock;
}

- (NSDictionary *)reformParams:(NSDictionary *)params {
    NSMutableDictionary *temp = [NSMutableDictionary dictionaryWithDictionary:params];
    if (self.expires) {
        [temp addEntriesFromDictionary:@{kCloudServiceApiReqKeyExpires:self.expires}];
    }
    if (self.accessKey) {
        [temp addEntriesFromDictionary:@{kCloudServiceApiReqKeyAccessKey:self.accessKey}];
    }
    if (self.signature) {
        [temp addEntriesFromDictionary:@{kCloudServiceApiReqKeySignature:[self.signature api_encodeURL]}];
    }
    if (self.token) {
        [temp addEntriesFromDictionary:@{kCloudServiceApiReqKeySecurityToken:[self.token api_encodeURL]}];
    }
    return [temp copy];
}

#pragma mark - GosApiManagerValidator
- (GosApiManagerErrorType)manager:(GosApiBaseManager *)manager isCorrectWithParamsData:(NSDictionary *)data {
    if ([manager isKindOfClass:[self class]]) {
        if ([data objectForKey:kCloudServiceApiReqKeySecurityToken]
            && [data objectForKey:kCloudServiceApiReqKeyExpires]
            && [data objectForKey:kCloudServiceApiReqKeyAccessKey]
            && [data objectForKey:kCloudServiceApiReqKeySignature]
            && [data count] == 4) {
            // 必须只存在 security-token, Expires, OSSAccessKeyId, Signature
            return GosApiManagerErrorTypeNoError;
        }
        return GosApiManagerErrorTypeParamsError;
    }
    return GosApiManagerErrorTypeNoError;
}

- (GosApiManagerErrorType)manager:(GosApiBaseManager *)manager isCorrectWithCallBackData:(NSDictionary *)data {
    return GosApiManagerErrorTypeNoError;
}

#pragma mark - private method
- (void)configDataWithTokenModel:(TokenCheckApiRespModel *)tokenModel videoModel:(VideoSlicesApiRespModel *)videoModel {
    self.token = [tokenModel.token api_trimming];
    self.accessKey = [tokenModel.key api_trimming];
    self.endPoint = [tokenModel.endPoint api_trimming];
    self.expires = [self expiresWithDurationSeconds:tokenModel.durationSeconds.integerValue];
    
    self.bucketName = [videoModel.bucket api_trimming];
    self.bucketKey = [videoModel.key api_trimming];
    
    self.signature = [self signatureWithBucketName:self.bucketName
                                         bucketKey:self.bucketKey
                               expirationTimestamp:self.expires
                                             token:self.token
                                            secret:tokenModel.secret];
}
@end


#pragma mark - OSSUtil (Public)
@interface OSSUtil : NSObject
+ (NSString *)calBase64Sha1WithData:(NSString *)data withSecret:(NSString *)key;
+ (NSString *)calBase64WithData:(uint8_t *)data;
+ (NSString *)populateSubresourceStringFromParameter:(NSDictionary *)parameters;
+ (NSString *)populateQueryStringFromParameter:(NSDictionary *)parameters;
+ (BOOL)isOssOriginBucketHost:(NSString *)host;
+ (NSString *)encodeURL:(NSString *)url;
+ (NSString *)sign:(NSString *)content withSecret:(NSString *)secret;
@end


#pragma mark - CloudDownloadFileApiManager (Helper) (Private)
@implementation CloudDownloadFileApiManager (Helper)

- (NSString *)expiresWithDurationSeconds:(NSInteger)durationSeconds {
    return [@((int64_t)[[NSDate date] timeIntervalSince1970] + durationSeconds) stringValue];
}

- (NSString *)methodNameWithEndPoint:(NSString *)endPoint
                          bucketName:(NSString *)bucketName
                           bucketKey:(NSString *)bucketKey {
    NSURL * endpointURL = [NSURL URLWithString:endPoint];
    NSString * host = endpointURL.host;
    if ([OSSUtil isOssOriginBucketHost:host]) {
        host = [NSString stringWithFormat:@"%@.%@", bucketName, host];
    }
    return [NSString stringWithFormat:@"%@://%@/%@",
            endpointURL.scheme,
            host,
            [OSSUtil encodeURL:bucketKey]];
    
}

- (NSString *)signatureWithBucketName:(NSString *)bucketName
                            bucketKey:(NSString *)bucketKey
                  expirationTimestamp:(NSString *)expirationTimestamp
                                token:(NSString *)token
                               secret:(NSString *)secret {
    if (IS_EMPTY_STRING(token)
        || IS_EMPTY_STRING(bucketName)
        || IS_EMPTY_STRING(bucketKey)
        || IS_EMPTY_STRING(expirationTimestamp)
        || IS_EMPTY_STRING(secret)) return nil;
    
    NSString *resource = [NSString stringWithFormat:@"/%@/%@?%@",
                          bucketName,
                          bucketKey,
                          [OSSUtil populateSubresourceStringFromParameter:@{kCloudServiceApiReqKeySecurityToken:token}]];
    
    NSString * string2sign = [[NSString stringWithFormat:@"GET\n\n\n%@\n%@", expirationTimestamp, resource] api_trimming];
    
    return [OSSUtil sign:string2sign withSecret:secret];
}

@end


#pragma mark - OSSUtil (Private)
#import <mach/mach.h>
#import "CommonCrypto/CommonDigest.h"
#import "CommonCrypto/CommonHMAC.h"

static NSString * const ALIYUN_HOST_SUFFIX = @".aliyuncs.com";
static NSString * const ALIYUN_OSS_TEST_ENDPOINT = @".aliyun-inc.com";

@implementation OSSUtil

+ (NSString *)calBase64Sha1WithData:(NSString *)data withSecret:(NSString *)key {
    NSData *secretData = [key dataUsingEncoding:NSUTF8StringEncoding];
    NSData *clearTextData = [data dataUsingEncoding:NSUTF8StringEncoding];
    uint8_t input[20];
    CCHmac(kCCHmacAlgSHA1, [secretData bytes], [secretData length], [clearTextData bytes], [clearTextData length], input);
    
    return [self calBase64WithData:input];
}

+ (NSString*)calBase64WithData:(uint8_t *)data {
    static char b[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";
    NSInteger a = 20;
    NSMutableData* c = [NSMutableData dataWithLength:((a + 2) / 3) * 4];
    uint8_t* d = (uint8_t*)c.mutableBytes;
    NSInteger i;
    for (i=0; i < a; i += 3) {
        NSInteger e = 0;
        NSInteger j;
        for (j = i; j < (i + 3); j++) {
            e <<= 8;
            if (j < a) {
                e |= (0xFF & data[j]);
            }
        }
        NSInteger index = (i / 3) * 4;
        d[index + 0] = b[(e >> 18) & 0x3F];
        d[index + 1] = b[(e >> 12) & 0x3F];
        if ((i + 1) < a) {
            d[index + 2] = b[(e >> 6) & 0x3F];
        } else {
            d[index + 2] = '=';
        }
        if ((i + 2) < a) {
            d[index + 3] = b[(e >> 0) & 0x3F];
        } else {
            d[index + 3] = '=';
        }
    }
    NSString *result = [[NSString alloc] initWithData:c encoding:NSASCIIStringEncoding];
    return result;
}

+ (BOOL)validateBucketName:(NSString *)bucketName {
    if (bucketName == nil) {
        return false;
    }
    
    static NSRegularExpression *regEx;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        regEx = [[NSRegularExpression alloc] initWithPattern:@"^[a-z0-9][a-z0-9_\\-]{2,62}$" options:NSRegularExpressionCaseInsensitive error:nil];
    });
    NSUInteger regExMatches = [regEx numberOfMatchesInString:bucketName options:0 range:NSMakeRange(0, [bucketName length])];
    return regExMatches != 0;
}

+ (BOOL)isSubresource:(NSString *)param {
    /****************************************************************
     * define a constant array to contain all specified subresource */
    static NSArray * OSSSubResourceARRAY = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        OSSSubResourceARRAY = @[
                                @"acl", @"uploads", @"location", @"cors", @"logging", @"website", @"referer", @"lifecycle", @"delete", @"append",
                                @"tagging", @"objectMeta", @"uploadId", @"partNumber", @"security-token", @"position", @"img", @"style",
                                @"styleName", @"replication", @"replicationProgress", @"replicationLocation", @"cname", @"bucketInfo", @"comp",
                                @"qos", @"live", @"status", @"vod", @"startTime", @"endTime", @"symlink", @"x-oss-process", @"response-content-type",
                                @"response-content-language", @"response-expires", @"response-cache-control", @"response-content-disposition", @"response-content-encoding"
                                ];
    });
    /****************************************************************/
    
    return [OSSSubResourceARRAY containsObject:param];
}

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

+ (NSString *)populateSubresourceStringFromParameter:(NSDictionary *)parameters {
    NSMutableArray * subresource = [NSMutableArray new];
    [parameters enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        NSString * keyStr = [key stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSString * valueStr = [obj stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if (![OSSUtil isSubresource:keyStr]) {
            return;
        }
        if ([valueStr length] == 0) {
            [subresource addObject:keyStr];
        } else {
            [subresource addObject:[NSString stringWithFormat:@"%@=%@", keyStr, valueStr]];
        }
    }];
    NSArray * sortedSubResource = [subresource sortedArrayUsingSelector:@selector(compare:)]; // 升序
    return [sortedSubResource componentsJoinedByString:@"&"];
}

+ (NSString *)populateQueryStringFromParameter:(NSDictionary *)parameters {
    NSMutableArray * subresource = [NSMutableArray new];
    [parameters enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        NSString * keyStr = [OSSUtil encodeURL:[key stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
        NSString * valueStr = [OSSUtil encodeURL:[obj stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
        if ([valueStr length] == 0) {
            [subresource addObject:keyStr];
        } else {
            [subresource addObject:[NSString stringWithFormat:@"%@=%@", keyStr, valueStr]];
        }
    }];
    return [subresource componentsJoinedByString:@"&"];
}

+ (BOOL)isOssOriginBucketHost:(NSString *)host {
    return [[host lowercaseString] hasSuffix:ALIYUN_HOST_SUFFIX] || [[host lowercaseString] hasSuffix:ALIYUN_OSS_TEST_ENDPOINT];
}

+ (NSString *)sign:(NSString *)content withSecret:(NSString *)secret {
    return [OSSUtil calBase64Sha1WithData:content withSecret:secret];
    
}

@end


@implementation NSString (CloudDownloadFileApiExtension)

- (NSString *)api_encodeURL {
    return [OSSUtil encodeURL:self];
}

- (NSString *)api_trimming {
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

@end
