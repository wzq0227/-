//
//  iOSConfigSDKModel.h
//  iOSConfigSDK
//
//  Created by shenyuanluo on 2018/3/15.
//  Copyright © 2018年 goscam. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "iOSConfigSDKDefine.h"

@interface iOSConfigSDKModel : NSObject

@end


/*
 新添加设备能力集，如果设备没有上传，则使用默认能力集
 
 注意：由于使用 Runtime 解析，所以 Property 定义顺序要按照 devCap[64] 的顺序定义
 */
@interface DeviceCapacity : NSObject <
                                        NSCoding,
                                        NSCopying,
                                        NSMutableCopying
                                     >

@property (nonatomic, readwrite, assign) PlatformType platformType;         // 平台类型
@property (nonatomic, readwrite, assign) StreamStoreType streamStoreType;   // 流存储类型
@property (nonatomic, readwrite, assign) DuplexType duplexType;             // 全双工类型
@property (nonatomic, readwrite, assign) MultiSplitType multiSplitType;     // 一拖多类型
@property (nonatomic, readwrite, assign) AudioEncodeType audioEncodeType;   // 音频编码类型

+ (instancetype)capWithString:(NSString *)capStr;

@end


/** 在线状态 数据模型类 */
@interface DevStatusModel : NSObject <
                                        NSCoding,
                                        NSCopying,
                                        NSMutableCopying
                                     >
/** 设备ID */
@property (nonatomic, readwrite, copy) NSString *DeviceId;
/** 设备在线状态标识 */
@property (nonatomic, readwrite, assign) DevStatusType Status;
@end


/**
 设备 数据模型类
 注意：已重写 ‘isEqual’ 方法，在此认为-如果两个 ID 相同，则两个设备数据【相等】
 */
@interface DevDataModel : DevStatusModel <
                                            NSCoding,
                                            NSCopying,
                                            NSMutableCopying
                                         >
/** 设备昵称 */
@property (nonatomic, readwrite, copy) NSString *DeviceName;
/** 拥有者标识 */
@property (nonatomic, readwrite, assign) DevOwnType DeviceOwner;
/** 设备类型标识 */
@property (nonatomic, readwrite, assign) DeviceType DeviceType;
/** 设备推送状态 */
//@property (nonatomic, readwrite, assign) DevPushStatus pushStatus;
/** 所属区域 ID */
@property (nonatomic, readwrite, copy) NSString *AreaId;
/** 新版能力集集合 */
@property (nonatomic, readwrite, copy) NSString *DeviceCap;
/** 设备硬件版本号 */
@property (nonatomic, readwrite, copy) NSString *DeviceHdwVer;
/** 设备软件版本号 */
@property (nonatomic, readwrite, copy) NSString *DeviceSfwVer;
/** 取流用户名 */
@property (nonatomic, readwrite, copy) NSString *StreamUser;
/** 取流密码 */
@property (nonatomic, readwrite, copy) NSString *StreamPassword;
/** 设备能力集（新版） */
@property (nonatomic, strong) DeviceCapacity    *devCapacity;
@end


/** TF 卡某月录制文件数据模型类 */
@interface RecMonthDataModel : NSObject <
                                            NSCoding,
                                            NSCopying,
                                            NSMutableCopying
                                        >
/** 日期（格式：yyyy/MM/dd) */
@property (nonatomic, readwrite, copy) NSString *dateStr;
/** （某日）录像文件总数 */
@property (nonatomic, readwrite, assign) NSInteger count;
@end


/**
 TF 卡某日录制媒体文件数据模型类
 注意：已重写 ‘isEqual’ 方法，在此认为-如果两个 ’设备 ID‘、‘文件名’、‘事件类型’、‘告警类型’ 相同，则两个媒体文件数据【相等】
 */
@interface TFMediaFileModel : NSObject <
                                        NSCoding,
                                        NSCopying,
                                        NSMutableCopying
                                      >
/** 设备 ID */
@property (nonatomic, readwrite, copy) NSString *DeviceId;
/** 文件类型 */
@property (nonatomic, readwrite, assign) TFMediaFileType fileType;
/** TF 卡媒体文件触发录制类型 */
@property (nonatomic, readwrite, assign) TFMediaRecType recType;
/** TF 卡媒体文件触发告警类型 */
@property (nonatomic, readwrite, assign) TFMediaAlarmType alarmType;
/** TF 卡媒体文件名称 */
@property (nonatomic, readwrite, copy) NSString *fileName;
/** TF 卡媒体文件 '显示名称‘ 20190108213846.mp4 | 20190108213846.jpg */
@property (nonatomic, readwrite, copy) NSString *showName;
/** TF 卡媒体文件日期（格式：yyyy/MM/dd HH:mm:ss） */
@property (nonatomic, readwrite, copy) NSString *fileDate;
/** TF 卡媒体文件大小 */
@property (nonatomic, readwrite, assign) long fileSize;
/** TF 卡媒体文件时长（如果是图片，则默认同视频大小） */
@property (nonatomic, readwrite, assign) NSInteger duration;
@end


