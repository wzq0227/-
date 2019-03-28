//  CloudStoreViewModel.m
//  GosIPCs
//
//  Create by daniel.hu on 2018/12/7.
//  Copyright © 2018年 goscam. All rights reserved.

#import "CloudStoreViewModel.h"
#import "CloudStoreCellModel.h"
#import "CloudStoreDetailViewController.h"
#import "AccountOrderListApiRespModel.h"
#import "DeviceOrderListApiRespModel.h"
#import "MediaManager.h"
#import "GosDevManager.h"
#import "GosLoggedInUserInfo.h"
#import "PushMsgManager.h"

@implementation CloudStoreViewModel
- (NSArray *)generateTableDataArray {
//    return @[
//             [CloudStoreCellModel modelWithDeviceName:@"客厅" deviceID:@"0" packageType:@"7天循环录制" validTime:@"有效期2018/08/08-2018/09/09" status:CloudStoreOrderStatusInUse cellClickActionBlock:^id(id  _Nullable hook) {
//                 return [[CloudStoreDetailViewController alloc] init];
//             }],
//             [CloudStoreCellModel modelWithDeviceName:@"客厅" deviceID:@"0" packageType:@"7天循环录制" validTime:@"有效期2018/08/08-2018/09/09" status:CloudStoreOrderStatusInUse cellClickActionBlock:^id(id  _Nullable hook) {
//                 return [[CloudStoreDetailViewController alloc] init];
//             }]
//    ];
    return @[];
}
#pragma mark - 处理网络数据 (Public)
/// 处理网络数据
- (NSArray <CloudStoreCellModel *> *)processNetRespModelArray:(NSArray *)respModelArray {
    id obj = [respModelArray firstObject];
    if ([obj isKindOfClass:[AccountOrderListApiRespModel class]]) {
        return [self processAccountOrderListApiRespModelArray:respModelArray];
    } else if ([obj isKindOfClass:[DeviceOrderListApiRespModel class]]) {
        return [self processDeviceOrderListApiRespModelArray:respModelArray];
    }
    return @[];
}
#pragma mark - private method
- (NSArray <CloudStoreCellModel *> *)processAccountOrderListApiRespModelArray:(NSArray <AccountOrderListApiRespModel *> *)respModelArray {
    NSMutableArray *temp = [NSMutableArray array];
    
    // 添加网络模型转化数据
    [temp addObjectsFromArray:[self convertNetRespModelArrayToCellModelArray:respModelArray]];
    
    // 获取的本地缓存的设备列表
    NSArray *deviceList = [self fetchDeviceDataModelArray];
    
    // 添加未开通的数据
    [temp addObjectsFromArray:[self convertDeviceDataModelArrayToCellModelArray:deviceList withoutExist:temp]];
    
    // 排序
    [temp sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        return ((CloudStoreCellModel *)obj1).status - ((CloudStoreCellModel *)obj2).status;
    }];
    return [temp copy];
}
- (NSArray <CloudStoreCellModel *> *)processDeviceOrderListApiRespModelArray:(NSArray <DeviceOrderListApiRespModel *> *)respModelArray {
    return [self convertNetRespModelArrayToCellModelArray:respModelArray];
}

