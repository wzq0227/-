//  CloudStoreCellModel.h
//  GosIPCs
//
//  Create by daniel.hu on 2018/11/29.
//  Copyright © 2018年 goscam. All rights reserved.

#import <Foundation/Foundation.h>
#import "MineCellModelProtocol.h"
/**
 设备云存储状态
 */
typedef NS_ENUM(NSInteger, CloudStoreOrderStatus) {
    CloudStoreOrderStatusInUse,      // 使用中
    CloudStoreOrderStatusUnpurchased,// 未开通
    CloudStoreOrderStatusExpired,    // 已过期
    CloudStoreOrderStatusUnbind,     // 已解绑
//    CloudStoreOrderStatusUnuse,      // 未使用
};

//typedef UIViewController *(^CloudStoreCellTurnToVCBlock)(void);

NS_ASSUME_NONNULL_BEGIN

@interface CloudStoreCellModel : NSObject <NSCopying, MineCellModelProtocol>
/// 截图
@property (nonatomic, copy) UIImage *screenshotImage;
/// 设备名
@property (nonatomic, copy) NSString *deviceName;
/// 设备ID
@property (nonatomic, copy) NSString *deviceID;
/// 开通类型
@property (nonatomic, copy) NSString *packageType;
/// 有效期
@property (nonatomic, copy) NSString *validTime;
/// 状态
@property (nonatomic, assign) CloudStoreOrderStatus status;
/// 状态颜色
@property (nonatomic, readonly, copy) UIColor *statusColor;
/// 状态说明，由status生成
@property (nonatomic, readonly, copy) NSString *statusString;


/// 跳转block
@property (nonatomic, copy, nullable) MineCellClickActionBlock cellClickActionBlock;
//@property (nonatomic, nullable, copy) CloudStoreCellTurnToVCBlock cellTurnToVCBlock;

+ (instancetype)modelWithDeviceName:(NSString *)deviceName
                           deviceID:(NSString *)deviceID
                        packageType:(NSString *)packageType
                          validTime:(NSString *)validTime
                             status:(CloudStoreOrderStatus)status
                  cellClickActionBlock:(nullable MineCellClickActionBlock)cellClickActionBlock;
/// 转化为：7天循环录制
- (NSString *)packageTypeWithDataLife:(NSString *)dataLife;
/// 转化为：有效期:2018/08/08-2019-09/09
- (NSString *)validTimeWithStartTime:(NSString *)startTime expiredTime:(NSString *)expiredTime;
/// 优化数据——针对status: unbind/expired做一些优化显示
- (void)optimistCellModelAccordingToStatus;
@end

NS_ASSUME_NONNULL_END
