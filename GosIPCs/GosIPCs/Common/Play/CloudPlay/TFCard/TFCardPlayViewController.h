//  TFCardPlayViewController.h
//  GosIPCs
//
//  Create by daniel.hu on 2019/2/19.
//  Copyright © 2019年 goscam. All rights reserved.

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 TFCard 流播
 */
@interface TFCardPlayViewController : UIViewController

/**
 初始化

 @param deviceId 设备id
 @param targetTimestamp 推送时间戳
 @return TFCardPlayViewController
 */
- (instancetype)initWithDeviceId:(NSString *)deviceId
                 targetTimestamp:(NSTimeInterval)targetTimestamp;

/**
 初始化

 @param deviceId 设备id
 @return TFCardPlayViewController
 */
- (instancetype)initWithDeviceId:(NSString *)deviceId;

@end

NS_ASSUME_NONNULL_END
