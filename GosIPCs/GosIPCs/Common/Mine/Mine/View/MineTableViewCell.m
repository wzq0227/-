//  MineTableViewCell.m
//  GosIPCs
//
//  Create by daniel.hu on 2018/11/20.
//  Copyright © 2018年 goscam. All rights reserved.

#import "MineTableViewCell.h"
#import "MineCellModel.h"

@interface MineTableViewCell ()
/// 右侧指向图片
@property (weak, nonatomic) IBOutlet UIImageView *indicatorImageView;
/// 标题
@property (weak, nonatomic) IBOutlet UILabel *cellTitleLabel;
/// 上分割线
@property (weak, nonatomic) IBOutlet UIView *topSeparationView;
/// 下分割线
@property (weak, nonatomic) IBOutlet UIView *bottomSeparationView;

/// 数据模型
@property (nonatomic, strong) MineCellModel *cellModel;
@end

@implementation MineTableViewCell

// cell id
static NSString *const kMineTableViewCellID = @"kMineTableViewCellID";

+ (instancetype)cellWithTableView:(UITableView *)tableView model:(MineCellModel *)model {
    
    // 注册cell
    [tableView registerNib:[UINib nibWithNibName:NSStringFromClass([self class]) bundle:nil] forCellReuseIdentifier:kMineTableViewCellID];
    
    // 重用
    MineTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kMineTableViewCellID];
    
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:self options:nil] lastObject];
    }
    
    // 更新数据
    cell.cellModel = model;
    
    return cell;
}
+ (CGFloat)cellHeightWithModel:(MineCellModel *)model {
    return 44;
}

- (void)setCellModel:(MineCellModel *)cellModel {
    _cellModel = cellModel;
    
    self.cellTitleLabel.text = cellModel.titleText;
    self.topSeparationView.hidden = !(cellModel.separatorType & MineCellSeparatorTypeTop);
    self.bottomSeparationView.hidden = !(cellModel.separatorType & MineCellSeparatorTypeBottom);
    self.indicatorImageView.hidden = !(cellModel.accessoryType == MineCellAccessoryTypeArrow);
    
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}
@end
