//
//  ExtractDevIdInfo.h
//  GosIPCs
//
//  Created by shenyuanluo on 2018/12/4.
//  Copyright © 2018 goscam. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GosPlatformDevIdDefine.h"

NS_ASSUME_NONNULL_BEGIN

/*
 根据设备 ID 提取平台 ID 域（前 8 位字符）信息 类
 */

@interface ExtractDevIdInfo : NSObject

/*
 获取设备 ID 区域类型
 
 @param deviceId 设备 ID
 @return ID 区域类型
 */
+ (GosPIDAreaType)areaTypeOfDevId:(NSString *)deviceId;

/*
 获取设备 ID 客户类型
 
 @param deviceId 设备 ID
 @return ID 客户类型
 */
+ (GosPIDAgentType)agentTypeOfDevId:(NSString *)deviceId;

/*
 获取设备 ID 设备类型
 
 @param deviceId 设备 ID
 @return ID 设备类型
 */
+ (GosPIDDevType)deviceTypeOfDevId:(NSString *)deviceId;

/*
 获取设备 ID 媒体服务器类型
 
 @param deviceId 设备 ID
 @return ID 媒体服务器类型
 */
+ (GosPIDMediaServerType)mediaServerTypeOfDevId:(NSString *)deviceId;

@end

NS_ASSUME_NONNULL_END
