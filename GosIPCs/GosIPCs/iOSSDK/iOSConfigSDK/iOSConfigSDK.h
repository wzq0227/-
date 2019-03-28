//
//  iOSConfigSDK.h
//  iOSConfigSDK
//
//  Created by shenyuanluo on 2018/1/17.
//  Copyright © 2018年 goscam. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "iOSConfigSDKDefine.h"
#import "iOSConfigSDKModel.h"

// 过期-弃用 提醒
#define CNFGSDK_DEPRECATE(instead)      __attribute__((deprecated(instead)))
// 过期-不可用 提醒
#define CNFGSDK_UN_AVAILABLE(instead)   __attribute__((unavailable(instead)))


#pragma mark - 用户管理代理
/** 用户管理代理 */
@protocol iOSConfigSDKUMDelegate <NSObject>
@optional

/**
 SDK 初始化回调
 
 @param isSuccess SDK 初始化否成功；YES：成功，NO：失败
 @param eCode 发送失败时原因，参见 Config SDK 错误码表
 */
- (void)initConfigSdk:(BOOL)isSuccess
            errorCode:(int)eCode;

/**
 请求验证码回调

 @param isSuccess 请求验证码是否成功；YES：成功，NO：失败
 @param eCode 发送失败时原因，参见 Config SDK 错误码表
 */
- (void)reqVerCode:(BOOL)isSuccess
         errorCode:(int)eCode;

/**
 注册账号回调

 @param isSuccess 是否注册成功；YES：成功，NO：失败
 @param eCode 注册失败原因，参见 Config SDK 错误码表
 */
- (void)registAccount:(BOOL)isSuccess
            errorCode:(int)eCode;

/**
 登录回调
 
 @param isSuccess 注册是否成功；YES：成功，NO：失败
 @param uToken 用户 token
 @param eCode 注册失败原因，参见 Config SDK 错误码表
 */
- (void)login:(BOOL)isSuccess
    userToken:(NSString *)uToken
    errorCode:(int)eCode;

/**
 找回密码回调

 @param isSuccess 找回是否成功；YES：成功，NO：失败
 @param eCode 重置失败原因，参见 Config SDK 错误码表
 */
- (void)findPassword:(BOOL)isSuccess
           errorCode:(int)eCode;

/**
 重置密码回调
 
 @param isSuccess 重置是否成功；YES：成功，NO：失败
 @param eCode 重置失败原因，参见 Config SDK 错误码表
 */
- (void)resetPassword:(BOOL)isSuccess
            errorCode:(int)eCode;
@end


#pragma mark -  推送管理代理
@protocol iOSConfigSDKPushDelegate <NSObject>
@optional
/**
 注册 iOS 推送功能回调
 
 @param isSuccess 注册是否成功；YES：成功，NO：失败
 @param eCode 重置失败原因，参见 Config SDK 错误码表
 */
- (void)registPushToken:(BOOL)isSuccess
              errorCode:(int)eCode;

/**
 打开设备推送功能回调
 
 @param isSuccess 打开是否成功；YES：成功，NO：失败
 @param devId 设备 ID
 @param eCode 重置失败原因，参见 Config SDK 错误码表
 */
- (void)openPush:(BOOL)isSuccess
        deviceId:(NSString *)devId
       errorCode:(int)eCode;

/**
 关闭设备推送功能回调
 
 @param isSuccess 关闭是否成功；YES：成功，NO：失败
 @param devId 设备 ID
 @param eCode 重置失败原因，参见 Config SDK 错误码表
 */
- (void)closePush:(BOOL)isSuccess
         deviceId:(NSString *)devId
        errorCode:(int)eCode;

/**
 查询账号下所有设备推送状态回调
 
 @param isSuccess 查询是否成功；YES：成功，NO：失败
 @param sList 设备推送状态状态列表，参见‘DevPushStatusModel’
 @param eCode 重置失败原因，参见 Config SDK 错误码表
 */
- (void)queryPushStatus:(BOOL)isSuccess
             statusList:(NSArray<DevPushStatusModel*> *)sList
              errorCode:(int)eCode;
/*
 ‘长连接’推送消息回调
 
 @param devId 设备 ID
 @param pushTime 推送消息时间
 @param pushType 推送消息类型
 @param pushUrl 推送消息图片-URL
*/
- (void)recvOfDevice:(NSString *)devId
                time:(long)pushTime
                type:(int)pushType
                 url:(NSString *)pushUrl;
@end


#pragma mark - 设备管理代理
@protocol iOSConfigSDKDMDelegate <NSObject>
@optional
/**
 查询设备绑定状态回调
 
 @param isSuccess 是否查询成功；YES：成功，NO：失败
 @param devId 设备 ID
 @param bStatus 设备绑定状态，参见‘DevBindStatus’
 @param eCode 查询失败原因，参见 Config SDK 错误码表
 */
- (void)queryBind:(BOOL)isSuccess
         deviceId:(NSString *)devId
           status:(DevBindStatus)bStatus
        errorCode:(int)eCode;

/**
 查询设备注册状态回调
 
 @param isSuccess 是否查询成功；YES：成功，NO：失败
 @param devId 设备 ID
 @param account 账号
 @param isRegist 是否注册；YES：已注册，NO：未注册
 @param eCode 查询失败原因，参见 Config SDK 错误码表
 */
- (void)queryRegist:(BOOL)isSuccess
           deviceId:(NSString *)devId
            account:(NSString *)account
             status:(BOOL)isRegist
          errorCode:(int)eCode;

/**
 查询设备分享列表数据回调
 
 @param isSuccess 是否查询成功；YES：成功，NO：失败
 @param devId 设备 ID
 @param aList 设备已分享的账号列表
 @param eCode 查询失败原因，参见 Config SDK 错误码表
 */
- (void)queryShareList:(BOOL)isSuccess
              deviceId:(NSString *)devId
           accountList:(NSArray<NSString *>*)aList
             errorCode:(int)eCode;