/** SD 卡告警数据模型类 */
@interface SDAlarmDataModel : NSObject <
                                        NSCoding,
                                        NSCopying,
                                        NSMutableCopying
                                       >
@property (nonatomic, readwrite, assign) NSInteger AT;
@property (nonatomic, readwrite, assign) NSInteger E;
@property (nonatomic, readwrite, assign) NSInteger S;
@end


/** 设备能力集 数据模型类 */
@interface AbilityModel : NSObject <
                                    NSCoding,
                                    NSCopying,
                                    NSMutableCopying
                                   >
@property (nonatomic, readwrite, copy) NSString *DeviceId;                      // 设备 ID
@property (nonatomic, readwrite, assign) BOOL hasPTZ;                           // 云台控制
@property (nonatomic, readwrite, assign) BOOL hasSpeaker;                       // 扬声器
@property (nonatomic, readwrite, assign) BOOL hasMic;                           // 麦克风
@property (nonatomic, readwrite, assign) BOOL hasMicSwitch;                     // 麦克风开关(控制)
@property (nonatomic, readwrite, assign) BOOL hasCameraSwitch;                  // 摄像头开关(控制)
@property (nonatomic, readwrite, assign) BOOL hasStatusLamp;                    // 状态指示灯
@property (nonatomic, readwrite, assign) BOOL hasMotionDetect;                  // 运动检测
@property (nonatomic, readwrite, assign) BOOL hasVoiceDetect;                   // 声音侦测
@property (nonatomic, readwrite, assign) BOOL hasPIR;                           // PIR 侦测
@property (nonatomic, readwrite, assign) BOOL hasTemDetect;                     // 温度探测
@property (nonatomic, readwrite, assign) BOOL hasNightVision;                   // 夜视
@property (nonatomic, readwrite, assign) BOOL hasLamp;                          // 照明灯
@property (nonatomic, readwrite, assign) BOOL hasSdCardSlot;                    // SD 卡槽（有，支持录像；否则，不支持）
@property (nonatomic, readwrite, assign) BOOL hasBattery;                       // 电量显示
@property (nonatomic, readwrite, assign) BOOL hasNetSignal;                     // 中继器和路由之间信号
@property (nonatomic, readwrite, assign) BOOL hasStreamPwd;                     // 设置摄像头密码
@property (nonatomic, readwrite, assign) BOOL hasAlexa;                         // Alexa 功能
@property (nonatomic, readwrite, assign) SupportIotSensorType iotSensorType;    // 支持‘IOT-传感器'类型
@property (nonatomic, readwrite, assign) LullabyDevType lullabyDevType;         // 支持摇篮曲设备系列
@end


/** 设备 SD 卡信息 数据模型类 */
@interface SdCardInfoModel : NSObject <
                                        NSCoding,
                                        NSCopying,
                                        NSMutableCopying
                                      >
@property (nonatomic, readwrite, assign) BOOL hasInsert;                // 是否插入 SD 卡
@property (nonatomic, readwrite, assign) NSUInteger totalSize;          // SD 卡总容量（单位：MB）
@property (nonatomic, readwrite, assign) NSUInteger usedSize;           // SD 卡已使用容量（单位：MB）
@property (nonatomic, readwrite, assign) NSUInteger freeSize;           // SD 卡剩余容量（单位：MB）
@end


/** 设备信息 数据模型类 */
@interface DevInfoModel : NSObject  <
                                        NSCoding,
                                        NSCopying,
                                        NSMutableCopying
                                    >
@property (nonatomic, readwrite, copy) NSString *swVersion;         // 软件版本
@property (nonatomic, readwrite, copy) NSString *hwVersion;         // 硬件版本
@property (nonatomic, readwrite, copy) NSString *devType;           // 设备类型
@property (nonatomic, readwrite, copy) NSString *devId;             // 设备 ID
@property (nonatomic, readwrite, copy) NSString *gatewayVersion;    // 网关版本
@property (nonatomic, readwrite, copy) NSString *wifiSSID;          // 设备连接的 WiFi 名称
@property (nonatomic, readwrite, assign) int Hz;                    // 防闪烁频率（0：表示自动）
@property (nonatomic, readwrite, assign) BOOL hasInsertSd;          // 是否插入 SD 卡
@property (nonatomic, readwrite, strong) SdCardInfoModel *sdInfo;   // SD 卡信息
@end


