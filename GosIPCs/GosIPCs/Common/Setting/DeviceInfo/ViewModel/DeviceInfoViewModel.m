//
//  DeviceInfoViewModel.m
//  Goscom
//
//  Created by 匡匡 on 2018/11/27.
//  Copyright © 2018 goscam. All rights reserved.
//

#import "DeviceInfoViewModel.h"
#import "DeviceInfoModel.h"
#import "iOSConfigSDK.h"
#import "iOSConfigSDKModel.h"
#import "GosDevManager.h"
@implementation DeviceInfoViewModel

#pragma mark - 返回设备信息数组模型
+ (NSArray <DeviceInfoTypeModel *>*)handleDeviceInfoModel:(DevInfoModel *) infoModel
                                             DevDataModel:(DevDataModel *) devDataModel{
    /*-----------------------<分割线>------------------------------*/
    DeviceInfoModel * nameModel = [[DeviceInfoModel alloc] init];
    nameModel.titleStr = devDataModel.DeviceName;
    nameModel.cellType = DeviceInfoCellType_hasNext;
    
    DeviceInfoTypeModel * typeModel1 = [[DeviceInfoTypeModel alloc] init];
    typeModel1.sectionTitleStr = DPLocalizedString(@"DevInfo_DevName");
    [typeModel1.sectionDataArr addObject:nameModel];
    
    
    /*-----------------------<分割线>------------------------------*/
    DeviceInfoTypeModel * typeModel2 = [[DeviceInfoTypeModel alloc] init];
    typeModel2.sectionTitleStr = DPLocalizedString(@"DevInfo_CameraVersion");
    
    if (infoModel.hwVersion) {
        DeviceInfoModel * hardwareVersionModel = [[DeviceInfoModel alloc] init];
        hardwareVersionModel.titleStr = DPLocalizedString(@"firmware_version");
        hardwareVersionModel.dataStr = infoModel.hwVersion;
        hardwareVersionModel.cellType = DeviceInfoCellType_hasDetail;
        [typeModel2.sectionDataArr addObject:hardwareVersionModel];
    }
    if (infoModel.swVersion) {
        DeviceInfoModel * systemFirmwareModel = [[DeviceInfoModel alloc] init];
        systemFirmwareModel.titleStr = DPLocalizedString(@"system_firmware");
        systemFirmwareModel.dataStr = infoModel.swVersion;
        systemFirmwareModel.cellType = DeviceInfoCellType_hasDetail;
        [typeModel2.sectionDataArr addObject:systemFirmwareModel];
    }
    
    /*-----------------------<分割线>------------------------------*/
    DeviceInfoTypeModel * typeModel3 = [[DeviceInfoTypeModel alloc] init];
    typeModel3.sectionTitleStr = DPLocalizedString(@"DevInfo_CameraInfo");
    
    if (infoModel.devType) {
        DeviceInfoModel * deviceModel = [[DeviceInfoModel alloc] init];
        deviceModel.titleStr = DPLocalizedString(@"DevInfo_DevModelNum");
        deviceModel.dataStr = infoModel.devType;
        deviceModel.cellType = DeviceInfoCellType_hasDetail;
        [typeModel3.sectionDataArr addObject:deviceModel];
    }
    if (infoModel.devId) {
        DeviceInfoModel * deviceIDModel = [[DeviceInfoModel alloc] init];
        deviceIDModel.titleStr = DPLocalizedString(@"DevInfo_DevID");
        deviceIDModel.dataStr = infoModel.devId;
        deviceIDModel.cellType = DeviceInfoCellType_hasDetail;
        [typeModel3.sectionDataArr addObject:deviceIDModel];
    }
    if (infoModel.wifiSSID) {
        DeviceInfoModel * wifiNameModel = [[DeviceInfoModel alloc] init];
        wifiNameModel.titleStr = DPLocalizedString(@"DevInfo_WiFiName");
        wifiNameModel.dataStr = infoModel.wifiSSID;
        wifiNameModel.cellType = DeviceInfoCellType_hasDetail;
        [typeModel3.sectionDataArr addObject:wifiNameModel];
    }
    
    
    /*-----------------------<分割线>------------------------------*/
    DeviceInfoTypeModel * typeModel4= [[DeviceInfoTypeModel alloc] init];
    typeModel4.sectionTitleStr = DPLocalizedString(@"DevInfo_SDCard");
    
    if (infoModel.sdInfo.usedSize || infoModel.sdInfo.freeSize) {
        DeviceInfoModel * TFCardUserModel = [[DeviceInfoModel alloc] init];
        TFCardUserModel.titleStr = DPLocalizedString(@"used_storage");
        TFCardUserModel.dataStr = [NSString stringWithFormat:@"%0.1lfGB",(double)infoModel.sdInfo.usedSize / 1024.0];
        TFCardUserModel.cellType = DeviceInfoCellType_hasDetail;
        [typeModel4.sectionDataArr addObject:TFCardUserModel];
    }
    if (infoModel.sdInfo.freeSize || infoModel.sdInfo.usedSize) {
        DeviceInfoModel * TFCardHaveModel = [[DeviceInfoModel alloc] init];
        TFCardHaveModel.titleStr = DPLocalizedString(@"free_storage");
        TFCardHaveModel.dataStr = [NSString stringWithFormat:@"%0.1lfGB",(double)infoModel.sdInfo.freeSize / 1024.0];
        TFCardHaveModel.cellType = DeviceInfoCellType_hasDetail;
        [typeModel4.sectionDataArr addObject:TFCardHaveModel];
    }
    
    NSMutableArray * mutDataArray = [[NSMutableArray alloc] init];
    if (typeModel1.sectionDataArr.count > 0) {
        [mutDataArray addObject:typeModel1];
    }
    if (typeModel2.sectionDataArr.count > 0) {
        [mutDataArray addObject:typeModel2];
    }
    if (typeModel3.sectionDataArr.count > 0) {
        [mutDataArray addObject:typeModel3];
    }
    if (typeModel4.sectionDataArr.count > 0) {
        [mutDataArray addObject:typeModel4];
    }
    
    return mutDataArray;
}


