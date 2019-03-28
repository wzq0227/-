//  PayPackageTypesApiManager.h
//  CloudStoreSDK
//
//  Create by daniel.hu on 2018/12/11.
//  Copyright © 2018年 daniel. All rights reserved.

#import "GosApiBaseManager.h"

NS_ASSUME_NONNULL_BEGIN

/**
 @brief 付费套餐种类
 @discussion
 request parameters: token, username
 
 @note reform data: NSArray<PayPackageTypesApiRespModel> or @[]
 
 @note
 国内: http://cn-css.ulifecam.com/api/cloudstore/cloudstore-service/plan
 
 国外: http://css.ulifecam.com/api/cloudstore/cloudstore-service/plan
 
 @attention POST
 
 @code
 PayPackageTypesApiManager *manager = [[PayPackageTypesApiManager alloc] init];
 manager.delegate = self;
 
 // request
 [manager loadData];
 
 // fetch data
 NSArray *dataArray = [manager fetchDataWithReformer:manager];
 @endcode
 */
@interface PayPackageTypesApiManager : GosApiBaseManager <GosApiManager, GosApiManagerDataReformer>
/// 可选请求类方法
+ (NSInteger)loadDataWithSuccess:(void (^)(GosApiBaseManager * _Nonnull))successCallback fail:(void (^)(GosApiBaseManager * _Nonnull))failCallback;
/// 请求
- (NSInteger)loadData;
@end

NS_ASSUME_NONNULL_END
