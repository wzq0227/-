//  GosApiBaseManager.h
//  CloudStoreSDK
//
//  Create by daniel.hu on 2018/12/11.
//  Copyright © 2018年 daniel. All rights reserved.

#import <Foundation/Foundation.h>
#import "GosNetworkingDefines.h"
#import "GosURLResponse.h"

NS_ASSUME_NONNULL_BEGIN

@interface GosApiBaseManager : NSObject <NSCopying>
#pragma mark - delegate
@property (nonatomic, weak) id<GosApiManagerCallBackDelegate> delegate;
@property (nonatomic, weak) id<GosApiManagerParamSource> _Nullable paramSource;
@property (nonatomic, weak) id<GosApiManagerValidator> _Nullable validator;
@property (nonatomic, weak) NSObject<GosApiManager> *_Nullable child;
@property (nonatomic, weak) id<GosApiManagerInterceptor> _Nullable interceptor;


#pragma mark - response
@property (nonatomic, strong) GosURLResponse *_Nonnull response;
@property (nonatomic, readonly) GosApiManagerErrorType errorType;
@property (nonatomic, readonly, copy) NSString *_Nullable errorMessage;

#pragma mark - before loading
@property (nonatomic, readonly, assign, getter=isReachable) BOOL reachable;
@property (nonatomic, readonly, assign, getter=isLoading) BOOL loading;

#pragma mark - callback block
@property (nonatomic, strong, nullable) void (^successBlock)(GosApiBaseManager *apimanager);
@property (nonatomic, strong, nullable) void (^failBlock)(GosApiBaseManager *apimanager);

// start
- (NSInteger)loadData;
+ (NSInteger)loadDataWithParams:(NSDictionary * _Nullable)params success:(void (^ _Nullable)(GosApiBaseManager * _Nonnull apiManager))successCallback fail:(void (^ _Nullable)(GosApiBaseManager * _Nonnull apiManager))failCallback;

// cancel
- (void)cancelAllRequests;
- (void)cancelRequestWithRequestId:(NSInteger)requestID;

// finish
- (id _Nullable )fetchDataWithReformer:(id <GosApiManagerDataReformer> _Nullable)reformer;
- (void)cleanData;

@end



@interface GosApiBaseManager (InnerInterceptor)
- (BOOL)beforePerformSuccessWithResponse:(GosURLResponse *_Nullable)response;
- (void)afterPerformSuccessWithResponse:(GosURLResponse *_Nullable)response;

- (BOOL)beforePerformFailWithResponse:(GosURLResponse *_Nullable)response;
- (void)afterPerformFailWithResponse:(GosURLResponse *_Nullable)response;

- (BOOL)shouldCallApiWithParams:(NSDictionary *_Nullable)params;
- (void)afterCallingApiWithParams:(NSDictionary *_Nullable)params;

@end
NS_ASSUME_NONNULL_END
