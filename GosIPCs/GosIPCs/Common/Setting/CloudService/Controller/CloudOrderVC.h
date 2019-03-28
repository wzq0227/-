//
//  CloudOrderVC.h
//  Goscom
//
//  Created by 匡匡 on 2018/11/28.
//  Copyright © 2018 goscam. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DevDataModel;
@class CloudServiceModel;
NS_ASSUME_NONNULL_BEGIN

/**
 套餐订购界面
 */
@interface CloudOrderVC : UIViewController
/// 设备模型
@property (nonatomic, strong) DevDataModel * dataModel;
/// 套餐订购模型
@property (nonatomic, strong) CloudServiceModel * cloudServiceModel;
@end

NS_ASSUME_NONNULL_END
