//
//  AddSensorCell.m
//  Goscom
//
//  Created by 匡匡 on 2018/11/30.
//  Copyright © 2018 goscam. All rights reserved.
//

#import "AddSensorCell.h"
#import "iOSConfigSDKModel.h"
@interface AddSensorCell()
/// 传感器修改按钮
@property (weak, nonatomic) IBOutlet UIButton *sensorModifyBtn;
/// 传感器开关
@property (weak, nonatomic) IBOutlet UISwitch *sensorSwitch;
/// 传感器名
@property (weak, nonatomic) IBOutlet UILabel *sensorTitleLab;
@end
@implementation AddSensorCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
+ (instancetype)cellWithTableView:(UITableView *) tableView
                         cellModel:(IotSensorModel *) cellModel
                          delegate:(id<addSensorCellDelegate>) delegate{
    [tableView registerNib:[UINib nibWithNibName:@"AddSensorCell" bundle:nil] forCellReuseIdentifier:@"AddSensorCell"];
    AddSensorCell * cell = [tableView dequeueReusableCellWithIdentifier:@"AddSensorCell"];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    cell.cellModel = cellModel;
    cell.delegate = delegate;
    return cell;
}
-(void)setCellModel:(IotSensorModel *)cellModel{
    _cellModel = cellModel;
    self.sensorSwitch.on = cellModel.isAPNSOpen;
    self.sensorTitleLab.text = cellModel.iotSensorName?cellModel.iotSensorName:@"";
}
#pragma mark - 重命名点击
- (IBAction)actionModifyNameClick:(UIButton *)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(modifySensorName:)]) {
        [self.delegate modifySensorName:self.cellModel];
    }
}
#pragma mark - switch状态改变
- (IBAction)actionSwitchClick:(UISwitch *)sender {
    self.cellModel.isAPNSOpen = sender.on;
    if (self.delegate && [self.delegate respondsToSelector:@selector(modifySensorSwitch:)]) {
        [self.delegate modifySensorSwitch:self.cellModel];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
