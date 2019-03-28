//
//  AddSOSVC.h
//  Goscom
//
//  Created by 匡匡 on 2018/11/30.
//  Copyright © 2018 goscam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ADDIotProtocol.h"
#import "AddSensorTypeModel.h"
#import "iOSConfigSDKDefine.h"
@class DevDataModel;
NS_ASSUME_NONNULL_BEGIN

/**
 添加SOS按钮界面
 */
@interface AddSOSVC : UIViewController
/// 传感器类型
@property (nonatomic, assign) GosIOTType gosIOTType;
/// 数据模型
@property (nonatomic, strong) DevDataModel * dataModel;
/// 代理
@property (nonatomic, weak) id<ADDIotProtocolDelegate> delegate;
@end

NS_ASSUME_NONNULL_END
