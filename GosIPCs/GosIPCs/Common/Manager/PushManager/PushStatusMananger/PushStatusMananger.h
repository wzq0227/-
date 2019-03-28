//
//  PushStatusMananger.h
//  GosIPCs
//
//  Created by shenyuanluo on 2018/12/19.
//  Copyright © 2018 goscam. All rights reserved.
//


/*
 推送状态管理器 类
 */

#import <Foundation/Foundation.h>
#import "iOSConfigSDK.h"

NS_ASSUME_NONNULL_BEGIN

@interface PushStatusMananger : NSObject

/*
 添加设备推送状态 Model
 
 @param dpsModel 推送状态，参见‘DevPushStatusModel’
 @return 添加是否成功；YES：成功，NO：失败
 */
+ (BOOL)addPushStatusModel:(DevPushStatusModel *)dpsModel;

/*
 移除设备推送状态 Model
 
 @param devId 设备 ID
 @return 移除是否成功；YES：成功，NO：失败
 */
+ (BOOL)rmvPushStatusWithDevId:(NSString *)devId;

/*
 获取某一设备推送状态 Model
 
 @param devId 设备 ID
 */
+ (DevPushStatusModel *)pushModelOfDevice:(NSString *)devId;

/*
 获取所有设备推送状态列表
 
 @return 推送状态列表
 */
+ (NSArray<DevPushStatusModel*>*)pushStatusList;

/*
 更新设备推送状态 Model
 
 @param dpsModel 设备推送状态，参见‘DevPushStatusModel’
 @return 更新是否成功；YES：成功，NO：失败
 */
+ (BOOL)updatePushStatus:(DevPushStatusModel *)dpsModel;

/*
 清空管理器（账号注销时）
 @return 清空是否成功；YES：成功，NO：失败
 */
+ (BOOL)cleanMananger;

/*
 通知已查询完成
 */
+ (void)notifyHasChecked;

/*
 是否已查询所有设备推送状态（保证只查询一次，避免多次请求）
 
 @return 是否已查询；YES：已查询，NO：未查询
 */
+ (BOOL)hasChecked;

@end

NS_ASSUME_NONNULL_END
