//  SceneTaskSelectDeviceVC.h
//  Goscom
//
//  Create by 匡匡 on 2018/12/29.
//  Copyright © 2018 goscam. All rights reserved.

#import <UIKit/UIKit.h>
@class DevDataModel;
@class IotSensorModel;
@class IotSceneTask;
@protocol sceneTaskSelectDelegate <NSObject>

- (void) didSelectSceneTaskIotModel:(NSArray<IotSensorModel *>*) IotSensorArr
                             isTask:(BOOL) isTask;

@end
NS_ASSUME_NONNULL_BEGIN
/**
 情景任务选择设备界面
 */
@interface SceneTaskSelectDeviceVC : UIViewController
/// 代理
@property (nonatomic, weak) id<sceneTaskSelectDelegate> delegate;
/// 数据模型
@property (nonatomic, strong) DevDataModel * devModel;
/// YES 任务 NO 条件
@property (nonatomic, assign,getter=isTask) BOOL task;
/// IOT数据模型
@property (nonatomic, strong) IotSceneTask * dataModel;
@end

NS_ASSUME_NONNULL_END
