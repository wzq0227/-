//  MessageCenterSetupTableViewCell.m
//  GosIPCs
//
//  Create by daniel.hu on 2018/12/5.
//  Copyright © 2018年 goscam. All rights reserved.

#import "MessageCenterSetupTableViewCell.h"
#import "MessageCenterSetupCellModel.h"

@interface MessageCenterSetupTableViewCell ()
/// title
@property (weak, nonatomic) IBOutlet UILabel *cellTitleLabel;
/// 开关
@property (weak, nonatomic) IBOutlet UISwitch *cellSwitch;
/// cell数据
@property (nonatomic, strong) MessageCenterSetupCellModel *cellModel;
@end

@implementation MessageCenterSetupTableViewCell

static NSString *const kMessageCenterSetupTableViewCellID = @"kMessageCenterSetupTableViewCellID";

+ (instancetype)cellWithTableView:(UITableView *)tableView model:(MessageCenterSetupCellModel *)model target:(nonnull id<MessageCenterSetupTableViewCellDelegate>)target {
    // 注册cell
    [tableView registerNib:[UINib nibWithNibName:NSStringFromClass([self class]) bundle:nil] forCellReuseIdentifier:kMessageCenterSetupTableViewCellID];
    // 重用
    MessageCenterSetupTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kMessageCenterSetupTableViewCellID];
    
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:self options:nil] lastObject];
    }
    cell.delegate = target;
    // 配置数据
    cell.cellModel = model;
    return cell;
}
+ (CGFloat)cellHeightWithModel:(MessageCenterSetupCellModel *)model {
    return 46;
}

- (void)setCellModel:(MessageCenterSetupCellModel *)cellModel {
    _cellModel = cellModel;
    
    self.cellTitleLabel.text = cellModel.titleText;
    self.cellSwitch.on = cellModel.isOn;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (IBAction)switchValueDidChanged:(id)sender {
}

@end
