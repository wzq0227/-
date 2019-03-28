//
//  AddDeviceWiFiSettingViewController.h
//  ULife3.5
//
//  Created by AnDong on 2018/8/22.
//  Copyright © 2018年 GosCam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DeviceAddModel.h"

///** 添加方式 */
//typedef NS_ENUM(NSInteger, ADDMethodsType) {
//    ADDMethodsTypeWifi               = 0,               // wifi添加
//    ADDMethodsTypeQrcode             = 1,               // 扫描二维码添加
//    ADDMethodsTypeAPMode             = 2,               // AP模式添加
//};

@interface AddDeviceWiFiSettingViewController : UIViewController

@property (strong, nonatomic)  DeviceAddModel *devModel;

@property (nonatomic, assign)  SupportAddStyle addMethodType;

@end
