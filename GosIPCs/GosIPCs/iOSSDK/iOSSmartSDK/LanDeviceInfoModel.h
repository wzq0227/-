//
//  LanDeviceInfoModel.h
//  iOSSmartSDK
//
//  Created by shenyuanluo on 2018/12/5.
//  Copyright © 2018 goscam. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/*
 局域网搜索到的设备信息类
 */
@interface LanDeviceInfoModel : NSObject <NSCoding, NSCopying, NSMutableCopying>

@property (nonatomic, readwrite, assign) int status;
@property (nonatomic, readwrite, assign) int isGroup;
@property (nonatomic, readwrite, assign) int selfID;
@property (nonatomic, readwrite, assign) int parentID;
/** 软件版本 */
@property (nonatomic, readwrite, copy) NSString *softWareVersion;
/** 硬件版本*/
@property (nonatomic, readwrite, copy) NSString *hardWareVersion;
/** 设备 ID */
@property (nonatomic, readwrite, copy) NSString *deviceId;
/** 设备名称 */
@property (nonatomic, readwrite, copy) NSString *deviceName;
/** tips */
@property (nonatomic, readwrite, copy) NSString *keyText;
/** 服务器地址 */
@property (nonatomic, readwrite, copy) NSString *serverUrl;
/** 设备类型 */
@property (nonatomic, readwrite, copy) NSString *deviceType;
/** 设备网络类型 */
@property (nonatomic, readwrite, assign) int netType;
/** 设备 IP */
@property (nonatomic, readwrite, copy) NSString *deviceIP;
/** 设备 MAC 地址 */
@property (nonatomic, readwrite, copy) NSString *deviceMacAddress;
/** WiFi 名称 */
@property (nonatomic, readwrite, copy) NSString *wifiSsid;
/** WiFi 密码 */
@property (nonatomic, readwrite, copy) NSString *password;
/** 是否支持硬解绑 */
@property (nonatomic, readwrite, assign, getter=isSupportForceUnBind) BOOL supportForceUnBind;

@end

NS_ASSUME_NONNULL_END
