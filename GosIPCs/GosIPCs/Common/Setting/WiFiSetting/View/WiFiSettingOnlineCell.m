//
//  WiFiSettingOnlineCell.m
//  Goscom
//
//  Created by 匡匡 on 2018/11/29.
//  Copyright © 2018 goscam. All rights reserved.
//

#import "WiFiSettingOnlineCell.h"
#import "iOSConfigSDKModel.h"
@interface WiFiSettingOnlineCell()
@property (weak, nonatomic) IBOutlet UILabel *wifiNameLab;
@property (weak, nonatomic) IBOutlet UIImageView *wifiLevelImg;
@end

@implementation WiFiSettingOnlineCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
+ (instancetype)cellWithTableView:(UITableView *)tableView
                        indexPath:(NSIndexPath *)indexPath
                        cellModel:(SsidInfoModel *)cellModel{
    [tableView registerNib:[UINib nibWithNibName:@"WiFiSettingOnlineCell" bundle:nil] forCellReuseIdentifier:@"WiFiSettingOnlineCell"];
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    WiFiSettingOnlineCell * cell = [tableView dequeueReusableCellWithIdentifier:@"WiFiSettingOnlineCell"];
    cell.cellModel = cellModel;
    return cell;
}
- (void)setCellModel:(SsidInfoModel *)cellModel{
    _cellModel = cellModel;
    int level = ((cellModel.wifiLevel+10)/30)%4;
    self.wifiNameLab.text = cellModel.wifiSsid;
    self.wifiLevelImg.image = [UIImage imageNamed:[NSString stringWithFormat:@"WiFiSignal_Level_%d",level]];
    
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
