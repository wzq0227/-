//
//  AddDeviceFirstViewController.h
//  ULife3.5
//
//  Created by 罗乐 on 2018/9/13.
//  Copyright © 2018年 GosCam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DeviceAddModel.h"
#import "ChooseAddMethodViewController.h"

@interface AddDeviceFirstViewController : UIViewController

@property (strong, nonatomic) DeviceAddModel *devModel;

- (ChooseAddMethodViewController *)getChooseAddMethodViewController;

@end