/**
 绑定设备回调

 @param isSuccess 是否绑定成功；YES：成功，NO：失败
 @param devId 设备 ID
 @param eCode 绑定失败原因，参见 Config SDK 错误码表
 */
- (void)bind:(BOOL)isSuccess
    deviceId:(NSString *)devId
   errorCode:(int)eCode;

/**
 解绑设备回调
 
 @param isSuccess 是否解绑成功；YES：成功，NO：失败
 @param devId 设备 ID
 @param eCode 绑定失败原因，参见 Config SDK 错误码表
 */
- (void)unBind:(BOOL)isSuccess
      deviceId:(NSString *)devId
     errorCode:(int)eCode;

/**
 ‘强制’解绑设备回调
 
 @param isSuccess 是否解绑成功；YES：成功，NO：失败
 @param devId 设备 ID
 @param eCode 绑定失败原因，参见 Config SDK 错误码表
 */
- (void)forceUnBind:(BOOL)isSuccess
           deviceId:(NSString *)devId
          errorCode:(int)eCode;

/**
 设备列表数据回调

 @param listArray 设备列表
 @param account 账号
 */
- (void)devlist:(NSArray <DevDataModel *>*)listArray
        account:(NSString *)account;

/**
 设备状态回调

 @param statusList 设备状态列表
 */
- (void)devStatusList:(NSArray <DevStatusModel*>*)statusList;

/**
 某月 Record List 数据回调

 @param isSuccess 是否请求成功；YES：成功，NO：失败
 @param dateList 日期列表(如：2018/03/07、2018/03/08、...)
 @param eType 查询失败原因，参见‘ReqRecListErrType’
 */
- (void)reqMoth:(BOOL)isSuccess
     recordList:(NSArray <RecMonthDataModel*>*)dateList
      errorCode:(ReqRecListErrType)eType;

/**
 某日 Record List 数据回调

 @param isSuccess 是否请求成功；YES：成功，NO：失败
 @param fileList 文件列表（如：20180308104226*******.mp4、...)
 @param pCount 首次请求时，返回总页数（每页最多 20 个文件）；否则返回当前页的文件数量，如最后一页未满时返回 12
 @param isNoFile 是否已经加载完文件；YES：已加载完，NO：未加载完成
 */
- (void)reqDay:(BOOL)isSuccess
    recordList:(NSArray <TFMediaFileModel*>*)fileList
         count:(NSInteger)pCount
      isNoFile:(BOOL)isNoFile;

/**
 删除 TF 卡录制文件结果回调
 
 @param isSuccess 是否删除成功；YES：成功，NO：失败
 @param devId 设备 ID
 @param eCode 删除失败原因，参见 Config SDK 错误码表
 */
- (void)delTFRecList:(BOOL)isSuccess
            deviceId:(NSString *)devId
           errorCode:(int)eCode;

/**
 请求 SD 卡录像列表结果回调
 
 @param isSuccess 是否请求成功；YES：成功，NO：失败
 @param list 请求成功时返回的列表数据
 @param rType 请求列表类型，参见‘SDRecListType’
 */
- (void)reqSDRecList:(BOOL)isSuccess
          recordList:(NSArray<SDAlarmDataModel*>*)list
             forType:(SDRecListType)rType;

@end


#pragma mark -- 设备属性 2018-03-14
#pragma mark - 参数管理代理
@protocol iOSConfigSDKParamDelegate <NSObject>
@optional

/**
 请求设备信息结果回调
 
 @param isSuccess 是否请求成功；YES：成功，NO：失败
 @param devId 设备 ID
 @param infoModel 设备信息，参见‘DevInfoModel’
 */
- (void)reqDevInfo:(BOOL)isSuccess
          deviceId:(NSString *)devId
              info:(DevInfoModel *)infoModel;

/**
 请求设备所有参数结果回调
 
 @param isSuccess 是否请求成功；YES：成功，NO：失败
 @param devId 设备 ID
 @param paramModel 设备属性，参见‘AllParamModel’
 */
- (void)reqAllParam:(BOOL)isSuccess
           deviceId:(NSString *)devId
              param:(AllParamModel *)paramModel;

/**
 请求设备运动侦测参数结果回调
 
 @param isSuccess 是否请求成功；YES：成功，NO：失败
 @param devId 设备 ID
 @param mDetect 运动侦测参数，参见‘MotionDetectModel’
 */
- (void)reqMotionDetect:(BOOL)isSuccess
               deviceId:(NSString *)devId
            detectParam:(MotionDetectModel *)mDetect;

/**
 设置设备运动侦测参数结果回调
 
 @param isSuccess 是否设置成功；YES：成功，NO：失败
 @param devId 设备 ID
 */
- (void)configMotionDetect:(BOOL)isSuccess
                  deviceId:(NSString *)devId;

/**
 请求温度侦测参数结果回调
 
 @param isSuccess 是否请求成功；YES：成功，NO：失败
 @param devId 设备 ID
 @param tDetect 温度侦测参数，参见‘TemDetectModel’
 */
- (void)reqTemDetect:(BOOL)isSuccess
            deviceId:(NSString *)devId
         detectParam:(TemDetectModel *)tDetect;

/**
 设置温度侦测参数结果回调
 
 @param isSuccess 是否设置成功；YES：成功，NO：失败
 @param devId 设备 ID
 */
- (void)configTemDetect:(BOOL)isSuccess
               deviceId:(NSString *)devId;

/**
 请求夜视参数结果回调
 
 @param isSuccess 是否请求成功；YES：成功，NO：失败
 @param devId 设备 ID
 @param nvModel 夜视参数，参见‘NightVisionModel’
 */
- (void)reqNightVision:(BOOL)isSuccess
              deviceId:(NSString *)devId
               nvParam:(NightVisionModel *)nvModel;

