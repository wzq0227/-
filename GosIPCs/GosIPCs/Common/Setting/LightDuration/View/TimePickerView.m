//  TimePickerView.m
//  Goscom
//
//  Create by 匡匡 on 2018/12/18.
//  Copyright © 2018 goscam. All rights reserved.

#import "TimePickerView.h"
#import "LightDurationViewModel.h"
#import "iOSConfigSDKModel.h"
#import "UIView+GosCoord.h"
@interface TimePickerView ()<UIPickerViewDelegate, UIPickerViewDataSource>
@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;
@property (weak, nonatomic) IBOutlet UIButton *cancelBtn;
@property (weak, nonatomic) IBOutlet UIButton *confirmBtn;
@property (weak, nonatomic) IBOutlet UILabel *titleLab;
/// 底部View
@property (weak, nonatomic) IBOutlet UIView *bottomView;

@end

@implementation TimePickerView


+ (instancetype)sharePickerViewWithTimeType:(OnOffTimeType) onOffTimeType
                               tableDataArr:(NSArray *) tableDataArr
                          lampDurationModel:(LampDurationModel *) lampDurationModel
                                   delegate:(id<TimePickerViewDelegate>)delegate{
    TimePickerView * pickerView = [[TimePickerView alloc] init];
    pickerView.onOffTimeType = onOffTimeType;
    pickerView.lampDurationModel = lampDurationModel;
    pickerView.tableDataArr = tableDataArr;
    pickerView.delegate = delegate;
    [pickerView showView];
    return pickerView;
}
-(void)setOnOffTimeType:(OnOffTimeType)onOffTimeType{
    _onOffTimeType = onOffTimeType;
    self.titleLab.text = onOffTimeType == OnOffTimeType_ON?DPLocalizedString(@"LightDuration_OnTime"):DPLocalizedString(@"LightDuration_OffTime");
}
-(void)setTableDataArr:(NSArray *)tableDataArr{
    _tableDataArr = tableDataArr;
}
-(void)setLampDurationModel:(LampDurationModel *)lampDurationModel{
    _lampDurationModel = lampDurationModel;
    NSInteger row0 = 0;
    NSInteger row1 = 0;
    if (self.onOffTimeType == OnOffTimeType_ON) {
        row0 = lampDurationModel.onTime.hour;
        row1 = lampDurationModel.onTime.minute;
    }else{
        row0 = lampDurationModel.offTime.hour;
        row1 = lampDurationModel.offTime.minute;
    }
    [self.pickerView reloadComponent:0];
    [self.pickerView selectRow:row0 inComponent:0 animated:YES];
    [self.pickerView reloadComponent:1];
    [self.pickerView selectRow:row1 inComponent:1 animated:YES];
}

- (void)showView{
    
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    [UIView animateWithDuration:0.5 animations:^{
        self.bottomView.y = 270;
        self.alpha = 1.0f;
    }];
    
    //    [UIView animateWithDuration:10.3 animations:^{
    //        CGRect animationRect = CGRectMake(0, GOS_SCREEN_H -270, GOS_SCREEN_W, 270);
    //        self.bottomView.frame = animationRect;
    //    } completion:^(BOOL finished) {
    //        [[UIApplication sharedApplication].keyWindow addSubview:self];
    //    }];
    
}
- (void)hiddenView{
    [UIView animateWithDuration:0.5 animations:^{
        self.bottomView.y = GOS_SCREEN_H;
        self.alpha = 0.0f;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (IBAction)cancleClick:(UIButton *)sender {
    [self hiddenView];
    //    [UIView animateWithDuration:0.5 animations:^{
    //        CGRect animationRect = CGRectMake(0, GOS_SCREEN_H -270, GOS_SCREEN_W, 0);
    //        self.frame = animationRect;
    //    } completion:^(BOOL finished) {
    //        [self removeFromSuperview];
    //    }];
}

- (IBAction)confirmClick:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(timePickerFinish)]) {
        [self.delegate timePickerFinish];
    }
    [self hiddenView];
    //    [UIView animateWithDuration:0.3 animations:^{
    //        self.backgroundColor = [UIColor clearColor];
    //    } completion:^(BOOL finished) {
    //        [self removeFromSuperview];
    //    }];
}
#pragma mark - 将选择的时分转化为NSDate
#pragma mark - pickerView&delegate
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 2;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    if (component == 0) {
        return [[[LightDurationViewModel handlePickerDate] firstObject] count];
    }else if (component == 1){
        return [[[LightDurationViewModel handlePickerDate] lastObject] count];
    }
    return 0;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
    UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, GOS_SCREEN_W / 2, 40)];
    label.adjustsFontSizeToFitWidth = YES;
    label.textAlignment = NSTextAlignmentCenter;
    if (component == 0) {
        label.text = [[LightDurationViewModel handlePickerDate] firstObject][row];
    }else if (component == 1){
        label.text = [[LightDurationViewModel handlePickerDate] lastObject][row];
    }
    return label;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    [LightDurationViewModel handleSelectTimeWithType:self.onOffTimeType tableDataArr:self.tableDataArr DurationModel:self.lampDurationModel component:component row:row];
    
}
- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component{
    return 40.0;
}
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    self = [[[NSBundle mainBundle] loadNibNamed:@"TimePickerView" owner:self options:nil] lastObject];
    if (self) {
        self.frame = [UIScreen mainScreen].bounds;
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
        self.pickerView.delegate = self;
        self.pickerView.dataSource = self;
        [self.cancelBtn setTitle:DPLocalizedString(@"GosComm_Cancel") forState:UIControlStateNormal];
        [self.confirmBtn setTitle:DPLocalizedString(@"GosComm_Confirm") forState:UIControlStateNormal];
    }
    return self;
}

#pragma mark - lazy


@end
