//
//  TempAlarmViewModel.m
//  Goscom
//
//  Created by 匡匡 on 2018/11/23.
//  Copyright © 2018 goscam. All rights reserved.
//

#import "TempAlarmViewModel.h"
#import "TempAlarmModel.h"
#import "TempAlarmPickModel.h"
#import "iOSConfigSDKModel.h"
#import "TempAlarmPickerView.h"

#define MAX_DEGREE  50          // 最高摄氏度：50°C
#define MIN_DEGREE  (-10)       // 最低摄氏度：-10°C

#define MAX_FAHRENHEIT 122      // 最高华氏度：122°F
#define MIN_FAHRENHEIT 14       // 最低华氏度：14°F
// 转换公式：华氏度 = 摄氏度 * 1.8 + 32

@implementation TempAlarmViewModel

#pragma mark - 初始化温度报警界面数据
- (NSArray *)handleTabledataModel:(TemDetectModel *)temDetectModel{
    
    //    温度表示类型
    TemperatureType temperatureType = temDetectModel.temType;
    BOOL isC = temperatureType==0?YES:NO;
    
    // 第一个cell   °C
    TempAlarmModel * tempAlarmC = [TempAlarmModel modelWithTarget:TempAlarmCellType_C tempAlarmShowType:TempAlarmShowType_ButtonFont20 titleStr:@"°C" on:isC];
    // 第二个cell   °F
    TempAlarmModel * tempAlarmF = [TempAlarmModel modelWithTarget:TempAlarmCellType_F tempAlarmShowType:TempAlarmShowType_ButtonFont20 titleStr:@"°F" on:!isC];
    
    
    TemDetectEnableType temDetectEnableType = temDetectModel.enableType;
    BOOL uplimit = NO;
    if (temDetectEnableType == TemDetectEnable_upperLimits || temDetectEnableType == TemDetectEnable_openAll) {
        uplimit = YES;
    }
    // 第三个cell   上限温度
    TempAlarmModel * tempAlarmUplimit = [TempAlarmModel modelWithTarget:TempAlarmCellType_Uplimit tempAlarmShowType:TempAlarmShowType_Switch titleStr:DPLocalizedString(@"temperature_ceiling") on:uplimit];
    
    // 第四个cell   100°F
    NSString * upValueStr = [NSString stringWithFormat:@"%0.lf%@",temDetectModel.upperLimitsTem,isC?@"°C":@"°F"];
    TempAlarmModel * tempAlarmUpvalue = [TempAlarmModel modelWithTarget:TempAlarmCellType_Upvalue tempAlarmShowType:TempAlarmShowType_ButtonFont16 titleStr:upValueStr on:YES value:temDetectModel.upperLimitsTem];
    
    BOOL downLimit = NO;
    if (temDetectEnableType == TemDetectEnable_lowerLimits || temDetectEnableType == TemDetectEnable_openAll) {
        downLimit = YES;
    }
    
    // 第五个cell   下限温度
    TempAlarmModel * tempAlarmDownlimit = [TempAlarmModel modelWithTarget:TempAlarmCellType_Downlimit tempAlarmShowType:TempAlarmShowType_Switch titleStr:DPLocalizedString(@"Temperature_floor") on:downLimit];
    
    // 第六个cell   50°F
    NSString * downValueStr = [NSString stringWithFormat:@"%0.lf%@",temDetectModel.lowerLimitsTem,isC?@"°C":@"°F"];
    TempAlarmModel * tempAlarmDownvalue = [TempAlarmModel modelWithTarget:TempAlarmCellType_Downvalue tempAlarmShowType:TempAlarmShowType_ButtonFont16 titleStr:downValueStr on:NO value:temDetectModel.lowerLimitsTem];
    
    NSArray * dataArr = @[
                          @[tempAlarmC,tempAlarmF],
                          @[tempAlarmUplimit,tempAlarmUpvalue],
                          @[tempAlarmDownlimit,tempAlarmDownvalue]
                          ];
    
    return dataArr;
}

