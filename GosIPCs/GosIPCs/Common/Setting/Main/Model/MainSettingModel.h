//
//  MainSettingModel.h
//  Goscom
//
//  Created by 匡匡 on 2018/11/21.
//  Copyright © 2018 goscam. All rights reserved.
//

#import <Foundation/Foundation.h>
@class AbilityModel;
@class AllParamModel;
@class PackageValidTimeApiRespModel;
typedef NS_ENUM(NSInteger, SettingCellType) {
    SettingCellType_HasNext,        //  有下一项的
    SettingCellType_Switch,         //  带switch的
    SettingCellType_ThreeTap,       //  三个可点击的
    SettingCellType_State,          //  带文字开关状态
};
/**
 摄像头信息设置类型枚举
 */
typedef NS_ENUM(NSInteger, SettingType) {
    
    SettingType_Alexa ,                    // Alexa
    SettingType_AddSensor,                 // 添加传感器
    SettingType_SceneTask,                 // 情景任务
    SettingType_LightDuration ,             //灯照时长
    SettingType_BabyMusic,                 // 音乐播放
    
    SettingType_MotionDetection,           // 移动侦测
    SettingType_VoiceDetection,            // 声音检测
    SettingType_PIRDetection,              // PIR（红外）侦测
    SettingType_TempAlarmSetting,          // 温度警报
    
    SettingType_CameraSwitch ,             // 摄像头开关
    SettingType_CameraMicrophone,          // 麦克风
    SettingType_CellularDataAutoPause,     // 移动网络自动暂停
    
    SettingType_CloudService,              // 云服务
    
    SettingType_ManualRecord,              // 手动录像
    SettingType_PhotoAlbum,                // 用户相册
    
    SettingType_StatusIndicator,           // 状态指示灯
    SettingType_RotateSemicircle,          // 旋转180度
    SettingType_NightVersion,              // 夜视
    
    SettingType_ShareWithFriends,          // 好友分享
    
    SettingType_TimeCheck,                 // 时间校验
    SettingType_WiFiSetting,               // WiFi 设置
    SettingType_DeviceInfo,                // 设备信息
    
    SettingType_HorizontalFlip,            // 水平翻转
    SettingType_VerticalFlip,              // 垂直翻转
    SettingType_BatteryLife,               // 电池电量
    SettingType_RecordingDuration,         // 录像时长
    
};



@interface MainSettingModel : NSObject
@property (nonatomic, assign) SettingType settingType;      //  cell类型
@property (nonatomic, copy) NSString *nameStr;              //  cell标题
@property (nonatomic, copy) NSString *imageStr;             //  cell图片
@property (nonatomic, assign) SettingCellType cellType;     //  cell的类型  带三角形  switch
@property (nonatomic, assign) BOOL switchState;             //  开关状态
@property (nonatomic, strong) NSString * nightVersionStr;   //  夜视开关文字

/** 数据存储时长3,7,30天 */
@property (assign, nonatomic)  int dataStorageTime;
/// 云储存时长显示 order now 3,7,30天
@property (nonatomic, copy) NSString * cloudServiceDateLife;
/// 云储存套餐模型 nil=立即订购  packageModel.dataLife = 套餐时间
@property (nonatomic, strong) PackageValidTimeApiRespModel * PackageModel;
/** 能力集模型 **/
@property (nonatomic, copy) AbilityModel * abilityModel;
/** 能力集开关模型 **/
@property (nonatomic, copy) AllParamModel * allParamModel;

//@property (nonatomic, copy) void (^handleBlock)(NSMutableArray * dataArr);
@property (nonatomic, copy) void (^handleBlock)(void);
@end
