//  VRPlayViewController.h
//  GosIPCs
//
//  Create by daniel.hu on 2018/12/6.
//  Copyright © 2018年 goscam. All rights reserved.

#import <UIKit/UIKit.h>
#import "iOSConfigSDK.h"


/// 显示类型
typedef NS_ENUM(NSInteger, VRPlayViewControllerDisplayType) {
    VRPlayViewControllerDisplayTypeVRLive,
    VRPlayViewControllerDisplayTypeVR360,
    VRPlayViewControllerDisplayTypeVR180,
};
NS_ASSUME_NONNULL_BEGIN


@interface VRPlayViewController : UIViewController
@property (nonatomic, readwrite, assign) BOOL hasConnected; // 设备是否已经建立连接
@property (nonatomic, readwrite, strong) DevDataModel *devModel;

- (instancetype)initWithDisplayType:(VRPlayViewControllerDisplayType)displayType;
@end

NS_ASSUME_NONNULL_END
