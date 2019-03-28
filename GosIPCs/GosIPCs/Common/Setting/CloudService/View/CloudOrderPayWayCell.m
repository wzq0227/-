//
//  CloudOrderPayWayCell.m
//  Goscom
//
//  Created by 匡匡 on 2018/11/28.
//  Copyright © 2018 goscam. All rights reserved.
//

#import "CloudOrderPayWayCell.h"
#import "CloudOrderModel.h"
@interface CloudOrderPayWayCell()
@property (weak, nonatomic) IBOutlet UIImageView *payIconImg;
@property (weak, nonatomic) IBOutlet UILabel *payWayLab;
@property (weak, nonatomic) IBOutlet UIButton *slectBtn;

@end
@implementation CloudOrderPayWayCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.slectBtn.userInteractionEnabled = NO;
    // Initialization code
}
+ (instancetype)cellWithTableView:(UITableView *) tableView
                        cellModel:(CloudOrderPayWayModel *) cellModel
                        indexPath:(NSIndexPath *) indexPath{
    [tableView registerNib:[UINib nibWithNibName:@"CloudOrderPayWayCell" bundle:nil] forCellReuseIdentifier:@"CloudOrderPayWayCell"];
    CloudOrderPayWayCell * cell = [tableView dequeueReusableCellWithIdentifier:@"CloudOrderPayWayCell"];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    cell.payIconImg.image = cellModel.iconImg;
    cell.payWayLab.text = cellModel.payWayNameStr;
    [cell.slectBtn setImage:cellModel.isSelect?[UIImage imageNamed:@"icon_circle_check"]:[UIImage imageNamed:@"icon_circle_normal"] forState:UIControlStateNormal];
    
    return cell;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
