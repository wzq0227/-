//
//  GosDevManager.h
//  GosIPCs
//
//  Created by shenyuanluo on 2018/11/24.
//  Copyright © 2018 goscam. All rights reserved.
//

/*
 设备管理器 类
 */

#import <Foundation/Foundation.h>
#import "iOSConfigSDK.h"
#import "iOSDevSDKDefine.h"

NS_ASSUME_NONNULL_BEGIN

@interface GosDevManager : NSObject

/**
 添加设备数据模型
 
 @param device 设备数据模型
 @return 添加是否成功；YES：成功，NO：失败
 */
+ (BOOL)addDevice:(DevDataModel *)device;

/**
 移除设备数据模型
 
 @param device 设备数据模型
 @return 移除是否成功；YES：成功，NO：失败
 */
+ (BOOL)delDevice:(DevDataModel *)device;

/**
 更新设备数据模型
 
 @param deviceModel 设备数据模型
 @return 更新是否成功；YES：成功，NO：失败
 */
+ (BOOL)updateDevice:(DevDataModel *)deviceModel;

/**
 根据设备 ID 获取设备数据模型
 
 @param deviceId 设备 ID
 @return 设备数据模型
 */
+ (DevDataModel *)devcieWithId:(NSString *)deviceId;

/**
 获取设备列表数据模型数组
 
 @return 列表数组
 */
+ (NSArray <DevDataModel *> *)deviceList;

/**
 同步设备列表数据（在设备列表界面获取时，用于数据库同步）
 
 @param devList 列表数组
 @return 同步是否成功；YES：成功，NO：失败
 */
+ (BOOL)synchDeviceList:(NSArray<DevDataModel*>*)devList;

/**
 更新设备连接状态
 
 @param deviceId 设备 ID
 @param connState 连接状态，参见‘DeviceConnState’
 */
+ (void)updateDevice:(NSString *)deviceId
         toConnState:(DeviceConnState)connState;

/**
 获取设备当前连接状态
 
 @param deviceId 设备 ID
 @return 设备连接状态，参见‘DeviceConnState’
 */
+ (DeviceConnState)connStateOfDevice:(NSString *)deviceId;

@end

NS_ASSUME_NONNULL_END
