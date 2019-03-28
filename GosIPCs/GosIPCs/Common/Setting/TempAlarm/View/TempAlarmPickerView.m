//
//  TempAlarmPickerView.m
//  Goscom
//
//  Created by 匡匡 on 2018/11/24.
//  Copyright © 2018 goscam. All rights reserved.
//

#import "TempAlarmPickerView.h"
#import "TempAlarmViewModel.h"
#import "TempAlarmModel.h"
#import "TempAlarmPickModel.h"

#define MAX_DEGREE  50          // 最高摄氏度：50°C
#define MIN_DEGREE  (-10)       // 最低摄氏度：-10°C

#define MAX_FAHRENHEIT 122      // 最高华氏度：122°F
#define MIN_FAHRENHEIT 14       // 最低华氏度：14°F

@interface TempAlarmPickerView ()<UIPickerViewDelegate,UIPickerViewDataSource>
@property (nonatomic, assign) NSInteger currentRow;
@end

@implementation TempAlarmPickerView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    self = [[[NSBundle mainBundle] loadNibNamed:@"TempAlarmPickerView" owner:self options:nil] lastObject];
    if (self) {
        self.frame = frame;
    }
    return self;
}
-(void)setDataSourceArray:(NSArray *)dataSourceArray currentRow:(NSInteger)currentRow{
    _dataSourceArray = dataSourceArray;
    self.currentRow = currentRow;
    if (self.currentRow>=0)
    {
        [self.tempPickView selectRow:self.currentRow inComponent:0 animated:NO];
    }
    [self.tempPickView reloadComponent:0];
}
-(void)awakeFromNib{
    [super awakeFromNib];
    self.tempPickView.showsSelectionIndicator=YES;
    self.tempPickView.dataSource = self;
    self.tempPickView.delegate = self;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView*)pickerView
{
    return 1; // 返回1表明该控件只包含1列
}
- (NSInteger)pickerView:(nonnull UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return self.dataSourceArray.count;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UILabel *label =[[UILabel alloc] initWithFrame:CGRectMake(0, 0.0f, GOS_SCREEN_W,28)];
    TempAlarmPickModel * model = self.dataSourceArray[row];
    [label setText:model.ValueStr];
    label.backgroundColor = [UIColor clearColor];
    [label setTextAlignment: NSTextAlignmentCenter];
    return label;
}
// 每列宽度
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    return 180;
}
// 返回选中的行
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    TempAlarmPickModel * model = self.dataSourceArray[row];
    if (self.delegate && [self.delegate respondsToSelector:@selector(pickerViewSelectRow:)]) {
        [self.delegate pickerViewSelectRow:model];
    }    
}
//返回当前行的内容,此处是将数组中数值添加到滚动的那个显示栏上
-(NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return self.dataSourceArray[row];
}

@end
