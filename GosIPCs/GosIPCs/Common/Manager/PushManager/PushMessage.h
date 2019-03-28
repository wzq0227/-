//
//  PushMessage.h
//  GosIPCs
//
//  Created by ShenYuanLuo on 2018/12/11.
//  Copyright © 2018年 goscam. All rights reserved.
//

#import <Foundation/Foundation.h>

/** 推送消息类型 */
typedef NS_ENUM(NSInteger, PushMsgType) {
    PushMsg_unknown                     = -1,       // 未知
    PushMsg_move                        = 0,        // 移动侦测
    PushMsg_guard                       = 1,        // 警戒
    PushMsg_pir                         = 2,        // PIR 侦测报警
    PushMsg_tempUpperLimit              = 3,        // 温度上限报警
    PushMsg_tempLowerLimit              = 4,        // 温度下限报警
    PushMsg_voice                       = 5,        // 声音报警
    PushMsg_bellRing                    = 6,        // 按铃
    PushMsg_lowBattery                  = 7,        // 低电量报警
    PushMsg_iotSensorLowBattery         = 8,        // IOT 设备低电报警
    PushMsg_iotSensorDoorOpen           = 9,        // IOT 设备开门报警
    PushMsg_iotSensorDoorClose          = 10,       // IOT 设备关门报警
    PushMsg_iotSensorDoorBreak          = 11,       // IOT 设备防拆报警
    PushMsg_iotSensorPirAlarm           = 12,       // IOT 设备 PIR 报警
    PushMsg_iotSensorSosAlarm           = 13,       // IOT 设备 SOS 报警
};


@interface PushMessage : NSObject  <
                                        NSCoding,
                                        NSCopying,
                                        NSMutableCopying
                                   >
@property (nonatomic, readwrite, assign) NSInteger serialNum;       // 序号
@property (nonatomic, readwrite, copy) NSString *account;           // 当前登录账号
@property (nonatomic, readwrite, copy) NSString *deviceId;          // 设备 ID
@property (nonatomic, readwrite, copy) NSString *deviceName;        // 设备昵称
@property (nonatomic, readwrite, copy) NSString *pushUrl;           // 推送 URL
@property (nonatomic, readwrite, copy) NSString *pushTime;          // 推送时间 yyyy-MM-dd HH:mm:ss
@property (nonatomic, readwrite, assign) BOOL hasReaded;            // 推送消息是否已读
@property (nonatomic, readwrite, assign) PushMsgType pmsgType;      // 推送消息类型

@end
