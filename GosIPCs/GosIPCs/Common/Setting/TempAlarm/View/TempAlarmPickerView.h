//
//  TempAlarmPickerView.h
//  Goscom
//
//  Created by 匡匡 on 2018/11/24.
//  Copyright © 2018 goscam. All rights reserved.
//

#import <UIKit/UIKit.h>
@class TempAlarmViewModel;
@class TempAlarmPickModel;
@protocol TempAlarmPickerViewDelegate<NSObject>
@optional;
-(void) pickerViewSelectRow:(TempAlarmPickModel *) rowData;
@end

NS_ASSUME_NONNULL_BEGIN

@interface TempAlarmPickerView : UIView
@property (weak, nonatomic) IBOutlet UILabel *titleLab; //  标题
@property (weak, nonatomic) IBOutlet UIPickerView *tempPickView;    //  温度选择
@property (nonatomic, weak) id <TempAlarmPickerViewDelegate> delegate;
@property (nonatomic, strong) NSArray * dataSourceArray; //  数据来源


-(void) setDataSourceArray:(NSArray *) dataArr
                currentRow:(NSInteger) currentRow;


@end

NS_ASSUME_NONNULL_END
