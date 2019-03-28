//  ClipViewController.h
//  GosIPCs
//
//  Create by daniel.hu on 2019/2/27.
//  Copyright © 2019年 goscam. All rights reserved.

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class VideoSlicesApiRespModel;

@interface ClipViewController : UIViewController
- (instancetype)initWithDeviceId:(NSString *)deviceId
                  startTimestamp:(NSTimeInterval)startTimestamp
                        duration:(NSUInteger)duration;

- (instancetype)initWithDeviceId:(NSString *)deviceId
                          videos:(NSArray <VideoSlicesApiRespModel *> *)videos
                  startTimestamp:(NSTimeInterval)startTimestamp
                       startTime:(NSUInteger)startTime
                        duration:(NSUInteger)duration;
@end

NS_ASSUME_NONNULL_END
