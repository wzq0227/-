//
//  PushMsgManager.h
//  GosIPCs
//
//  Created by ShenYuanLuo on 2018/12/11.
//  Copyright © 2018年 goscam. All rights reserved.
//


/*
 推送消息管理器 类
 */


#import <Foundation/Foundation.h>
#import "PushMessage.h"

@interface PushMsgManager : NSObject

/**
 添加新推送
 
 @param pushMsg 推送消息 model
 @return 添加是否成功；YES：成功，NO：失败
 */
+ (BOOL)addPushMsg:(PushMessage *)pushMsg;


/**
 删除推送消息
 
 @param pushMsg 推送消息 model
 @return 删除是否成功；YES：成功，NO：失败
 */
+ (BOOL)rmvPushMsg:(PushMessage *)pushMsg;

/**
 删除某一设备所有推送消息
 
 @param deviceId 设备 ID
 */
+ (void)rmvPushMsgOfDevice:(NSString *)deviceId;


/**
 修改推送消息
 
 @param pushMsg 推送消息 model
 @return 更新是否成功；YES：成功，NO：失败
 */
+ (BOOL)modifyushMsg:(PushMessage *)pushMsg;


/**
 获取指定账号下的所有推送消息
 
 @return 推送消息列表
 */
+ (NSArray<PushMessage *>*)pushMsgList;


/**
 获取指定设备 ID 的所有推送
 
 @param deviceId 设备ID
 @return 推送消息列表
 */
+ (NSArray <PushMessage *>*)pushMsgListOfDevice:(NSString *)deviceId;

/*
 播放推送消息插入声音并震动手机（正在消息列表/消息详情页面时播放）
 */
+ (void)playInserMsgSound;

@end
