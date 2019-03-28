//
//  MainSettingViewModel.h
//  Goscom
//
//  Created by 匡匡 on 2018/11/27.
//  Copyright © 2018 goscam. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "iOSConfigSDKDefine.h"
@class DevDataModel;
@class AbilityModel;
@class AllParamModel;
@class NightVisionModel;
@class IotSensorModel;
@class IotSceneTask;
@class PackageValidTimeApiRespModel;
NS_ASSUME_NONNULL_BEGIN

@interface MainSettingViewModel : NSObject

/**
 根据能力集得到cell数据数组
 @param abilityModel  能力数据
 @param devDataModel  设备模型
 */
+ (NSArray <NSMutableArray *> *)handleTableDataModel:(AbilityModel *) abilityModel
                                         devDataModel:(DevDataModel *) devDataModel;

/**
 返回设置界面的开关状态
 @param allParamModel  状态开关集
 @param tableDataArr   数据数组
 */
+ (NSArray *)updateTableDataArr:(NSArray *)tableDataArr
                  allParamModel:(AllParamModel *)allParamModel;


/**
 更新云储存显示:剩余时间或未购买

 @param tableDataArr 原始table数组
 @param packageCloudModel 云套餐模型
 */
+ (void)updateValidCloudSerVice:(NSArray *) tableDataArr
               packageCloudModel:(PackageValidTimeApiRespModel *) packageCloudModel;

/**
 是否支持情景任务(如果有声光报警器，则支持)

 @param IotSensorArr IOT数组用于查询是否有声光报警器
 @param tableArr 原始数组
 @param devDataModel 原始数据模型(是否分享权限或主权限)
 */
+ (void)hasSensorTaskModel:(NSArray<IotSensorModel *>*)IotSensorArr
               tableDataArr:(NSArray <NSMutableArray *> *) tableArr
               devDataModel:(DevDataModel *) devDataModel;

/**
 更新设置界面显示数据
 
 @param tableDataArr 设置界面数组数据
 @param nightVisionModel 夜视开关模型
 */
+ (void)updateNightVersionWithDataArr:(NSArray *) tableDataArr
                      nightVisionModel:(NightVisionModel *) nightVisionModel;

//+ (void)reductSwitchState:(SwitchType)switchType;

+ (NSArray <NSMutableArray *> *)getDefaultAbilityDevModel:(DevDataModel *)devModel;

@end

NS_ASSUME_NONNULL_END
