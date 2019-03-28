//  SceneTaskViewModel.h
//  Goscom
//
//  Create by 匡匡 on 2018/12/27.
//  Copyright © 2018 goscam. All rights reserved.

#import <Foundation/Foundation.h>
@class IotSensorModel;
@class SceneTaskModel;
@class IotSceneTask;
NS_ASSUME_NONNULL_BEGIN

@interface SceneTaskViewModel : NSObject

/**
 处理情景任务的选择设备(是否选中、任务或条件)
 
 @param sensorArr IOT数组
 @param iotSceneTask 原始IOT模型
 @param isTask YES 为任务  NO 为条件
 @return 处理好的带选择的IOT数组
 */
+ (NSArray<SceneTaskModel *>*)handleSceneTask:(NSArray<IotSensorModel *>*)sensorArr
                                 iotSceneTask:(IotSceneTask *)iotSceneTask
                                       isTask:(BOOL)isTask;



/**
 选择设备点击更改选中状态
 
 @param taskModel 点击的IOT模型
 @param tableArr 原始Table数组
 */
+ (void)handleSelectTask:(SceneTaskModel *)taskModel
                tableArr:(NSArray<SceneTaskModel *>*)tableArr;



/**
 处理确认添加时IOT模型数组
 
 @param tableArr 原始table数组
 @return 接口需要的模型数组
 */
+ (NSArray<IotSensorModel *>*)handleDoneSelectIOT:(NSArray<SceneTaskModel *>*) tableArr;
@end

NS_ASSUME_NONNULL_END
