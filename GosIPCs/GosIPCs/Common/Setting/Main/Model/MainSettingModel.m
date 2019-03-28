//
//  MainSettingModel.m
//  Goscom
//
//  Created by 匡匡 on 2018/11/21.
//  Copyright © 2018 goscam. All rights reserved.
//

#import "MainSettingModel.h"
#import "iOSConfigSDKModel.h"


@implementation MainSettingModel
-(void)setSettingType:(SettingType)settingType{
    _settingType = settingType;
    switch (settingType) {
        case SettingType_Alexa:{  // Alexa
            self.cellType =  SettingCellType_HasNext;
            self.nameStr = DPLocalizedString(@"Setting_Alexa");
            self.imageStr = @"icon_access";
        }break;
        case SettingType_AddSensor: {   //  添加传感器
            self.cellType =  SettingCellType_HasNext;
            self.nameStr = DPLocalizedString(@"Setting_AddSensor");
            self.imageStr = @"icon_AddSensor";
        }break;
        case SettingType_SceneTask: {
            
            
        }break;
        case SettingType_LightDuration: {   //  灯照时长
            self.cellType =  SettingCellType_HasNext;
            self.nameStr = DPLocalizedString(@"Setting_LightDuration");
            self.imageStr = @"icon_light";
        }break;
        case SettingType_BabyMusic: {  // 音乐播放
            self.cellType =  SettingCellType_HasNext;
            self.nameStr = DPLocalizedString(@"Setting_BabyMusic");
            self.imageStr = @"icon_PlayMusic";
            
        }break;
        case SettingType_MotionDetection: {     //  移动侦测
            self.cellType =  SettingCellType_HasNext;
            self.nameStr = DPLocalizedString(@"Setting_MotionDetection");
            self.imageStr = @"icon_motion_32";
            
        }break;
        case SettingType_VoiceDetection: {      //  声音侦测
            self.cellType =  SettingCellType_HasNext;
            self.nameStr = DPLocalizedString(@"Setting_VoiceDetection");
            self.imageStr = @"icon_VoiceDetection";
            
        }break;
        case SettingType_PIRDetection: {    //  PIR（红外）侦测
            self.cellType =  SettingCellType_Switch;
            self.nameStr = DPLocalizedString(@"Setting_PIRDetection");
            self.imageStr = @"icon_infrared";
            
        }break;
        case SettingType_TempAlarmSetting: {    //  温度警报
            self.cellType =  SettingCellType_HasNext;
            self.nameStr = DPLocalizedString(@"Setting_TempAlarmSetting");
            self.imageStr = @"icon_temp";
            
        }break;
        case SettingType_CameraSwitch: {    //  摄像头开关
            self.cellType =  SettingCellType_Switch;
            self.nameStr = DPLocalizedString(@"Setting_CameraSwitch");
            self.imageStr = @"icon_CameraSwitch";
            
        }break;
        case SettingType_CameraMicrophone: {    //  摄像头麦克风
            self.cellType =  SettingCellType_Switch;
            self.nameStr = DPLocalizedString(@"Setting_CameraMicrophone");
            self.imageStr = @"icon_CameraMic";
            
        }break;
        case SettingType_CellularDataAutoPause: {
            
            
        }break;
        case SettingType_CloudService: {    //  云录制套餐
            self.cellType =  SettingCellType_State;
            self.nameStr = DPLocalizedString(@"Setting_CloudService");
            self.imageStr = @"icon_settingcloud";
            
        }break;
        case SettingType_ManualRecord: {    //  手动录像
            self.cellType =  SettingCellType_Switch;
            self.nameStr = DPLocalizedString(@"Setting_ManualRecord");
            self.imageStr = @"icon_Settingtf";
            
        }break;
        case SettingType_PhotoAlbum: {
            self.cellType =  SettingCellType_HasNext;
            self.nameStr = DPLocalizedString(@"Setting_PhotoAlbum");
            self.imageStr = @"icon_album";
            
        }break;
        case SettingType_StatusIndicator: {     //  状态指示灯
            self.cellType = SettingCellType_Switch;
            self.nameStr = DPLocalizedString(@"Setting_StatusIndicator");
            self.imageStr = @"icon_indicator";
            
        }break;
        case SettingType_RotateSemicircle: {     //  旋转视频图像180度
            self.cellType =  SettingCellType_Switch;
            self.nameStr = DPLocalizedString(@"Setting_RotateSemicircle");
            self.imageStr = @"icon_rotate";
            
        }break;
        case SettingType_NightVersion: {    //  夜视
            self.cellType =  SettingCellType_State;
            self.nameStr = DPLocalizedString(@"Setting_NightVersion");
            self.imageStr = @"icon_night";
            
        }break;
        case SettingType_ShareWithFriends: {    //  好友分享
            self.cellType =  SettingCellType_HasNext;
            self.nameStr = DPLocalizedString(@"Setting_ShareWithFriends");
            self.imageStr = @"icon_share";
        }break;
        case SettingType_TimeCheck: {   //  摄像头时间校验
            self.cellType =  SettingCellType_HasNext;
            self.nameStr = DPLocalizedString(@"Setting_TimeCheck");
            self.imageStr = @"icon_clock";
            
        }break;
        case SettingType_WiFiSetting: {     //  WiFi设置
            self.cellType =  SettingCellType_HasNext;
            self.nameStr = DPLocalizedString(@"Setting_WiFiSetting");
            self.imageStr = @"icon_wifi";
            
        }break;
        case SettingType_DeviceInfo: {      //  设备信息
            self.cellType =  SettingCellType_HasNext;
            self.nameStr = DPLocalizedString(@"Setting_DeviceInfo");
            self.imageStr = @"icon_info";
            
        }break;
        case SettingType_HorizontalFlip: {
            
            
        }break;
        case SettingType_VerticalFlip: {
            
            
        }break;
        case SettingType_BatteryLife: {
            
            
        }break;
        case SettingType_RecordingDuration: {
            
            
        }break;
        default:
            break;
    }
}
-(void)setAbilityModel:(AbilityModel *)abilityModel{
    _abilityModel = abilityModel;
}

@end
