//  CloudPlaybackViewController.h
//  GosIPCs
//
//  Create by daniel.hu on 2018/12/28.
//  Copyright © 2018年 goscam. All rights reserved.

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 云存储回放
 */
@interface CloudPlaybackViewController : UIViewController

/**
初始化

@param deviceId 设备id
@param targetTimestamp 推送时间戳
@return CloudPlaybackViewController
*/
- (instancetype)initWithDeviceId:(NSString *)deviceId
                 targetTimestamp:(NSTimeInterval)targetTimestamp;

/**
 初始化
 
 @param deviceId 设备id
 @return CloudPlaybackViewController
 */
- (instancetype)initWithDeviceId:(NSString *)deviceId;


@end

NS_ASSUME_NONNULL_END
