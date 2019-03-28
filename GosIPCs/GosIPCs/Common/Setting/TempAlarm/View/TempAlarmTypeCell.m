//
//  TempAlarmTypeCell.m
//  Goscom
//
//  Created by 匡匡 on 2018/11/23.
//  Copyright © 2018 goscam. All rights reserved.
//

#import "TempAlarmTypeCell.h"
#import "TempAlarmModel.h"

@interface TempAlarmTypeCell()
@property (weak, nonatomic) IBOutlet UILabel *titleLab;
@property (weak, nonatomic) IBOutlet UISwitch *onSwitch;
@property (weak, nonatomic) IBOutlet UIButton *selectBtn;
@end

@implementation TempAlarmTypeCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

+(instancetype)cellModelWithTableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath model:(TempAlarmModel *)dataModel delegate:(id<TempAlarmTypeCellDelegate>)delegate{
    [tableView registerNib:[UINib nibWithNibName:@"TempAlarmTypeCell" bundle:nil] forCellReuseIdentifier:@"TempAlarmTypeCell"];
    TempAlarmTypeCell * cell = [tableView dequeueReusableCellWithIdentifier:@"TempAlarmTypeCell"];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    cell.delegate = delegate;
    cell.dataModel = dataModel;
    return cell;
}

-(void)setDataModel:(TempAlarmModel *)dataModel{
    _dataModel = dataModel;
    self.titleLab.text = dataModel.titleStr;
    self.onSwitch.on = dataModel.on;
    if (self.dataModel.on) {
        [self.selectBtn setImage:[UIImage imageNamed:@"icon_circle_selected"] forState:UIControlStateNormal];

    }else{
         [self.selectBtn setImage:[UIImage imageNamed:@"icon_circle_normal"] forState:UIControlStateNormal];
    }
    
    switch (dataModel.tempAlarmShowType) {
        case TempAlarmShowType_Switch:{
            self.onSwitch.hidden = NO;
            self.selectBtn.hidden = YES;
        }break;
        case TempAlarmShowType_ButtonFont16:{
            self.onSwitch.hidden = YES;
            self.selectBtn.hidden = NO;
            self.titleLab.font = GOS_FONT(16);
        }break;
        case TempAlarmShowType_ButtonFont20:{
            self.onSwitch.hidden = YES;
            self.selectBtn.hidden = NO;
            self.titleLab.font = GOS_FONT(20);
        }break;
            
        default:
            break;
    }
}

- (IBAction)switchChangeClick:(UISwitch *)sender {
    self.dataModel.on = sender.on;
    if (self.delegate && [self.delegate respondsToSelector:@selector(switchStateDidChange:)]) {
        [self.delegate switchStateDidChange:self];
    }
}
- (IBAction)selectClick:(UIButton *)sender {
    if (self.dataModel.on) {
        return;
    }
    self.dataModel.on = YES;
    if (self.delegate && [self.delegate respondsToSelector:@selector(switchStateDidChange:)]) {
        [self.delegate switchStateDidChange:self];
    }
}


-(void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