/**
 设置夜视参数结果回调
 
 @param isSuccess 是否设置成功；YES：成功，NO：失败
 @param devId 设备 ID
 */
- (void)configNightVision:(BOOL)isSuccess
                 deviceId:(NSString *)devId;

/**
 请求灯照时长参数结果回调
 
 @param isSuccess 是否请求成功；YES：成功，NO：失败
 @param devId 设备 ID
 @param ldModel 灯照时长参数，参见‘LampDurationModel’
 */
- (void)reqLampDuration:(BOOL)isSuccess
               deviceId:(NSString *)devId
                ldParam:(LampDurationModel *)ldModel;

/**
 设置灯照时长参数结果回调
 
 @param isSuccess 是否设置成功；YES：成功，NO：失败
 @param devId 设备 ID
 */
- (void)configLampDuration:(BOOL)isSuccess
                  deviceId:(NSString *)devId;

/**
 请求 NTP 时间参数结果回调

 @param isSuccess 是否请求成功；YES：成功，NO：失败
 @param devId 设备 ID
 @param ntModel NTP 时间参数，参见‘NtpTimeModel’
 */
- (void)reqNtpTime:(BOOL)isSuccess
          deviceId:(NSString *)devId
         timeParam:(NtpTimeModel *)ntModel;

/**
 设置 NTP 时间参数结果回调

 @param isSuccess 是否设置成功；YES：成功，NO：失败
 @param devId 设备 ID
 */
- (void)configNtpTime:(BOOL)isSuccess
             deviceId:(NSString *)devId;

/**
 请求设备附近 WiFi 列表结果回调

 @param isSuccess 是否请求成功；YES：成功，NO：失败
 @param devId 设备 ID
 @param wList WiFi 列表，参见‘SsidInfoModel’
 */
- (void)reqSsidInfo:(BOOL)isSuccess
           deviceId:(NSString *)devId
           wifiList:(NSArray <SsidInfoModel *>*)wList;

/**
 设置设备连接 WiFi结果回调

 @param isSuccess 是否设置成功；YES：成功，NO：失败
 @param devId 设备 ID
 */
- (void)configConnSsid:(BOOL)isSuccess
              deviceId:(NSString *)devId;

/**
 设置开关属性结果回调
 
 @param isSuccess 是否设成功；YES：成功，NO：失败
 @param sType 开关类型，参见‘SwitchType’
 @param devId 设备 ID
 */
- (void)configSwitch:(BOOL)isSuccess
                type:(SwitchType)sType
            deviceId:(NSString *)devId;

/**
 设置声音侦测结果回调
 
 @param isSuccess 是否设成功；YES：成功，NO：失败
 @param devId 设备 ID
 */
- (void)configVoiceDetect:(BOOL)isSuccess
                 deviceId:(NSString *)devId;

/**
 设置视频模式结果回调
 
 @param isSuccess 是否设成功；YES：成功，NO：失败
 @param devId 设备 ID
 */
- (void)configVideoMode:(BOOL)isSuccess
               deviceId:(NSString *)devId;

/**
 格式化设备 SD 卡结果回调
 
 @param isSuccess 是否格式化成功；YES：成功，NO：失败
 @param devId 设备 ID
 @param cardInfo 格式化成功后返回的 SD 卡信息，参见‘SdCardInfoModel’
 */
- (void)formatSdCard:(BOOL)isSuccess
            deviceId:(NSString *)devId
           sdCarInfo:(SdCardInfoModel*)cardInfo;

/**
 设置摇篮曲播放序号结果回调
 
 @param isSuccess 是否设置成功；YES：成功，NO：失败
 @param devId 设备 ID
 */
- (void)configLullabyNum:(BOOL)isSuccess
                deviceId:(NSString *)devId;

/**
 请求摇篮曲播放序号、播放状态结果回调
 
 @param isSuccess 是否请求成功；YES：成功，NO：失败
 @param lNum 摇篮曲序号，参见‘LullabyNumber’
 @param lStatus 是否正在播放；YES：正在播放，NO：未播放
 @param devId 设备 ID
 */
- (void)reqLullaby:(BOOL)isSuccess
            number:(LullabyNumber)lNum
        playStatus:(LullabyStatus)lStatus
          deviceId:(NSString *)devId;

/**
 修改设备属性（昵称、取流账号、取流密码）结果回调
 
 @param isSuccess 是否修改成功；YES：成功，NO：失败
 @param devId 设备 ID
 */
- (void)modifyDevAttr:(BOOL)isSuccess
             deviceId:(NSString *)devId;


/**
 查询设备固件版本信息结果回调
 
 @param isSuccess 是否查询成功；YES：成功，NO：失败
 @param firmwareInfo 设备固件版本信息，参见‘DevFirmwareInfoModel’
 @param devId 设备 ID
 @param eCode 查询失败原因，参见 Config SDK 错误码表
 */
- (void)checkFirmware:(BOOL)isSuccess
         firmwareInfo:(DevFirmwareInfoModel *)firmwareInfo
             deviceId:(NSString *)devId
            errorCode:(int)eCode;

/**
 开始升级设备固件版本信息结果回调
 
 @param isSuccess 是否开始升级成功；YES：成功，NO：失败
 @param result 升级进度结果【说明】如下：
                0：准备开始升级；
                1：由于申请内存失败导致升级失败
                2：由于创建线程失败导致升级失败
                3：升级过程中出错
                4、5：升级完成
                100~200：表示升级进度百分比（如 108 表示当前升级进度 8%），其中 100~130 会实时回调回来，超过了 30% 时，由于设备下载固件成功，安装后需要重启，所以无法继续回调进度，因此 APP 端需要使用定时器模拟后面 30%~100% 的进度，当接收到 4、5 时，表明设备s安装固件并重启成功，表明升级完成
 @param devId 设备 ID
 */
- (void)startUpdateFirmware:(BOOL)isSuccess
               updateResult:(int)result
                   deviceId:(NSString *)devId;

