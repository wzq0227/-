//
//  LightDurationViewModel.h
//  Goscom
//
//  Created by 匡匡 on 2018/11/30.
//  Copyright © 2018 goscam. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LightDurationVC.h"
@class LampDurationModel;
@class LightDurationModel;
NS_ASSUME_NONNULL_BEGIN

@interface LightDurationViewModel : NSObject

/**
 根据灯照时长模型返回处理好的数据
 
 @param durationModel 灯照时长模型
 @return cell组别数据
 */
+ (NSArray <LightDurationModel *>*)handleDataWithDurationModel:(LampDurationModel *) durationModel;


/**
 处理选择日期
 
 @param selectDay 选中的天
 @param durationModel 整个数据模型
 @param tableDataArr 原始数组
 */
+ (void)handleSelectDayWithSelectDay:(int) selectDay
                       DurationModel:(LampDurationModel *) durationModel
                        tableDataArr:(NSArray <LightDurationModel *>*) tableDataArr;


/**
 处理开关
 
 @param isOn 开关状态
 @param tableDataArr 原始数组
 @param lampDurationModel 模型
 */
+ (void)handleSwitchWithOn:(BOOL) isOn
              tableDataArr:(NSArray <LightDurationModel *>*) tableDataArr
          ampDurationModel:(LampDurationModel *) lampDurationModel;



/**
 处理开始结束时间选择
 
 @param type 选择的类型
 @param tableDataArr 原始数组
 @param durationModel 原始模型
 @param component 列
 @param row 行
 */
+ (void)handleSelectTimeWithType:(OnOffTimeType) type
                    tableDataArr:(NSArray <LightDurationModel *> *) tableDataArr
                   DurationModel:(LampDurationModel *) durationModel
                       component:(NSInteger) component
                             row:(NSInteger) row;




/**
 初始化开启和结束时间数据
 
 @return 返回开始和结束时间两个数组
 */
+ (NSArray<NSArray *> *)handlePickerDate;

@end

NS_ASSUME_NONNULL_END
