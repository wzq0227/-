//
//  ThirdAccessCell.m
//  Goscom
//
//  Created by 匡匡 on 2018/11/28.
//  Copyright © 2018 goscam. All rights reserved.
//

#import "ThirdAccessCell.h"
#import "ThirdAccessModel.h"
@interface ThirdAccessCell ()
@property (weak, nonatomic) IBOutlet UIImageView *iconImg;
@property (weak, nonatomic) IBOutlet UIButton *jumpTypeBtn;
@property (weak, nonatomic) IBOutlet UIButton *jumpOutSideBtn;

@end

@implementation ThirdAccessCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self configUI];
    // Initialization code
}
- (void)configUI{
    self.jumpTypeBtn.layer.cornerRadius = 19.0f;
    self.jumpTypeBtn.clipsToBounds = YES;
}
+ (instancetype)cellWithTableView:(UITableView *) tableView
                        indexPath:(NSIndexPath *) indexPath
                        cellModel:(ThirdAccessModel *) cellModel
                         delegate:(id<ThirdAccessCellDelegate>) delegate{
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [tableView registerNib:[UINib nibWithNibName:@"ThirdAccessCell" bundle:nil] forCellReuseIdentifier:@"ThirdAccessCell"];
    ThirdAccessCell * cell = [tableView dequeueReusableCellWithIdentifier:@"ThirdAccessCell"];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    cell.cellModel = cellModel;
    cell.delegate = delegate;
    return cell;
}
- (void)setCellModel:(ThirdAccessModel *)cellModel{
    _cellModel = cellModel;
    self.iconImg.image = [UIImage imageNamed:cellModel.imgStr];
    [self.jumpTypeBtn setTitle:cellModel.jumpBtnStr forState:UIControlStateNormal];
}
- (IBAction)actionClick:(UIButton *)sender {
    NSURL * jumpUrl = [[NSURL alloc] init];
    switch (sender.tag) {
        case 10:{
            jumpUrl = self.cellModel.alexaStr;
        }break;
        case 11:{
            jumpUrl = self.cellModel.settingStr;
        }break;
            
        default:
            break;
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(thirdAccessJumpClick:)]) {
        [self.delegate thirdAccessJumpClick:jumpUrl];
    }
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
