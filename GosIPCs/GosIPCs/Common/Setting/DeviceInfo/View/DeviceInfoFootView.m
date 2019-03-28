//
//  DeviceInfoFootView.m
//  Goscom
//
//  Created by 匡匡 on 2018/11/28.
//  Copyright © 2018 goscam. All rights reserved.
//

#import "DeviceInfoFootView.h"
@interface DeviceInfoFootView()


@end
@implementation DeviceInfoFootView

- (void)awakeFromNib{
    [super awakeFromNib];
    [self.formatSDcardBtn setTitle:DPLocalizedString(@"Format") forState:UIControlStateNormal];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    self = [[[NSBundle mainBundle] loadNibNamed:@"DeviceInfoFootView" owner:self options:nil] lastObject];
    if (self) {
        self.frame = CGRectMake(0, 0, GOS_SCREEN_W, 150);
    }
    return self;
}
- (IBAction)actionFormatSD:(UIButton *)sender {
    
}

@end