/**
 取消升级设备固件版本信息结果回调
 
 @param isSuccess 是否开始升级成功；YES：成功，NO：失败
 @param result 暂未知
 @param devId 设备 ID
 */
- (void)cancelUpdateFirmware:(BOOL)isSuccess
               updateResult:(int)result
                   deviceId:(NSString *)devId;

@end


#pragma mark - 设备能力集代理
@protocol iOSConfigSDKABDelegate <NSObject>
@optional
/**
 请求设备能力集结果回调
 
 @param isSuccess 是否请求成功；YES：成功，NO：失败
 @param devId 设备 ID
 @param abModel 设备能力集，参见‘AbilityModel’
 */
- (void)reqAbility:(BOOL)isSuccess
          deviceId:(NSString *)devId
           ability:(AbilityModel *)abModel;
@end


#pragma mark - IOT（子设备）代理
@protocol iOSConfigSDKIOTDelegate <NSObject>
@optional
#pragma mark -- 设备相关
/**
 准备添加 IOT 结果回调
 
 @param isSuccess 是否请求‘准备添加’成功；YES：成功，NO：失败
 @param devId 设备 ID
 @param eCode 请求失败原因，参见 Config SDK 错误码表
 */
- (void)prepareAddIot:(BOOL)isSuccess
             deviceId:(NSString *)devId
            errorCode:(int)eCode;

/**
 查询添加 IOT 状态结果回调
 
 @param addStatus 添加状态，参见’AddIOTStatus‘
 @param sensorId IOT-传感器 ID，可以添加时返回，否则为 nil
 @param devId 设备 ID
 @param eCode 查询失败原因，参见 Config SDK 错误码表
 */
- (void)addIotStatus:(AddIOTStatus)addStatus
           iotSensor:(NSString *)sensorId
            deviceId:(NSString *)devId
           errorCode:(int)eCode;

/**
 开始添加 IOT 状态结果回调
 
 @param isSuccess 是否‘添加’成功；YES：成功，NO：失败
 @param devId 设备 ID
 @param eCode 查询失败原因，参见 Config SDK 错误码表
 */
- (void)addIot:(BOOL)isSuccess
      deviceId:(NSString *)devId
     errorCode:(int)eCode;

/**
 删除 IOT 状态结果回调
 
 @param isSuccess 是否‘删除’成功；YES：成功，NO：失败
 @param devId 设备 ID
 @param eCode 查询失败原因，参见 Config SDK 错误码表
 */
- (void)deleteIot:(BOOL)isSuccess
         deviceId:(NSString *)devId
        errorCode:(int)eCode;

/**
 修改 IOT 状态结果回调
 
 @param isSuccess 是否‘删除’成功；YES：成功，NO：失败
 @param devId 设备 ID
 @param eCode 查询失败原因，参见 Config SDK 错误码表
 */
- (void)modifyIot:(BOOL)isSuccess
         deviceId:(NSString *)devId
        errorCode:(int)eCode;

/**
 查询 IOT 列表结果回调
 
 @param isSuccess 是否‘查询’成功；YES：成功，NO：失败
 @param devId 设备 ID
 @param iList IOT-传感器列表
 @param eCode 查询失败原因，参见 Config SDK 错误码表
 */
- (void)queryIotList:(BOOL)isSuccess
            deviceId:(NSString *)devId
             iotList:(NSArray<IotSensorModel*>*)iList
           errorCode:(int)eCode;

/**
 配对声光报警器结果回调
 
 @param iStatus 配对结果状态，参见‘AddIOTStatus’
 @param sensorId 声光报警器 ID，配对成功时返回，否则为 nil
 @param devId 设备 ID
 param eCode 配对失败原因，参见 Config SDK 错误码表
 */
- (void)pairStrobeSiren:(AddIOTStatus)iStatus
              iotSensor:(NSString *)sensorId
               deviceId:(NSString *)devId
              errorCode:(int)eCode;

/**
 查询声光报警器-开关状态结果回调
 
 @param isSuccess 是否‘查询’成功；YES：成功，NO：失败
 @param isOpen 开关状态-是否打开；YES：打开，NO：关闭
 @param devId 设备 ID
 param eCode 停止失败原因，参见 Config SDK 错误码表
 */
- (void)checkStrobeSiren:(BOOL)isSuccess
                  status:(BOOL)isOpen
                deviceId:(NSString *)devId
               errorCode:(int)eCode;

/**
 停止声光报警器报警结果回调
 
 @param isSuccess 是否‘停止’成功；YES：成功，NO：失败
 @param devId 设备 ID
 param eCode 停止失败原因，参见 Config SDK 错误码表
 */
- (void)stopStrobeSiren:(BOOL)isSuccess
               deviceId:(NSString *)devId
              errorCode:(int)eCode;

/**
 设置声光报警器（报警）开关结果回调
 
 @param isSuccess 是否‘设置’成功；YES：成功，NO：失败
 @param devId 设备 ID
 param eCode 设置失败原因，参见 Config SDK 错误码表
 */
- (void)configStrobeSirenSwitch:(BOOL)isSuccess
                       deviceId:(NSString *)devId
                      errorCode:(int)eCode;

#pragma mark -- 账号相关
/**
 绑定 IOT-传感器到设备结果回调
 
 @param isSuccess 是否‘绑定’成功；YES：成功，NO：失败
 @param devId 设备 ID
 param eCode 绑定失败原因，参见 Config SDK 错误码表
 */
- (void)bindIotSensor:(BOOL)isSuccess
             deviceId:(NSString *)devId
            errorCode:(int)eCode;

/**
 解除绑定 IOT-传感器到设备结果回调
 
 @param isSuccess 是否‘解除绑定’成功；YES：成功，NO：失败
 @param devId 设备 ID
 param eCode 解除绑定失败原因，参见 Config SDK 错误码表
 */
- (void)unBindIotSensor:(BOOL)isSuccess
               deviceId:(NSString *)devId
              errorCode:(int)eCode;

