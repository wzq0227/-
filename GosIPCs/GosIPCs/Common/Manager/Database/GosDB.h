//
//  GosDB.h
//  GosIPCs
//
//  Created by ShenYuanLuo on 2018/11/25.
//  Copyright © 2018年 goscam. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "iOSConfigSDK.h"
#import "PushMessage.h"

@interface GosDB : NSObject

/*
 关闭数据库
 */
+ (void)closeDB;

#pragma mark - 用户管理


#pragma mark - 设备管理
/**
 添加设备数据 model
 
 @param device 设备数据 model
 @param account 添加到哪个账号
 @return 添加是否成功；YES：成功，NO：失败
 */
+ (BOOL)addDevice:(DevDataModel *)device
        toAccount:(NSString *)account;

/**
 删除设备数据 model
 
 @param device 设备数据 model
 @param account 从哪个账号删除
 @return 删除是否成功；YES：成功，NO：失败
 */
+ (BOOL)delDevice:(DevDataModel *)device
      fromAccount:(NSString *)account;

/**
 修改设备数据 model
 
 @param device 设备数据 model
 @param account 修改哪个账号下的设备
 @return 修改是否成功；YES：成功，NO：失败
 */
+ (BOOL)updateDevice:(DevDataModel *)device
           onAccount:(NSString *)account;

/**
 获取用户设备列表
 
 @param account 账号
 @return 符合条件的 设备 model 数组
 */
+ (NSArray<DevDataModel *>*)deviceListOfAccount:(NSString *)account;



#pragma mark - 消息管理
/**
 添加推送消息数据 model
 
 @param pushMsg 推送消息数据 model
 @param account 添加到哪个账号
 @return 添加是否成功；YES：成功，NO：失败
 */
+ (BOOL)addPushMsg:(PushMessage *)pushMsg
         toAccount:(NSString *)account;

/**
 删除推送消息数据 model
 
 @param pushMsg 推送消息数据 model
 @param account 从哪个账号删除
 @return 删除是否成功；YES：成功，NO：失败
 */
+ (BOOL)delPushMsg:(PushMessage *)pushMsg
       fromAccount:(NSString *)account;

/**
 删除指定设备所有推送消息数据 model
 
 @param deviceId 设备 ID
 @param account 从哪个账号删除
 @return 删除是否成功；YES：成功，NO：失败
 */
+ (BOOL)delAllPushMsgOfDevice:(NSString *)deviceId
                  fromAccount:(NSString *)account;

/**
 修改推送消息数据 model
 
 @param pushMsg 推送消息数据 model
 @param account 修改哪个账号下的消息
 @return 修改是否成功；YES：成功，NO：失败
 */
+ (BOOL)updatePushMsg:(PushMessage *)pushMsg
            onAccount:(NSString *)account;

/**
 获取推送消息列表
 
 @param account 账号
 @return 符合条件的 推送消息 model 数组
 */
+ (NSArray<PushMessage *>*)pushMsgListOfAccount:(NSString *)account;

/**
 获取指定设备所有推送消息列表
 
 @param deviceId 设备 ID
 @param account 账号
 @return 符合条件的 推送消息 model 数组
 */
+ (NSArray<PushMessage *>*)pushMsgListWithDevice:(NSString *)deviceId
                                       ofAccount:(NSString *)account;

#pragma mark - 能力集管理
/*
 添加设备能力集
 
 @param ability 设备能力集，参见‘AbilityModel’
 @return 添加是否成功；YES：成功，NO：失败
 */
+ (BOOL)addDevAbility:(AbilityModel *)ability;

/*
 删除设备能力集
 
 @param ability 设备能力集，参见‘AbilityModel’
 @return 删除是否成功；YES：成功，NO：失败
 */
+ (BOOL)delDevAbility:(AbilityModel *)ability;

/*
 获取设备能力集
 
 @param deviceId 设备 ID
 @return 指定设备（ID）的能力集，参见‘AbilityModel’
 */
+ (AbilityModel *)abilityOfDevice:(NSString *)deviceId;

/*
 获取账号下所有设备能力集列表
 
 #param account 账号
 @return 能力集列表
 */
+ (NSArray<AbilityModel*>*)abilityListOfAccount:(NSString *)account;

@end
