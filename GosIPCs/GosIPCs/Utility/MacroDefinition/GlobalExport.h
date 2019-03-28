//
//  GlobalExport.h
//  GosIPCs
//
//  Created by ShenYuanLuo on 2018/12/26.
//  Copyright © 2018年 goscam. All rights reserved.
//

#import <Foundation/Foundation.h>

/** 按钮状态 */
typedef NS_ENUM(NSInteger, ButtonStatus) {
    Button_disble               = -1,   // 不可用
    Button_normal               = 0,    // 普通
    Button_highlight            = 1,    // 高亮
};

/** 当前网络状态 枚举*/
typedef NS_ENUM(NSInteger, CurNetworkStatus) {
    CurNetwork_unknow           = 0,    // 未知（或网络不可达）
    CurNetwork_wifi             = 1,    // WiFi 连接
    CurNetwork_2G               = 2,    // 蜂窝数据连接 - 2G
    CurNetwork_3G               = 3,    // 蜂窝数据连接 - 3G
    CurNetwork_4G               = 4,    // 蜂窝数据连接 - 4G
};

@interface GlobalExport : NSObject

// 流媒体服务器地址（北美）
FOUNDATION_EXPORT NSString * const kStreamServerAddrsNorthAmerica;
// 流媒体服务器地址（欧洲）
FOUNDATION_EXPORT NSString * const kStreamServerAddrsEuropean;
// 流媒体服务器地址（中国）
FOUNDATION_EXPORT NSString * const kStreamServerAddrsChina;
// 流媒体服务器地址（亚太）
FOUNDATION_EXPORT NSString * const kStreamServerAddrsAsiaPacific;
// 流媒体服务器地址（中东）
FOUNDATION_EXPORT NSString * const kStreamServerAddrsMiddleEast;

// 自动登录成功通知 key
FOUNDATION_EXPORT NSString * const kAutoLoginSuccessNotify;
// 登录成功通知 key (用于处理 APNS-Remote token 注册到服务器)
FOUNDATION_EXPORT NSString * const kLoginSuccessNotify;
// 注销成功通知
FOUNDATION_EXPORT NSString * const kLogoutSuccessNotify;

// 当前预览设备在线状态通知 key
FOUNDATION_EXPORT NSString * const kCurPreviewDevStatusNotify;
// 当前预览设备正在创建连接通知 key
FOUNDATION_EXPORT NSString * const kCurDevConnectingNotify;
// 重新断开连接再创建连接通知（用于拉流失败多次情况，其他情况请慎用）
FOUNDATION_EXPORT NSString * const kReDisConnAndConnAgainNotify;

// APNS_MSG 已解析并成功保存至数据库通知
FOUNDATION_EXPORT NSString * const kPushMsgSaveSuccessNotify;
// 已查询得推送状态结果通知
FOUNDATION_EXPORT NSString * const kCheckedPushStatusNotify;
// 点击 iOS 消息中心解析推送消息通知
FOUNDATION_EXPORT NSString * const kClickPushMsgNotify;
// 点击 iOS 消息中心解析推送消息并同步更新设备列表通知
FOUNDATION_EXPORT NSString * const kClickPushMsgToUpdateListNotify;
// 预览界面是否正在展示通知
FOUNDATION_EXPORT NSString * const kIsVideoShowingNotify;


// 推送消息已读通知（消息详情页，不是由消息列表页 push 的情况）
FOUNDATION_EXPORT NSString * const kPushMsgHasReadedNotify;

// 开始下载 TF 卡录制图片通知（浏览翻页时）
FOUNDATION_EXPORT NSString * const kStartDownloadTFPhotoNotify;

// 计量大小（GB = 1024 * 1024 * 1024）
FOUNDATION_EXPORT NSUInteger kMeasureSizeGB;
// 计量大小（MB = 1024 * 1024）
FOUNDATION_EXPORT NSUInteger kMeasureSizeMB;
// 计量大小（KB = 1024）
FOUNDATION_EXPORT NSUInteger kMeasureSizeKB;

// TF 图片下载 row key
FOUNDATION_EXPORT NSString * const kDownloadTFPhotoRowKey;
// TFCRMediaModel key
FOUNDATION_EXPORT NSString * const kTFMediaKey;
// Cell Row key
FOUNDATION_EXPORT NSString * const kRowIndexKey;

// 已登录过的账号 key
FOUNDATION_EXPORT NSString * const kHistoryAccountList;

// 网络监测通知 - key @{@"CurNetworkStatus" : @(CurNetworkStatus)}
FOUNDATION_EXPORT NSString * const kCurNetworkChangeNotify;

// 封面保存成功通知
FOUNDATION_EXPORT NSString * const kSaveCoverNotify;
// 修改设备属性通知
FOUNDATION_EXPORT NSString * const kModifyDevInfoNotify;
// 删除设备通知
FOUNDATION_EXPORT NSString * const kDeleteDeviceNotify;

/// 扫描二维码提示框 (添加设备)不再提醒
FOUNDATION_EXPORT NSString * const kNoRemindAddNotify;
//// 扫描二维码提示框 (WiFi设置)不再提醒
FOUNDATION_EXPORT NSString * const kNoRemindWiFiNotify;
@end
