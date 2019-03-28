//
//  LightDurationCell.m
//  Goscom
//
//  Created by 匡匡 on 2018/11/27.
//  Copyright © 2018 goscam. All rights reserved.
//

#import "LightDurationCell.h"
#import "iOSConfigSDK.h"
#import "LightDurationModel.h"
@interface LightDurationCell()
@property (weak, nonatomic) IBOutlet UILabel *titleLab; //  标题lab
@property (weak, nonatomic) IBOutlet UILabel *timeLab;   // 时间lab
@property (weak, nonatomic) IBOutlet UIImageView *arrowImg; //  三角形img
@property (weak, nonatomic) IBOutlet UISwitch *onSwitch;    //  开关switch
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *arrowImgWidth;

@end
@implementation LightDurationCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

+ (instancetype)cellWithTableView:(UITableView *) tableView
                        indexPath:(NSIndexPath *) indexPath
                        cellModel:(LightDurationModel *) cellModel
                         delegate:(id<LightDurationCellDelegate>) delegate{
    [tableView registerNib:[UINib nibWithNibName:@"LightDurationCell" bundle:nil] forCellReuseIdentifier:@"LightDurationCell"];
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    LightDurationCell * cell = [tableView dequeueReusableCellWithIdentifier:@"LightDurationCell"];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    cell.delegate = delegate;
    cell.cellModel = cellModel;
    switch (cellModel.cellType) {
        case lightDurationCellType_Switch:{
            cell.timeLab.hidden = YES;
            cell.arrowImg.hidden = YES;
            cell.onSwitch.on = cellModel.isOn;
            cell.titleLab.text = cellModel.titleStr;
        }break;
        case lightDurationCellType_Label:{
            cell.onSwitch.hidden = YES;
            cell.timeLab.text = cellModel.dateTimeStr;
            cell.titleLab.text = cellModel.titleStr;
        default:
            break;
        }
    }
    switch (cellModel.editType) {
        case lightDurationEditType_NoEdit:{
            cell.timeLab.textColor = GOS_COLOR_RGB(0xE6E6E6);
            cell.arrowImgWidth.constant = 0.0f;
        }break;
        case lightDurationEditType_Editable:{
            cell.timeLab.textColor = GOS_COLOR_RGB(0x1A1A1A);
            cell.arrowImgWidth.constant = 8.0f;
        }break;
            
        default:
            break;
    }
    return cell;
}
- (void)setCellModel:(LightDurationModel *)cellModel{
    _cellModel = cellModel;
}
- (IBAction)actionSwitchStateChange:(UISwitch *)sender {
    self.cellModel.isOn =! self.cellModel.isOn;
    if (self.delegate && [self.delegate respondsToSelector:@selector(LightDurationSwitch:)]) {
        [self.delegate LightDurationSwitch:self.cellModel.isOn];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
