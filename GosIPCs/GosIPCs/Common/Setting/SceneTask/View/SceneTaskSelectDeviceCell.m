//  SceneTaskSelectDeviceCell.m
//  Goscom
//
//  Create by 匡匡 on 2018/12/27.
//  Copyright © 2018 goscam. All rights reserved.

#import "SceneTaskSelectDeviceCell.h"
#import "SceneTaskModel.h"
@interface SceneTaskSelectDeviceCell()
@property (weak, nonatomic) IBOutlet UIImageView *iconImg;
@property (weak, nonatomic) IBOutlet UILabel *titleLab;
@property (weak, nonatomic) IBOutlet UIImageView *selectImg;
@end
@implementation SceneTaskSelectDeviceCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.iconImg.image = [UIImage imageNamed:@"icon_circle_normal"];
//    icon_circle_selected
//    icon_circle_check
//    icon_circle_normal
}

+(instancetype)cellWithTableView:(UITableView *)tableView
                       cellModel:(nonnull SceneTaskModel *)cellModel{
    [tableView registerNib:[UINib nibWithNibName:NSStringFromClass([self class]) bundle:nil] forCellReuseIdentifier:@"SceneTaskSelectDeviceCell"];
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    SceneTaskSelectDeviceCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SceneTaskSelectDeviceCell"];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    cell.cellModel = cellModel;
    return cell;
}

-(void)setCellModel:(SceneTaskModel *)cellModel{
    self.titleLab.text = cellModel.iotSensorName;
    self.selectImg.image = [UIImage imageNamed:cellModel.isSelect?@"icon_circle_check":@"icon_circle_normal"];
    switch (cellModel.iotSensorType) {
        case GosIot_sensorAudibleAlarm: {
            self.iconImg.image = [UIImage imageNamed:@"icon_iot_sensor_alarm"];
        }break;
        case GosIot_sensorMagnetic: {
            self.iconImg.image = [UIImage imageNamed:@"icon_iot_sensor_magnetic"];
        }break;
        case GosIot_sensorInfrared:{
            self.iconImg.image = [UIImage imageNamed:@"icon_iot_sensor_pir"];
        }break;
        case GosIot_sensorSOS: {
            self.iconImg.image = [UIImage imageNamed:@"icon_iot_sensor_sos"];
        }break;
        case GosIot_unknow: {
            
        }break;
        default:
            break;
    }
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
