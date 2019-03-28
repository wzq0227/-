//
//  MainSettingViewModel.m
//  Goscom
//
//  Created by 匡匡 on 2018/11/27.
//  Copyright © 2018 goscam. All rights reserved.
//

#import "MainSettingViewModel.h"
#import "iOSConfigSDKModel.h"
#import "MainSettingModel.h"
#import "CloudStoreViewModel.h"
#import "ExtractDevIdInfo.h"
#import "iOSConfigSDKModel.h"
#import "PackageValidTimeApiRespModel.h"
@implementation MainSettingViewModel
#pragma mark - 根据能力集得到cell数据数组
+ (NSArray <NSMutableArray *> *)handleTableDataModel:(AbilityModel *) abilityModel
                                        devDataModel:(DevDataModel *) devDataModel{
    /// NOTE:第三方接入+音乐播放+添加传感器+情景任务+灯照时长
    NSMutableArray * customGroupArr = [NSMutableArray arrayWithCapacity:1];
    /// NOTE:运动检测+声音检测+红外侦测+温度报警
    NSMutableArray * normalActionGroupArr = [NSMutableArray arrayWithCapacity:1];
    /// NOTE:摄像头开关+摄像头麦克风+蜂窝移动网络自动暂停
    NSMutableArray * cameraSwitchGroupArr = [NSMutableArray arrayWithCapacity:1];
    /// NOTE:相册+TF卡手动录像
    NSMutableArray * manualRecordGroupArr = [NSMutableArray arrayWithCapacity:1];
    /// NOTE:云录制套餐
    NSMutableArray * cloudServiceGroupArr = [NSMutableArray arrayWithCapacity:1];
    /// NOTE:状态指示灯+旋转视频图像180度+夜视
    NSMutableArray * hardwareGroupArr = [NSMutableArray arrayWithCapacity:1];
    /// NOTE: 好友分享
    NSMutableArray * friendShareGroupArr = [NSMutableArray arrayWithCapacity:1];
    /// NOTE:摄像头时间校验+WiFi设置+设备信息
    NSMutableArray * deviceInfoArr = [NSMutableArray arrayWithCapacity:1];
    
    /// NOTE:主权限为自己
    if (devDataModel.DeviceOwner == DevOwn_owner) {
        if (abilityModel.hasAlexa) {
            /// NOTE:Alexa 第三方接入 顺序1
            MainSettingModel * model = [[MainSettingModel alloc] init];
            model.settingType = SettingType_Alexa;
            [customGroupArr addObject:model];
        }
         /// NOTE: 音乐播放 顺序2
        if(abilityModel.lullabyDevType != 0){
            MainSettingModel * babyModel = [[MainSettingModel alloc] init];
            babyModel.settingType = SettingType_BabyMusic;
            [customGroupArr addObject:babyModel];
        }
        /// NOTE:添加传感器 顺序4
        if (abilityModel.iotSensorType) {
            
            MainSettingModel * addSensorModel = [[MainSettingModel alloc] init];
            addSensorModel.settingType = SettingType_AddSensor;
            [customGroupArr addObject:addSensorModel];
        }
        /// NOTE: 灯照时长 顺序5
        if(abilityModel.hasLamp){
            MainSettingModel * lightModel = [[MainSettingModel alloc] init];
            lightModel.settingType = SettingType_LightDuration;
            [customGroupArr addObject:lightModel];
        }
        /// NOTE: 移动侦测 运动检测 顺序6
        if(abilityModel.hasMotionDetect){
            MainSettingModel * motionDetModel = [[MainSettingModel alloc] init];
            motionDetModel.settingType = SettingType_MotionDetection;
            [normalActionGroupArr addObject:motionDetModel];
        }
        /// NOTE: 声音侦测 顺序7
        if(abilityModel.hasVoiceDetect){
            MainSettingModel * voiceModel = [[MainSettingModel alloc] init];
            voiceModel.settingType = SettingType_VoiceDetection;
            [normalActionGroupArr addObject:voiceModel];
        }
        /// NOTE: PIR（红外）侦测  顺序8
        if(abilityModel.hasPIR){
            MainSettingModel * pirModel = [[MainSettingModel alloc] init];
            pirModel.settingType = SettingType_PIRDetection;
            [normalActionGroupArr addObject:pirModel];
        }
        
        /// NOTE: 温度警报  顺序9
        if (abilityModel.hasTemDetect) {
            MainSettingModel * tempAlarmModel = [[MainSettingModel alloc] init];
            tempAlarmModel.settingType = SettingType_TempAlarmSetting;
            [normalActionGroupArr addObject:tempAlarmModel];
        }
        /// NOTE: 摄像头开关 顺序10
        if(abilityModel.hasCameraSwitch){
            MainSettingModel * cameraModel = [[MainSettingModel alloc] init];
            cameraModel.settingType = SettingType_CameraSwitch;
            [cameraSwitchGroupArr addObject:cameraModel];
        }
        /// NOTE: 摄像头麦克风 顺序11
        if(abilityModel.hasMicSwitch){          // 麦克风
            MainSettingModel * cameraMicroModel = [[MainSettingModel alloc] init];
            cameraMicroModel.settingType = SettingType_CameraMicrophone;
            [cameraSwitchGroupArr addObject:cameraMicroModel];
        }
        /// NOTE: 云录制套餐 顺序13   存储时长显示不同
        if ([[[CloudStoreViewModel alloc] init] validateIsSupportCloudServiceWithDeviceId:devDataModel.DeviceId]) {
            MainSettingModel * cloudModel = [[MainSettingModel alloc] init];
            cloudModel.settingType = SettingType_CloudService;
            [cloudServiceGroupArr addObject:cloudModel];
        }
        
        /// NOTE: 手动录像 T5100ZJ无录像 顺序15
        if(abilityModel.hasSdCardSlot && (GosIpc_T5100ZJ != [ExtractDevIdInfo deviceTypeOfDevId:devDataModel.DeviceId])){
            MainSettingModel * manualModel = [[MainSettingModel alloc] init];
            manualModel.settingType = SettingType_ManualRecord;
            [manualRecordGroupArr addObject:manualModel];
        }
        /// NOTE: 状态指示灯  顺序16
        if (abilityModel.hasStatusLamp) {
            MainSettingModel * statusModel = [[MainSettingModel alloc] init];
            statusModel.settingType = SettingType_StatusIndicator;
            [hardwareGroupArr addObject:statusModel];
        }
        /// NOTE: 旋转视频图像180度  顺序17   除T5100ZJ，其他的都有
        if (GosIpc_T5100ZJ != [ExtractDevIdInfo deviceTypeOfDevId:devDataModel.DeviceId]) {
            
            MainSettingModel * rotatingModel = [[MainSettingModel alloc] init];
            rotatingModel.settingType = SettingType_RotateSemicircle;
            [hardwareGroupArr addObject:rotatingModel];
        }
        /// NOTE: 夜视  顺序18
        if (abilityModel.hasNightVision) {
            MainSettingModel * nightModel = [[MainSettingModel alloc] init];
            nightModel.settingType = SettingType_NightVersion;
            [hardwareGroupArr addObject:nightModel];
        }
        
        /// NOTE: 好友分享  顺序19
        MainSettingModel * sharedModel = [[MainSettingModel alloc] init];
        sharedModel.settingType = SettingType_ShareWithFriends;
        [friendShareGroupArr addObject:sharedModel];
        
        /// NOTE: 摄像头时间校验  顺序20
        MainSettingModel * timeCheckModel = [[MainSettingModel alloc] init];
        timeCheckModel.settingType = SettingType_TimeCheck;
        [deviceInfoArr addObject:timeCheckModel];
        
        /// NOTE: WiFi设置  顺序21
        MainSettingModel * wifiModel = [[MainSettingModel alloc] init];
        wifiModel.settingType = SettingType_WiFiSetting;
        [deviceInfoArr addObject:wifiModel];
        
        /// NOTE: 设备信息  顺序22
        MainSettingModel * deviceInfomodel = [[MainSettingModel alloc] init];
        deviceInfomodel.settingType = SettingType_DeviceInfo;
        [deviceInfoArr addObject:deviceInfomodel];
    }
    /// 设备在线&
    /// NOTE:主权限为分享
    else if (devDataModel.DeviceOwner == DevOwn_share) {
        
    }
    
    /// NOTE:相册 顺序14
    MainSettingModel * photoModel = [[MainSettingModel alloc] init];
    photoModel.settingType = SettingType_PhotoAlbum;
    photoModel.cellType =  SettingCellType_HasNext;
    photoModel.nameStr = DPLocalizedString(@"Setting_PhotoAlbum");
    photoModel.imageStr = @"icon_album";
    [manualRecordGroupArr addObject:photoModel];
    
    /// 云储存判断
    //    if (StreamStoreCloud != _ipcDevListTBCellData.devCapacity.streamStoreType)
    
    
    
    
    /*-----------------------<分割线>------------------------------*/
    
    /// NOTE:蜂窝移动网络自动暂停 顺序12  好像也用不上了
    //    MainSettingModel * autoPauseModel = [[MainSettingModel alloc] init];
    //    autoPauseModel.settingType = SettingType_CellularDataAutoPause;
    //    autoPauseModel.cellType =  SettingCellType_Switch;
    //    autoPauseModel.nameStr = DPLocalizedString(@"Setting_CellularDataAutoPause");
    //    autoPauseModel.imageStr = @"icon_CellularData";
    //    [cameraSwitchGroupArr addObject:autoPauseModel];
    
    
    
    /// NOTE: 好像去掉了
    //    MainSettingModel * horizontalFlipModel = [[MainSettingModel alloc] init];
    //    horizontalFlipModel.settingType = SettingType_HorizontalFlip;
    //    horizontalFlipModel.cellType =  SettingCellType_Switch;
    //    horizontalFlipModel.nameStr = @"水平翻转";
    //    horizontalFlipModel.imageStr = @"icon_FlipHorizontal";
    //    [customGroupArr addObject:horizontalFlipModel];
    //
    //    MainSettingModel * vertivalModel = [[MainSettingModel alloc] init];
    //    vertivalModel.settingType = SettingType_VerticalFlip;
    //    vertivalModel.cellType =  SettingCellType_Switch;
    //    vertivalModel.nameStr = @"垂直翻转";
    //    vertivalModel.imageStr = @"icon_FlipVertical";
    //    [customGroupArr addObject:vertivalModel];
    
    
    NSMutableArray * backArr = [NSMutableArray arrayWithCapacity:1];
    if (customGroupArr.count > 0) {
        [backArr addObject:customGroupArr];
    }
    if (normalActionGroupArr.count > 0) {
        [backArr addObject:normalActionGroupArr];
    }
    if (cameraSwitchGroupArr.count > 0) {
        [backArr addObject:cameraSwitchGroupArr];
    }
    if (manualRecordGroupArr.count > 0) {
        [backArr addObject:manualRecordGroupArr];
    }
    if (cloudServiceGroupArr.count > 0) {
        [backArr addObject:cloudServiceGroupArr];
    }
    if (hardwareGroupArr.count > 0) {
        [backArr addObject:hardwareGroupArr];
    }
    if (friendShareGroupArr.count > 0) {
        [backArr addObject:friendShareGroupArr];
    }
    if (deviceInfoArr.count > 0) {
        [backArr addObject:deviceInfoArr];
    }
    return backArr;
}


