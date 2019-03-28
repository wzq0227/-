//  UITableViewCell+DeviceListENUM.h
//  Goscom
//
//  Create by 匡匡 on 2019/2/21.
//  Copyright © 2019 goscam. All rights reserved.



NS_ASSUME_NONNULL_BEGIN
/* IPC 类型设备 Cell 点击事件类型 */
typedef NS_ENUM(NSInteger, DeviceListClickActionType) {
    CellClickAction_liveStream       = 0,    // 播放直播流
    CellClickAction_message          = 1,    // 消息中心
    CellClickAction_CloudPB          = 2,    // 云存储回放
    CellClickAction_TFCardPB         = 3,    // TF 卡回放
    CellClickAction_setting          = 4,    // 设置中心
};

typedef void(^CellClickActionBlock)(DeviceListClickActionType actionType);

@interface UITableViewCell (DeviceListENUM)

@end

NS_ASSUME_NONNULL_END
