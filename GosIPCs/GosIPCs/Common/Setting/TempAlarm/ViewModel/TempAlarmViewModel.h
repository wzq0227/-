//
//  TempAlarmViewModel.h
//  Goscom
//
//  Created by 匡匡 on 2018/11/23.
//  Copyright © 2018 goscam. All rights reserved.
//

#import <Foundation/Foundation.h>
@class TempAlarmModel;
@class TemDetectModel;
@class TempAlarmPickerView;
@class TempAlarmPickModel;

typedef NS_ENUM(NSInteger, TempAlarmCellType) {
    TempAlarmCellType_C,     //  摄氏度
    TempAlarmCellType_F,     //  华氏度
    TempAlarmCellType_Uplimit,     //  最大温度
    TempAlarmCellType_Upvalue,     //  最大温度值
    TempAlarmCellType_Downlimit,     //  最小温度
    TempAlarmCellType_Downvalue,     //  最小温度值
};

NS_ASSUME_NONNULL_BEGIN

@interface TempAlarmViewModel : NSObject

/**
 初始化温度报警界面数据
 
 @param temDetectModel 温度报警模型
 @return 界面数组数据
 */
- (NSArray *)handleTabledataModel:(TemDetectModel *)temDetectModel;


/**
 选中或开关 数据更改
 
 @param cellModel 选中或点击的模型数据
 @param tableDataArray 原始界面数组数据
 @param temDetectModel 原始温度报警模型
 */
- (void)cellActionWithCellModel:(TempAlarmModel *)cellModel
                  dataSourceArr:(NSArray *)tableDataArray
                 temDetectModel:(TemDetectModel *)temDetectModel;


/**
 华氏度摄氏度切换数据更改
 
 @param tableDataArray 原始tableArr
 @param pickerView 温度选择界面
 */
- (void)pickerViewData:(NSArray *)tableDataArray
          dataPickview:(TempAlarmPickerView *)pickerView;


/**
 温度选择器选择后数据更改
 
 @param modelData 选择器单个模型
 @param tableDataArray 原始TableArr
 @param temDetectModel 温度报警模型
 */
- (void)modifyPickViewModelData:(TempAlarmPickModel *)modelData
                        dataArr:(NSArray *)tableDataArray
                 temDetectModel:(TemDetectModel *)temDetectModel;


@end

NS_ASSUME_NONNULL_END
