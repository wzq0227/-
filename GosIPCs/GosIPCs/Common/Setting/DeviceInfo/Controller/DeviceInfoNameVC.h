//
//  DeviceInfoNameVC.h
//  Goscom
//
//  Created by 匡匡 on 2018/11/23.
//  Copyright © 2018 goscam. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DevDataModel;

@protocol DeviceInfoNameVCDelegate <NSObject>

-(void) modifyDeviceName:(DevDataModel *) dataModel;

@end
NS_ASSUME_NONNULL_BEGIN

/**
 设备名称名称界面
 */
@interface DeviceInfoNameVC : UIViewController
/// 代理
@property (nonatomic, weak) id<DeviceInfoNameVCDelegate> delegate;
@property (nonatomic, strong) DevDataModel * dataModel;   // 设备模型
@end

NS_ASSUME_NONNULL_END
