//  GosNetworkingDefines.h
//  CloudStoreSDK
//
//  Create by daniel.hu on 2018/12/11.
//  Copyright © 2018年 daniel. All rights reserved.

#ifndef GosNetworkingDefines_h
#define GosNetworkingDefines_h

@class GosApiBaseManager;
@class GosURLResponse;
typedef NS_ENUM (NSUInteger, GosServiceApiTaskType) {
    GosServiceApiTaskTypeGeneral,   // 一般任务Api —— get, post, put, delete
    GosServiceApiTaskTypeDownload   // 下载任务Api —— download
};
typedef NS_ENUM (NSUInteger, GosServiceApiArea) {
    GosServiceApiAreaDomestic,  // 国内
    GosServiceApiAreaOverseas,  // 海外
};
typedef NS_ENUM (NSUInteger, GosServiceApiEnvironment){
    GosServiceApiEnvironmentDevelop,            // 开发中
    GosServiceApiEnvironmentReleaseCandidate,   // 准发布
    GosServiceApiEnvironmentRelease             // 发布版
};

typedef NS_ENUM (NSUInteger, GosApiManagerRequestType){
    GosApiManagerRequestTypePost,   // POST
    GosApiManagerRequestTypeGet,    // GET
    GosApiManagerRequestTypePut,    // PUT
    GosApiManagerRequestTypeDelete, // DELETE
};

typedef NS_ENUM (NSUInteger, GosApiManagerErrorType){
//    GosApiManagerErrorTypeNeedAccessToken, // 需要重新刷新accessToken
//    GosApiManagerErrorTypeNeedLogin,       // 需要登陆
    GosApiManagerErrorTypeDefault,         // 没有产生过Api请求，这个是manager的默认状态。
//    GosApiManagerErrorTypeLoginCanceled,   // 调用Api需要登陆态，弹出登陆页面之后用户取消登陆了
    GosApiManagerErrorTypeSuccess,         // Api请求成功且返回数据正确，此时manager的数据是可以直接拿来使用的。
    GosApiManagerErrorTypeServerFailed,    // Api请求成功且返回数据正确，但是结果是失败的
    GosApiManagerErrorTypeNoContent,       // Api请求成功但返回数据不正确。如果回调数据验证函数返回值为NO，manager的状态就会是这个。
    GosApiManagerErrorTypeParamsError,     // 参数错误，此时manager不会调用Api，因为参数验证是在调用Api之前做的。
    GosApiManagerErrorTypeTimeout,         // 请求超时。GosApiProxy设置的是20秒超时，具体超时时间的设置请自己去看GosApiProxy的相关代码。
    GosApiManagerErrorTypeNoNetWork,       // 网络不通。在调用Api之前会判断一下当前网络是否通畅，这个也是在调用Api之前验证的，和上面超时的状态是有区别的。
    GosApiManagerErrorTypeCanceled,        // 取消请求
    GosApiManagerErrorTypeNoError,         // 无错误
    GosApiManagerErrorTypeDownGrade,       // ApiManager被降级了
};





/**
 GosApiBaseManager的子类或者使用者，必须遵循此代理
 */
@protocol GosApiManager <NSObject>
@required
- (NSString *_Nonnull)methodName;
- (NSString *_Nonnull)serviceIdentifier;
- (GosApiManagerRequestType)requestType;

@optional
- (nullable void (^) (NSProgress *_Nonnull progress))uploadProcess;
- (nullable void (^) (NSProgress *_Nonnull progress))downloadProcess;
- (nullable NSURL *_Nonnull (^) (NSURL *_Nonnull targetPath, NSURLResponse *_Nonnull response))destination;
- (NSDictionary *_Nullable)reformParams:(NSDictionary *_Nullable)params;
- (NSInteger)loadDataWithParams:(NSDictionary *_Nullable)params;
- (void)cleanData;

@end


/**
 拦截处理
 */
@protocol GosApiManagerInterceptor <NSObject>
@optional
- (BOOL)manager:(GosApiBaseManager *_Nonnull)manager beforePerformSuccessWithResponse:(GosURLResponse *_Nonnull)response;
- (void)manager:(GosApiBaseManager *_Nonnull)manager afterPerformSuccessWithResponse:(GosURLResponse *_Nonnull)response;

- (BOOL)manager:(GosApiBaseManager *_Nonnull)manager beforePerformFailWithResponse:(GosURLResponse *_Nonnull)response;
- (void)manager:(GosApiBaseManager *_Nonnull)manager afterPerformFailWithResponse:(GosURLResponse *_Nonnull)response;

- (BOOL)manager:(GosApiBaseManager *_Nonnull)manager shouldCallApiWithParams:(NSDictionary *_Nullable)params;
- (void)manager:(GosApiBaseManager *_Nonnull)manager afterCallingApiWithParams:(NSDictionary *_Nullable)params;
- (void)manager:(GosApiBaseManager *_Nonnull)manager didReceiveResponse:(GosURLResponse *_Nullable)response;

@end


/**
 回调代理
 */
@protocol GosApiManagerCallBackDelegate <NSObject>
@required
- (void)managerCallApiDidSuccess:(GosApiBaseManager *_Nonnull)manager;
- (void)managerCallApiDidFailed:(GosApiBaseManager *_Nonnull)manager;
@end

/**
 数据优化者
 */
@protocol GosApiManagerDataReformer <NSObject>
- (id _Nullable)manager:(GosApiBaseManager *_Nonnull)manager reformData:(NSDictionary *_Nullable)data;

@end


/**
 校验数据
 */
@protocol GosApiManagerValidator <NSObject>
@required
- (GosApiManagerErrorType)manager:(GosApiBaseManager *_Nonnull)manager isCorrectWithCallBackData:(NSDictionary *_Nullable)data;
- (GosApiManagerErrorType)manager:(GosApiBaseManager *_Nonnull)manager isCorrectWithParamsData:(NSDictionary *_Nullable)data;
@end


/**
 获取参数字典
 */
@protocol GosApiManagerParamSource <NSObject>
@required
- (NSDictionary *_Nullable)paramsForApi:(GosApiBaseManager *_Nonnull)manager;

@end



#endif /* GosNetworkingDefines_h */
