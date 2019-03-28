//
//  TempAlarmModel.m
//  Goscom
//
//  Created by 匡匡 on 2018/11/23.
//  Copyright © 2018 goscam. All rights reserved.
//

#import "TempAlarmModel.h"


@implementation TempAlarmModel
/**
 模型的赋值
 没有value的方法
 */
+(instancetype) modelWithTarget:(NSInteger)target
              tempAlarmShowType:(TempAlarmShowType)tempAlarmShowType
                       titleStr:(NSString *)titleStr
                             on:(BOOL)on{
    return [self modelWithTarget:target tempAlarmShowType:tempAlarmShowType titleStr:titleStr on:on value:-100];
}

/**
 模型的赋值
 */
+(instancetype)modelWithTarget:(NSInteger)target
             tempAlarmShowType:(TempAlarmShowType) tempAlarmShowType
                      titleStr:(NSString *)titleStr
                            on:(BOOL)on
                         value:(double)value{
    TempAlarmModel * model = [[TempAlarmModel alloc] init];
    model.target = target;
    model.tempAlarmShowType = tempAlarmShowType;
    model.titleStr = titleStr;
    model.on = on;
    model.value = value;
    return model;
}

/**
 切换华氏度摄氏度时温度需要计算
 @param value  温度值是否是摄氏度
 */
-(void) setValue:(double)value isC:(BOOL) isC{
    if (isC) {
        value = (value - 32)/1.8;
        self.titleStr = [NSString stringWithFormat:@"%d°C",(int)value];
    }else{
        value = (value * 1.8)+32;
        self.titleStr = [NSString stringWithFormat:@"%d°F",(int)value];
    }
    _value = value;
}

/**
 pickView 改变温度 改变数据源
 @param value 赋值
 @param isC   是否是摄氏度
 */
-(void)setValue:(double)value isCFromPickView:(BOOL)isC{
    if (isC) {
        self.titleStr = [NSString stringWithFormat:@"%d°C",(int)value];
    }else{
        self.titleStr = [NSString stringWithFormat:@"%d°F",(int)value];
    }
    _value = value;
}

@end
