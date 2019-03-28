//
//  DevAbilityManager.h
//  GosIPCs
//
//  Created by shenyuanluo on 2018/12/7.
//  Copyright © 2018 goscam. All rights reserved.
//

/*
 设备能力集管理类（自动缓存设备能力集）
 */

#import <Foundation/Foundation.h>
#import "iOSConfigSDK.h"

NS_ASSUME_NONNULL_BEGIN

/*
 添加设备能力集成功通知：@{@"DeviceID" : @"***"}
 */
static NSString * const kAddAbilityNotify = @"ABMAddAbilityNotify";
/*
 删除设备能力集成功通知：@{@"DeviceID" : @"***"}
 */
static NSString * const kRmvAbilityNotify = @"ABMRmvAbilityNotify";    

@interface DevAbilityManager : NSObject

/*
 添加设备能力集
 
 @param abModel 能力集信息模型
 */
+ (BOOL)addAbility:(AbilityModel *)abModel;

/*
 删除设备能力集
 
 @param devId 设备 ID
 */
+ (BOOL)rmvAbilityFromDevice:(NSString *)devId;

/*
 获取设备能力集
 
 @param devId 设备 ID
 @return 返回指定设备 ID 能力集，不存在则返回空
 */
+ (AbilityModel *)abilityOfDevice:(NSString *)devId;

/*
 获取账号所有设备能力集列表
 
 @return 能力集列表
 */
+ (NSArray<AbilityModel*>*)abilityList;

@end

NS_ASSUME_NONNULL_END
