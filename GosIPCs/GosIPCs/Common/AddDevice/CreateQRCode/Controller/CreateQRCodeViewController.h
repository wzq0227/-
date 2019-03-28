//
//  CreateQRCodeViewController.h
//  ULife3.5
//
//  Created by 罗乐 on 2018/9/15.
//  Copyright © 2018年 GosCam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DeviceAddModel.h"

@interface CreateQRCodeViewController : UIViewController

@property (nonatomic,strong) NSString *wifiStr;
@property (nonatomic,strong) NSString *wifiPWD;
@property (nonatomic,strong) NSString *deviceID;
@property (nonatomic,strong) NSString *devName;
@property (nonatomic,assign) GosDeviceType deviceType;  //设备类型
@property (nonatomic,strong) DeviceAddModel *devModel;

@end
