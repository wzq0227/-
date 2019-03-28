//
//  MsgSettingViewController.h
//  GosIPCs
//
//  Created by shenyuanluo on 2018/12/18.
//  Copyright © 2018 goscam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iOSConfigSDK.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^ConfigPushStatusResultBlock)(DevPushStatusModel *dpsModel);

@interface MsgSettingViewController : UIViewController

@property (nonatomic, readwrite, strong) DevDataModel *deviceModel;
/** 是否只显示当前设备推送设置；YES：只显示当前设备推送设置，NO：显示当前账号所有设备推送设置 */
@property (nonatomic, readwrite, assign) BOOL isOnlyShowOnDevMsg;

@end

NS_ASSUME_NONNULL_END
