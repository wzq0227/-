//
//  TempAlarmModel.h
//  Goscom
//
//  Created by 匡匡 on 2018/11/23.
//  Copyright © 2018 goscam. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, TempAlarmShowType){
    TempAlarmShowType_Switch,             //  显示switch   titleLab 默认14号字体
    TempAlarmShowType_ButtonFont20,       //  显示button   titleLab20号字体
    TempAlarmShowType_ButtonFont16,       //  显示button   titleLab16号字体
};

NS_ASSUME_NONNULL_BEGIN

@interface TempAlarmModel : NSObject
@property (nonatomic, assign) NSInteger target;     // target标识符
@property (nonatomic, assign) TempAlarmShowType tempAlarmShowType;   // cell显示类型
@property (nonatomic, strong) NSString *titleStr;   //  左边的文字
@property (nonatomic, assign) double value;         //  上下限温度值
@property (nonatomic, assign, getter=isOn) BOOL on; //  开关是否开启，也用来做按钮的选择

/**
 模型的赋值
    没有value的方法
 */
+(instancetype) modelWithTarget:(NSInteger) target
              tempAlarmShowType:(TempAlarmShowType) tempAlarmShowType
                       titleStr:(NSString *) titleStr
                             on:(BOOL) on;

/**
 模型的赋值
 */
+(instancetype) modelWithTarget:(NSInteger) target
              tempAlarmShowType:(TempAlarmShowType) tempAlarmShowType
                       titleStr:(NSString *) titleStr
                             on:(BOOL) on
                          value:(double) value;


/**
 切换华氏度摄氏度时温度需要计算
 @param value  温度值是否是摄氏度
 */
-(void) setValue:(double)value isC:(BOOL) isC;


/**
 pickView 改变温度 改变数据源
 @param value 赋值
 @param isC   是否是摄氏度
 */
-(void) setValue:(double)value isCFromPickView:(BOOL) isC;

@end

NS_ASSUME_NONNULL_END
