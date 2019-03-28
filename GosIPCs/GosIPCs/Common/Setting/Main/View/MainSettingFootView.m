//
//  MainSettingFootView.m
//  Goscom
//
//  Created by 匡匡 on 2018/11/22.
//  Copyright © 2018 goscam. All rights reserved.
//

#import "MainSettingFootView.h"

@implementation MainSettingFootView
-(void)awakeFromNib{
    [super awakeFromNib];
    [self.deleteBtn setTitle:DPLocalizedString(@"Setting_DeleteDevice") forState:UIControlStateNormal];
}
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    self = [[[NSBundle mainBundle] loadNibNamed:@"MainSettingFootView" owner:self options:nil] lastObject];
    if (self) {
        self.frame = CGRectMake(0, 0, GOS_SCREEN_W, 180);
    }
    return self;
}




@end
