//
//  WiFiSettingOnlineVC.h
//  Goscom
//
//  Created by 匡匡 on 2018/11/29.
//  Copyright © 2018 goscam. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DevDataModel;
NS_ASSUME_NONNULL_BEGIN

/**
 配置设备端WiFi界面
 */
@interface WiFiSettingOnlineVC : UIViewController
@property (nonatomic, strong) DevDataModel * dataModel;   // 设备模型
@end

NS_ASSUME_NONNULL_END
