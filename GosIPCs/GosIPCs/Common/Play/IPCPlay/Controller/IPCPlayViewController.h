//
//  IPCPlayViewController.h
//  GosIPCs
//
//  Created by shenyuanluo on 2018/12/3.
//  Copyright © 2018 goscam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iOSConfigSDK.h"
#import "DevAbilityManager.h"

NS_ASSUME_NONNULL_BEGIN


@interface IPCPlayViewController : UIViewController

@property (nonatomic, readwrite, assign) BOOL hasConnected; // 设备是否已经建立连接
@property (nonatomic, readwrite, strong) DevDataModel *devModel;
@property (nonatomic, readwrite, strong) AbilityModel *abModel;

+ (instancetype)shareIpcPlayVC;

@end

NS_ASSUME_NONNULL_END
