//  AddSensorViewModel.h
//  Goscom
//
//  Create by 匡匡 on 2019/1/8.
//  Copyright © 2019 goscam. All rights reserved.

#import <Foundation/Foundation.h>
@class IotSensorModel;
@class AddSensorTypeModel;

NS_ASSUME_NONNULL_BEGIN

@interface AddSensorViewModel : NSObject

/**
 处理列表数据
 
 @param iList 原始数组数据
 @return 新数组数据
 */
+ (NSArray <AddSensorTypeModel *>*)handleListDataWithArr:(NSArray<IotSensorModel*>*)iList;


/**
 删除IOT设备
 
 @param iotModel iot模型
 @param tableArr 原始table数组
 */
+ (void)deleteSensorWithIotModel:(IotSensorModel *) iotModel
                    withTableArr:(NSArray <AddSensorTypeModel *>*) tableArr;


/**
 添加IOT设备
 
 @param iotModel iot模型
 @param tableArr 原始table数组
 */
+ (void)addSensorWithIotModel:(IotSensorModel *) iotModel
                 withTableArr:(NSArray <AddSensorTypeModel *>*) tableArr;
@end

NS_ASSUME_NONNULL_END
