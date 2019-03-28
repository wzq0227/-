//
//  AddDeviceConfigViewController.h
//  GosIPCs
//
//  Created by 罗乐 on 2018/12/6.
//  Copyright © 2018 goscam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DeviceAddModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface AddDeviceConfigViewController : UIViewController

@property (nonatomic, strong) DeviceAddModel *devModel;

@property (nonatomic, assign) SupportAddStyle addMethodType;

@end

NS_ASSUME_NONNULL_END
