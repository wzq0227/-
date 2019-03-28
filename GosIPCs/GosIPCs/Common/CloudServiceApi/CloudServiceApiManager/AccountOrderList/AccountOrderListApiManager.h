//  AccountOrderListApiManager.h
//  CloudStoreSDK
//
//  Create by daniel.hu on 2018/12/11.
//  Copyright © 2018年 daniel. All rights reserved.

#import "GosApiBaseManager.h"

NS_ASSUME_NONNULL_BEGIN

/**
 @brief 用户购买记录
 @discussion
 request parameters: token, username
 
 @note reform data: NSArray<AccountOrderListApiModel> or @[]
 
 @note
 国内: http://cn-css.ulifecam.com/api/cloudstore/cloudstore-service/manage/service-list
 
 国外: http://css.ulifecam.com/api/cloudstore/cloudstore-service/manage/service-list
 
 @attention GET
 
 @code
 AccountOrderListApiManager *manager = [[AccountOrderListApiManager alloc] init];
 manager.delegate = self;
 // request
 [manager loadData];
 
 // fetch data
 NSArray *dataArray = [manager fetchDataWithReformer:manager];
 @endcode
 */
@interface AccountOrderListApiManager : GosApiBaseManager <GosApiManager, GosApiManagerDataReformer>
/// 可选请求类方法
+ (NSInteger)loadDataWithSuccess:(void (^ _Nullable)(GosApiBaseManager * _Nonnull apiManager))successCallback fail:(void (^ _Nullable)(GosApiBaseManager * _Nonnull apiManager))failCallback;
/// 请求方法
- (NSInteger)loadData;
@end

NS_ASSUME_NONNULL_END
