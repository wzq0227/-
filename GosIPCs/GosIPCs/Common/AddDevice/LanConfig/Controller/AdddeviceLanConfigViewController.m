//
//  AdddeviceLanConfigViewController.m
//  GosIPCs
//
//  Created by 罗乐 on 2018/12/6.
//  Copyright © 2018 goscam. All rights reserved.
//

#import "AdddeviceLanConfigViewController.h"
#import "UIColor+GosColor.h"
#import "iOSSmartSDK.h"
#import "iOSConfigSDK.h"
#import "AddDeviceConfigViewController.h"

@interface AdddeviceLanConfigViewController ()

@property (weak, nonatomic) IBOutlet UIButton *nextBtn;
@property (weak, nonatomic) IBOutlet UILabel *tipOne;
@property (weak, nonatomic) IBOutlet UILabel *tipTwo;

@end

@implementation AdddeviceLanConfigViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor gosGrayColor];
    
    self.title = DPLocalizedString(@"AddDEV_LanAdd");
    self.tipOne.text = DPLocalizedString(@"AddDEV_LanTipOne");
    self.tipTwo.text = DPLocalizedString(@"AddDEV_LanTipTwo");
    [self.nextBtn setTitle:DPLocalizedString(@"AddDEV_NextStep") forState:UIControlStateNormal];
}

- (void)viewDidLayoutSubviews {
    self.nextBtn.layer.cornerRadius = self.nextBtn.bounds.size.height / 2;
    self.nextBtn.backgroundColor = GOSCOM_THEME_START_COLOR;
}

- (IBAction)nextBtnAction:(UIButton *)sender {
    AddDeviceConfigViewController *vc = [[AddDeviceConfigViewController alloc] init];
    vc.devModel = self.devModel;
    vc.addMethodType = SupportAdd_wlan;
    [self.navigationController pushViewController:vc animated:YES];
}

@end
