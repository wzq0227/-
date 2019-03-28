//
//  AlertTipsView.h
//  Goscom
//
//  Created by 匡匡 on 2018/11/29.
//  Copyright © 2018 goscam. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AlertTipsView : UIView
// 扫描二维码提示框 (添加设备)不再提醒   kNoRemindAddNotify
// 扫描二维码提示框 (WiFi设置)不再提醒  kNoRemindWiFiNotify

/// 是否是添加设备(YES 添加设备  NO 修改设备二维码)
@property (nonatomic, assign) BOOL isAddDevice;
/// GIF 动图
@property (weak, nonatomic) IBOutlet UIImageView *topGifImg;
/// 提示语label
@property (weak, nonatomic) IBOutlet UILabel *tipsLab;
/// 确定按钮
@property (weak, nonatomic) IBOutlet UIButton *confirmBtn;
/// 选择按钮
@property (weak, nonatomic) IBOutlet UIButton *selectBtn;
/// 不再提醒文字
@property (weak, nonatomic) IBOutlet UILabel *notRemindLabel;


@end

NS_ASSUME_NONNULL_END
