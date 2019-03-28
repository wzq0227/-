//
//  AddSensorVC.h
//  Goscom
//
//  Created by 匡匡 on 2018/11/30.
//  Copyright © 2018 goscam. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DevDataModel;
NS_ASSUME_NONNULL_BEGIN

/**
 添加传感器界面
 */
@interface AddSensorVC : UIViewController
@property (nonatomic, strong) DevDataModel * dataModel;
@end

NS_ASSUME_NONNULL_END
