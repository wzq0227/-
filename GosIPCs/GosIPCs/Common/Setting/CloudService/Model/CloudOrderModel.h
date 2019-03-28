//  CloudOrderModel.h
//  Goscom
//
//  Create by 匡匡 on 2018/12/21.
//  Copyright © 2018 goscam. All rights reserved.

#import <Foundation/Foundation.h>
#import <iOSPaymentSDK/iOSPaymentSDK.h>
NS_ASSUME_NONNULL_BEGIN





/**
 支付方式模型
 */
@interface CloudOrderPayWayModel : NSObject
/// 支付方式图标
@property (nonatomic, strong) UIImage * iconImg;
/// 支付方式名
@property (nonatomic, copy) NSString * payWayNameStr;
/// 支付方式枚举
@property (nonatomic, assign) GosPaymentType paymentType;
/// 是否选中
@property (nonatomic, assign,getter=isSelect) BOOL select;
@end



/**
 给套餐订购界面添加type
 */
@interface CloudOrderPayWayTypeModel : NSObject
/// 组别标题
@property (nonatomic, copy) NSString * sectionTitle;
/// 组别数组
@property (nonatomic, strong) NSArray * sectionArr;
@end




/**
 套餐订购模型
 */
@interface CloudOrderModel : NSObject
/// 左边的标题
@property (nonatomic, copy) NSString * leftTitleStr;
/// 右边的数值
@property (nonatomic, copy) NSString * rightTitleStr;
/// 右边数值的颜色
@property (nonatomic, strong) UIColor * rightTitleColor;
@end

NS_ASSUME_NONNULL_END
