//
//  BabyMusicCell.m
//  Goscom
//
//  Created by 匡匡 on 2018/11/28.
//  Copyright © 2018 goscam. All rights reserved.
//

#import "BabyMusicCell.h"
#import "BabyMusicModel.h"
@interface BabyMusicCell()
@property (weak, nonatomic) IBOutlet UILabel *nameLab;
@property (weak, nonatomic) IBOutlet UIButton *selectBtn;

@end

@implementation BabyMusicCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.selectBtn.userInteractionEnabled = NO;
    // Initialization code
}

+ (instancetype)cellWithTableView:(UITableView *)tableView
                        indexPath:(NSIndexPath *) indexPath
                        cellModel:(BabyMusicModel *) cellModel{
    [tableView registerNib:[UINib nibWithNibName:@"BabyMusicCell" bundle:nil] forCellReuseIdentifier:@"BabyMusicCell"];
    BabyMusicCell * cell = [tableView dequeueReusableCellWithIdentifier:@"BabyMusicCell"];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    cell.cellModel = cellModel;
    return cell;
}

- (void)setCellModel:(BabyMusicModel *)cellModel{
    self.nameLab.text = cellModel.titleStr;
    [self.selectBtn setImage:cellModel.isOn?[UIImage imageNamed:@"icon_circle_check"]:[UIImage imageNamed:@"icon_circle_normal"] forState:UIControlStateNormal];
}



- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
