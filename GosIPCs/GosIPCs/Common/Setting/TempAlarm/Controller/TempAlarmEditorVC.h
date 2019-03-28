//
//  TempAlarmEditorVC.h
//  Goscom
//
//  Created by 匡匡 on 2018/11/22.
//  Copyright © 2018 goscam. All rights reserved.
//

#import <UIKit/UIKit.h>
@class TemDetectModel;

/**
 编辑温度报警界面
 */
@interface TempAlarmEditorVC : UIViewController
@property (nonatomic, strong) NSString * deviceId;   // 设备ID
@property (nonatomic, strong) TemDetectModel * tempDataModel;   // 温度的模型
@end