#pragma mark - 选中或开关 数据更改
- (void)cellActionWithCellModel:(TempAlarmModel *)cellModel
                  dataSourceArr:(nonnull NSArray *)tableDataArray
                 temDetectModel:(nonnull TemDetectModel *)temDetectModel{
    switch (cellModel.target) {
        case TempAlarmCellType_C:{  //  摄氏度
            TempAlarmModel * modelC = [self modelWithTarget:TempAlarmCellType_F dataArray:tableDataArray];
            modelC.on = !cellModel.on;
            
            // 获取最大/最小温度
            TempAlarmModel * upValueModel = [self modelWithTarget:TempAlarmCellType_Upvalue dataArray:tableDataArray];
            TempAlarmModel * downValueModel = [self modelWithTarget:TempAlarmCellType_Downvalue dataArray:tableDataArray];
            
            // 从华氏度 切换到摄氏度
            [upValueModel setValue:upValueModel.value isC:YES];
            [downValueModel setValue:downValueModel.value isC:YES];
            // 转换公式：华氏度 = 摄氏度 * 1.8 + 32
            temDetectModel.temType = Temperature_C;
            temDetectModel.lowerLimitsTem = downValueModel.value;
            temDetectModel.upperLimitsTem = upValueModel.value;
        }break;
        case TempAlarmCellType_F:{  //  华氏度
            TempAlarmModel * modelF = [self modelWithTarget:TempAlarmCellType_C dataArray:tableDataArray];
            modelF.on = !cellModel.on;
            
            // 获取最大/最小温度
            TempAlarmModel * upValueModel = [self modelWithTarget:TempAlarmCellType_Upvalue dataArray:tableDataArray];
            TempAlarmModel * downValueModel = [self modelWithTarget:TempAlarmCellType_Downvalue dataArray:tableDataArray];
            // 从摄氏度切换到华氏度
            [upValueModel setValue:upValueModel.value isC:NO];
            [downValueModel setValue:downValueModel.value isC:NO];
            temDetectModel.temType = Temperature_F;
            temDetectModel.lowerLimitsTem = downValueModel.value;
            temDetectModel.upperLimitsTem = upValueModel.value;
        }break;
        case TempAlarmCellType_Uplimit:{     //   上限温度
            
            if (cellModel.on) {
                if (TemDetectEnable_closeAll == temDetectModel.enableType) {
                    temDetectModel.enableType = TemDetectEnable_upperLimits;
                }else if(TemDetectEnable_lowerLimits == temDetectModel.enableType){
                    temDetectModel.enableType = TemDetectEnable_openAll;
                }
            }else{
                if (TemDetectEnable_upperLimits == temDetectModel.enableType) {
                    temDetectModel.enableType = TemDetectEnable_closeAll;
                }else if(TemDetectEnable_openAll == temDetectModel.enableType){
                    temDetectModel.enableType = TemDetectEnable_lowerLimits;
                }
            }
            
        }break;
        case TempAlarmCellType_Downlimit:{  //  下限温度
            if (cellModel.on) {
                if (TemDetectEnable_closeAll == temDetectModel.enableType) {
                    temDetectModel.enableType = TemDetectEnable_lowerLimits;
                }else if(TemDetectEnable_upperLimits == temDetectModel.enableType){
                    temDetectModel.enableType = TemDetectEnable_openAll;
                }
            }else{
                if (TemDetectEnable_openAll == temDetectModel.enableType) {
                    temDetectModel.enableType = TemDetectEnable_upperLimits;
                }else if(TemDetectEnable_lowerLimits == temDetectModel.enableType){
                    temDetectModel.enableType = TemDetectEnable_closeAll;
                }
            }
        }break;
            
        case TempAlarmCellType_Upvalue:{    //  最大温度值
            TempAlarmModel * modelD = [self modelWithTarget:TempAlarmCellType_Downvalue dataArray:tableDataArray];
            modelD.on = !cellModel.on;
            temDetectModel.upperLimitsTem = cellModel.value;
        }break;
            
        case TempAlarmCellType_Downvalue:{  //  最小温度值
            TempAlarmModel * modelU = [self modelWithTarget:TempAlarmCellType_Upvalue dataArray:tableDataArray];
            modelU.on = !cellModel.on;
            temDetectModel.lowerLimitsTem = cellModel.value;
        }break;
            
        default:
            break;
    }
}
#pragma mark - 华氏度摄氏度切换数据更改
- (void)pickerViewData:(NSArray *)tableDataArray
          dataPickview:(nonnull TempAlarmPickerView *)pickerView{
    
    // 根据此判断是否为摄氏度
    TempAlarmModel * modelC = [self modelWithTarget:TempAlarmCellType_C dataArray:tableDataArray];
    
    // 根据此判断选择的是上线温度还是下限温度
    TempAlarmModel * modelU = [self modelWithTarget:TempAlarmCellType_Upvalue dataArray:tableDataArray];
    
    // 温度下限
    TempAlarmModel * modelD = [self modelWithTarget:TempAlarmCellType_Downvalue dataArray:tableDataArray];
    
    NSInteger currentRow = 0;
    
    NSMutableArray * dataArr = [[NSMutableArray alloc] init];
    
    //    int min = modelC.on?(modelU.on?modelD.value:MIN_DEGREE):(modelU.on?modelD.value:MIN_FAHRENHEIT);
    //    int max = modelC.on?(modelU.on?MAX_DEGREE:modelU.value):(modelU.on?MAX_FAHRENHEIT:modelU.value);
    //
    //    for (int i = min, j=0; i <= max; i++, j++) {
    //        TempAlarmPickModel * model = [[TempAlarmPickModel alloc] init];
    //        NSString * tempStr = [NSString stringWithFormat:@"%d%@",i, modelC.on?@"°C":@"°F"];
    //        model.value = (double)i;
    //        model.ValueStr = tempStr;
    //        if (i == (modelU.on?(int)modelU.value:(int)modelD.value)) {
    //            currentRow = j;
    //        }
    //        [dataArr addObject:model];
    //    }
    
    int min = 0;
    int max = 0;
    
    // 摄氏度选中  代表当前为摄氏度
    if (modelC.on) {
        // 上线温度选择 代表当前为上限温度
        if (modelU.on) {
            min = (int)modelD.value;
            max = MAX_DEGREE;
        }else{      //  当前为下限温度
            min = MIN_DEGREE;
            max = (int)modelU.value;
        }
    }
    // 当前为华氏度
    else{
        // 上线温度选择 代表当前为上限温度
        if (modelU.on) {
            min = (int)modelD.value;
            max = MAX_FAHRENHEIT;
        }else{      //  当前为下限温度
            min = MIN_FAHRENHEIT;
            max = (int)modelU.value;
        }
    }
    for (int i = min, j=0; i <= max; i++, j++) {
        TempAlarmPickModel * model = [[TempAlarmPickModel alloc] init];
        NSString * tempStr = [NSString stringWithFormat:@"%d%@",i, modelC.on?@"°C":@"°F"];
        model.value = (double)i;
        model.ValueStr = tempStr;
        if (i == (modelU.on?(int)modelU.value:(int)modelD.value)) {
            currentRow = j;
        }
        [dataArr addObject:model];
    }
    
    if (modelU.on) {
        pickerView.titleLab.text = DPLocalizedString(@"temperature_ceiling_temperature");
    }else{
        pickerView.titleLab.text = DPLocalizedString(@"temperature_floor_temperature");
    }
    
    [pickerView setDataSourceArray:dataArr currentRow:currentRow];
    
}
#pragma mark - 温度选择器选择后数据更改
- (void) modifyPickViewModelData:(TempAlarmPickModel *)modelData
                         dataArr:(NSArray *) tableDataArray
                  temDetectModel:(nonnull TemDetectModel *)temDetectModel{
    TempAlarmModel * tempAlarmC = [self modelWithTarget:TempAlarmCellType_C dataArray:tableDataArray];
    TempAlarmModel * tempAlarmUpvalue = [self modelWithTarget:TempAlarmCellType_Upvalue dataArray:tableDataArray];
    TempAlarmModel * tempAlarmDownvalue = [self modelWithTarget:TempAlarmCellType_Downvalue dataArray:tableDataArray];
    
    // 选择的上限温度值
    if (tempAlarmUpvalue.on) {
        tempAlarmUpvalue.value = modelData.value;
        [tempAlarmUpvalue setValue:modelData.value isCFromPickView:tempAlarmC.on];
        temDetectModel.upperLimitsTem = modelData.value;
    }else{
        tempAlarmDownvalue.value = modelData.value;
        [tempAlarmDownvalue setValue:modelData.value isCFromPickView:tempAlarmC.on];
        temDetectModel.lowerLimitsTem = modelData.value;
    }
}

- (TempAlarmModel *)modelWithTarget:(NSInteger)target
                          dataArray:(NSArray *)dataArr{
    for (id element in dataArr) {
        if ([element isKindOfClass:[NSArray class]]) {
            for (TempAlarmModel * model in element) {
                if (model.target == target) {
                    return model;
                }
            }
        }else{
            if (((TempAlarmModel *)element).target == target) {
                return element;
            }
        }
    }
    return nil;
}

@end
