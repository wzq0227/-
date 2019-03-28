//
//  DeviceInfoCell.m
//  Goscom
//
//  Created by 匡匡 on 2018/11/23.
//  Copyright © 2018 goscam. All rights reserved.
//

#import "DeviceInfoCell.h"
#import "DeviceInfoModel.h"
@implementation DeviceInfoCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.redView.layer.cornerRadius = 3.0f;
    self.redView.clipsToBounds = YES;
    self.redView.hidden = YES;
    // Initialization code
}
+ (instancetype) cellWithTableView:(UITableView *) tableView
                         indexPath:(NSIndexPath *) indexPath
                         infoModel:(DeviceInfoModel *) infoModel{
    [tableView registerNib:[UINib nibWithNibName:@"DeviceInfoCell" bundle:nil] forCellReuseIdentifier:@"DeviceInfoCell"];
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    DeviceInfoCell * cell = [tableView dequeueReusableCellWithIdentifier:@"DeviceInfoCell"];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    cell.cellModel = infoModel;
    return cell;
}
- (void)setCellModel:(DeviceInfoModel *)cellModel{
    _cellModel = cellModel;
    self.titleLab.text = cellModel.titleStr;
    switch (cellModel.cellType) {
        case DeviceInfoCellType_hasNext:{
            self.dataLab.hidden = YES;
        }break;
        case DeviceInfoCellType_hasDetail:{
            self.arrowImg.hidden = YES;
            self.dataLab.text = cellModel.dataStr;
        }break;
            
        default:
            break;
    }
    if (cellModel.hasNewVersion && [cellModel.titleStr isEqualToString:DPLocalizedString(@"system_firmware")]) {
        self.redView.hidden = NO;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
