//
//  WiFiSettingVC.h
//  Goscom
//
//  Created by 匡匡 on 2018/11/29.
//  Copyright © 2018 goscam. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DevDataModel;
NS_ASSUME_NONNULL_BEGIN

/**
 WiFi设置界面
 */
@interface WiFiSettingVC : UIViewController
//@property (nonatomic, strong) NSString * DeviceID;   // 设备ID
@property (nonatomic, strong) DevDataModel * dataModel;   // 设备模型
@end

NS_ASSUME_NONNULL_END
