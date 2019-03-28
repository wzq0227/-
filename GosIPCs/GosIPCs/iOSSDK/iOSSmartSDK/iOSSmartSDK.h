//
//  iOSSmartSDK.h
//  iOSSmartSDK
//
//  Created by shenyuanluo on 2018/1/22.
//  Copyright © 2018年 goscam. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "iOSSmartDefine.h"
#import <UIKit/UIKit.h>
#import "LanDeviceInfoModel.h"

@protocol iOSSmartDelegate <NSObject>
@optional

/**
 扫描二维码解析回调

 @param isSuccess 是否解析成功；YES：成功，NO：失败
 @param devId 设备 ID
 @param areaType 设备区域类型，参见‘DevAreaType’
 @param devType 设备类型，参见‘DevType’
 @param styleList 支持添加方式列表，参见‘SupportAddStyle’
 @param isSupport 是否支持硬解绑；YES：支持，NO：不支持
 */
- (void)scanResult:(BOOL)isSuccess
          deviceId:(NSString *)devId
          areaType:(DevAreaType)areaType
        deviceType:(DevType)devType
   supportAddStyle:(NSArray <NSNumber *>*)styleList
       forceUnBind:(BOOL)isSupport;

/**
 Smart 连接结果回调（WiFi + 扫码 + 网线 模式添加）
 
 @param slStatus 连接结果，参见‘SmartLinkStatus’
 */
- (void)smartLinkResult:(SmartLinkStatus)slStatus;

/**
 查询 WiFi 列表回调（AP 模式添加）

 @param isSuccess 是否查询成功；YES：成功，NO：失败
 @param wifiList WiFi 列表，结构参见‘SmartWifiList’
 */
- (void)reqWIFI:(BOOL)isSuccess
           list:(SmartWifiList *)wifiList;

/**
 配置设备连接 WiFi 是否成功（AP 模式添加）

 @param isSuccess 是否配置成功；YES：成功，NO：失败
 */
- (void)connToWifi:(BOOL)isSuccess;

/**
 搜索并获取设备信息
 
 @param isSuccess 是否获取成功；YES：成功，NO：失败
 @param devInfo 设备信息
 */
- (void)isExtract:(BOOL)isSuccess
       forDevInfo:(LanDeviceInfoModel *)devInfo;

@end


@interface iOSSmartSDK : NSObject
@property (nonatomic, weak) id<iOSSmartDelegate>delegate;

+ (instancetype)shareSmartSdk;

/**
 扫描二维码
 
 @param showType 扫描控制器展示类型，参见‘ScaneQRVCShowType’
 @param isAutoDismiss 扫描后是否自动退出控制器；YES：自动退出，NO：不自动退出（则须调用 removeScanVC 接口）
 */
- (void)scanQrCodeWithShowType:(ScaneQRVCShowType)showType
                   autoDismiss:(BOOL)isAutoDismiss;
/**
 移除扫描控制器
 */
- (void)removeScanVC;

/**
 Smart搜索连接（WiFi + 扫描 + 网线）
 
 @param ssid （APP 连接的）WiFi 名称
 @param pwd （APP 连接的）WiFi 密码
 @param devId 设备 ID
 @param isWifi 是否是 WiFi 添加方式
 */
- (void)smartLinkByWifi:(NSString *)ssid
           withPassowrd:(NSString *)pwd
               deviceId:(NSString *)devId
              isWifiAdd:(BOOL)isWifi;

/**
 生成二维码（扫描添加）
 
 @param ssid WiFi 名称
 @param pwd WiFi 密码
 @param devId 设备 ID
 @return 二维码 Image
 */
- (UIImage *)genQRCodeWithSsid:(NSString *)ssid
                       wifiPwd:(NSString *)pwd
                      deviceId:(NSString *)devId;

/**
 搜索设备并查询 WiFi 列表（AP 模式添加）

 @param devId 设备 ID
 @param tout 超时时间（单位：毫秒）
 */
- (void)queryWifiListWithDevId:(NSString *)devId
                       timeout:(int)tout;

/**
 搜索并配置设备连接指定的 WiFi（AP 模式添加）

 @param devId 设备 ID
 @param ssid WiFi ssid
 @param pwd WiFi 密码
 @param tout 超时时间（单位：毫秒）
 */
- (void)configDeviceId:(NSString *)devId
            connToWifi:(NSString *)ssid
          withPassword:(NSString *)pwd
               timeout:(int)tout;

/**
 搜索并获取设备信息
 
 @param devId 设备 ID
 @param tout 超时时间（单位：毫秒）
 */
- (void)extractInfoWithDevId:(NSString *)devId
                     timeout:(int)tout;

/**
 生成二维码（分享添加）

 @param devId 设备 ID
 @return 二维码 image
 */
- (UIImage *)genShareQRCodeWithDeviId:(NSString *)devId;

@end
