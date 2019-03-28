//
//  iOSConfigSDKDefine.h
//  iOSConfigSDK
//
//  Created by shenyuanluo on 2018/1/19.
//  Copyright © 2018年 goscam. All rights reserved.
//

#ifndef iOSConfigSDKDefine_h
#define iOSConfigSDKDefine_h

/** 服务器区域类型 枚举 */
typedef NS_ENUM(NSInteger, ServerAreaType) {
    ServerArea_unknown              = -1,       // 未知
    ServerArea_domestic             = 0,        // 国内
    ServerArea_overseas             = 1,        // 海外
};

/** 账号类型 枚举 */
typedef NS_ENUM(NSInteger, AccountType) {
    Account_name                    = 1,        // 用户名（暂不支持）
    Account_email                   = 2,        // 邮箱
    Account_phone                   = 3,        // 手机号
};

/** 请求验证码事件类型 枚举 */
typedef NS_ENUM(NSInteger, ReqVerCodeType) {
    ReqVerCode_regist               = 1,        // 注册新用户
    ReqVerCode_findPwd              = 2,        // 找回密码
};

/** 设备绑定状态类型 枚举 */
typedef NS_ENUM(NSInteger, DevBindStatus) {
    DevBind_unkown                  = -1,       // 状态未知
    DevBind_no                      = 0,        // 未被绑定
    DevBind_owner                   = 1,        // 已被本账号绑定（主权限）
    DevBind_shared                  = 2,        // 已被本账号绑定（分享）
    DevBind_binded                  = 3,        // 已被其他账号绑定
    DevBind_notExist                = 4,        // 设备不存在
};

/** 设备类型 枚举 */
typedef NS_ENUM(NSInteger, DeviceType) {
    DevType_unknown                 = 0,        // 未知类型
    DevType_ipc                     = 1,        // 普通 IPC
    DevType_nvr                     = 2,        // NVR
    DevType_pano180                 = 4,        // 全景180
    DevType_pano360                 = 3,        // 全景360
    DevType_socket                  = 5,        // 插座
};

/** 设备权限类型 枚举 */
typedef NS_ENUM(NSInteger, DevOwnType) {
    DevOwn_share                    = 0,        // 分享权限
    DevOwn_owner                    = 1,        // 主权限
};

/** 设备状态类型 枚举 */
typedef NS_ENUM(NSInteger, DevStatusType) {
    DevStatus_offLine               = 0,        // 不在线
    DevStatus_onLine                = 1,        // 在线
    DevStatus_sleep                 = 2,        // 睡眠
};

/*
 设备新添加能力集：64 字符（如果设备没有上传，则默认使用老设备能力集）
 
 unsigned char  devCap[64];
 devCap[0]   1. TUTK   2. 4.0_P2P   3. 4.0_TCP  4. 4.0_p2p&tcp
 devCap[1]   0.不支持云存储    1. 支持云存储
 devCap[2]   0.半双工         1. 全双工
 devCap[3]   0. 不支持一拖多   1. 支持一拖多
 devCap[4]   0. AAC          1. G711A
 
 devCap[63] = ‘\0’;
 */
/* devCap[0]：平台类型 */
typedef NS_ENUM(NSInteger, PlatformType) {
    PlatformUnknow              = -1,       // 未知
    PlatformTUTK                = 1,        // TUTK 平台
    PlatformP2P                 = 2,        // 4.0 P2P 打洞
    PlatformTCP                 = 3,        // 4.0 TCP 转发
    PlatformP2PAndTCP           = 4,        // 4.0 P2P 打洞和 TCP 转发
};

/* devCap[1]：流存储类型 */
typedef NS_ENUM(NSInteger, StreamStoreType) {
    StreamStoreUnknow           = -1,       // 未知
    StreamStoreNotAll           = 0,        // 云存储和 TF 卡录像流播都不支持（默认老设备）
    StreamStoreCloud            = 1,        // 支持云存储（TF 卡录像流播是否支持暂时未知）
    StreamStoreOnlyTF           = 2,        // 只支持 TF 卡录像流播，不支持云存储
    StreamStoreOnlyCloud        = 3,        // 只支持云存储，不支持 TF 卡录像流播
};

