//
//  SettingPhotoAlbumCell.m
//  Goscom
//
//  Created by 匡匡 on 2018/11/20.
//  Copyright © 2018 goscam. All rights reserved.
//

#import "SettingPhotoAlbumCell.h"

@interface SettingPhotoAlbumCell()
@property (weak, nonatomic) IBOutlet UILabel *timeLab;      /// 时间
@property (weak, nonatomic) IBOutlet UIImageView *iconImg;  /// 视频或图片
@property (weak, nonatomic) IBOutlet UILabel *titleLab;     /// 201812129838.MP4
@property (weak, nonatomic) IBOutlet UILabel *sizeLab;      /// 多少KB
@property (weak, nonatomic) IBOutlet UIView *leftView;      /// 左边的View
@property (weak, nonatomic) IBOutlet UIButton *selectBtn;   /// 选择Btn
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leadingWith;   /// 约束
@end
@implementation SettingPhotoAlbumCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.leadingWith.constant = 0.0f;
    self.selectBtn.userInteractionEnabled = NO;
}
+ (instancetype)cellWithTableView:(UITableView *) tableView
                        cellModel:(PhotoAlbumModel *) cellModel{
    [tableView registerNib:[UINib nibWithNibName:@"SettingPhotoAlbumCell" bundle:nil] forCellReuseIdentifier:@"SettingPhotoAlbumCell"];
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    SettingPhotoAlbumCell * cell = [tableView dequeueReusableCellWithIdentifier:@"SettingPhotoAlbumCell"];
    cell.cellModel = cellModel;
    return cell;
}
- (void)setCellModel:(PhotoAlbumModel *)cellModel{
    _cellModel = cellModel;
    self.timeLab.text = [NSString stringWithFormat:@"%@",cellModel.createTime];
    self.titleLab.text = cellModel.fileName;
    self.sizeLab.text = cellModel.fileSizeStr;
    self.iconImg.image = [UIImage imageNamed:[cellModel.fileName containsString:@"jpg"]?@"icon_jpg":@"icon_mp4"];
    self.leftView.hidden = !cellModel.isEdit;
    self.leadingWith.constant = cellModel.isEdit?50.0f:0.0f;
    [self.selectBtn setImage:cellModel.isSelected?[UIImage imageNamed:@"icon_circle_check"]:[UIImage imageNamed:@"icon_circle_normal"] forState:UIControlStateNormal];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