#pragma mark - 返回设置界面的开关状态
+ (NSArray *) updateTableDataArr:(NSArray *) tableDataArr
                   allParamModel:(AllParamModel *) allParamModel{
    
    // 摄像头开关
    MainSettingModel * cameraSwitchModel = [self modelWithSettingType:SettingType_CameraSwitch tableDatarArr:tableDataArr];
    cameraSwitchModel.switchState = allParamModel.isCameraOn;
    
    // 麦克风开关
    MainSettingModel * microphoneModel = [self modelWithSettingType:SettingType_CameraMicrophone tableDatarArr:tableDataArr];
    microphoneModel.switchState = allParamModel.isDevMicOn;
    
    // 状态指示灯
    MainSettingModel * statusIndicatorModel = [self modelWithSettingType:SettingType_StatusIndicator tableDatarArr:tableDataArr];
    statusIndicatorModel.switchState = allParamModel.isStatusLampOn;
    
    // 旋转180度  无接口
    MainSettingModel * rotatingModel = [self modelWithSettingType:SettingType_RotateSemicircle tableDatarArr:tableDataArr];
    rotatingModel.switchState = allParamModel.videMode == Video_mirror?YES:NO;
    
    
    // 手动录像
    MainSettingModel * SdCardSlotModel = [self modelWithSettingType:SettingType_ManualRecord tableDatarArr:tableDataArr];
    SdCardSlotModel.switchState = allParamModel.isManualRecOn;
    
    // 红外侦测
    MainSettingModel * pirModel = [self modelWithSettingType:SettingType_PIRDetection tableDatarArr:tableDataArr];
    pirModel.switchState = allParamModel.isPirDetectOn;
    
    
    // 蜂窝移动网络自动暂停  无接口
    //    MainSettingModel * autoPauseModel = [self modelWithSettingType:SettingType_StatusIndicator tableDatarArr:tableDataArr];
    //    autoPauseModel.switchState = allParamModel.isPirDetectOn;
    
    //   水平翻转
    //    MainSettingModel * horizontalModel = [self modelWithSettingType:SettingType_HorizontalFlip tableDatarArr:tableDataArr];
    //    horizontalModel.switchState = allParamModel.isPirDetectOn;
    
    //   垂直翻转
    //    MainSettingModel * vertivalModel = [self modelWithSettingType:SettingType_VerticalFlip tableDatarArr:tableDataArr];
    //    vertivalModel.switchState = allParamModel.isPirDetectOn;
    
    return tableDataArr;
}