/* devCap[2]：全双工标识类型 */
typedef NS_ENUM(NSInteger, DuplexType) {
    DuplexUnknow                = -1,       // 未知
    DuplexHalf                  = 0,        // 半双工
    DuplexFull                  = 1,        // 全双工
    DuplexHalfAndFull           = 2,        // 半双工、全双工都支持
};

/* devCap[3]：一拖多类型 */
typedef NS_ENUM(NSInteger, MultiSplitType) {
    MultiSplitUnknow            = -1,       // 未知
    MultiSplitOne               = 0,        // 不支持一拖多
    MultiSplitMore              = 1,        // 支持一拖多
};

/* devCap[4]：音频编码类型 */
typedef NS_ENUM(NSInteger, AudioEncodeType) {
    CloudStoreUnknown           = -1,       // 未知
    CloudStoreAAC               = 0,        // AAC
    CloudStoreG711A             = 1,        // G711（A 律）
};

/* 设备推送状态 */
typedef NS_ENUM(NSInteger, DevPushStatus) {
    DevPush_close                   = 0,        // 关闭推送
    GosDevPush_open                 = 1,        // 打开推送
};

/** 请求 SD 卡录像文件错误类型 枚举 */
typedef NS_ENUM(NSInteger, ReqRecListErrType) {
    ReqRecListErr_unknow            = -1,       // 未知错误
    ReqRecListErr_no                = 0,        // 未发生错误
    ReqRecListErr_param             = 1,        // 参数错误
    ReqRecListErr_noFiles           = 2,        // 没有文件
    ReqRecListErr_noSDCard          = 3,        // 没有插 TF 卡
};

/** TF 卡媒体文件触发录制类型 枚举 */
typedef NS_ENUM(NSInteger, TFMediaRecType) {
    TFMediaRec_unknown              = 0x61,         // ‘a’ 未知
    TFMediaRec_event                = 0x62,         // 'b' 事件录象
    TFMediaRec_manual               = 0x63,         // 'c' 手动录像
    TFMediaRec_schedule             = 0x64,         // 'd' 计划录像
};

/** TF 卡媒体文件触发告警类型 枚举 */
typedef NS_ENUM(NSInteger, TFMediaAlarmType) {
    TFMediaAlarm_unknown            = 0x61,         // ‘a’ 未知
    TFMediaAlarm_videoMotion        = 0x62,         // 'b' 移动侦测
    TFMediaAlarm_pirMotion          = 0x63,         // 'c' PIR
    TFMediaAlarm_pirVideoMotion     = 0x64,         // 'd' PIR_移动侦测
    TFMediaAlarm_audioMotion        = 0x65,         // 'e' 声音侦测
    TFMediaAlarm_io                 = 0x66,         // 'f' IO
    TFMediaAlarm_lowTemp            = 0x67,         // 'g' 低温告警
    TFMediaAlarm_hightTemp          = 0x68,         // 'h' 高温告警
    TFMediaAlarm_lowHum             = 0x69,         // 'i' 低湿度告警
    TFMediaAlarm_hightHum           = 0x6A,         // 'j' 高湿度告警
    TFMediaAlarm_lowWBGT            = 0x6B,         // 'k' 低湿球黑球温度（用来评价在整个工作周期中人体所受的热强度）告警
    TFMediaAlarm_hightWBGT          = 0x6C,         // 'l' 高湿球黑球温度（用来评价在整个工作周期中人体所受的热强度）告警
    TFMediaAlarm_lowPower           = 0x6D,         // 'm' 低电告警
    TFMediaAlarm_calling            = 0x6E,         // 'n'
};

/** TF 卡录像文件类型 枚举 */
typedef NS_ENUM(NSInteger, TFMediaFileType) {
    TFMediaFile_video               = 0,            // 视频
    TFMediaFile_photo               = 1,            // 图片
};

/** 加载更多 Record List 文件方向 枚举 */
typedef NS_ENUM(NSInteger, RecListPageTurnDirection) {
    RecListPageTurn_forward         = 0,        // 往前一页（加载最新）
    RecListPageTurn_backward        = 1,        // 往后一页（加载历史）
};

/** SD 卡录像文件列表类型 枚举 */
typedef NS_ENUM(NSInteger, SDRecListType) {
    SDRecList_unknow                = -1,           // 未知
    SDRecList_normal                = 0,            // 普通视频文件
    SDRecList_alarm                 = 1,            // 告警视频文件
};


