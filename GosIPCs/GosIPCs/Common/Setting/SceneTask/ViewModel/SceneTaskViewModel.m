//  SceneTaskViewModel.m
//  Goscom
//
//  Create by 匡匡 on 2018/12/27.
//  Copyright © 2018 goscam. All rights reserved.

#import "SceneTaskViewModel.h"
#import "iOSConfigSDKModel.h"
#import "SceneTaskModel.h"
@implementation SceneTaskViewModel
#pragma mark - 处理情景任务(是否选中、任务或条件)
+ (NSArray<SceneTaskModel *>*)handleSceneTask:(NSArray<IotSensorModel *>*) sensorArr
                                 iotSceneTask:(IotSceneTask *) iotSceneTask
                                       isTask:(BOOL) isTask{
    if (!sensorArr || sensorArr.count <1 || !iotSceneTask) {
        return @[];
    }
    __block NSMutableArray * dataArr = [[NSMutableArray alloc] init];
    [sensorArr enumerateObjectsUsingBlock:^(IotSensorModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        SceneTaskModel * model = [[SceneTaskModel alloc] init];
        model.iotSensorType = obj.iotSensorType;
        model.iotSensorId = obj.iotSensorId;
        model.iotSensorName = obj.iotSensorName;
        model.isAPNSOpen = obj.isAPNSOpen;
        model.isSceneOpen = obj.isAPNSOpen;
        model.select = NO;
        if (isTask && obj.iotSensorType == GosIot_sensorAudibleAlarm) {
            [dataArr addObject:model];
        }
        if(!isTask && obj.iotSensorType != GosIot_sensorAudibleAlarm){
            [dataArr addObject:model];
        }
    }];
    
    [dataArr enumerateObjectsUsingBlock:^(SceneTaskModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (isTask) {
            [iotSceneTask.carryoutList enumerateObjectsUsingBlock:^(IotSensorModel * _Nonnull newObj, NSUInteger newIdx, BOOL * _Nonnull newStop) {
                if ([obj.iotSensorId isEqual:newObj.iotSensorId]) {
                    obj.select = YES;
                }
            }];
        }else{
            [iotSceneTask.satisfyList enumerateObjectsUsingBlock:^(IotSensorModel * _Nonnull newObj, NSUInteger newIdx, BOOL * _Nonnull newStop) {
                if ([obj.iotSensorId isEqual:newObj.iotSensorId]) {
                    obj.select = YES;
                }
            }];
        }
    }];
    return dataArr;
}

#pragma mark - 选择设备点击更改选中状态
+ (void)handleSelectTask:(SceneTaskModel *) taskModel
                tableArr:(NSArray<SceneTaskModel *>*) tableArr{
    if (!taskModel || !tableArr || tableArr.count <1) {
        return;
    }
    [tableArr enumerateObjectsUsingBlock:^(SceneTaskModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.iotSensorId isEqualToString:taskModel.iotSensorId]) {
            obj.select =! obj.select;
            *stop = YES;
        }
    }];
}

#pragma mark - 处理确认添加时IOT模型数组
+ (NSArray<IotSensorModel *>*)handleDoneSelectIOT:(NSArray<SceneTaskModel *>*) tableArr{
    if (!tableArr || tableArr.count <1) {
        return @[];
    }
    __block NSMutableArray * dataArr = [[NSMutableArray alloc] init];
    [tableArr enumerateObjectsUsingBlock:^(SceneTaskModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.isSelect) {
            IotSensorModel * model = [[IotSensorModel alloc] init];
            model.iotSensorType = obj.iotSensorType;
            model.iotSensorId = obj.iotSensorId;
            model.iotSensorName = obj.iotSensorName;
            model.isAPNSOpen = obj.isAPNSOpen;
            model.isSceneOpen = obj.isAPNSOpen;
            [dataArr addObject:model];
        }
    }];
    return dataArr;
}
@end