/**
 请求 IOT-传感器列表结果回调
 
 @param isSuccess 是否‘请求’成功；YES：成功，NO：失败
 @param sList IOT-传感器列表
 @param devId 设备 ID
 param eCode 请求失败原因，参见 Config SDK 错误码表
 */
- (void)reqIot:(BOOL)isSuccess
    sensorList:(NSArray<IotSensorModel *>*)sList
      deviceId:(NSString *)devId
     errorCode:(int)eCode;

/**
 修改 IOT-传感器结果回调
 
 @param isSuccess 是否‘修改’成功；YES：成功，NO：失败
 @param devId 设备 ID
 param eCode 请求失败原因，参见 Config SDK 错误码表
 */
- (void)modifyIotSensor:(BOOL)isSuccess
               deviceId:(NSString *)devId
              errorCode:(int)eCode;

#pragma mark -- 情景任务
/**
 添加 IOT-情景任务结果回调
 
 @param isSuccess 是否‘添加’成功；YES：成功，NO：失败
 @param sTaskId 情景任务 ID
 @param devId 设备 ID
 param eCode 添加失败原因，参见 Config SDK 错误码表
 */
- (void)addSceneTask:(BOOL)isSuccess
         sceneTaskId:(NSInteger)sTaskId
            deviceId:(NSString *)devId
           errorCode:(int)eCode;

/**
 删除 IOT-情景任务结果回调
 
 @param isSuccess 是否‘删除’成功；YES：成功，NO：失败
 @param devId 设备 ID
 param eCode 添加失败原因，参见 Config SDK 错误码表
 */
- (void)delSceneTask:(BOOL)isSuccess
            deviceId:(NSString *)devId
           errorCode:(int)eCode;

/**
 修改 IOT-情景任务结果回调
 
 @param isSuccess 是否‘修改’成功；YES：成功，NO：失败
 @param devId 设备 ID
 param eCode 添加失败原因，参见 Config SDK 错误码表
 */
- (void)modifySceneTask:(BOOL)isSuccess
               deviceId:(NSString *)devId
              errorCode:(int)eCode;

/**
 查询 IOT-情景任列表务结果回调
 
 @param isSuccess 是否‘查询’成功；YES：成功，NO：失败
 @param stList 情景任务列表
 @param devId 设备 ID
 param eCode 添加失败原因，参见 Config SDK 错误码表
 */
- (void)querySceneTask:(BOOL)isSuccess
                  list:(NSArray<IotSceneTask*>*)stList
               deviceId:(NSString *)devId
              errorCode:(int)eCode;

/**
 查询 IOT-情景任务（满足条件/执行传感器）信息列表结果回调
 
 @param isSuccess 是否‘查询’成功；YES：成功，NO：失败
 @param ifSensorList ‘满足条件’传感器列表
 @param exeSensorList ‘执行任务'传感器列表
 param eCode 添加失败原因，参见 Config SDK 错误码表
 */
- (void)query:(BOOL)isSuccess
 ifSensorList:(NSArray<IotSensorModel*>*)ifSensorList
exeSensorList:(NSArray<IotSensorModel*>*)exeSensorList
    errorCode:(int)eCode;


@end


@protocol iOSConfigSDKCheckDelegate <NSObject>
@optional

/**
 查询 CBS 服务器地址结果回调
 
 @param isSuccess 是否‘查询’成功；YES：成功，NO：失败
 @param aList 服务器地址列表
 */
- (void)queryCBS:(BOOL)isSuccess
     addressList:(NSArray<ServerAddressInfo*>*)aList;
@end



#pragma mark - iOSConfigSDK
@interface iOSConfigSDK : NSObject
/** 用户管理代理 */
@property (nonatomic, weak) id<iOSConfigSDKUMDelegate>umDelegate;
/** 推送管理代理 */
@property (nonatomic, weak)id<iOSConfigSDKPushDelegate>pushDelegate;
/** 设备管理代理 */
@property (nonatomic, weak) id<iOSConfigSDKDMDelegate>dmDelegate;
/** 参数管理代理 */
@property (nonatomic, weak) id<iOSConfigSDKParamDelegate>paramDelegate;
/** 能力集代理 */
@property (nonatomic, weak) id<iOSConfigSDKABDelegate>abDelegate;
/** IOT 代理 */
@property (nonatomic, weak) id<iOSConfigSDKIOTDelegate>iotDelegate;
/*** 网络检测代理 */
@property (nonatomic, weak) id<iOSConfigSDKCheckDelegate>checkDelegate;


+ (instancetype)shareCofigSdk;

/**
 设置服务器（慎用：仅初始化 SDK 和登录切换地区的时候用）
 
 @param sArea 服务器类型，参见‘ServerAreaType’
 */
+ (void)setupServerArea:(ServerAreaType)sArea;

#pragma mark - 用户管理
/**
 获取验证码

 @param account 账号（邮箱）
 @param aType 账号类型，参见‘AccountType’
 @param eType 请求验证码事件类型，参见‘ReqVerCodeType’
 */
- (void)reqVerCodeWithAccount:(NSString *)account
                  accountType:(AccountType)aType
                    eventType:(ReqVerCodeType)eType;

/**
 注册账号

 @param account 账号
 @param aType 账号类型，参见‘AccountType’
 @param vCode 验证码
 @param password 初始密码
 */
- (void)registWithAccount:(NSString *)account
              accountType:(AccountType)aType
                 veryCode:(NSString *)vCode
                 password:(NSString *)password;

/**
 登录

 @param account 账号
 @param password 密码
 */
- (void)loginWithAccount:(NSString *)account
                password:(NSString *)password;

/**
 注销登录

 @return 注销是否成功；YES：成功，NO：失败
 */
- (BOOL)logout;

/**
 找回密码

 @param password 新密码
 @param account 账号
 @param aType 账号类型，参见‘AccountType’
 @param vCode 验证码
 */