#pragma mark - convert array method
/// 网络数据模型数组 -> Cell模型数组
- (NSArray <CloudStoreCellModel *> *)convertNetRespModelArrayToCellModelArray:(NSArray *)respModelArray {
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:respModelArray.count];
    for (id respModel in respModelArray) {
        if ([respModel isKindOfClass:[AccountOrderListApiRespModel class]]) {
            [result addObject:[self convertAccountOrderListApiRespModelToCellModel:respModel]];
        } else if ([respModel isKindOfClass:[DeviceOrderListApiRespModel class]]) {
            [result addObject:[self convertDeviceOrderListApiRespModelToCellModel:respModel]];
        }
    }
    return [result copy];
}
/// 根据设备列表添加未开通的cell模型数组
- (NSArray <CloudStoreCellModel *> *)convertDeviceDataModelArrayToCellModelArray:(NSArray <DevDataModel *> *)deviceDataModelArray withoutExist:(NSArray <CloudStoreCellModel *> *)existArray {
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:deviceDataModelArray.count];
    for (DevDataModel *devModel in deviceDataModelArray) {
        CloudStoreCellModel *cellModel = [self convertDeviceDataModelToCellModel:devModel];
        BOOL hasPurchased = [existArray containsObject:cellModel];
        // 过滤分享设备，以及不支持云存储的（门铃全部支持）&& devModel.hasCloudPlay
        if (!hasPurchased && devModel.DeviceOwner != DevOwn_share ) {
            [result addObject:cellModel];
        }
    }
    return [result copy];
}
#pragma mark - convert model method
/// 网络数据模型DeviceOrderListApiRespModel -> CloudStoreCellModel
- (CloudStoreCellModel *)convertDeviceOrderListApiRespModelToCellModel:(id)respModel {
    CloudStoreCellModel *cellModel = [[CloudStoreCellModel alloc] init];
    if (![respModel isKindOfClass:[DeviceOrderListApiRespModel class]]) {
        return cellModel;
    }
    DeviceOrderListApiRespModel *actualModel = respModel;
    cellModel.deviceName = [self fetchDeviceNameFromDeviceId:actualModel.deviceId];
    cellModel.deviceID = actualModel.deviceId;
    cellModel.packageType = [cellModel packageTypeWithDataLife:actualModel.dataLife];
    cellModel.validTime = [cellModel validTimeWithStartTime:actualModel.startTime expiredTime:actualModel.dataExpiredTime];
    cellModel.status = [self convertFromServiceStatus:actualModel.cloudServicePackageStatusType];
    // 根据status有优化显示数据
    [cellModel optimistCellModelAccordingToStatus];
    
    return cellModel;
}
/// 网络数据模型AccountOrderListApiRespModel -> CloudStoreCellModel
- (CloudStoreCellModel *)convertAccountOrderListApiRespModelToCellModel:(id)respModel {
    CloudStoreCellModel *cellModel = [[CloudStoreCellModel alloc] init];
    if (![respModel isKindOfClass:[AccountOrderListApiRespModel class]]) {
        return cellModel;
    }
    AccountOrderListApiRespModel *actualModel = respModel;
    // FIXME: 有可能要按照原来的处理deviceid以获取截图: info.deviceId.length<=20?info.deviceId:[info.deviceId substringFromIndex:8]
    cellModel.screenshotImage = [self fetchScreenshotImageFromDeviceId:actualModel.deviceId];
    cellModel.deviceName = [self fetchDeviceNameFromDeviceId:actualModel.deviceId];
    cellModel.deviceID = actualModel.deviceId;
    cellModel.packageType = [cellModel packageTypeWithDataLife:actualModel.dataLife];
    cellModel.validTime = [cellModel validTimeWithStartTime:actualModel.startTime expiredTime:actualModel.dataExpiredTime];
    cellModel.status = [self convertFromServiceStatus:actualModel.cloudServicePackageStatusType];
    // 根据status有优化显示数据
    [cellModel optimistCellModelAccordingToStatus];
    CloudStoreCellModel *temp = [cellModel copy];
    cellModel.cellClickActionBlock = ^id(id  _Nullable hook) {
        // FIXME: 跳转到你懂的
        return [[CloudStoreDetailViewController alloc] initWithCellModel:temp];
    };
    return cellModel;
}

/// DevDataModel -> CloudStoreCellModel
- (CloudStoreCellModel *)convertDeviceDataModelToCellModel:(DevDataModel *)deviceDataModel {
    CloudStoreCellModel *cellModel = [[CloudStoreCellModel alloc] init];
    cellModel.deviceID = deviceDataModel.DeviceId;
    cellModel.deviceName = deviceDataModel.DeviceName;
     // FIXME: 有可能要按照原来的处理deviceid以获取截图: info.deviceId.length<=20?info.deviceId:[info.deviceId substringFromIndex:8]
    cellModel.screenshotImage = [self fetchScreenshotImageFromDeviceId:deviceDataModel.DeviceId];
    cellModel.status = CloudStoreOrderStatusUnpurchased;
    // 根据status有优化显示数据
    [cellModel optimistCellModelAccordingToStatus];
    CloudStoreCellModel *temp = [cellModel copy];
    cellModel.cellClickActionBlock = ^id(id  _Nullable hook) {
        // FIXME: 跳转到你懂的
        return [[CloudStoreDetailViewController alloc] initWithCellModel:temp];
    };
    return cellModel;
}

