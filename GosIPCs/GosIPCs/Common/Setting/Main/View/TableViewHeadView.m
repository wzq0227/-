//
//  TableViewHeadView.m
//  Goscom
//
//  Created by 匡匡 on 2018/11/27.
//  Copyright © 2018 goscam. All rights reserved.
//

#import "TableViewHeadView.h"

@implementation TableViewHeadView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    self = [[[NSBundle mainBundle] loadNibNamed:@"TableViewHeadView" owner:self options:nil] lastObject];
    if (self) {
        self.frame = frame;
    }
    return self;
}
-(void)setTitleStr:(NSString *)titleStr{
    _titleStr = titleStr;
    self.titleLab.text = titleStr;
}

-(void)awakeFromNib{
    [super awakeFromNib];
    self.backgroundColor = GOS_COLOR_RGBA(247, 247, 247, 1);
}

@end