- (void)findPassword:(NSString *)password
             account:(NSString *)account
         accountType:(AccountType)aType
            veryCode:(NSString *)vCode;

/**
 重置密码

 @param password 新密码
 @param account 账号
 @param aType 账号类型，参见‘AccountType’
 */
- (void)resetPassword:(NSString *)password
          oldPassword:(NSString *)oldPwd
              account:(NSString *)account
          accountType:(AccountType)aType;

/*
 注册 iOS 推送功能 （GOS 平台）
 
 @param token 成功注册 APNS-Remote 返回的 token
 @param account 用户账号
 @param appId APP 应用唯一标识
 @param uuid iOS 设备唯一标识
 */
- (void)registPushWithToken:(NSString *)token
                  onAccount:(NSString *)account
                      appId:(NSString *)appId
                    iOSUUID:(NSString *)uuid;

/*
 打开设备推送功能（GOS 平台）
 
 @param devId 设备 ID
 @param account 账号
 @param appId APP 应用唯一标识
 @param UUID iOS 设备唯一标识
 */
- (void)openPushOfDevice:(NSString *)devId
               onAccount:(NSString *)account
                   appId:(NSString *)appId
                 iOSUUID:(NSString *)uuid;
/*
 关闭设备推送功能（GOS 平台）
 
 @param devId 设备 ID
 @param account 账号
 @param appId APP 应用唯一标识
 @param UUID iOS 设备唯一标识
 */
- (void)closePushOfDevice:(NSString *)devId
                onAccount:(NSString *)account
                    appId:(NSString *)appId
                  iOSUUID:(NSString *)uuid;

/*
 查询账号下所有设备推送开关状态（GOS、TUTK 平台）
 
 @param account 账号
 @param appId APP 应用唯一标识
 @param UUID iOS 设备唯一标识
 */
- (void)queryPushStatusOnAccount:(NSString *)account
                           appId:(NSString *)appId
                         iOSUUID:(NSString *)uuid;



#pragma mark - 设备管理
/**
 查询设备绑定状态

 @param devId 设备 ID
 @param account 账号
 */
- (void)queryBindWithDeviceId:(NSString *)devId
                      account:(NSString *)account;

/**
 查询设备是否已经注册到服务器（AP 模式添加时）

 @param devId 设备 ID
 @param account 账号
 */
- (void)queryRegistWithDevId:(NSString *)devId
                     account:(NSString *)account;

/**
 查询设备分享列表
 
 @param devId 设备 ID
 */
- (void)queryShareListWithDevId:(NSString *)devId;

/**
 绑定设备

 @param devId 设备 ID
 @param devName 设备昵称
 @param devType 设备类型，参见‘DeviceType’
 @param ownType 设备权限类型，参见‘DevOwnType’
 @param account 账号
 */
- (void)bindDeviceId:(NSString *)devId
          deviceName:(NSString *)devName
          deviceType:(DeviceType)devType
             ownType:(DevOwnType)ownType
             account:(NSString *)account CNFGSDK_DEPRECATE("Use bindDevice:toAccount instead");

/**
 绑定设备
 
 @param device 设备数据模型
 @param account 账号
 */
- (void)bindDevice:(DevDataModel *)device
         toAccount:(NSString *)account;

/**
 解绑设备

 @param devId 设备 ID
 @param account 账号
 */
- (void)unBindDeviceId:(NSString *)devId
               account:(NSString *)account CNFGSDK_DEPRECATE("Use unBindDevice:fromAccount instead");
/**
 解绑设备
 
 @param device 设备数据模型
 @param account 账号
 */
- (void)unBindDevice:(DevDataModel *)device
         fromAccount:(NSString *)account;

/**
 '强制'解绑设备
 
 @param devId 设备 ID
 */
- (void)forceUnbindDeviceId:(NSString *)devId;

/**
 获取设备列表

 @param account 账号
 */
- (void)reqDevListWithAccount:(NSString *)account;

/**
 请求设备某月 Record List

 @param devId 设备 ID
 */
- (void)reqMothRecListWithDevId:(NSString *)devId;

/**
 请求设备某月某天 Record List（首页，每页最多 20 个文件）
 
 @param devId 设备 ID
 @param day 某天日期（如：2018-03-08）
 @param fType 文件类型，参见‘TFMediaFileType’
 */
- (void)reqDayRecListWithdDevId:(NSString *)devId
                          onDay:(NSDate *)day
                       fileType:(TFMediaFileType)fType;

/**
 加载更多 Record List 文件

 @param devId 设备 ID
 @param day 某天日期（如：2018-03-08）
 @param fType 文件类型，参见‘TFMediaFileType’
 @param stFileName 分界点文件名
 @param tDirection 翻页方向，参见‘RecListPageTurnDirection’
 */
- (void)loadMoreRecListWithDevId:(NSString *)devId
                           onDay:(NSDate *)day
                        fileType:(TFMediaFileType)fType
                       startFile:(NSString *)stFileName
                   turnDirection:(RecListPageTurnDirection)tDirection;

/**
 删除 Record List 文件
 
 @param recList 文件名数组（如：@[@"201801031506180bb0030.mp4", @"201801031506180bb0030.mp4"];
 */
- (void)delTFRecList:(NSArray<NSString*>*)recList
             ofDevId:(NSString *)devId;

/**
 请求 SD 卡告警录像列表
 
 @param devId 设备 ID
 @param sTime 起始时间
 @param eTime 结束时间
 @param rType 文件类型，参见‘SDRecListType’
 */
- (void)reqSDRecListWithdDevId:(NSString *)devId
                     startTime:(NSString *)sTime
                       endTime:(NSString *)eTime
                       forType:(SDRecListType)rType;


#pragma mark -- 设备属性 2018-03-14

#pragma mark - 设备属性、参数、能力集相关
/**
 请求设备能力集（云台、咪头、扬声器。。。）

 @param devId 设备 ID
 */
