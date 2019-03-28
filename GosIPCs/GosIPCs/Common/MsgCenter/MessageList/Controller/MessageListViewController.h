//
//  MessageListViewController.h
//  GosIPCs
//
//  Created by ShenYuanLuo on 2018/12/17.
//  Copyright © 2018年 goscam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iOSConfigSDK.h"

@interface MessageListViewController : UIViewController

@property (nonatomic, readwrite, strong) DevDataModel *deviceModel;
/** 是否只显示当前设备的消息；YES：只显示当前设备的消息，NO：显示当前账号所有设备的消息 */
@property (nonatomic, readwrite, assign) BOOL isOnlyShowOnDevMsg;

@end
