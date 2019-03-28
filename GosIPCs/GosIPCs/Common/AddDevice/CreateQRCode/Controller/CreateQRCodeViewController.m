//
//  CreateQRCodeViewController.m
//  ULife3.5
//
//  Created by 罗乐 on 2018/9/15.
//  Copyright © 2018年 GosCam. All rights reserved.
//

#import "CreateQRCodeViewController.h"
#import "iOSSmartSDK.h"
#import "GosGradualBrightness.h"
#import "AddDeviceConfigViewController.h"
#import "KKAlertView.h"
#import "AlertNotVoiceView.h"
#import "AlertTipsView.h"
#import "UIAlertController+AddDeviceTip.h"

@interface CreateQRCodeViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *QRCodeImageView;
//@property (weak, nonatomic) IBOutlet UIImageView *scanGIFImageView;
@property (strong, nonatomic) UIImageView *scanGIFImageView;
//@property (weak, nonatomic) IBOutlet UILabel *deviceScanQRCodeTipLabel;
@property (weak, nonatomic) IBOutlet UIButton *nextSetpBtn;
@property (weak, nonatomic) IBOutlet UIButton *noSoundBtn;

@property (nonatomic, strong) iOSSmartSDK *smartSDK;

//@property (nonatomic, strong) CustomWindow *customWindow;

@end

@implementation CreateQRCodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = DPLocalizedString(@"AddDEV_Qrcode_title");
    //    self.deviceScanQRCodeTipLabel.text = DPLocalizedString(@"AddDEV_Qrcode_tip");AddDEV_Qrcode_tip
    [self.nextSetpBtn setTitle:DPLocalizedString(@"AddDEV_NextStep") forState:UIControlStateNormal];
    [self.noSoundBtn  setTitle:DPLocalizedString(@"AddDEV_NoSound") forState:UIControlStateNormal];
    
    self.nextSetpBtn.backgroundColor = GOSCOM_THEME_START_COLOR;
    self.nextSetpBtn.layer.cornerRadius = self.nextSetpBtn.frame.size.height / 2.f;
    self.noSoundBtn.titleLabel.textColor = GOSCOM_THEME_START_COLOR;
    
    [self createQRCodeImage];
    
    [self showScanQRCondeTipView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [GosGradualBrightness sySaveDefaultBrightness];
    [GosGradualBrightness syConfigBrightness:0.8];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [GosGradualBrightness syResumeBrightness];
}

#pragma mark - lazy load
- (iOSSmartSDK *)smartSDK {
    if (!_smartSDK) {
        _smartSDK = [iOSSmartSDK shareSmartSdk];
    }
    return _smartSDK;
}

#pragma mark - 显示提示View
- (void)showScanQRCondeTipView {
    BOOL obj = GOS_GET_OBJ(kNoRemindAddNotify);
    if (!obj) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            AlertTipsView *contentView = [[AlertTipsView alloc]init];
            contentView.isAddDevice = YES;
            [KKAlertView shareView].contentView = contentView;
            [[KKAlertView shareView] show];
        });
    }
}

#pragma mark - 生成二维码
-(void)createQRCodeImage
{
    self.QRCodeImageView.image = [self.smartSDK genQRCodeWithSsid:self.devModel.wifiName wifiPwd:self.devModel.wifiPWD deviceId:self.devModel.devId];
}

#pragma mark - btn Action
- (IBAction)nextStepBtnAction:(UIButton *)sender {
    AddDeviceConfigViewController *vc = [[AddDeviceConfigViewController alloc] init];
    vc.devModel = self.devModel;
    vc.addMethodType = SupportAdd_scan;
    [self.navigationController pushViewController:vc animated:NO];
}

- (IBAction)noSoundBtnAction:(UIButton *)sender {
    UIAlertController *alertView = [UIAlertController NoSoundAlertController];
    
    [self.navigationController presentViewController:alertView
                                            animated:YES
                                          completion:nil];
    
}
@end
