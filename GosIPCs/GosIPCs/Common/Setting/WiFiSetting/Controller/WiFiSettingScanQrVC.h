//
//  WiFiSettingScanQrVC.h
//  Goscom
//
//  Created by 匡匡 on 2018/11/29.
//  Copyright © 2018 goscam. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DevDataModel;
NS_ASSUME_NONNULL_BEGIN

/**
 扫描二维码界面
 */
@interface WiFiSettingScanQrVC : UIViewController
@property (nonatomic, strong) NSString * wifiName;   // wifi名
@property (nonatomic, strong) NSString * wifiPassword;   // wifi密码
@property (nonatomic, strong) DevDataModel * dataModel;     /// 数据模型

@end

NS_ASSUME_NONNULL_END
