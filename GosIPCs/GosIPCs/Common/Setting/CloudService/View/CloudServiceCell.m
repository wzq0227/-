//
//  CloudServiceCell.m
//  Goscom
//
//  Created by 匡匡 on 2018/11/20.
//  Copyright © 2018 goscam. All rights reserved.
//

#import "CloudServiceCell.h"
#import "CloudServiceModel.h"

@interface CloudServiceCell()
@property (weak, nonatomic) IBOutlet UIImageView *iconImg;
/// 录像保存（循环）
@property (weak, nonatomic) IBOutlet UILabel *saveDateLab;
/// 套餐类型
@property (weak, nonatomic) IBOutlet UILabel *packageTypeLab;
/// 当前价格
@property (weak, nonatomic) IBOutlet UILabel *currentPriceLab;
/// 原价
@property (weak, nonatomic) IBOutlet UILabel *originalPriceLab;

@end
@implementation CloudServiceCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.currentPriceLab.font = [UIFont fontWithName:@"DIN-Medium" size:14];
    self.originalPriceLab.font = [UIFont fontWithName:@"DIN-Medium" size:8];
}

+ (instancetype)cellWithTableView:(UITableView *) tableView
                     andCellModel:(CloudServiceModel *) cellModel{
    // 注册cell
    [tableView registerNib:[UINib nibWithNibName:@"CloudServiceCell" bundle:nil] forCellReuseIdentifier:@"CloudServiceCell"];
    CloudServiceCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CloudServiceCell"];
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    cell.cellModel = cellModel;
    return cell;
}
- (void)setCellModel:(CloudServiceModel *)cellModel{
    _cellModel = cellModel;
    self.saveDateLab.text = cellModel.dataLifeString;
    self.packageTypeLab.text = cellModel.serviceLifeString;
    self.currentPriceLab.text = cellModel.currentPriceString;
    self.originalPriceLab.attributedText = [self getAttributedStr:cellModel.normalPrice];
    self.iconImg.image = [UIImage imageNamed:cellModel.isSelect?@"icon_circle_check":@"icon_circle_normal"];
}
- (NSMutableAttributedString *)getAttributedStr:(NSString *) nomalStr{
    NSMutableAttributedString * attrStr = [[NSMutableAttributedString alloc] initWithString:nomalStr
                                                                                 attributes:@{NSStrikethroughStyleAttributeName : @(NSUnderlineStyleSingle),NSFontAttributeName:[UIFont systemFontOfSize:12]}];
    return attrStr;
}




- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