/** 设备所有属性 数据模型类 */
@interface AllParamModel : NSObject <
                                        NSCoding,
                                        NSCopying,
                                        NSMutableCopying
                                    >
@property (nonatomic, readwrite, assign) VideoMode videMode;            // 视频模式
@property (nonatomic, readwrite, assign) BOOL isManualRecOn;            // 手动录像开关
@property (nonatomic, readwrite, assign) BOOL isPirDetectOn;            // PIR 侦测开关
@property (nonatomic, readwrite, assign) int pirDetectLevel;            // PIR 侦测敏感度
@property (nonatomic, readwrite, assign) BOOL isAudioAlarmOn;           // 声音报警开关
@property (nonatomic, readwrite, assign) DetectLevel audioAlarmLevel;   // 声音报警敏感度
@property (nonatomic, readwrite, assign) BOOL isMotionDetectOn;         // 运动侦测开关
@property (nonatomic, readwrite, assign) DetectLevel motionLevel;       // 运动侦测敏感度
@property (nonatomic, readwrite, assign) BOOL isCameraOn;               // 摄像头开关
@property (nonatomic, readwrite, assign) BOOL isStatusLampOn;           // 设备状态指示灯开关
@property (nonatomic, readwrite, assign) BOOL isDevMicOn;               // 设备麦克风开关
@end


/** 设备运动侦测属性 数据模型类 */
@interface MotionDetectModel : NSObject <
                                            NSCoding,
                                            NSCopying,
                                            NSMutableCopying
                                        >
@property (nonatomic, readwrite, assign) BOOL isMotionDetectOn;         // 运动侦测开关
@property (nonatomic, readwrite, assign) DetectLevel motionLevel;       // 运动侦测敏感度
@property (nonatomic, readwrite, assign) BOOL isAutoPartition;          // 是否自动划分多屏
@property (nonatomic, readwrite, assign) MultiScreenType screenType;    // 分屏类型
@property (nonatomic, readwrite, assign) unsigned int enable;           // 根据不同的分屏模式，设置检测区域（如：4x4 分屏下，选择检测区域为：4、7个小屏区，则 enable = 1 << 4 & 1 << 7）每个区域占用 1 bit，最大为 4x4分屏的 16 bit enable = 0xffff
@end


/** 设备温度侦测属性 数据模型类 */
@interface TemDetectModel : NSObject <
                                        NSCoding,
                                        NSCopying,
                                        NSMutableCopying
                                     >
@property (nonatomic, readwrite, assign) TemDetectEnableType enableType;// 温度侦测开关类型
@property (nonatomic, readwrite, assign) TemperatureType temType;       // 温度表示类型
@property (nonatomic, readwrite, assign) double currentTem;             // 当前温度
@property (nonatomic, readwrite, assign) double upperLimitsTem;         // 上限报警温度
@property (nonatomic, readwrite, assign) double lowerLimitsTem;         // 下限报警温度
@end


/** 设备夜视属性 数据模型类 */
@interface NightVisionModel : NSObject <
                                        NSCoding,
                                        NSCopying,
                                        NSMutableCopying
                                       >
@property (nonatomic, readwrite, assign) BOOL isAuto;                   // 夜视模式是否自动（注意：与手动互斥）
@property (nonatomic, readwrite, assign) BOOL isManual;                 // 夜视模式是否手动（注意：与自动互斥）
@end


/** 设备灯照时间点 数据模型类 */
@interface LampTime : NSObject <
                                    NSCoding,
                                    NSCopying,
                                    NSMutableCopying
                               >
@property (nonatomic, readwrite, assign) unsigned int hour;             // 小时（0~23）
@property (nonatomic, readwrite, assign) unsigned int minute;           // 分钟（0~59）
@property (nonatomic, readwrite, assign) unsigned int second;           // 秒  （0~59）
@end
/** 设备灯照时长属性 数据模型类 */
@interface LampDurationModel : NSObject <
                                            NSCoding,
                                            NSCopying,
                                            NSMutableCopying
                                        >
@property (nonatomic, readwrite, strong) LampTime *onTime;              // 开始时间
@property (nonatomic, readwrite, strong) LampTime *offTime;             // 结束时间
@property (nonatomic, readwrite, assign) LampDayOption lampDayMask;     // 重复时间
@end


/** 设备NTP时间属性 数据模型类 */
@interface NtpTimeModel : NSObject <
                                    NSCoding,
                                    NSCopying,
                                    NSMutableCopying
                                   >
