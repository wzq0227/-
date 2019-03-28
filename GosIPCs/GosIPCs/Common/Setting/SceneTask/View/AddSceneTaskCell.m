//  AddSceneTaskCell.m
//  Goscom
//
//  Create by 匡匡 on 2018/12/27.
//  Copyright © 2018 goscam. All rights reserved.

#import "AddSceneTaskCell.h"
#import "iOSConfigSDKModel.h"
@interface AddSceneTaskCell()
@property (weak, nonatomic) IBOutlet UILabel *titleLab;

@end
@implementation AddSceneTaskCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
+ (instancetype) cellWithTableView:(UITableView *) tableView
                         cellModel:(IotSensorModel *) cellModel{
    [tableView registerNib:[UINib nibWithNibName:NSStringFromClass([self class]) bundle:nil] forCellReuseIdentifier:@"AddSceneTaskCell"];
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    AddSceneTaskCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AddSceneTaskCell"];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    cell.cellModel = cellModel;
    return cell;
}
-(void)setCellModel:(IotSensorModel *)cellModel{
    _cellModel = cellModel;
    self.titleLab.text = cellModel.iotSensorName;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