- (void)reqAbilityOfDevId:(NSString *)devId;

/**
 请求设备信息（硬件版本、软件版本。。。）

 @param devId 设备 ID
 */
- (void)reqInfoOfDevId:(NSString *)devId;

/**
 请求设备所有参数（移动侦测、PIR、声音侦测。。。）
 
 @param devId 设备 ID
 */
- (void)reqAllParamOfDevId:(NSString *)devId;

/**
 请求设备运动侦测参数

 @param devId 设备 ID
 */
- (void)reqMotionDetectOfDevId:(NSString *)devId;

/**
 设置运动侦测参数
 
 @param mDetect 运动侦测参数,参见‘MotionDetectModel’
 @param devId 设备 ID
 */
- (void)configMotionDetect:(MotionDetectModel *)mDetect
                 withDevId:(NSString *)devId;

/**
 请求温度侦测测参数

 @param devId 设备 ID
 */
- (void)reqTemDetectOfDevId:(NSString *)devId;

/**
 设置温度侦测参数
 
 @param tDetect 温度侦测参数，参见‘TemDetectModel’
 @param devId 设备 ID
 */
- (void)configTemDetect:(TemDetectModel *)tDetect
           withDeviceId:(NSString *)devId;

/**
 请求夜视参数

 @param devId 设备 ID
 */
- (void)reqNightVisionWithDevId:(NSString *)devId;

/**
 设置夜视参数

 @param nvModel 夜视参数，参见‘NightVisionModel’
 @param devId 设备 ID
 */
- (void)configNightVision:(NightVisionModel *)nvModel
             withDeviceId:(NSString *)devId;

/**
 请求灯照时长参数

 @param devId 设备 ID
 */
- (void)reqLampDurationOfDevId:(NSString *)devId;

/**
 设置灯照时长参数

 @param ldModel 灯照时长参数，参见‘LampDurationModel’
 @param devId 设备 ID
 */
- (void)configLampDuration:(LampDurationModel *)ldModel
              withDeviceId:(NSString *)devId;

/**
 请求 NTP 时间参数

 @param devId 设备 ID
 */
- (void)reqNtpTimeOfDevId:(NSString *)devId;

/**
 设置 NTP 时间参数

 @param ntModel NTP 时间参数，参见‘NtpTimeModel’
 @param devId 设备 ID
 */
- (void)configNtpTime:(NtpTimeModel *)ntModel
         withDeviceId:(NSString *)devId;

/**
 请求设备附近 WiFi 列表

 @param devId 设备 ID
 */
- (void)reqSsidListOfDevId:(NSString *)devId;

/**
 设置设备连接 WiFi

 @param wifiSsid WiFi 名称
 @param wifiPwd WiFi 密码
 @param devId 设备 ID
 */
- (void)configConnToSsid:(NSString *)wifiSsid
                password:(NSString *)wifiPwd
            withDeviceId:(NSString *)devId;

/**
 设置开关参数

 @param sType 开关类型，参见‘SwitchType’
 @param isOn 开关状态；YES：打开，NO：关闭
 @param devId 设备 ID
 */
- (void)configSwitch:(SwitchType)sType
               state:(BOOL)isOn
           withDevId:(NSString *)devId;

/**
 设置声音侦测参数

 @param dLevel 侦测敏感度，参见‘DetectLevel’
 @param isOn 开关状态；YES：打开，NO：关闭
 @param devId 设备 ID
 */
- (void)configVoiceDetect:(DetectLevel)dLevel
                    state:(BOOL)isOn
                withDevId:(NSString *)devId;

/**
 设置视频模式参数

 @param vMode 视频模式，参见‘VideoMode’
 @param devId 设备 ID
 */
- (void)configVideoMode:(VideoMode)vMode
              withDevId:(NSString *)devId;
/**
 格式化设备 SD 卡
 
 @param devId 设备 ID
 */
- (void)formatSdCarOfDevice:(NSString *)devId;

/**
 设置播放摇篮曲序号
 
 @param lullabyNum 摇篮曲序号，参见‘LullabyNumber’
 @param devId 设备 ID
 */
- (void)configLullabyNum:(LullabyNumber)lullabyNum
              widthDevId:(NSString *)devId;

/**
 请求播放摇篮曲序号、播放状态
 
 @param devId 设备 ID
 */
- (void)reqLullabyNumWithDevId:(NSString *)devId;

/**
 修改设备属性（昵称、取流账号、取流密码）
 
 @param devName 新设备昵称
 @param sUser 取流账号
 @param sPassword 取流密码
 @param devId 设备 ID
 */
- (void)modifyDevName:(NSString *)devName
           streamUser:(NSString *)sUser
       streamPassword:(NSString *)sPassword
            withDevId:(NSString *)devId;

/**
 查询设备固件版本是否有新版本需要升级
 
 @param devId 设备 ID
 @param swVersion 设备当前软件版本信息，参见‘DevInfoModel.swVersion’
 @param hwVersion 设备当前硬件版本信息，参见‘DevInfoModel.hwVersion’
 */
- (void)checkFirmwareOfDevice:(NSString *)devId
              forCurSWVersion:(NSString *)swVersion
                 curHWVersion:(NSString *)hwVersion;

/**
 开始升级设备固件版本
 
 @param devId 设备 ID
 @param upsAddr 升级服务器地址（查询固件时有新版可升级时会返回）
 @param upsPort 升级服务器端口（查询固件时有新版可升级时会返回）
 */
- (void)startUpdateFirmwareOfDevice:(NSString *)devId
                         upsAddress:(NSString *)upsAddr
                            upsPort:(int)upsPort;

/**
 取消升级设备固件版本
 
 @param devId 设备 ID
 @param upsAddr 升级服务器地址（查询固件时有新版可升级时会返回）
 @param upsPort 升级服务器端口（查询固件时有新版可升级时会返回）
 */
