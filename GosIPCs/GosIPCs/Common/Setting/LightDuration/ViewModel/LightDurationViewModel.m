//
//  LightDurationViewModel.m
//  Goscom
//
//  Created by 匡匡 on 2018/11/30.
//  Copyright © 2018 goscam. All rights reserved.
//

#import "LightDurationViewModel.h"
#import "LightDurationModel.h"
#import "iOSConfigSDKModel.h"
@implementation LightDurationViewModel

#pragma mark - 根据灯照时长模型返回处理好的数据
+ (NSArray <LightDurationModel *>*)handleDataWithDurationModel:(LampDurationModel *) durationModel{
    if (!durationModel) {
        return nil;
    }
    LightDurationModel * model1 = [[LightDurationModel alloc] init];
    model1.titleStr = DPLocalizedString(@"LightDuration_WholeDayOff");
    model1.dateTimeStr = @"";
    model1.cellType = lightDurationCellType_Switch;
    model1.isOn = (durationModel.lampDayMask&0x7f)==0;
    
    LightDurationModel * model2 = [[LightDurationModel alloc] init];
    model2.titleStr = DPLocalizedString(@"LightDuration_OnTime");
    model2.dateTimeStr = [NSString stringWithFormat:@"%@%d:%@%d",durationModel.onTime.hour<10?@"0":@"",durationModel.onTime.hour,durationModel.onTime.minute<10?@"0":@"",durationModel.onTime.minute];
    model2.cellType = lightDurationCellType_Label;
    
    LightDurationModel * model3 = [[LightDurationModel alloc] init];
    model3.titleStr = DPLocalizedString(@"LightDuration_OffTime");
    model3.dateTimeStr = [NSString stringWithFormat:@"%@%d:%@%d",durationModel.offTime.hour<10?@"0":@"",durationModel.offTime.hour,durationModel.offTime.minute<10?@"0":@"",durationModel.offTime.minute];
    model3.cellType = lightDurationCellType_Label;
    
    model2.editType = model1.isOn?lightDurationEditType_NoEdit:lightDurationEditType_Editable;
    model3.editType = model1.isOn?lightDurationEditType_NoEdit:lightDurationEditType_Editable;
    return @[model1,model2,model3];
}


#pragma mark - 处理选择日期
+ (void)handleSelectDayWithSelectDay:(int) selectDay
                       DurationModel:(LampDurationModel *) durationModel
                        tableDataArr:(NSArray <LightDurationModel *>*) tableDataArr{
    if (!durationModel || tableDataArr.count <1 || !tableDataArr) {
        return;
    }
    BOOL hasSelectedPosition = (durationModel.lampDayMask >> selectDay) & 1;
    int  selectValue = hasSelectedPosition ? (durationModel.lampDayMask & (~(1 << selectDay))) : (durationModel.lampDayMask | (1 << selectDay)) ;
    durationModel.lampDayMask = selectValue;
    GosLog(@"选中的数据 = %d",durationModel.lampDayMask);
    [tableDataArr enumerateObjectsUsingBlock:^(LightDurationModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.titleStr isEqualToString:DPLocalizedString(@"LightDuration_WholeDayOff")]) {
            obj.isOn = (durationModel.lampDayMask==0)?YES:NO;
        }
        if([obj.titleStr isEqualToString:DPLocalizedString(@"LightDuration_OnTime")]||
           [obj.titleStr isEqualToString:DPLocalizedString(@"LightDuration_OffTime")]){
            obj.editType = (durationModel.lampDayMask==0)?YES:NO;
        }
    }];
}

#pragma mark - 处理开关
+(void)handleSwitchWithOn:(BOOL) isOn
             tableDataArr:(NSArray <LightDurationModel *>*) tableDataArr
         ampDurationModel:(LampDurationModel *) lampDurationModel{
    if (!lampDurationModel || tableDataArr.count <1 || !tableDataArr) {
        return;
    }
    lampDurationModel.lampDayMask = isOn?0:0x7f;
    [tableDataArr enumerateObjectsUsingBlock:^(LightDurationModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.editType = isOn?lightDurationEditType_NoEdit:lightDurationEditType_Editable;
    }];
}


#pragma mark - 处理开始结束时间选择
+ (void)handleSelectTimeWithType:(OnOffTimeType) type
                    tableDataArr:(NSArray <LightDurationModel *> *) tableDataArr
                   DurationModel:(LampDurationModel *) durationModel
                       component:(NSInteger) component
                             row:(NSInteger) row{
    switch (type) {
        case OnOffTimeType_ON:{     //  处理开启时间
            [tableDataArr enumerateObjectsUsingBlock:^(LightDurationModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([obj.titleStr isEqualToString:DPLocalizedString(@"LightDuration_OnTime")]) {
                    NSArray * hourArr = [[LightDurationViewModel handlePickerDate] firstObject];
                    NSArray * minuteArr = [[LightDurationViewModel handlePickerDate] lastObject];
                    
                    if (component == 0) {  // 选择了小时
                        durationModel.onTime.hour = [[hourArr objectAtIndex:row] integerValue];
                    }else{
                        durationModel.onTime.minute = [[minuteArr objectAtIndex:row] integerValue];
                    }
                    obj.dateTimeStr = [NSString stringWithFormat:@"%@%d:%@%d",durationModel.onTime.hour<10?@"0":@"",durationModel.onTime.hour,durationModel.onTime.minute<10?@"0":@"",durationModel.onTime.minute];
                    *stop = YES;
                }
            }];
            
        }break;
        case OnOffTimeType_OFF:{    //  处理关闭时间
            [tableDataArr enumerateObjectsUsingBlock:^(LightDurationModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([obj.titleStr isEqualToString:DPLocalizedString(@"LightDuration_OffTime")]) {
                    NSArray * hourArr = [[LightDurationViewModel handlePickerDate] firstObject];
                    NSArray * minuteArr = [[LightDurationViewModel handlePickerDate] lastObject];
                    
                    if (component == 0) {  // 选择了小时
                        durationModel.offTime.hour = [[hourArr objectAtIndex:row] integerValue];
                    }else{
                        durationModel.offTime.minute = [[minuteArr objectAtIndex:row] integerValue];
                    }
                    obj.dateTimeStr = [NSString stringWithFormat:@"%@%d:%@%d",durationModel.offTime.hour<10?@"0":@"",durationModel.offTime.hour,durationModel.offTime.minute<10?@"0":@"",durationModel.offTime.minute];
                    *stop = YES;
                }
            }];
        }break;
        default:
            break;
    }
}

#pragma mark - 初始化开启和结束时间数据
+ (NSArray<NSArray *> *)handlePickerDate{
    NSArray<NSArray *> * pickerDataArr = nil;
    if (!pickerDataArr)
    {
        NSMutableArray * hourArr = [[NSMutableArray alloc] init];
        NSMutableArray * minutesArr = [[NSMutableArray alloc] init];
        for (int i = 0; i <= 24; i++) {
            NSString * hourStr = [NSString stringWithFormat:@"%@%d",i<10?@"0":@"",i];
            [hourArr addObject:hourStr];
        }
        for (int i =0; i<=60; i++) {
            NSString * minutesStr = [NSString stringWithFormat:@"%@%d",i<10?@"0":@"",i];
            [minutesArr addObject:minutesStr];
        }
        
        pickerDataArr = @[hourArr,minutesArr];
    }
    return pickerDataArr;
}
@end
