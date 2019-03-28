//  ExperienceCenterCellModel.m
//  Goscom
//
//  Create by daniel.hu on 2018/11/29.
//  Copyright © 2018年 goscam. All rights reserved.

#import "ExperienceCenterCellModel.h"
#import "MediaManager.h"

@interface ExperienceCenterCellModel ()
@property (nonatomic, readwrite, copy) UIImage *icon;
@property (nonatomic, readwrite, copy) NSString *name;
@property (nonatomic, readwrite, copy) NSString *times;
@end

@implementation ExperienceCenterCellModel
+ (instancetype)cellModelWithCellType:(ExperienceCenterCellType)cellType cellTurnToVCBlock:(ExperienceCellTurnToVCBlock)cellTurnToVCBlock {
    ExperienceCenterCellModel *model = [[ExperienceCenterCellModel alloc] init];
    model.cellType = cellType;
    model.cellTurnToVCBlock = cellTurnToVCBlock;
    return model;
}
- (id)copyWithZone:(NSZone *)zone {
    ExperienceCenterCellModel *model = [[ExperienceCenterCellModel allocWithZone:zone] init];
    model.cellType = self.cellType;
    model.cellTurnToVCBlock = self.cellTurnToVCBlock;
    return model;
}

- (void)setCellType:(ExperienceCenterCellType)cellType {
    _cellType = cellType;
    NSString *name = nil;
    NSString *iconName = nil;
    NSString *times = @"1288";
    
    switch (cellType) {
        case ExperienceCenterCellTypeVR360:
            name = @"VR-360";
            iconName = @"ExpCenter_VR_360";
            break;
        case ExperienceCenterCellTypeVR180:
            name = @"VR-180";
            iconName = @"ExpCenter_VR_180";
            break;
        case ExperienceCenterCellTypeIPC:
            name = @"IPC-200W";
            iconName = @"ExpCenter_IPC";
            break;
        case ExperienceCenterCellTypeNVR:
            name = @"NVR-720P";
            iconName = @"ExpCenter_NVR";
            break;
        default:
            break;
    }
    
    _name = name;
    // FIXME: 暂时使用此占位图
    _icon = [UIImage imageNamed:@"Cover"];
//    _icon = [[MediaManager shareManager] coverWithDevId:nil fileName:name deviceType:[self convertWithCellType:cellType] position:PositionMain];
    _times = times;
}
- (GosDeviceType)convertWithCellType:(ExperienceCenterCellType)cellType {
    switch (cellType) {
        case ExperienceCenterCellTypeVR360:
            return GosDevice360;
        case ExperienceCenterCellTypeVR180:
            return GosDevice180;
        case ExperienceCenterCellTypeIPC:
            return GosDeviceIPC;
        case ExperienceCenterCellTypeNVR:
            return GosDeviceNVR;
        default:
            break;
    }
    return GosDeviceUnkown;
}

@end