- (void)cancelUpdateFirmwareOfDevice:(NSString *)devId
                          upsAddress:(NSString *)upsAddr
                             upsPort:(int)upsPort;


#pragma mark - IOT
#pragma mark -- 添加到(IPC)设备
/**
 准备添加 IOT（IPC 子设备）（结果回调：’prepareAddIot:deviceId:errorCode:‘）
 注意：添加 IOT 之前，必需先调用此接口告诉设备(IPC)准备开始添加
 然后开始调用‘checkStatusOfIotAddToDevice:’接口查询，
 
 
 @param devId 设备 ID
 */
- (void)prepareAddIotToDevice:(NSString *)devId;

/**
 查询准备添加 IOT 的结果状态（结果回调：’addIotStatus:deviceId:errorCode:‘）
 注意：调用此接口之前，需先调用‘prepareAddIotToDevice:‘接口通知设备准备开始添加，
 然循环调用查询添加结果，建议查询时间间隔：5(单位：秒)，
 
 @param devId 设备 ID
 */
- (void)checkStatusOfIotAddToDevice:(NSString *)devId;

/**
 添加 IOT
 注意：如果查询状态返回‘超时’时，也必需调用此接口并'sensorId'参数为空，用于告知设备【断开准备模式】，
 否则正常传递需要绑定的 IOT 子设备 ID
 
 @param iotSensor IOT-传感器
 @param devId 设备 ID
 */
- (void)addIotSensor:(IotSensorModel *)iotSensor
          toDeviceId:(NSString *)devId;

/**
 删除 IOT
 
 @param iotSensor IOT-传感器
 @param devId 设备 ID
 */
- (void)deleteIotSensor:(IotSensorModel *)iotSensor
             fromDevice:(NSString *)devId;

/**
 修改 IOT
 
 @param iotSensor IOT-传感器
 @param devId 设备 ID
 */
- (void)modifyIotSensor:(IotSensorModel *)iotSensor
               ofDevice:(NSString *)devId;

/**
 查询 IOT 列表
 
 @param devId 设备 ID
 */
- (void)queryIotListOfDevice:(NSString *)devId;

/**
 配对声光报警器（目前逻辑：一个设备只能配对一个声光报警器）
 
 @param devId 设备 ID
 */
- (void)pairStrobeSirenToDevice:(NSString *)devId;

/**
 查询声报警器-开关状态
 
 @param devId 设备 ID
 */
- (void)checkStrobeSirenStatusOfDevice:(NSString *)devId;

/**
 停止声光报警器-报警
 
 @param devId 设备 ID
 */
- (void)stopStrobeSirenOfDevice:(NSString *)devId;

/**
 设置声光报警器（报警）开关
 
 @param isOpen 是否打开；YES：打开，NO：关闭
 @param devId 设备 ID
 */
- (void)configStrobeSirenSwitch:(BOOL)isOpen
                       ofDevice:(NSString *)devId;

#pragma mark -- 添加到账号（用于同步统一账号登录 iOS、Android 设备）
/**
 绑定 IOT-传感器到设备
 
 @param iotSensor 传感器
 @param devId 设备 ID
 @param account 账号
 */
- (void)bindIotSensor:(IotSensorModel *)iotSensor
             toDevice:(NSString *)devId
            onAccount:(NSString *)account;

/**
 解除绑定 IOT-传感器到设备
 
 @param iotSensor 传感器
 @param devId 设备 ID
 @param account 账号
 */
- (void)unBindIotSensor:(IotSensorModel *)iotSensor
             fromDevice:(NSString *)devId
              onAccount:(NSString *)account;

/**
 请求设备的 IOT-传感器列表
 
 @param devId 设备 ID
 @param account 账号
 */
- (void)reqIotSensorListOfDevice:(NSString *)devId
                       onAccount:(NSString *)account;
/**
 修改 IOT-传感器
 
 @param iotSensor 传感器
 @param devId 设备 ID
 @param account 账号
 */
- (void)modifyIotSensor:(IotSensorModel *)iotSensor
               ofDevice:(NSString *)devId
              onAccount:(NSString *)account;

#pragma mark -- 情景任务
/**
 添加 IOT-情景任务
 
 @param iotSceneTask 情景任务
 @param devId 设备 ID
 @param account 账号
 */
- (void)addSceneTask:(IotSceneTask *)iotSceneTask
            toDevice:(NSString *)devId
           onAccount:(NSString *)account;

/**
 删除 IOT-情景任务
 
 @param sceneTaskId 情景任务 ID
 @param devId 设备 ID
 @param account 账号
 */
- (void)delSceneTask:(NSInteger)sceneTaskId
          fromDevice:(NSString *)devId
           onAccount:(NSString *)account;

/**
 修改 IOT-情景任务
 
 @param iotSceneTask 情景任务
 @param devId 设备 ID
 @param account 账号
 */
- (void)modifySceneTask:(IotSceneTask *)iotSceneTask
               toDevice:(NSString *)devId
              onAccount:(NSString *)account;

/**
 查询 IOT-情景任务列表
 
 @param devId 设备 ID
 @param account 账号
 */
- (void)querySceneTaskListOfDevice:(NSString *)devId
                         onAccount:(NSString *)account;

/**
 查询 IOT-情景任务（满足条件/执行传感器）信息列表
 
 @param sceneTaskId 情景任务 ID
 @param account 账号
 */
- (void)queryIfExeListOfSceneTask:(NSInteger)sceneTaskId
                        onAccount:(NSString *)account;


#pragma mark - 网络检测
/**
 查询 CBS 服务器地址
 */
- (void)queryCBSAddress;

/**
 检测服务器地址是否可达
 
 @param serverInfo 服务器地址信息模型
 @param resultBlock 检测结果 Block 回调
 */
- (void)checkServer:(ServerAddressInfo *)serverInfo
        isReachable:(void(^)(BOOL isReachable))resultBlock;


@end
