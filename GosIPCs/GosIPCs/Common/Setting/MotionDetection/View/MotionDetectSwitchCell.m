//
//  MotionDetectSwitchCell.m
//  Goscom
//
//  Created by 匡匡 on 2018/11/27.
//  Copyright © 2018 goscam. All rights reserved.
//

#import "MotionDetectSwitchCell.h"
#import "iOSConfigSDK.h"
#import "VoiceMonitonModel.h"
@interface MotionDetectSwitchCell ()
@property (weak, nonatomic) IBOutlet UILabel *titleLab;
@property (weak, nonatomic) IBOutlet UIImageView *iconImg;
@end

@implementation MotionDetectSwitchCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

+ (instancetype)cellWithTableView:(UITableView *)tableView
                        indexPath:(NSIndexPath *)indexPath
                        cellModel:(VoiceMonitonModel *) cellModel
                         delegate:(nonnull id<MotionDetectSwitchDelegate>)delegate{
    [tableView registerNib:[UINib nibWithNibName:@"MotionDetectSwitchCell" bundle:nil] forCellReuseIdentifier:@"MotionDetectSwitchCell"];
    MotionDetectSwitchCell * cell = [tableView dequeueReusableCellWithIdentifier:@"MotionDetectSwitchCell"];
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    cell.cellModel = cellModel;
    cell.delegate = delegate;
    return cell;
}
//-(void)setIsOn:(BOOL)isOn{
//    _isOn = isOn;
//    self.monitSwitch.on = isOn;
//}
- (void)setCellModel:(VoiceMonitonModel *)cellModel{
    _cellModel = cellModel;
    self.titleLab.text = cellModel.titleStr;
    self.iconImg.image = [UIImage imageNamed:cellModel.iconImgStr];
    self.monitSwitch.on = cellModel.isON;
}

- (IBAction)actionSwitchChangeClick:(UISwitch *)sender {
    self.cellModel.isON = sender.on;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(MotionDetectSwitchDidChange:)]) {
        [self.delegate MotionDetectSwitchDidChange:self.cellModel.isON];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
