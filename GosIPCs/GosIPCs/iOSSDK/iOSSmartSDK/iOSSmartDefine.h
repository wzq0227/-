//
//  iOSSmartDefine.h
//  iOSSmartSDK
//
//  Created by shenyuanluo on 2018/1/24.
//  Copyright © 2018年 goscam. All rights reserved.
//

#ifndef iOSSmartDefine_h
#define iOSSmartDefine_h


#define SmartLocalizedString(s) [LocalizableStrings LocalizedString:s]    // 多语言化

/* 展示扫描二维码页面方式类型枚举 */
typedef NS_ENUM(NSInteger, ScaneQRVCShowType) {
    ScaneQRVCShow_presend           = 0,    // Presend (默认）
    ScaneQRVCShow_push              = 1,    // Push
};

/** 设备区域类型 枚举*/
typedef NS_ENUM(NSInteger, DevAreaType) {
    DevArea_unknown                 = 0,            // 未知
    DevArea_domestic                = 0x01,         // 国内
    DevArea_overseas                = 0x02,         // 国外
};

/** 设备类型 枚举 */
typedef NS_ENUM(NSInteger, DevType) {
    Dev_unknown                     = 0,            // 未知类型
    Dev_ipc                         = 0x01,         // 普通 IPC
    Dev_nvr                         = 0x02,         // NVR
    Dev_pano360                     = 0x03,         // 全景360
    Dev_pano180                     = 0x04,         // 全景180
};

/** 二维码支持的添加方式 枚举 */
typedef NS_ENUM(NSInteger, SupportAddStyle) {
    SupportAdd_unknown              = 0,            // 未知
    SupportAdd_wifi                 = 0x01,         // 'WiFi（Smart）'添加
    SupportAdd_scan                 = 0x02,         // '扫描二维码'添加
    SupportAdd_apMode               = 0x03,         // 'AP模式' 添加
    SupportAdd_wlan                 = 0x04,         // '网线'添加
    SupportAdd_share                = 0x05,         // '好友分享'添加
    SupportAdd_voice                = 0x06,         // 声波添加
    SupportAdd_apNew                = 0x07,         // 新AP 方式 类门铃
    SupportAdd_4G                   = 0x08,         // '4G' 添加
};

/** Smart 连接 状态枚举 */
typedef NS_ENUM(NSInteger, SmartLinkStatus) {
    SmartLink_failure           = -1,       // 失败
    SmartLink_start             = 0,        // 开始 Smart 连接
    SmartLink_success           = 1,        // 成功
};

typedef struct _smartWifiinfo
{
    char wifiSsid[128];
    char password[128];
    int signalLevel;
}SmartWifiInfo;

typedef struct _smartWifiList{
    SmartWifiInfo *plist;
    int totalcount;
}SmartWifiList;


#endif /* iOSSmartDefine_h */
