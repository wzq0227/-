//  MessageCenterTableViewCell.m
//  GosIPCs
//
//  Create by daniel.hu on 2018/12/4.
//  Copyright © 2018年 goscam. All rights reserved.

#import "MessageCenterTableViewCell.h"
#import "MessageCenterCellModel.h"

@interface MessageCenterTableViewCell ()
/// 选择按钮
@property (weak, nonatomic) IBOutlet UIButton *selectButton;
/// 图标
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
/// 红点
@property (weak, nonatomic) IBOutlet UIImageView *redCircleImageView;
/// 标题
@property (weak, nonatomic) IBOutlet UILabel *cellTitleLabel;
/// 详细信息
@property (weak, nonatomic) IBOutlet UILabel *cellDetailLabel;
/// 指示
@property (weak, nonatomic) IBOutlet UIImageView *indicatorImageView;
/// 上分割线
@property (weak, nonatomic) IBOutlet UIView *topSeparatorView;
/// 下分割线
@property (weak, nonatomic) IBOutlet UIView *bottomSeparatorView;
/// 图标的左边
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *iconImageLeftConstrait;
/// cell数据
@property (nonatomic, strong) MessageCenterCellModel *cellModel;
@end
@implementation MessageCenterTableViewCell
// cell id
static NSString *const kMessageCenterTableViewCellID = @"kMessageCenterTableViewCellID";
#pragma mark - class method
+ (instancetype)cellWithTableView:(UITableView *)tableView model:(MessageCenterCellModel *)model {
    // 注册cell
    [tableView registerNib:[UINib nibWithNibName:NSStringFromClass([self class]) bundle:nil] forCellReuseIdentifier:kMessageCenterTableViewCellID];
    // 重用
    MessageCenterTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kMessageCenterTableViewCellID];
    
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:self options:nil] lastObject];
    }
    // 配置数据
    cell.cellModel = model;
    return cell;
}
+ (CGFloat)cellHeightWithModel:(MessageCenterCellModel *)model {
    return 46;
}
#pragma mark - nib method
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

#pragma mark - setters
- (void)setCellModel:(MessageCenterCellModel *)cellModel {
    _cellModel = cellModel;
    
    // 配置显示隐藏
    self.indicatorImageView.hidden = cellModel.cellStyle != MessageCellStyleArrow;
    self.detailTextLabel.hidden = cellModel.cellStyle != MessageCellStyleDetail;
    self.topSeparatorView.hidden = !(cellModel.separatorType & MessageCellSeparatorTypeTop);
    self.bottomSeparatorView.hidden = !(cellModel.separatorType & MessageCellSeparatorTypeBottom);
    self.selectButton.hidden = !cellModel.isEditing;
    
    // 配置数据
    self.cellTitleLabel.text = cellModel.titleText;
    self.cellDetailLabel.text = cellModel.detailText;
    self.iconImageView.image = cellModel.image;
    self.iconImageLeftConstrait.constant = self.selectButton.hidden ? 15 : 50;
    self.selectButton.selected = cellModel.isSelected;
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
