//  CloudStoreCellModel.m
//  GosIPCs
//
//  Create by daniel.hu on 2018/11/29.
//  Copyright © 2018年 goscam. All rights reserved.

#import "CloudStoreCellModel.h"
#import "NSString+GosFormatDate.h"

@interface CloudStoreCellModel ()

@property (nonatomic, readwrite, copy) NSString *statusString;
/// 状态颜色
@property (nonatomic, readwrite, copy) UIColor *statusColor;

@end
@implementation CloudStoreCellModel
#pragma mark - public method
+ (instancetype)modelWithDeviceName:(NSString *)deviceName
                           deviceID:(NSString *)deviceID
                        packageType:(NSString *)packageType
                          validTime:(NSString *)validTime
                             status:(CloudStoreOrderStatus)status
                  cellClickActionBlock:(nullable MineCellClickActionBlock)cellClickActionBlock {
    CloudStoreCellModel *model = [[CloudStoreCellModel alloc] init];
    model.deviceName = deviceName;
    model.deviceID = deviceID;
    model.packageType = packageType;
    model.validTime = validTime;
    model.status = status;
    model.cellClickActionBlock = cellClickActionBlock;
    return model;
}

- (NSString *)packageTypeWithDataLife:(NSString *)dataLife {
    // 默认dataLife只有个数字
    // 例：7天循环录制
    return [NSString stringWithFormat:@"%@%@", dataLife, DPLocalizedString(@"Mine_DayInCycleRecording")];
}
- (NSString *)validTimeWithStartTime:(NSString *)startTime expiredTime:(NSString *)expiredTime {
    NSDate *startDate = [NSDate dateWithTimeIntervalSince1970:[[startTime substringToIndex:10] doubleValue]];
    NSDate *expiredDate = [NSDate dateWithTimeIntervalSince1970:[[expiredTime substringToIndex:10] doubleValue]];
    // 默认startTime, expiredTime是时间戳
    // 例：有效期:2018/08/08-2019-09/09
    return [NSString stringWithFormat:@"%@:%@-%@", DPLocalizedString(@"Mine_ValidityPeriod"), [NSString stringWithDate:startDate format:slashDateFormatString], [NSString stringWithDate:expiredDate format:slashDateFormatString]];
}

- (void)optimistCellModelAccordingToStatus {
    // 如果没有设备名，将强制标记为已移除
    if (!_deviceName) {
        self.status = CloudStoreOrderStatusUnbind;
    }
    if (self.status == CloudStoreOrderStatusUnbind) {
        _deviceName = DPLocalizedString(@"Mine_Unbind_DeviceName");
    } else if (self.status == CloudStoreOrderStatusExpired) {
        _packageType = nil;
//        _validTime = DPLocalizedString(@"Mine_PackageExpired");
    }
//    else if (self.status == CloudStoreOrderStatusUnpurchased) {
//        _validTime = DPLocalizedString(@"Mine_Unpurchased");
//    }
}

#pragma mark - getters and setters
- (UIImage *)screenshotImage {
    if (!_screenshotImage) {
        _screenshotImage = GOS_IMAGE(@"Cover");
    }
    return _screenshotImage;
}
- (void)setStatus:(CloudStoreOrderStatus)status {
    _status = status;
    NSString *statusString = nil;
    UIColor *statusColor = nil;
    switch (status) {
        case CloudStoreOrderStatusInUse:
            statusString = @"Mine_InUse";
            statusColor = GOS_COLOR_RGB(0x21EA5E);
            break;
        case CloudStoreOrderStatusUnbind:
            statusString = @"Mine_Unbind";
            statusColor = GOS_COLOR_RGB(0xFF2424);
            break;
        case CloudStoreOrderStatusExpired:
            statusString = @"Mine_Expired";
            statusColor = GOS_COLOR_RGB(0x999999);
            break;
        case CloudStoreOrderStatusUnpurchased:
            statusString = @"Mine_Unpurchased";
            statusColor = GOS_COLOR_RGB(0x55AFFC);
            break;
//        case CloudStoreOrderStatusUnuse:
//            statusString = @"Mine_Unuse";
//            statusColor = GOS_COLOR_RGB(0x999999);
//            break;
        default:
            break;
    }
    
    _statusString = DPLocalizedString(statusString);
    _statusColor = statusColor;
}

#pragma mark - NSCopying
- (id)copyWithZone:(NSZone *)zone {
    CloudStoreCellModel *model = [[CloudStoreCellModel alloc] init];
    model.deviceID = [self.deviceID copy];
    model.deviceName = [self.deviceName copy];
    model.status = self.status;
    model.packageType = [self.packageType copy];
    model.validTime = [self.validTime copy];
    model.screenshotImage = [self.screenshotImage copy];
    // 不将点击事件复制
    return model;
}

#pragma mark - equal
- (BOOL)isEqual:(id)object {
    // 非本模型不等
    if (![object isKindOfClass:[self class]]) return NO;
    CloudStoreCellModel *model = object;
    // 非string类型不相等
    if (![model.deviceID isKindOfClass:[NSString class]]) return NO;
    // 只判断id相同即为相同
    if ([model.deviceID isEqualToString:self.deviceID]) return YES;
    // 其他情况都视为不同
    return NO;
}
@end