@property (nonatomic, readwrite, copy) NSString *ntpServerAddr;         // ntp 校时服务器地址
@property (nonatomic, readwrite, assign) unsigned int ntpPort;          // ntp 校时服务器端口
@property (nonatomic, readwrite, assign) unsigned int currentSec;       // 当前时间：秒数
@property (nonatomic, readwrite, assign) unsigned int ntpTimeInterval;  // ntp 校时间隔 (单位秒)
@property (nonatomic, readwrite, assign) int timeZone;                  // 时区 (-12~11)
@property (nonatomic, readwrite, assign) BOOL isNtpOn;                  // ntp 校时开关
@property (nonatomic, readwrite, assign) BOOL isDaylightSavingTimeOn;   // 夏令时开关
@end


/** WiFi SSID 信息 数据模型类 */
@interface SsidInfoModel : NSObject <
                                        NSCoding,
                                        NSCopying,
                                        NSMutableCopying
                                    >
@property (nonatomic, readwrite, copy) NSString *wifiSsid;              // WiFi 名称
@property (nonatomic, readwrite, assign) int wifiLevel;                 // WiFi 信号强度
@end


/** 设备固件版本信息模型类 */
@interface DevFirmwareInfoModel : NSObject <
                                            NSCoding,
                                            NSCopying,
                                            NSMutableCopying
                                           >
@property (nonatomic, readwrite, assign) BOOL hasNewer;                 // 是否有新版本可升级
@property (nonatomic, readwrite, copy) NSString *version;               // 可升级的软件版本信息（E_103.T5800HAB.010.367）
@property (nonatomic, readwrite, copy) NSString *updateDes;             // 更新描述（更新了什么内容）
@property (nonatomic, readwrite, copy) NSString *upsIp;                 // 升级服务器 IP 地址
@property (nonatomic, readwrite, assign) int upsPort;                     // 升级服务器端口号
@property (nonatomic, readwrite, copy) NSString *app;                   // (367.app.E_103.tar.bz2)
@end


/** 设备推送状态信息模型类 */
@interface DevPushStatusModel : NSString <
                                            NSCoding,
                                            NSCopying,
                                            NSMutableCopying
                                         >
@property (nonatomic, readwrite, copy) NSString *DeviceId;              // 设备 ID
@property (nonatomic, readwrite, assign) BOOL PushFlag;                 // 推送状态标识；YES：打开，NO：关闭
@end



#pragma mark - IOT
/** IOT-传感器信息模型类 */
@interface IotSensorModel : NSObject <
                                        NSCoding,
                                        NSCopying,
                                        NSMutableCopying
                                     >
@property (nonatomic, readwrite, assign) GosIOTType iotSensorType;  // 传感器类型
@property (nonatomic, readwrite, copy) NSString *iotSensorId;       // 传感器 ID
@property (nonatomic, readwrite, copy) NSString *iotSensorName;     // 传感器名称
@property (nonatomic, readwrite, assign) BOOL isAPNSOpen;           // 传感器推送消息开关
@property (nonatomic, readwrite, assign) BOOL isSceneOpen;          // 情景模式开关
@end


/**
 IOT-情景任务信息模型类
 （目前逻辑是：情景任务重中的 ‘满足条件’、‘执行任务’ 的传感器列表时不允许修改，要修改只能先删除，再重新添加）
 */
@interface IotSceneTask : NSObject <
                                    NSCoding,
                                    NSCopying,
                                    NSMutableCopying
                                   >
@property (nonatomic, readwrite, assign) NSInteger iotSceneTaskId;                      // 情景任务 ID
@property (nonatomic, readwrite, copy) NSString *iotSceneTaskName;                      // 情景任务名称
@property (nonatomic, readwrite, strong) NSMutableArray<IotSensorModel*> *satisfyList;  // 满足条件 IOT-传感器列表
@property (nonatomic, readwrite, strong) NSMutableArray<IotSensorModel*> *carryoutList; // 执行任务 IOT-传感器列表
@property (nonatomic, readwrite, assign) BOOL isCarryOut;                               // 是否执行
@end



#pragma mark - 网络检测
/**
 服务器地址信息模型类
 */
@interface ServerAddressInfo : NSObject <
                                            NSCoding,
                                            NSCopying,
                                            NSMutableCopying
                                        >
@property (nonatomic, readwrite, assign) ServerAddrType serverType;     // 服务器类型
@property (nonatomic, readwrite, copy) NSString *serverIp;              // 服务器 IP 地址
@property (nonatomic, readwrite, assign) NSInteger serverPort;          // 服务器端口号
@end
