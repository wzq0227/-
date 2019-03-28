//
//  MsgSettingListTableViewCell.m
//  GosIPCs
//
//  Created by shenyuanluo on 2018/12/18.
//  Copyright © 2018 goscam. All rights reserved.
//

#import "MsgSettingListTableViewCell.h"

@interface MsgSettingListTableViewCell()
@property (weak, nonatomic) IBOutlet UILabel *devNameLabel;
@property (weak, nonatomic) IBOutlet UISwitch *devPushSwitch;
@property (weak, nonatomic) IBOutlet UIView *seperateLineView;

@end

@implementation MsgSettingListTableViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.backgroundColor = GOS_WHITE_COLOR;
    self.contentView.backgroundColor = GOS_WHITE_COLOR;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (void)setMsgSettingListCellData:(MsgSettingModel *)msgSettingListCellData
{
    if (!msgSettingListCellData)
    {
        return;
    }
    _msgSettingListCellData      = msgSettingListCellData;
    self.devNameLabel.text       = msgSettingListCellData.devModel.DeviceName;
    self.devPushSwitch.on        = msgSettingListCellData.PushFlag;
    self.seperateLineView.hidden = self.isHiddenSeperateLine;
}

- (void)setSwitchAction:(PushSwitchActionBlock)switchAction
{
    _switchAction = [switchAction copy];
}

- (IBAction)pushSwitchAction:(id)sender
{
    if (self.switchAction)
    {
        self.switchAction(self.devPushSwitch.on);
    }
}

@end
