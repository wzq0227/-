//
//  TFCRDateListTableViewCell.m
//  GosIPCs
//
//  Created by shenyuanluo on 2018/12/28.
//  Copyright © 2018 goscam. All rights reserved.
//

#import "TFCRDateListTableViewCell.h"

@interface TFCRDateListTableViewCell()
@property (weak, nonatomic) IBOutlet UILabel *recordDateLabel;

@end

@implementation TFCRDateListTableViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (void)setRecordDateStr:(NSString *)recordDateStr
{
    if (!recordDateStr)
    {
        return;
    }
    _recordDateStr            = [recordDateStr copy];
    self.recordDateLabel.text = recordDateStr;
}

@end
