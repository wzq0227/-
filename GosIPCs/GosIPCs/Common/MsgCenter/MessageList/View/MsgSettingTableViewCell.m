//
//  MsgSettingTableViewCell.m
//  GosIPCs
//
//  Created by ShenYuanLuo on 2018/12/17.
//  Copyright © 2018年 goscam. All rights reserved.
//

#import "MsgSettingTableViewCell.h"

@interface MsgSettingTableViewCell()
@property (weak, nonatomic) IBOutlet UILabel *msgSettingTitleLabel;

@end

@implementation MsgSettingTableViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.msgSettingTitleLabel.text = DPLocalizedString(@"Mine_MessageCenterSetup");
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

@end
