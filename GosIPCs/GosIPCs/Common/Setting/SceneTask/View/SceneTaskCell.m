//  SceneTaskCell.m
//  Goscom
//
//  Create by 匡匡 on 2018/12/27.
//  Copyright © 2018 goscam. All rights reserved.

#import "SceneTaskCell.h"
#import "iOSConfigSDKModel.h"
@interface SceneTaskCell()
@property (weak, nonatomic) IBOutlet UILabel *titleLab;
@property (weak, nonatomic) IBOutlet UISwitch *onSwitch;

@end
@implementation SceneTaskCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
+ (instancetype) cellWithTableView:(UITableView *) tableView
                         cellModel:(IotSceneTask *) cellModel
                          delegate:(id<sceneTaskCellDelegate>) delegate{
    [tableView registerNib:[UINib nibWithNibName:NSStringFromClass([self class]) bundle:nil] forCellReuseIdentifier:@"SceneTaskCell"];
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    SceneTaskCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SceneTaskCell"];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    cell.cellModel = cellModel;
    cell.delegate = delegate;
    return cell;
}
- (IBAction)actionSwitchClick:(UISwitch *)sender {
    self.cellModel.isCarryOut = sender.on;
    if (self.delegate && [self.delegate respondsToSelector:@selector(didModifySceneTask:)]) {
        [self.delegate didModifySceneTask:self.cellModel];
    }
}

-(void)setCellModel:(IotSceneTask *)cellModel{
    _cellModel = cellModel;    
    self.titleLab.text = cellModel.iotSceneTaskName;
    self.onSwitch.on = cellModel.isCarryOut;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
