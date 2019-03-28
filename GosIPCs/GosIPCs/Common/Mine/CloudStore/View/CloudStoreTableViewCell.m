//  CloudStoreTableViewCell.m
//  GosIPCs
//
//  Create by daniel.hu on 2018/11/29.
//  Copyright © 2018年 goscam. All rights reserved.

#import "CloudStoreTableViewCell.h"
#import "CloudStoreCellModel.h"
#import "UIView+GosClipView.h"

@interface CloudStoreTableViewCell ()
/// 截图
@property (weak, nonatomic) IBOutlet UIImageView *screenshotImageView;
/// 名字
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
/// 类型
@property (weak, nonatomic) IBOutlet UILabel *typeLabel;
/// 有效期
@property (weak, nonatomic) IBOutlet UILabel *validDateLabel;
/// 状态
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
/// cell数据模型
@property (nonatomic, strong) CloudStoreCellModel *cellModel;
@end
@implementation CloudStoreTableViewCell

static NSString *const kCloudStoreTableViewCellID = @"kCloudStoreTableViewCellID";

+ (instancetype)cellWithTableView:(UITableView *)tableView model:(CloudStoreCellModel *)model {
    [tableView registerNib:[UINib nibWithNibName:NSStringFromClass([self class]) bundle:nil] forCellReuseIdentifier:kCloudStoreTableViewCellID];
    
    CloudStoreTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCloudStoreTableViewCellID];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:self options:nil] lastObject];
    }
    cell.cellModel = model;
    return cell;
}

+ (CGFloat)cellHeightWithModel:(CloudStoreCellModel *)model {
    return 120.0;
}

- (void)setCellModel:(CloudStoreCellModel *)cellModel {
    _cellModel = cellModel;
    
    self.screenshotImageView.image = cellModel.screenshotImage;
    self.nameLabel.text = cellModel.deviceName;
    self.typeLabel.text = cellModel.packageType;
    self.statusLabel.text = cellModel.statusString;
    self.validDateLabel.text = cellModel.validTime;
    self.statusLabel.backgroundColor = cellModel.statusColor;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // 左上与左下圆角
    _statusLabel.layer.cornerRadius = 2.0;
    _statusLabel.layer.masksToBounds = YES;
//    [_statusLabel clipCorners:UIRectCornerTopLeft|UIRectCornerBottomLeft radius:2];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
