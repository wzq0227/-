//
//  CloudOrderInfoCell.m
//  Goscom
//
//  Created by 匡匡 on 2018/11/28.
//  Copyright © 2018 goscam. All rights reserved.
//

#import "CloudOrderInfoCell.h"
#import "CloudOrderModel.h"
@interface CloudOrderInfoCell()
@property (weak, nonatomic) IBOutlet UILabel *titlelab;
@property (weak, nonatomic) IBOutlet UILabel *dateLab;

@end
@implementation CloudOrderInfoCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
+ (instancetype)cellWithTableView:(UITableView *) tableView
                        cellModel:(CloudOrderModel *) cellModel
                        indexPath:(NSIndexPath *) indexPath{
    [tableView registerNib:[UINib nibWithNibName:@"CloudOrderInfoCell" bundle:nil] forCellReuseIdentifier:@"CloudOrderInfoCell"];
    CloudOrderInfoCell * cell = [tableView dequeueReusableCellWithIdentifier:@"CloudOrderInfoCell"];
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    cell.titlelab.text = cellModel.leftTitleStr;
    cell.dateLab.text = cellModel.rightTitleStr;
    cell.dateLab.textColor = cellModel.rightTitleColor;
    return cell;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