#pragma mark - 更新云储存显示:剩余时间或未购买
+ (void) updateValidCloudSerVice:(NSArray *) tableDataArr
                  packageCloudModel:(PackageValidTimeApiRespModel *) packageCloudModel{
    // 云套餐服务
    MainSettingModel * cloudModel = [self modelWithSettingType:SettingType_CloudService tableDatarArr:tableDataArr];
    cloudModel.PackageModel = packageCloudModel;
    cloudModel.cloudServiceDateLife = DPLocalizedString(@"Mine_OrderNow");
    if (packageCloudModel) {
         cloudModel.cloudServiceDateLife = [NSString stringWithFormat:@"%@%@",packageCloudModel.dataLife,DPLocalizedString(@"CS_PackageType_Days")];
    }
}

#pragma mark - 是否支持情景任务(如果有声光报警器，则支持)
+ (void) hasSensorTaskModel:(NSArray<IotSensorModel *>*)IotSensorArr
               tableDataArr:(NSArray <NSMutableArray *> *) tableArr
               devDataModel:(DevDataModel *) devDataModel{
    __block BOOL hasSensor = NO;
    [IotSensorArr enumerateObjectsUsingBlock:^(IotSensorModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (GosIot_sensorAudibleAlarm == obj.iotSensorType) {
            hasSensor = YES;
            *stop = YES;
        }
    }];

    if (hasSensor) {
        [tableArr enumerateObjectsUsingBlock:^(NSMutableArray * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (idx == 0 && DevOwn_owner == devDataModel.DeviceOwner) {
                /// NOTE:情景任务 顺序3  如果传感器里有声光报警器 就加上
                MainSettingModel * sceneTaskModel = [[MainSettingModel alloc] init];
                sceneTaskModel.settingType = SettingType_SceneTask;
                sceneTaskModel.cellType =  SettingCellType_HasNext;
                sceneTaskModel.nameStr = DPLocalizedString(@"Setting_SceneTask");
                sceneTaskModel.imageStr = @"icon_SceneTask";
                [obj addObject:sceneTaskModel];
                *stop = YES;
            }
        }];
    }
}

