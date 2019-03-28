//  MessageCenterCellModel.h
//  GosIPCs
//
//  Create by daniel.hu on 2018/12/4.
//  Copyright © 2018年 goscam. All rights reserved.

#import <Foundation/Foundation.h>

typedef NS_OPTIONS(NSInteger, MessageCellSeparatorType) {
    MessageCellSeparatorTypeNone      = 0,        // 无
    MessageCellSeparatorTypeTop       = 1 << 0,   // 上分割线
    MessageCellSeparatorTypeBottom    = 1 << 1,   // 下分割线
    MessageCellSeparatorTypeBoth      = MessageCellSeparatorTypeTop | MessageCellSeparatorTypeBottom,           // 上下都有
};
/// 样式
typedef NS_ENUM(NSInteger, MessageCellStyle) {
    MessageCellStyleDetail, // 存在详情
    MessageCellStyleArrow,  // 箭头
};

/// 消息阅读状态
typedef NS_ENUM(NSInteger, MessageReadState) {
    MessageReadStateUnread,    // 未读
    MessageReadStateReading,   // 正在读
    MessageReadStateReaded,    // 已读
};

/// 消息类型
typedef NS_ENUM(NSInteger, MessageType) {
    MessageTypeMoved,                    // 移动侦测
    MessageTypeGuard,                    // 警戒
    MessageTypePir,                      // PIR 侦测
    MessageTypeTemperatureUpperLimit,    // 温度上限
    MessageTypeTemperatureLowerLimit,    // 温度下限
    MessageTypeVoice,                    // 声音
    MessageTypeBellRing,                 // 按铃
    MessageTypeLowBattery,               // 低电量
};

/// 点击cell响应
typedef UIViewController *(^MessageCellClickActionBlock)(id hook);
NS_ASSUME_NONNULL_BEGIN

@interface MessageCenterCellModel : NSObject <NSCopying, NSMutableCopying>
#pragma mark - 外观数据
/// 标题
@property (nonatomic, copy) NSString *titleText;
/// 子标题
@property (nonatomic, copy) NSString *detailText;
/// 图片
@property (nonatomic, readonly, copy) UIImage *image;
/// 分割线类型
@property (nonatomic, assign) MessageCellSeparatorType separatorType;
/// 显示样式
@property (nonatomic, assign) MessageCellStyle cellStyle;
/// 点击事件
@property (nonatomic, copy) MessageCellClickActionBlock cellClickActionBlock;

#pragma mark - 附加数据
/// 阅读状态
@property (nonatomic, assign) MessageReadState readState;
/// 是否可编辑
@property (nonatomic, assign, getter=isEditable) BOOL editable;
/// 是否正在编辑
@property (nonatomic, assign, getter=isEditing) BOOL editing;
/// 是否被选择
@property (nonatomic, assign, getter=isSelected) BOOL selected;

#pragma mark - 服务器数据
/// 消息类型
@property (nonatomic, assign) MessageType messageType;
/// 序列号
@property (nonatomic, assign) NSInteger serialNum;
/// 当前登录账号的邮箱
@property (nonatomic, copy) NSString *email;
/// 设备 ID
@property (nonatomic, copy) NSString *deviceId;
/// 设备昵称
@property (nonatomic, copy) NSString *deviceName;
/// 推送 URL
@property (nonatomic, copy) NSString *pushUrl;
/// 推送时间 yyyy-MM-dd HH:mm:ss
@property (nonatomic, copy) NSString *pushTime;

#pragma mark - 门铃版
/// 子设备通道号
@property (nonatomic, assign) NSInteger subChannel;
/// 子设备ID
@property (nonatomic, strong)  NSString *subDeviceID;

+ (instancetype)modelWithTitleText:(NSString *)titleText
                     separatorType:(MessageCellSeparatorType)separatorType
                         cellStyle:(MessageCellStyle)cellStyle
                        cellAction:(MessageCellClickActionBlock)cellAction;
+ (instancetype)modelWithTitleText:(NSString *)titleText
                        detailText:(nullable NSString *)detailText
                     separatorType:(MessageCellSeparatorType)separatorType
                         cellStyle:(MessageCellStyle)cellStyle
                          editable:(BOOL)editable
                        cellAction:(MessageCellClickActionBlock)cellAction;

@end

NS_ASSUME_NONNULL_END
