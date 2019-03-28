//  CloudStoreDetailTableViewCell.m
//  GosIPCs
//
//  Create by daniel.hu on 2018/12/7.
//  Copyright © 2018年 goscam. All rights reserved.

#import "CloudStoreDetailTableViewCell.h"
#import "CloudStoreCellModel.h"
@interface CloudStoreDetailTableViewCell ()
/// 开通类型标签
@property (weak, nonatomic) IBOutlet UILabel *typeLabel;
/// 有效期标签
@property (weak, nonatomic) IBOutlet UILabel *validTimeLabel;
/// cell数据模型
@property (nonatomic, strong) CloudStoreCellModel *cellModel;

@end
@implementation CloudStoreDetailTableViewCell


static NSString *const kCloudStoreDetailTableViewCellID = @"kCloudStoreDetailTableViewCellID";

+ (instancetype)cellWithTableView:(UITableView *)tableView model:(CloudStoreCellModel *)model {
    [tableView registerNib:[UINib nibWithNibName:NSStringFromClass([self class]) bundle:nil] forCellReuseIdentifier:kCloudStoreDetailTableViewCellID];
    
    CloudStoreDetailTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCloudStoreDetailTableViewCellID];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:self options:nil] lastObject];
    }
    cell.cellModel = model;
    return cell;
}
+ (CGFloat)cellHeightWithModel:(CloudStoreCellModel *)model {
    return 25.0;
}
- (void)setCellModel:(CloudStoreCellModel *)cellModel {
    _cellModel = cellModel;
    
    self.validTimeLabel.text = cellModel.validTime;
    self.typeLabel.text = cellModel.packageType;
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
