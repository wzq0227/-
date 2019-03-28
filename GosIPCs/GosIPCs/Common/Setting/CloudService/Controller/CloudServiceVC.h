//
//  CloudServiceVC.h
//  Goscom
//
//  Created by 匡匡 on 2018/11/20.
//  Copyright © 2018 goscam. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DevDataModel;

/**
 云录制套餐界面
 */
@interface CloudServiceVC : UIViewController
@property (nonatomic, strong) DevDataModel * dataModel;   // 设备模型
@end
