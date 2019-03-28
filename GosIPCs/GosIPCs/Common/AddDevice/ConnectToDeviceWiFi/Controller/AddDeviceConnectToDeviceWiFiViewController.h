//
//  AddDeviceConnectToDeviceWiFiViewController.h
//  ULife3.5
//
//  Created by 罗乐 on 2018/10/9.
//  Copyright © 2018 GosCam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DeviceAddModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface AddDeviceConnectToDeviceWiFiViewController : UIViewController

@property (nonatomic,strong) NSString *wifiStr;
@property (nonatomic,strong) NSString *wifiPWD;
@property (nonatomic,strong) DeviceAddModel *devModel;

@end

NS_ASSUME_NONNULL_END
