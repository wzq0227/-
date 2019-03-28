//  CloudServiceModel.h
//  Goscom
//
//  Create by 匡匡 on 2018/12/21.
//  Copyright © 2018 goscam. All rights reserved.

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 云录制套餐界面模型
 */
@interface CloudServiceModel : NSObject
/// 数据保存时间（多少天可循环录制）
@property (nonatomic, copy) NSString *dataLife;
/// 服务有效期
@property (nonatomic, copy) NSString *serviceLife;
/// 当前价格
@property (nonatomic, copy) NSString *currentPrice;
/// 原来价格
@property (nonatomic, copy) NSString *normalPrice;
/// 当前价格加钱单位
@property (nonatomic, copy) NSString * currentPriceString;
/// 套餐id
@property (nonatomic, copy) NSString *planId;
/// 改成字符串的  数据保存时间（多少天可循环录制）
@property (nonatomic, copy) NSString *dataLifeString;
/// 改成字符串的 服务有效期
@property (nonatomic, copy) NSString *serviceLifeString;
/// 是否选中
@property (nonatomic, assign,getter=isSelect) BOOL select;
@end

NS_ASSUME_NONNULL_END