#pragma mark -- 设备属性 2018-03-14
/** 视频模式类型 枚举 */
typedef NS_ENUM(NSInteger, VideoMode) {
    Video_normal                    = 0x00,     // 普通
    Video_flip                      = 0x01,     // 翻转
    Video_mirror                    = 0x02,     // 镜像
    Video_flipAndMirror             = 0x03,     // 翻转 + 镜像
};

/** 侦测（运动、声音）敏感度 枚举 */
typedef NS_ENUM(NSInteger, DetectLevel) {
    Detect_close                    = 0,        // 关闭
    Detect_low                      = 1,        // 低
    Detect_middle                   = 2,        // 中
    Detect_high                     = 3,        // 高
};

/** 运动侦测多屏划分类型 枚举 */
typedef NS_ENUM(NSInteger, MultiScreenType) {
    MultiScreen_1x1                 = 0,        // （1 x 1） 分屏
    MultiScreen_2x2                 = 1,        // （2 x 2） 分屏
    MultiScreen_3x3                 = 2,        // （3 x 3） 分屏
    MultiScreen_4x4                 = 3,        // （4 x 4） 分屏
};

/** 温度侦测开关类型 枚举 */
typedef NS_ENUM(NSInteger, TemDetectEnableType) {
    TemDetectEnable_closeAll        = 0,        // 上下限全部关闭
    TemDetectEnable_upperLimits     = 1,        // 上限开启，下限关闭
    TemDetectEnable_lowerLimits     = 2,        // 上限关闭，下限开启
    TemDetectEnable_openAll         = 3,        // 上下限全部开启
};

/** 温度类型 枚举 */
typedef NS_ENUM(NSInteger, TemperatureType) {
    Temperature_C                   = 0,        // 摄氏度
    Temperature_F                   = 1,        // 华氏度
};

/** 设备开关类型 枚举 */
typedef NS_ENUM(NSInteger, SwitchType) {
    Switch_camera                   = 0,        // 摄像头
    Switch_statusLamp               = 1,        // 设备状态指示灯
    Switch_mic                      = 2,        // 麦克风
    Switch_manualRecord             = 3,        // 手动录像
    Switch_pirDetect                = 4,        // PIR 侦测
    Switch_lullaby                  = 5,        // 摇篮曲
};



/** 照明灯重复开启开启星期 选项 */
typedef NS_OPTIONS(NSInteger, LampDayOption) {
    LampDay_SUN                     = 1 << 0,   // 星期天
    LampDay_MON                     = 1 << 1,   // 星期一
    LampDay_TUE                     = 1 << 2,   // 星期二
    LampDay_WED                     = 1 << 3,   // 星期三
    LampDay_THU                     = 1 << 4,   // 星期四
    LampDay_FRI                     = 1 << 5,   // 星期五
    LampDay_SAT                     = 1 << 6,   // 星期六
    LampDay_ALL = (LampDay_SUN | LampDay_MON | LampDay_TUE | LampDay_WED | LampDay_THU | LampDay_FRI | LampDay_SAT),  // 全部开启
};

/** 支持摇篮曲播放设备系列 */
typedef NS_ENUM(NSInteger, LullabyDevType) {
    LullabyDev_unSupport            = 0,        // 不支持摇篮曲播放
    LullabyDev_5886HAB              = 1,        // 5886HAB 系列设备
    LullabyDev_GD8208KE             = 2,        // GD8202KE 系列设备
    LullabyDev_VOXX                 = 3,        // VOXX 系列设备
    LullabyDev_RCA                  = 4,        // RCA 系列设备
    LullabyDev_T5810HCA             = 5,        // T5810HCA 系列设备
};

