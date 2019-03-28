//
//  ChangeWifiTipViewController.m
//  GosIPCs
//
//  Created by 罗乐 on 2018/12/5.
//  Copyright © 2018 goscam. All rights reserved.
//

#import "ChangeWifiTipViewController.h"
#import "UIColor+GosColor.h"

@interface ChangeWifiTipViewController ()
@property (weak, nonatomic) IBOutlet UILabel *tipLabel;
@property (weak, nonatomic) IBOutlet UIImageView *tipImageView;

@end

@implementation ChangeWifiTipViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = DPLocalizedString(@"AddDEV_ChangeNet_title");
    self.tipLabel.text = DPLocalizedString(@"AddDEV_ChangeNet_tip");
    self.view.backgroundColor = [UIColor gosGrayColor];
}


@end
