//  GosURLResponse.h
//  CloudStoreSDK
//
//  Create by daniel.hu on 2018/12/11.
//  Copyright © 2018年 daniel. All rights reserved.

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, GosURLResponseStatus)
{
    GosURLResponseStatusSuccess, //作为底层，请求是否成功只考虑是否成功收到服务器反馈。至于签名是否正确，返回的数据是否完整，由上层的CTAPIBaseManager来决定。
    GosURLResponseStatusErrorTimeout,       // 响应超时
    GosURLResponseStatusErrorCancel,        // 操作取消
    GosURLResponseStatusErrorNoNetwork,     // 默认除了超时以外的错误都是无网络错误。
    GosURLResponseStatusErrorServerFailed,  // 服务器返回操作失败
};

NS_ASSUME_NONNULL_BEGIN

@interface GosURLResponse : NSObject

@property (nonatomic, assign, readonly) GosURLResponseStatus status;
@property (nonatomic, copy, readonly) NSString *contentString;
@property (nonatomic, copy, readonly) id content;
@property (nonatomic, assign, readonly) NSInteger requestId;
@property (nonatomic, copy, readonly) NSURLRequest *request;
/// 由content解析Json数据，如果未解析成功就设为@""
@property (nonatomic, copy, readonly) NSData *responseData;
@property (nonatomic, strong, readonly) NSString *errorMessage;

@property (nonatomic, copy) NSDictionary *acturlRequestParams;
@property (nonatomic, copy) NSDictionary *originRequestParams;
@property (nonatomic, strong) NSString *logString;
@property (nonatomic, copy) NSURL *filePath;

@property (nonatomic, assign, readonly) BOOL isCache;

- (instancetype)initWithResponseString:(NSString *)responseString
                             requestId:(NSNumber *)requestId
                               request:(NSURLRequest *)request
                        responseObject:(id)responseObject
                                 error:(NSError *)error;
- (instancetype)initWithFilePath:(NSURL *)filePath
                       requestId:(NSNumber *)requestId
                         request:(NSURLRequest *)request
                           error:(NSError *)error;
@end

NS_ASSUME_NONNULL_END
