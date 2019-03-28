//  TokenCheckApiManager.h
//  GosIPCs
//
//  Create by daniel.hu on 2018/12/24.
//  Copyright © 2018年 goscam. All rights reserved.

#import "GosApiBaseManager.h"

NS_ASSUME_NONNULL_BEGIN
/**
 @brief 获取云存储TOKEN
 @discussion
 request parameters: token, username, device_id
 
 @note reform data: TokenCheckApiRespModel or nil
 
 @note
 国内: http://cn-css.ulifecam.com/api/cloudstore/cloudstore-service/sts/check-token
 
 国外: http://css.ulifecam.com/api/cloudstore/cloudstore-service/sts/check-token
 
 @attention POST
 
 @code
 TokenCheckApiManager *manager = [[TokenCheckApiManager alloc] init];
 manager.delegate = self;
 
 // request
 [manager loadDataWithDeviceId:@"1"];
 
 // fetch data, result maybe nil
 TokenCheckApiRespModel *result = [manager fetchDataWithReformer:manager];
 @endcode
 */
@interface TokenCheckApiManager : GosApiBaseManager <GosApiManager, GosApiManagerDataReformer>
/// 可选请求类方法
+ (NSInteger)loadDataWithDeviceId:(NSString *_Nonnull)deviceId success:(void (^ _Nullable)(GosApiBaseManager * _Nonnull apiManager))successCallback fail:(void (^ _Nullable)(GosApiBaseManager * _Nonnull apiManager))failCallback;
/// 必须使用此方法请求
- (NSInteger)loadDataWithDeviceId:(NSString *)deviceId;

@end

NS_ASSUME_NONNULL_END
