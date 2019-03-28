//  CloudServiceViewModel.h
//  Goscom
//
//  Create by 匡匡 on 2018/12/20.
//  Copyright © 2018 goscam. All rights reserved.

#import <Foundation/Foundation.h>
#import <iOSPaymentSDK/iOSPaymentSDK.h>
@class PayPackageTypesApiRespModel;
@class CloudServiceModel;
@class CloudOrderModel;
@class CloudOrderPayWayModel;
@class CloudOrderPayWayTypeModel;
NS_ASSUME_NONNULL_BEGIN

@interface CloudServiceViewModel : NSObject

/**
 初始化云录制套餐列表数组数据
 
 @param normalData 原来的数组
 @return 新数据
 */
+ (NSArray <CloudServiceModel *> *)initTableDataWithDataArr:(NSArray <PayPackageTypesApiRespModel *> *) normalData;


/**
 获取云录制套餐当前选中的模型
 
 @param tableArr 列表数组
 @return 选中模型
 */
+ (CloudServiceModel *)getCurrentSelectModel:(NSArray <CloudServiceModel *> *) tableArr;

/**
 修改选中的套餐
 
 @param selectModel 元时数组
 @param tableArr 新数组
 */
+(void) modifySelectState:(CloudServiceModel *)selectModel
             tableDataArr:(NSArray <CloudServiceModel *> *) tableArr;



/**
 初始化套餐订购界面数据
 
 @param dataModel 原始模型
 @return 数组数据
 */
+(NSArray <CloudOrderPayWayTypeModel *> *)initTableDataWithModel:(CloudServiceModel *) dataModel;


/**
 改变支付方式
 
 @param model 新支付方式模型
 @param payWayArr 支付方式数据数组
 */
+ (void)modifyPayWayWithModel:(CloudOrderPayWayModel *) model
                    payWayArr:(NSArray <CloudOrderPayWayModel *>*) payWayArr
                  paymentType:(GosPaymentType *) paymentType;

@end

NS_ASSUME_NONNULL_END