#pragma mark - 更新设置界面显示数据
+ (void) updateNightVersionWithDataArr:(NSArray *) tableDataArr
                      nightVisionModel:(NightVisionModel *) nightVisionModel{
    // 夜视开关
    MainSettingModel * nightVersionModel = [self modelWithSettingType:SettingType_NightVersion tableDatarArr:tableDataArr];
    nightVersionModel.nightVersionStr = nightVisionModel.isAuto?DPLocalizedString(@"NightVersion_Auto"):DPLocalizedString(@"NightVersion_Open");
}

//+ (void)reductSwitchState:(SwitchType)switchType{
//   
//}

+ (NSArray <NSMutableArray *> *)getDefaultAbilityDevModel:(DevDataModel *)devModel{
    /// NOTE:相册+TF卡手动录像
    NSMutableArray * manualRecordGroupArr = [NSMutableArray arrayWithCapacity:1];
    /// NOTE: 好友分享
    NSMutableArray * friendShareGroupArr = [NSMutableArray arrayWithCapacity:1];
    /// NOTE:摄像头时间校验+WiFi设置+设备信息
    NSMutableArray * deviceInfoArr = [NSMutableArray arrayWithCapacity:1];
    switch (devModel.DeviceOwner) {
        case DevOwn_share:{     //  分享权限
            /// NOTE:相册 顺序14
            MainSettingModel * photoModel = [[MainSettingModel alloc] init];
            photoModel.settingType = SettingType_PhotoAlbum;
            photoModel.cellType =  SettingCellType_HasNext;
            photoModel.nameStr = DPLocalizedString(@"Setting_PhotoAlbum");
            photoModel.imageStr = @"icon_album";
            [manualRecordGroupArr addObject:photoModel];
        }break;
            
        case DevOwn_owner:{     //  主权限
            /// NOTE:相册 顺序14
            MainSettingModel * photoModel = [[MainSettingModel alloc] init];
            photoModel.settingType = SettingType_PhotoAlbum;
            photoModel.cellType =  SettingCellType_HasNext;
            photoModel.nameStr = DPLocalizedString(@"Setting_PhotoAlbum");
            photoModel.imageStr = @"icon_album";
            [manualRecordGroupArr addObject:photoModel];
            
            /// NOTE: 好友分享  顺序19
            MainSettingModel * sharedModel = [[MainSettingModel alloc] init];
            sharedModel.settingType = SettingType_ShareWithFriends;
            [friendShareGroupArr addObject:sharedModel];
            
            /// NOTE: WiFi设置  顺序21
            MainSettingModel * wifiModel = [[MainSettingModel alloc] init];
            wifiModel.settingType = SettingType_WiFiSetting;
            [deviceInfoArr addObject:wifiModel];
            
            /// NOTE: 设备信息  顺序22
            MainSettingModel * deviceInfomodel = [[MainSettingModel alloc] init];
            deviceInfomodel.settingType = SettingType_DeviceInfo;
            [deviceInfoArr addObject:deviceInfomodel];
        }break;
            
        default:
            break;
    }
    NSMutableArray * backArr = [NSMutableArray arrayWithCapacity:1];
    if (manualRecordGroupArr.count > 0) {
        [backArr addObject:manualRecordGroupArr];
    }
 
    if (friendShareGroupArr.count > 0) {
        [backArr addObject:friendShareGroupArr];
    }
    if (deviceInfoArr.count > 0) {
        [backArr addObject:deviceInfoArr];
    }
    return backArr;
}
+ (MainSettingModel *) modelWithSettingType:(SettingType) settingType
                              tableDatarArr:(NSArray *)tableDataArr{
    for (id element in tableDataArr) {
        if ([element isKindOfClass:[NSArray class]]) {
            for (MainSettingModel * model in element) {
                if (model.settingType == settingType) {
                    return model;
                }
            }
        }else if(((MainSettingModel *)element).settingType == settingType){
            return element;
        }
    }
    return nil;
}

@end
