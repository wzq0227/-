//
//  DeviceInfoViewModel.h
//  Goscom
//
//  Created by 匡匡 on 2018/11/27.
//  Copyright © 2018 goscam. All rights reserved.
//

#import <Foundation/Foundation.h>
@class DevInfoModel;
@class DevDataModel;
@class SdCardInfoModel;
@class DeviceInfoTypeModel;
NS_ASSUME_NONNULL_BEGIN

@interface DeviceInfoViewModel : NSObject

/**
 返回设备信息数组模型
 
 @param infoModel 设备信息模型
 @param devDataModel 设备模型
 @return 整理好的数组
 */
+ (NSArray <DeviceInfoTypeModel *>*)handleDeviceInfoModel:(DevInfoModel *) infoModel
                                             DevDataModel:(DevDataModel *) devDataModel;


/**
 返回设备信息数组模型(设备离线)

 @param devDataModel 已有数据模型
 @return 已有数据转化数组
 */
+ (NSArray <DeviceInfoTypeModel *>*)handleTableArrOFFLineModel:(DevDataModel *) devDataModel;
/**
 // 根据传进来的设备名修改整个模型 加可升级小红点
 //
 // @param dataArr 已有数据
 // @return 修改后的数组
 // */
+ (NSArray *)modifyModelData:(NSArray <DeviceInfoTypeModel *>*) dataArr;


/**
 格式化SD卡成功后修改SD卡数据显示
 
 @param dataArr 传进原来的TableData
 @param sdCardInfoModel 新SD卡模型信息
 @return 返回新的数组
 */
+ (NSArray *)modifyTFCardData:(NSArray *) dataArr
           andSdCardInfoModel:(SdCardInfoModel *) sdCardInfoModel;


/**
 修改设备名刷新数据
 
 @param tableArr 新设备列表数据
 */
+ (void)modifyDeviceName:(NSString *) deviceName
                tableArr:(NSArray <DeviceInfoTypeModel *>*) tableArr;

/**
 数据库查询设备名是否已存在
 
 @param haveName 需比较的名
 @return YES 存在 NO 不存在
 */
+ (BOOL)compareNameWithHaveName:(NSString *) haveName;
@end

NS_ASSUME_NONNULL_END