#pragma mark -- 返回设备信息数组模型(设备离线)
+ (NSArray <DeviceInfoTypeModel *>*)handleTableArrOFFLineModel:(DevDataModel *) devDataModel{
    
    /*-----------------------<分割线>------------------------------*/
    DeviceInfoModel * nameModel = [[DeviceInfoModel alloc] init];
    nameModel.titleStr = devDataModel.DeviceName;
    nameModel.cellType = DeviceInfoCellType_hasNext;
    
    DeviceInfoTypeModel * typeModel1 = [[DeviceInfoTypeModel alloc] init];
    typeModel1.sectionTitleStr = DPLocalizedString(@"DevInfo_DevName");
    [typeModel1.sectionDataArr addObject:nameModel];
    
    
    /*-----------------------<分割线>------------------------------*/
    DeviceInfoTypeModel * typeModel3 = [[DeviceInfoTypeModel alloc] init];
    typeModel3.sectionTitleStr = DPLocalizedString(@"DevInfo_CameraInfo");
    
    DeviceInfoModel * deviceIDModel = [[DeviceInfoModel alloc] init];
    deviceIDModel.titleStr = DPLocalizedString(@"DevInfo_DevID");
    deviceIDModel.dataStr = devDataModel.DeviceId;
    deviceIDModel.cellType = DeviceInfoCellType_hasDetail;
    [typeModel3.sectionDataArr addObject:deviceIDModel];
    
    NSMutableArray * mutDataArray = [[NSMutableArray alloc] init];
    if (typeModel1.sectionDataArr.count > 0) {
        [mutDataArray addObject:typeModel1];
    }

    if (typeModel3.sectionDataArr.count > 0) {
        [mutDataArray addObject:typeModel3];
    }
    
    return mutDataArray;
    
}

#pragma mark - 根据传进来的设备名修改整个模型
+ (NSArray *)modifyModelData:(NSArray <DeviceInfoTypeModel *>*) dataArr{
    [dataArr enumerateObjectsUsingBlock:^(DeviceInfoTypeModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.sectionTitleStr isEqualToString:DPLocalizedString(@"DevInfo_CameraVersion")]) {
            DeviceInfoModel * infoModel = [obj.sectionDataArr lastObject];
            infoModel.hasNewVersion = YES;
        }
    }];
    return dataArr;
}

#pragma mark - 格式化SD卡成功后修改SD卡数据显示
+ (NSArray *)modifyTFCardData:(NSArray *) dataArr
           andSdCardInfoModel:(SdCardInfoModel *) sdCardInfoModel{
    for (int i=0; i<dataArr.count; i++) {
        DeviceInfoTypeModel * typeModel = dataArr[i];
        if ([typeModel.sectionTitleStr isEqualToString:DPLocalizedString(@"DevInfo_SDCard")]) {
            /// 已用模型
            DeviceInfoModel * TFCardHasUserModel = [typeModel.sectionDataArr firstObject];
            /// 未用模型
            DeviceInfoModel * TFCardHaveModel = [typeModel.sectionDataArr lastObject];
            
            TFCardHasUserModel.dataStr = [NSString stringWithFormat:@"%0.1lfGB",(double)sdCardInfoModel.usedSize / 1024.0];
            TFCardHaveModel.dataStr = [NSString stringWithFormat:@"%0.1lfGB",(double)sdCardInfoModel.freeSize / 1024.0];
        }
    }
    return dataArr;
}

#pragma mark - 修改设备名刷新数据
+ (void)modifyDeviceName:(NSString *) deviceName
                tableArr:(NSArray <DeviceInfoTypeModel *>*) tableArr{
    [tableArr enumerateObjectsUsingBlock:^(DeviceInfoTypeModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.sectionTitleStr isEqualToString:DPLocalizedString(@"DevInfo_DevName")]) {
            DeviceInfoModel * model = [obj.sectionDataArr firstObject];
            model.titleStr = deviceName;
            *stop = YES;
        }
    }];
}

#pragma mark - 数据库查询设备名是否已存在
+ (BOOL)compareNameWithHaveName:(NSString *) haveName{
    NSArray <DevDataModel *> * dataModelArr = [GosDevManager deviceList];
    for (int i=0; i<dataModelArr.count; i++) {
        DevDataModel * model =dataModelArr[i];
        if ([model.DeviceName isEqualToString:haveName]) {
            return YES;
        }
    }
    return NO;
}

@end
