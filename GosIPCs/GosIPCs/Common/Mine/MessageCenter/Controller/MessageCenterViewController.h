//  MessageCenterViewController.h
//  GosIPCs
//
//  Create by daniel.hu on 2018/11/22.
//  Copyright © 2018年 goscam. All rights reserved.

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MessageCenterViewController : UIViewController

/**
 初始化方法

 @param deviceId 设备ID可为空，为空时显示的就是全部的通知消息
 @return MessageCenterViewController
 */
- (instancetype)initWithDeviceID:(nullable NSString *)deviceId;
@end

NS_ASSUME_NONNULL_END
