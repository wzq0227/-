//  AddSceneTaskVC.h
//  Goscom
//
//  Create by 匡匡 on 2018/12/29.
//  Copyright © 2018 goscam. All rights reserved.

#import <UIKit/UIKit.h>
@class IotSceneTask;
@class DevDataModel;
typedef void (^callBackBlock)(IotSceneTask * model);
typedef void (^callBackDeleteBlcok)(IotSceneTask * model);
NS_ASSUME_NONNULL_BEGIN
/**
 添加情景任务界面
 */
@interface AddSceneTaskVC : UIViewController
/// block
@property (nonatomic, copy) callBackBlock block;
/// 删除block
@property (nonatomic, copy) callBackDeleteBlcok deleteBlock;
/// 是否详情
@property (nonatomic,assign,getter=isDetail) BOOL detail;
/// IOT数据模型
@property (nonatomic, strong) IotSceneTask * dataModel;
/// 有设备ID的模型
@property (nonatomic, strong) DevDataModel * devModel;
/// 将此数组传过来，只是为了获取默认的情景任务名
@property (nonatomic, strong) NSArray<IotSceneTask*> * sceneTaksArr;

@end

NS_ASSUME_NONNULL_END