/** 摇篮曲序号（注意：这里的序号《相当于命令参数》是固定的后续维护 SDK 时，如需修改，请慎重；名称根据需求变动） */
typedef NS_ENUM(NSInteger, LullabyNumber) {
    LullabyNum_unknow                           = 0,        // 未知
    // 5886HAB 系列
    Lullaby5886HABNum_twinklePiano              = 13,       // twinkle piano
    Lullaby5886HABNum_littleMozart              = 14,       // little Mozart
    Lullaby5886HABNum_relax                     = 15,       // relax
    Lullaby5886HABNum_nature                    = 16,       // nature
    Lullaby5886HABNum_BrahmsLullaby             = 17,       // Brahms lullaby
    Lullaby5886HABNum_bedtimeLullaby            = 18,       // bedtime lullaby
    
    // GD8202KE 系列设备
    LullabyGD8202KENum_IDontWantToMissAThing    = 19,       // I don't want to miss a thing
    LullabyGD8202KENum_Holiday                  = 20,       // Holiday
    LullabyGD8202KENum_Jolene                   = 21,       // Jolene
    LullabyGD8202KENum_Rain                     = 22,       // Rain
    LullabyGD8202KENum_Waves                    = 23,       // Waves
    LullabyGD8202KENum_PinkNoise                = 24,       // Pink Noise
    
    // VOXX 系列设备（注意：3.5 平台 VOXX 和 RCA 是共用的）
    LullabyVOXXNum_IDontWantToMissAThing        = 7,        // I don't want to miss a thing
    LullabyVOXXNum_Holiday                      = 8,        // Holiday
    LullabyVOXXNum_Jolene                       = 9,        // Jolene
    LullabyVOXXNum_Rain                         = 10,       // Rain
    LullabyVOXXNum_Waves                        = 11,       // Waves
    LullabyVOXXNum_PinkNoise                    = 12,       // Pink Noise
    
    // RCA 系列设备（这里目前只适用于 2.0 平台）
    LullabyRCANum_Campfire                      = 25,       // Campfire
    LullabyRCANum_CountryAmbience               = 26,       // CountryAmbience
    LullabyRCANum_Heartbeat                     = 27,       // Jolene
    LullabyRCANum_Rain                          = 28,       // Rain
    LullabyRCANum_Waves                         = 29,       // Waves
    LullabyRCANum_WhiteNoise                    = 30,       // WhiteNoise
    
    // T5810HCA 系列设备
    LullabyT5810HCANum_BirdsStreamNatureForestLoop = 32,    // birds_sream_nature_forest_loop
    LullabyT5810HCANum_BrahmsLullaby               = 33,    // Brahms_Lullaby
    LullabyT5810HCANum_Relax                       = 34,    // Relax
    LullabyT5810HCANum_twinklePiano                = 35,    // twinklepiano
};

/** 摇篮曲播放状态 */
typedef NS_ENUM(NSInteger, LullabyStatus) {
    LullabyStatus_unknow                        = -1,       // 未知
    LullabyStatus_stop                          = 0,        // 未播放
    LullabyStatus_playing                       = 1,        // 正在播放
};

/** 'IOT-能力集‘(支持 IOT-传感器 选项 )*/
typedef NS_OPTIONS(NSInteger, SupportIotSensorType) {
    SupportIot_not                  = 0,        // 不支持
    SupportIot_all                  = 1 << 0,   // 支持所有
    SupportIot_strobeSiren          = 1 << 1,   // 声光报警器
    SupportIot_magnetic             = 1 << 2,   // 门磁
    SupportIot_infrared             = 1 << 3,   // 红外（PIR）
    SupportIot_sos                  = 1 << 4,   // SOS
    SupportIot_water                = 1 << 5,   // 水浸报警器
    SupportIot_lamp                 = 1 << 6,   // 投影灯/彩灯
};

/** IOT 类型 枚举 */
typedef NS_ENUM(NSInteger, GosIOTType) {
    GosIot_unknow                       = -1,   // 未知
    GosIot_sensorAudibleAlarm           = 1,    // 传感器-’声光报警‘
    GosIot_sensorMagnetic               = 2,    // 传感器-‘门磁’
    GosIot_sensorInfrared               = 3,    // 传感器-’红外‘
    GosIot_sensorSOS                    = 4,    // 传感器-‘SOS’
};

/** 查询添加 IOT 结果状态 枚举 */
typedef NS_ENUM(NSInteger, AddIOTStatus) {
    AddIot_timeout                      = -2,   // 超时（同样需要调用’添加‘命令：IotSensorId 为 nil，告知设备断开连接）
    AddIot_failure                      = -1,   // 失败
    AddIot_success                      = 0,    // （如果是‘声光报警器，则是添加成功；如果是’其他‘传感器，则是准备好，可以开始添加）
    AddIot_repeat                       = 1,    // 重复添加
    AddIot_respone                      = 2,    // 如果是’其他‘传感器，则是’准备添加‘回复还没准备好添加 IOT（则继续查询）
};

