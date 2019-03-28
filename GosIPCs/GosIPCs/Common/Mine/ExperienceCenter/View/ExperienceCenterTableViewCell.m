//  ExperienceCenterTableViewCell.m
//  GosIPCs
//
//  Create by daniel.hu on 2018/11/29.
//  Copyright © 2018年 goscam. All rights reserved.

#import "ExperienceCenterTableViewCell.h"
#import "ExperienceCenterCellModel.h"
#import "UIImage+GosClipImage.h"
#import "UIView+GosAnimation.h"

@interface ExperienceCenterTableViewCell ()

@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *timesLabel;
@property (nonatomic, strong) ExperienceCenterCellModel *cellModel;
@end
@implementation ExperienceCenterTableViewCell

static NSString *const kExperienceCenterTableViewCellID = @"kExperienceCenterTableViewCellID";
+ (instancetype)cellWithTableView:(UITableView *)tableView model:(ExperienceCenterCellModel *)model {
    // 注册cellID
    [tableView registerNib:[UINib nibWithNibName:NSStringFromClass([self class]) bundle:nil] forCellReuseIdentifier:kExperienceCenterTableViewCellID];
    
    ExperienceCenterTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kExperienceCenterTableViewCellID];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:self options:nil] lastObject];
    }
    cell.cellModel = model;
    // 旋转动画
    [cell.iconImageView infiniteRotateAnimation];
    return cell;
}
+ (CGFloat)cellHeightWithModel:(ExperienceCenterCellModel *)model {
    return 200;
}

- (void)setCellModel:(ExperienceCenterCellModel *)cellModel {
    _cellModel = cellModel;
    
    self.iconImageView.image = [cellModel.icon clipToRoundImageWithRect:self.iconImageView.bounds];
    self.nameLabel.text = cellModel.name;
    self.timesLabel.text = [NSString stringWithFormat:@"%@: %@", DPLocalizedString(@"Mine_PlayedTimes"), cellModel.times];
}

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
