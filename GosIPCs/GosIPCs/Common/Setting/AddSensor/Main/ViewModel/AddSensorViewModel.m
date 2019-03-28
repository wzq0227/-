//  AddSensorViewModel.m
//  Goscom
//
//  Create by 匡匡 on 2019/1/8.
//  Copyright © 2019 goscam. All rights reserved.

#import "AddSensorViewModel.h"
#import "iOSConfigSDKModel.h"
#import "AddSensorTypeModel.h"
#import "iOSConfigSDKDefine.h"
@implementation AddSensorViewModel
#pragma mark - 处理列表数据
+ (NSArray <AddSensorTypeModel *>*)handleListDataWithArr:(NSArray<IotSensorModel*>*)iList{
    // 门磁
    AddSensorTypeModel * magneticModel = [[AddSensorTypeModel alloc] init];
    magneticModel.sectionStr = DPLocalizedString(@"Setting_Magnetic");
    magneticModel.gosIOTType = GosIot_sensorMagnetic;
    // 红外
    AddSensorTypeModel * infraredModel = [[AddSensorTypeModel alloc] init];
    infraredModel.sectionStr = DPLocalizedString(@"Setting_Infrared");
    infraredModel.gosIOTType = GosIot_sensorInfrared;
    // SOS
    AddSensorTypeModel * sosModel = [[AddSensorTypeModel alloc] init];
    sosModel.sectionStr = DPLocalizedString(@"Setting_Sos");
    sosModel.gosIOTType = GosIot_sensorSOS;
    // 声光报警
    AddSensorTypeModel * alarmModel = [[AddSensorTypeModel alloc] init];
    alarmModel.sectionStr = DPLocalizedString(@"Setting_AudibleAlarm");
    alarmModel.gosIOTType = GosIot_sensorAudibleAlarm;
    
    [iList enumerateObjectsUsingBlock:^(IotSensorModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        switch (obj.iotSensorType) {
            case GosIot_sensorMagnetic:{        // 传感器-‘门磁’
                [magneticModel.sectionArr addObject:obj];
            }break;
            case GosIot_sensorInfrared:{        // 传感器-’红外‘
                [infraredModel.sectionArr addObject:obj];
            }break;
            case GosIot_sensorAudibleAlarm:{    // 传感器-’声光报警‘
                [alarmModel.sectionArr addObject:obj];
            }break;
            case GosIot_sensorSOS:{             // // 传感器-‘SOS’
                [sosModel.sectionArr addObject:obj];
            }break;
            default:
                break;
        }
    }];
    return @[magneticModel,infraredModel,sosModel,alarmModel];
}

#pragma mark - 删除IOT设备
+ (void)deleteSensorWithIotModel:(IotSensorModel *) iotModel
                    withTableArr:(NSArray <AddSensorTypeModel *>*) tableArr{
    if (!iotModel || !tableArr || tableArr.count <1) {
        return;
    }
    [tableArr enumerateObjectsUsingBlock:^(AddSensorTypeModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj.sectionArr enumerateObjectsUsingBlock:^(IotSensorModel * _Nonnull xobj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([iotModel isEqual:xobj]) {
                [obj.sectionArr removeObject:xobj];
                *stop = YES;
            }
        }];
    }];
}

#pragma mark - 添加IOT设备
+ (void)addSensorWithIotModel:(IotSensorModel *) iotModel
                 withTableArr:(NSArray <AddSensorTypeModel *>*) tableArr{
    if (!iotModel) {
        return;
    }
    [tableArr enumerateObjectsUsingBlock:^(AddSensorTypeModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.gosIOTType == iotModel.iotSensorType) {
            [obj.sectionArr addObject:iotModel];
            *stop = YES;
        }
    }];
}
@end
