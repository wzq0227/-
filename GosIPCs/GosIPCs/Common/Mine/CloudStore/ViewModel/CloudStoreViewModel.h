//  CloudStoreViewModel.h
//  GosIPCs
//
//  Create by daniel.hu on 2018/12/7.
//  Copyright © 2018年 goscam. All rights reserved.

#import "MineViewModelDelegate.h"

NS_ASSUME_NONNULL_BEGIN
@class CloudStoreCellModel;
@class DevDataModel;
@interface CloudStoreViewModel : NSObject <MineViewModelDelegate>
- (NSArray *)generateTableDataArray;

/// 处理网络数据
- (NSArray <CloudStoreCellModel *> *)processNetRespModelArray:(NSArray *)respModelArray;
/// 获取 设备模型数组
- (NSArray <DevDataModel *> *)fetchDeviceDataModelArray;
/// 通过设备id 获取设备模型
- (DevDataModel *)fetchDeviceDataModelWithDeviceId:(NSString *)deviceId;
/// 获取用于展示的KeyPath——设备名
- (NSString *)fetchDeviceDataModelForDisplayKeyPath;
/// 根据设备模型获取设备id
- (NSString *)fetchDeviceIdFromDeviceDataModel:(DevDataModel *)deviceModel;
/// 删除推送
- (void)deletePushMessageWithDeviceId:(NSString *)deviceId;
/// 判断是否支持云存储
- (BOOL)validateIsSupportCloudServiceWithDeviceId:(NSString *)deviceId;
@end

NS_ASSUME_NONNULL_END
