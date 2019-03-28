//
//  DeviceListViewController.h
//  Goscom
//
//  Created by shenyuanluo on 2018/11/10.
//  Copyright © 2018 shenyuanluo. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DeviceListViewController : UIViewController

/**是否有网络 */
@property (nonatomic, readwrite, assign) BOOL hasNetWork;
/** 是否已登录（用于判断自动登录模式下，没有网络的情况） */
@property (nonatomic, readwrite, assign) BOOL hasLogined;
/** 是否是自动登录 */
@property (nonatomic, readwrite, assign) BOOL isAutoLogin;
/** 是否是添加设备成功后跳转 */
@property (nonatomic, readwrite, assign) BOOL isAddSuccess;
@end

NS_ASSUME_NONNULL_END
