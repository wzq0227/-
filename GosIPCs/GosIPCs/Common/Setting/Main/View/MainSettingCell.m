//
//  MainSettingCell.m
//  Goscom
//
//  Created by 匡匡 on 2018/11/20.
//  Copyright © 2018 goscam. All rights reserved.
//

#import "MainSettingCell.h"
#import "MainSettingModel.h"

@interface MainSettingCell()
@property (weak, nonatomic) IBOutlet UIImageView *iconImg;
@property (weak, nonatomic) IBOutlet UILabel *nameLab;

@property (weak, nonatomic) IBOutlet UILabel *stateLab;     //  开关自动
@property (weak, nonatomic) IBOutlet UIImageView *arrowImg;
@end

@implementation MainSettingCell

- (void)awakeFromNib {
    [super awakeFromNib];
}
+ (instancetype)cellModelWithTableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath model:(MainSettingModel *)cellModel delegate:(id<MainSettingCellDelegate>)delegate{
    [tableView registerNib:[UINib nibWithNibName:@"MainSettingCell" bundle:nil] forCellReuseIdentifier:@"MainSettingCell"];
     MainSettingCell * cell = [tableView dequeueReusableCellWithIdentifier:@"MainSettingCell"];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    cell.delegate = delegate;
    cell.cellModel = cellModel;
    return cell;
}

-(void)setCellModel:(MainSettingModel *)cellModel{
    _cellModel = cellModel;
    self.nameLab.text = cellModel.nameStr;
    self.iconImg.image = [UIImage imageNamed:cellModel.imageStr];
    switch (cellModel.cellType) {
        case SettingCellType_HasNext:{
            self.settingSwitch.hidden = YES;
            self.stateLab.hidden = YES;
            self.arrowImg.hidden = NO;
        }break;
        case SettingCellType_Switch:{
            self.arrowImg.hidden = YES;
            self.settingSwitch.on = cellModel.switchState;
            self.settingSwitch.hidden = NO;
            self.stateLab.hidden = YES;
        }break;
        case SettingCellType_State:{
            self.settingSwitch.hidden = YES;
            self.stateLab.hidden = NO;
            self.arrowImg.hidden = NO;
            if (SettingType_CloudService == cellModel.settingType) {
                self.stateLab.text = cellModel.cloudServiceDateLife;
            }else if(SettingType_NightVersion == cellModel.settingType){
                self.stateLab.text = cellModel.nightVersionStr;
            }
        }break;
            
        default:
            break;
    }
}
- (IBAction)switchStateChange:(UISwitch *)sender {
    self.cellModel.switchState = sender.on;
    if (self.delegate && [self.delegate respondsToSelector:@selector(cellSwitchDidChangeState:)]) {
        [self.delegate cellSwitchDidChangeState:self];
    }
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
