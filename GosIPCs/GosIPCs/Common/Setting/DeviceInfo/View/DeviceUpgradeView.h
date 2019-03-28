//  DeviceUpgradeView.h
//  Goscom
//
//  Create by 匡匡 on 2018/12/8.
//  Copyright © 2018 goscam. All rights reserved.

#import <UIKit/UIKit.h>
typedef NS_ENUM(NSUInteger, UpdateStage) {
    UpdateStageBegin,       ///  准备更新
    UpdateStageDownloading, ///  正在下载
    UpdateStageUpdating,    ///  正在更新
    UpdateStageSucceeded,   ///  更新成功
    UpdateStageFailed,      ///  更新失败
    UpdateStageCancelled,   ///  取消更新
};
NS_ASSUME_NONNULL_BEGIN
@protocol DeviceUpgradeViewDelegate <NSObject>
@optional;
-(void) DeviceUpgradeCancel;

@end
@interface DeviceUpgradeView : UIView
/// 代理
@property (nonatomic, weak) id<DeviceUpgradeViewDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIButton *cancelBtn;
/// 进度条进度
@property (nonatomic, assign) float viewProgress;
/// 升级返回值
@property (nonatomic, assign) int upgradeResult;
/// 升级状态
@property (nonatomic, assign) UpdateStage updateStage;
///  把更新请求的result 和更新状态一起传进来
-(void) setUpgradeResult:(int) result andUpdateStage:(UpdateStage) updateStage;
@end

NS_ASSUME_NONNULL_END
