//  MessageCenterCellModel.m
//  GosIPCs
//
//  Create by daniel.hu on 2018/12/4.
//  Copyright © 2018年 goscam. All rights reserved.

#import "MessageCenterCellModel.h"

@implementation MessageCenterCellModel

+ (instancetype)modelWithTitleText:(NSString *)titleText
                     separatorType:(MessageCellSeparatorType)separatorType
                         cellStyle:(MessageCellStyle)cellStyle
                        cellAction:(MessageCellClickActionBlock)cellAction {
    return [MessageCenterCellModel modelWithTitleText:titleText
                                           detailText:nil
                                        separatorType:separatorType cellStyle:cellStyle
                                             editable:NO
                                           cellAction:cellAction];
}
+ (instancetype)modelWithTitleText:(NSString *)titleText
                        detailText:(nullable NSString *)detailText
                     separatorType:(MessageCellSeparatorType)separatorType
                         cellStyle:(MessageCellStyle)cellStyle
                          editable:(BOOL)editable
                        cellAction:(MessageCellClickActionBlock)cellAction {
    GosLog(@"%s", __PRETTY_FUNCTION__);
    MessageCenterCellModel *model = [[MessageCenterCellModel alloc] init];
    model.titleText = DPLocalizedString(titleText);
    model.detailText = detailText;
    model.separatorType = separatorType;
    model.cellStyle = cellStyle;
    model.editable = editable;
    model.cellClickActionBlock = cellAction;
    return model;
}
- (id)copyWithZone:(NSZone *)zone {
    MessageCenterCellModel *model = [[MessageCenterCellModel allocWithZone:zone] init];
    
    model.titleText = [self.titleText copy];
    model.detailText = [self.detailText copy];
    model.separatorType = self.separatorType;
    model.cellStyle = self.cellStyle;
    model.readState = self.readState;
    model.editable = self.editable;
    model.selected = self.selected;
    model.editing = self.editing;
    model.messageType = self.messageType;
    model.serialNum = self.serialNum;
    model.email = [self.email copy];
    model.deviceId = [self.deviceId copy];
    model.deviceName = [self.deviceName copy];
    model.pushUrl = [self.pushUrl copy];
    model.pushTime = [self.pushTime copy];
    model.subChannel = self.subChannel;
    model.subDeviceID = [self.subDeviceID copy];
    model.cellClickActionBlock = [self.cellClickActionBlock copy];
    return model;
}
- (id)mutableCopyWithZone:(NSZone *)zone {
    MessageCenterCellModel *model = [[MessageCenterCellModel allocWithZone:zone] init];
    model.titleText = [self.titleText copy];
    model.detailText = [self.detailText copy];
    model.separatorType = self.separatorType;
    model.cellStyle = self.cellStyle;
    model.readState = self.readState;
    model.editable = self.editable;
    model.selected = self.selected;
    model.editing = self.editing;
    model.messageType = self.messageType;
    model.serialNum = self.serialNum;
    model.email = [self.email copy];
    model.deviceId = [self.deviceId copy];
    model.deviceName = [self.deviceName copy];
    model.pushUrl = [self.pushUrl copy];
    model.pushTime = [self.pushTime copy];
    model.subChannel = self.subChannel;
    model.subDeviceID = [self.subDeviceID copy];
    model.cellClickActionBlock = [self.cellClickActionBlock copy];
    
    return model;
}

- (BOOL)isEqual:(id)object {
    // 1. 判断类型
    if (![object isKindOfClass:[self class]]) return NO;
    
    MessageCenterCellModel *model = object;
    // 2. 判断cell
    if (model.cellStyle != self.cellStyle) return NO;
    // 3. 判断title
    if (![model.titleText isEqualToString:self.titleText]) return NO;
    // 4. 判断detailTitle
    if (![model.titleText isEqualToString:self.detailText]) return NO;
    
    
    return YES;
    
}
- (UIImage *)image {
    
    if (self.cellStyle == MessageCellStyleArrow) {
        return GOS_IMAGE(@"icon_message_mine");
    } else {
        switch (self.messageType) {
                /// 移动侦测
            case MessageTypeMoved:
                return GOS_IMAGE(@"icon_motion_52");
                /// 警戒
            case MessageTypeGuard:
                return GOS_IMAGE(@"icon_motion_52");
                /// PIR 侦测
            case MessageTypePir:
                return GOS_IMAGE(@"icon_infrared");
                /// 温度上限
            case MessageTypeTemperatureUpperLimit:
                return GOS_IMAGE(@"temp_upper_limit");
                /// 温度下限
            case MessageTypeTemperatureLowerLimit:
                return GOS_IMAGE(@"temp_lower_limit");
                /// 声音
            case MessageTypeVoice:
                return GOS_IMAGE(@"icon_voice_detection");
                /// 按铃
            case MessageTypeBellRing:
                return GOS_IMAGE(@"");
                /// 低电量
            case MessageTypeLowBattery:
                return GOS_IMAGE(@"");
            default:
                break;
        }
    }
    return nil;
}

@end