/** 服务器地址类型 枚举 */
typedef NS_ENUM(NSInteger, ServerAddrType) {
    ServerAddr_unknown                  = -1,   // 未知
    ServerAddr_mps                      = 2,    // MPS
    ServerAddr_cbs                      = 3,    // CBS
    ServerAddr_ups                      = 4,    // UPS
};



/** Config SDK 错误码表 */

#define CONSDK_ERR_NO                            0          // 未发生错误
#define CONSDK_ERR_TIME_OUT                      8888       // 超时
#define CONSDK_ERR_PARAM_ILLEGAL                -1          // 参数不合法
#define CONSDK_ERR_UNKNOWN_ERROR                -2          // 未知错误


#define CONSDK_ERR_NO_SUPPORT_BLOCK_MODE        -100        // 不支持阻塞模式
#define CONSDK_ERR_TIMEOUT                      -101        // 请求超时
#define CONSDK_ERR_NO_SUPPORT_REQ               -102        // SDK不支持该请求
#define CONSDK_ERR_SEND_FAILED                  -103        // 发送请求失败
#define CONSDK_ERR_SEND_REQ_WHEN_DISCONNECT     -104        // 在断线的情况下发送的请求
#define CONSDK_ERR_CONNECT_FAILED               -105        // 连接服务器失败
#define CONSDK_ERR_SOCKET_ERROR                 -106        // 套接字异常
#define CONSDK_ERR_BUFFER_IS_TOO_SMALL          -107        // 用作输出拷贝的buffer空间不够


#define CONSDK_ERR_PARAM                        -2000       // 参数错误
#define CONSDK_ERR_INIT                         -2001       // 初始化失败
#define CONSDK_ERR_UN_INIT                      -2002       // 未初始化
#define CONSDK_ERR_PRO                          -2003       // 协议错误
#define CONSDK_ERR_GET_CHANNEL                  -2004       // 获取空闲通道错误
#define CONSDK_ERR_HEART_BEAT                   -2005       // 保持心跳失败
#define CONSDK_ERR_LOST_CONN                    -2006       // 掉线


#define CONSDK_ERR_USER_IS_EXIST                -10030      // 用户已经注册
#define CONSDK_ERR_REG_FAILED                   -10085      // 注册用户失败
#define CONSDK_ERR_ADD_ABILITY_FAILED           -10086      // 添加服务器能力集失败
#define CONSDK_ERR_UPDATE_ABILITY_FAILED        -10087      // 更新服务器能力集失败
#define CONSDK_ERR_ADD_LOAD_FAILED              -10088      // 添加服务器负载失败
#define CONSDK_ERR_UPDATE_LOAD_FAILED           -10089      // 更新服务器负载失败
#define CONSDK_ERR_NO_DEV_LIST                  -10090      // 不存在设备列表信息
#define CONSDK_ERR_DEV_IS_BINDED                -10091      // 用户已经绑定设备
#define CONSDK_ERR_BIND_FAILED                  -10092      // 绑定设备失败
#define CONSDK_ERR_UN_BINDED                    -10093      // 设备未绑定
#define CONSDK_ERR_UN_BIND_FAILED               -10094      // 解绑设备失败
#define CONSDK_ERR_DEV_NOT_EXIST                -10095      // 设备不存在
#define CONSDK_ERR_MODIFY_DEV_PROERTY_FAILED    -10096      // 修改设备属性失败
#define CONSDK_ERR_MODIFY_USER_PWD_FAILED       -10097      // 修改用户密码失败
#define CONSDK_ERR_NO_BINED_DEV                 -10098      // 用户未绑定该设备
#define CONSDK_ERR_USER_NOT_EXIST               -10099      // 用户不存在
#define CONSDK_ERR_USER_NAME_ERROR              -10100      // 用户名错误
#define CONSDK_ERR_OWNER_ERROR                  -10101      // 用户与设备拥有关系错误
#define CONSDK_ERR_BIND_DEV_FAILED              -10102      // 绑定设备失败
#define CONSDK_ERR_REG_PUSH_SERVER_FAILED       -10103      // 注册推送服务器失败
#define CONSDK_ERR_REG_CGS_FAILED               -10104      // 注册 CGS 失败
#define CONSDK_ERR_DB_NET_ERROR                 -10105      // 数据库网络连接异常
#define CONSDK_ERR_RECORD_NOT_EXIST             -10106      // 查询记录不存在
#define CONSDK_ERR_USER_PWD_REPEAT              -10107      // 用户密码重复
#define CONSDK_ERR_PHONE_IS_EXIST               -10108      // 电话号码已存在
#define CONSDK_ERR_EMAIL_IS_EXIST               -10109      // 邮箱地址已存在
#define CONSDK_ERR_USER_PWD_ERROR               -10110      // 用户密码错误
#define CONSDK_ERR_DECODE_PWD_ERROR             -10111      // 密码解码失败
#define CONSDK_ERR_SERVER_REG_IS_EXIST          -10112      // 服务器注册已存在