#pragma mark - fetch method
/// 根据设备id 获取 设备名
- (NSString *_Nullable)fetchDeviceNameFromDeviceId:(NSString *)deviceId {
    return [GosDevManager devcieWithId:deviceId].DeviceName;
}
/// 根据设备id 获取 设备类型
- (GosDeviceType)fetchDeviceTypeFromDeviceId:(NSString *)deviceId {
    return [self convertFromDeviceType:[GosDevManager devcieWithId:deviceId].DeviceType];
}
/// 获取 设备模型数组
- (NSArray <DevDataModel *> *)fetchDeviceDataModelArray {
    return [GosDevManager deviceList];
}
/// 通过设备id 获取设备模型
- (DevDataModel *)fetchDeviceDataModelWithDeviceId:(NSString *)deviceId {
    return [GosDevManager devcieWithId:deviceId];
}
/// 获取用于展示的KeyPath——设备名
- (NSString *)fetchDeviceDataModelForDisplayKeyPath {
    return @"DeviceName";
}
/// 根据设备模型获取设备id
- (NSString *)fetchDeviceIdFromDeviceDataModel:(DevDataModel *)deviceModel {
    return deviceModel.DeviceId;
}
/// 根据设备id 获取 截图
- (UIImage *_Nullable)fetchScreenshotImageFromDeviceId:(NSString *)deviceId {
    return [UIImage imageWithContentsOfFile:[MediaManager pathWithDevId:deviceId fileName:nil mediaType:GosMediaCover deviceType:[self fetchDeviceTypeFromDeviceId:deviceId] position:PositionMain]];
}
/// 判断是否支持云存储
- (BOOL)validateIsSupportCloudServiceWithDeviceId:(NSString *)deviceId {
    StreamStoreType streamStoreType = [GosDevManager devcieWithId:deviceId].devCapacity.streamStoreType;
    return streamStoreType == StreamStoreCloud || streamStoreType == StreamStoreOnlyCloud;
}
/// 删除deviceId的推送通知
- (void)deletePushMessageWithDeviceId:(NSString *)deviceId {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [PushMsgManager rmvPushMsgOfDevice:deviceId];
    });
}
#pragma mark - convert type method
/// CloudServicePackageStatusType -> CloudStoreOrderStatus
- (CloudStoreOrderStatus)convertFromServiceStatus:(CloudServicePackageStatusType)serviceStatus {
    CloudStoreOrderStatus status = CloudStoreOrderStatusUnpurchased;
    switch (serviceStatus) {
        case CloudServicePackageStatusTypeExpired:
            status = CloudStoreOrderStatusExpired;
            break;
        case CloudServicePackageStatusTypeUnused:
        case CloudServicePackageStatusTypeInUse:
            status = CloudStoreOrderStatusInUse;
            break;
        case CloudServicePackageStatusTypeUnbind:
            status = CloudStoreOrderStatusUnbind;
            break;
        case CloudServicePackageStatusTypeForbidden:
            status = CloudStoreOrderStatusUnpurchased;
            break;
        default:
            break;
    }
    return status;
}
/// DeviceType -> GosDeviceType
- (GosDeviceType)convertFromDeviceType:(DeviceType)devType {
    GosDeviceType resultType = GosDeviceUnkown;
    switch (devType) {
        case DevType_ipc:
            resultType = GosDeviceIPC;
            break;
        case DevType_nvr:
            resultType = GosDeviceNVR;
            break;
        case DevType_pano180:
            resultType = GosDevice180;
            break;
        case DevType_pano360:
            resultType = GosDevice360;
            break;
        case DevType_unknown:
        case DevType_socket:
            resultType = GosDeviceUnkown;
        default:
            break;
    }
    return resultType;
}




@end
