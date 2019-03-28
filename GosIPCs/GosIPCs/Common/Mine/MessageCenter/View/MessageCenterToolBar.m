//  MessageCenterToolBar.m
//  GosIPCs
//
//  Create by daniel.hu on 2018/12/3.
//  Copyright © 2018年 goscam. All rights reserved.

#import "MessageCenterToolBar.h"

@interface MessageCenterToolBar ()

@end
@implementation MessageCenterToolBar
- (void)awakeFromNib {
    [super awakeFromNib];
    
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    self = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:self options:nil] firstObject];
    if (self) {
        [self.checkAllButton setTitle:DPLocalizedString(@"GosComm_SelectAll") forState:UIControlStateNormal];
        [self.checkAllButton setTitle:DPLocalizedString(@"GosComm_CancelCheckAll") forState:UIControlStateSelected];
        [self.deleteButton setTitle:DPLocalizedString(@"GosComm_Delete") forState:UIControlStateNormal];
    }
    return self;
}
- (void)show {
    self.hidden = NO;
}
- (void)hide {
    self.hidden = YES;
}

@end