#define CONSDK_ERR_JSON_ERROR                   -70001      // 解析 json 串错误
#define CONSDK_ERR_UNKNOWN_REQ                  -70002      // 未知请求
#define CONSDK_ERR_CONN_DB_ERROR                -70003      // 连接数据库错误
#define CONSDK_ERR_NOT_FOUND_DEV                -70004      // 没有找到设备
#define CONSDK_ERR_GET_CGSA_FAILED              -70005      // 获取网关 CGSA 失败
#define CONSDK_ERR_CONN_CGSA_FAILED             -70006      // 连接 CGSA 失败
#define CONSDK_ERR_LOGIN_CGSA_FAILED            -70007      // 登录 CGSA 失败
#define CONSDK_ERR_DEV_NOT_REPLAY_UPDATE_REQ    -70008      // 设备端没有正确回复升级请求
#define CONSDK_ERR_UPDATE_REQ_FAILED            -70009      // 升级请求失败
#define CONSDK_ERR_MD5_VERIFY_FAILED            -70010      // MD5 校验 失败
#define CONSDK_ERR_QUERY_UPDATE_INFO_FAILED     -70011      // 查询 APP 升级信息失败
#define CONSDK_ERR_SERVER_IS_BUSY               -70012      // 服务器繁忙
#define CONSDK_ERR_MAX_DOWNLOAD                 -70013      // 达到设定的同时存在的最大下载数
#define CONSDK_ERR_NOT_FOUND                    -70014      // 没有找到
#define CONSDK_ERR_PARAM_ERROR                  -70015      // 参数错误
#define CONSDK_ERR_BUILD_JSON_ERROR             -70016      // 构建 json 错误
#define CONSDK_ERR_VERIFY_MD5_FAILED            -70017      // 校验 MD5 失败
#define CONSDK_ERR_INSERT_SQL_FAILED            -70018      // 数据库插入失败
#define CONSDK_ERR_FILE_NOT_EXIST               -70019      // 没有在 FTP 目录找到指定文件


#define CONSDK_ERR_REDIS_ERROR                  -80003      // Redis set 错误
#define CONSDK_ERR_EMAIL_NOT_EXIST              -80005      // 用户无邮箱
#define CONSDK_ERR_EMAIL_ERROR                  -80006      // 用户邮箱地址错误
#define CONSDK_ERR_CMS_ERROR                    -80007      // CMS 服务器错误
#define CONSDK_ERR_VERIFY_CODE_ERROR            -80009      // 验证码错误
#define CONSDK_ERR_VERIFY_CODE_OVERDUE          -80010      // 验证码过期
#define CONSDK_ERR_NO_REQ_VERIFY_CODE           -80012      // 没有获取验证码
#define CONSDK_ERR_SEND_SEND_VERIFY_CODE_FAILED -80013      // 发送验证码到邮箱失败
#define CONSDK_ERR_MODIFYING_PWD                -80014      // 用户正在修改密码
#define CONSDK_ERR_LOGIN_ERROR                  -80015      // 发送邮箱登录失败
#define CONSDK_ERR_REDIS_EXPIRE_ERROR           -80016      // Redis expire 错误
#define CONSDK_ERR_REDIS_AUTH_ERROR             -80017      // Redis auth 错误
#define CONSDK_ERR_DELETE_VERIFY_CODE_FAILED    -80019      // Redis 删除验证码失败
#define CONSDK_ERR_REDIS_NOT_CONN               -80020      // Redis 无连接
#define CONSDK_ERR_REDIS_CMD_EXECUTE_ERROR      -80021      // Redis 命令执行错误
#define CONSDK_ERR_REDIS_RESP_ERROR             -80022      // Redis 应答错误
#define CONSDK_ERR_REQ_PARAM_ERROR              -80023      // APP 请求参数错误


#endif /* iOSConfigSDKDefine_h */
