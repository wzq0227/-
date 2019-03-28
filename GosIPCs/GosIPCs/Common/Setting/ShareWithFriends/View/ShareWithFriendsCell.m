//
//  ShareWithFriendsCell.m
//  Goscom
//
//  Created by 匡匡 on 2018/11/27.
//  Copyright © 2018 goscam. All rights reserved.
//

#import "ShareWithFriendsCell.h"
#import "ShareWithFriendsModel.h"
@interface ShareWithFriendsCell()
@property (weak, nonatomic) IBOutlet UILabel *titleLab;
@property (weak, nonatomic) IBOutlet UIButton *deleteBtn;
@end
@implementation ShareWithFriendsCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
+ (instancetype)cellWithTableView:(UITableView *) tableView
                        cellModel:(ShareWithFriendsModel *) cellModel
                         delegate:(id<ShareWithFriendsDeletDelegate>) delegate
{
    [tableView registerNib:[UINib nibWithNibName:@"ShareWithFriendsCell" bundle:nil] forCellReuseIdentifier:@"ShareWithFriendsCell"];
    ShareWithFriendsCell * cell = [tableView dequeueReusableCellWithIdentifier:@"ShareWithFriendsCell"];
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    cell.cellModel = cellModel;
    cell.delegate = delegate;
    return cell;
}
- (void)setCellModel:(ShareWithFriendsModel *)cellModel{
    _cellModel = cellModel;
    self.deleteBtn.hidden = !cellModel.isEdit;
    self.titleLab.text = [NSString stringWithFormat:@"ID:%@",cellModel.IDStr];
}
- (IBAction)actionDeleteClick:(UIButton *)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(friendsDeleteWithCellModel:)]) {
        [self.delegate friendsDeleteWithCellModel:self.cellModel];
    }
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
