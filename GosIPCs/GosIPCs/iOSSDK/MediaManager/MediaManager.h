//
//  MediaManager.h
//  MediaManager
//
//  Created by shenyuanluo on 2017/7/20.
//  Copyright © 2017年 goscam. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "MediaHeader.h"
#import "MediaFileModel.h"




@interface MediaManager : NSObject

/**
 获取媒体文件保存路径

 @param deviceId 设备 ID
 @param fileName 文件名，为空则使用默认名字（最后一帧图片：Cover；拍照：时间戳（yyyyMMddHHmmss）；录像：时间戳（yyyyMMddHHmmss））
 @param mediaType 文件类型，参见‘MediaType’
 @param deviceType 设备类型，参见‘DeviceType’
 @param position 画面位置，参见‘PositionType’
 @return 沙盒绝对路径，失败时返回 nil
 */
+ (NSString *)pathWithDevId:(NSString *)deviceId
                   fileName:(NSString *)fileName
                  mediaType:(GosMediaType)mediaType
                 deviceType:(GosDeviceType)deviceType
                   position:(PositionType)position;


/**
 获取视频最后一帧图片（封面）

 @param deviceId 设备 ID
 @param fileName 文件名，为空则使用默认名字（最后一帧图片：Cover）
 @param deviceType 设备类型，参见‘DeviceType’
 @param position 画面位置，参见‘PositionType’
 @return 图片实例
 */
+ (UIImage *)coverWithDevId:(NSString *)deviceId
                   fileName:(NSString *)fileName
                 deviceType:(GosDeviceType)deviceType
                   position:(PositionType)position;

/**
 获取推送消息图片（推送图片不存在时，默认返回封面）
 
 @param deviceId 设备 ID
 @param fileName 文件名
 @param deviceType 设备类型，参见‘DeviceType’
 @param position 画面位置，参见‘PositionType’
 @param isExist 是否存在推送图片；YES：存在，NO：不存在
 @return 图片实例
 */
+ (UIImage *)pushImageWithDevId:(NSString *)deviceId
                       fileName:(nonnull NSString *)fileName
                     deviceType:(GosDeviceType)deviceType
                       position:(PositionType)position
                          exist:(BOOL*)isExist;



/**
 获取媒体文件列表

 @param deviceId 设备 ID (暂用 TUTK 平台 ID)
 @param mediaType 媒体文件类型，参见‘MediaType’
 @param deviceType 设备类型，参见‘DeviceType’
 @param position 画面位置，参见‘PositionType’
 @return 文件列表
 */
+ (NSMutableArray <MediaFileModel *>*)mediaListWithDevId:(NSString *)deviceId
                                               mediaType:(GosMediaType)mediaType
                                              deviceType:(GosDeviceType)deviceType
                                                position:(PositionType)position;
/**
 清空指定设备缓存（注意：这将会删除设备所有的文件，慎用）
 
 @param deviceId 设备 ID
 @param devType 设备类型，参见‘GosDeviceType’
 */
+ (BOOL)cleanOfDevice:(NSString *)deviceId
           deviceType:(GosDeviceType)devType;

/**
 清空（所有）缓存（注意：这将会删除所有的文件，慎用）
 */
+ (BOOL)cleanAll;

@end
