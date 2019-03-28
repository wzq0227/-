//  CloudPackageDetailVC.h
//  Goscom
//
//  Create by 匡匡 on 2019/1/12.
//  Copyright © 2019 goscam. All rights reserved.

#import <UIKit/UIKit.h>
@class DevDataModel;
@class PackageValidTimeApiRespModel;
NS_ASSUME_NONNULL_BEGIN

/**
 套餐详情界面
 */
@interface CloudPackageDetailVC : UIViewController
/// 云储存套餐模型 nil=立即订购  packageModel.dataLife = 套餐时间
@property (nonatomic, strong) PackageValidTimeApiRespModel * PackageModel;
/// 设备模型
@property (nonatomic, strong) DevDataModel * dataModel;
@end

NS_ASSUME_NONNULL_END
