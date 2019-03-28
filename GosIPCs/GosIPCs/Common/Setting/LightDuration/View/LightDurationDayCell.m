//
//  LightDurationDayCell.m
//  Goscom
//
//  Created by 匡匡 on 2018/11/27.
//  Copyright © 2018 goscam. All rights reserved.
//

#import "LightDurationDayCell.h"

@implementation LightDurationDayCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.contentView.backgroundColor = GOS_COLOR_RGBA(247, 247, 247, 1);
    self.dayLab.layer.cornerRadius = 20.0f;
    self.dayLab.clipsToBounds = YES;
}

@end
