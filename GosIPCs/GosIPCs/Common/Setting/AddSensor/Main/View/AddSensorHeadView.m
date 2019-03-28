//
//  AddSensorHeadView.m
//  Goscom
//
//  Created by 匡匡 on 2018/11/30.
//  Copyright © 2018 goscam. All rights reserved.
//

#import "AddSensorHeadView.h"

@interface AddSensorHeadView ()
@property (weak, nonatomic) IBOutlet UIImageView *iconImg;
@property (weak, nonatomic) IBOutlet UILabel *titleLab;
@property (weak, nonatomic) IBOutlet UIImageView *addImg;
@end

@implementation AddSensorHeadView

+ (AddSensorHeadView *)headViewWithTypeModel:(AddSensorTypeModel *)sensorTypeModel
                                     delegate:(id<AddSensorHeadViewDelegate>)delegate{
    AddSensorHeadView * headView = [[AddSensorHeadView alloc] init];
    headView.titleLab.text = sensorTypeModel.sectionStr;
    headView.gosIOTType = sensorTypeModel.gosIOTType;
    headView.delegate = delegate;
    return headView;
}
-(void)setGosIOTType:(GosIOTType)gosIOTType{
    _gosIOTType = gosIOTType;
    switch (gosIOTType) {
        case GosIot_sensorMagnetic:{
            self.iconImg.image = [UIImage imageNamed:@"icon_iot_sensor_magnetic"];
        }break;
        case GosIot_sensorInfrared:{
            self.iconImg.image = [UIImage imageNamed:@"icon_iot_sensor_pir"];
        }break;
        case GosIot_sensorAudibleAlarm:{
            self.iconImg.image = [UIImage imageNamed:@"icon_iot_sensor_alarm"];
        }break;
        case GosIot_sensorSOS:{
            self.iconImg.image = [UIImage imageNamed:@"icon_iot_sensor_sos"];
        }break;
        default:
            break;
    }
}

- (IBAction)actionAddClick:(UIButton *)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(AddSensorWithType:)]) {
        [self.delegate AddSensorWithType:self.gosIOTType];
    }
}
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    self = [[[NSBundle mainBundle] loadNibNamed:@"AddSensorHeadView" owner:self options:nil] lastObject];
    if (self) {
        self.frame = frame;
    }
    return self;
}
@end
