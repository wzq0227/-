//  AddSensorTypeModel.m
//  Goscom
//
//  Create by 匡匡 on 2019/1/8.
//  Copyright © 2019 goscam. All rights reserved.

#import "AddSensorTypeModel.h"

@implementation AddSensorTypeModel
-(NSMutableArray<IotSensorModel *> *)sectionArr{
    if (!_sectionArr) {
        _sectionArr = [[NSMutableArray alloc] init];
    }
    return _sectionArr;
}
@end
