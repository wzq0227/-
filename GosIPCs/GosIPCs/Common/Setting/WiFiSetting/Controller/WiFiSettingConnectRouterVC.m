//
//  WiFiSettingConnectRouterVC.m
//  Goscom
//
//  Created by 匡匡 on 2018/11/29.
//  Copyright © 2018 goscam. All rights reserved.
//

#import "WiFiSettingConnectRouterVC.h"
#import "KKAlertView.h"
#import "AlertAddFailView.h"
#import "WiFiSettingOutLineVC.h"
#import "iOSSmartSDK.h"
#import "iOSConfigSDKModel.h"
#import "UIImage+GIF.h"
@interface WiFiSettingConnectRouterVC ()
<AlertAddFailViewDelegate,
iOSSmartDelegate>
@property (nonatomic, strong) iOSSmartSDK * smartSDK;
@property (weak, nonatomic) IBOutlet UILabel *tipsLab;
@property (weak, nonatomic) IBOutlet UIImageView *tipGifImg;
/// 请求次数
@property (nonatomic, assign) NSInteger requestNumber;

@end

@implementation WiFiSettingConnectRouterVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configUI];
    [self configData];
    // Do any additional setup after loading the view from its nib.
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    if ([SVProgressHUD isVisible]) {
        [SVProgressHUD dismiss];
    }
}
#pragma mark - lifestyle
#pragma mark - config
- (void)configUI{
    self.title = DPLocalizedString(@"Qrcode_ScanThreeView");
    self.tipsLab.text = DPLocalizedString(@"AddDEV_configTip");
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"addDev_configuration" ofType:@"gif"];
    NSData* imageData = [NSData dataWithContentsOfFile:filePath];
    self.tipGifImg.image = [UIImage animatedGIFWithData:imageData];
    self.requestNumber = 0;
}
- (void)configData{
    [GosHUD showProcessHUDWithStatus:DPLocalizedString(@"SVPLoading")];
    [self.smartSDK extractInfoWithDevId:self.dataModel.DeviceId timeout:10000];
}

#pragma mark - 搜索并获取设备信息
- (void)isExtract:(BOOL)isSuccess
       forDevInfo:(LanDeviceInfoModel *)devInfo{
    GosLog(@"疯狂打印 isSuccess = %d 当前WiFi名=%@  设备ID =%@",isSuccess,devInfo.wifiSsid,devInfo.deviceId);
    if (self.requestNumber > 10) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [GosHUD dismiss];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [KKAlertView shareView].contentView = [AlertAddFailView initWithDelegate:self];
                [[KKAlertView shareView] show];
                return ;
            });
        });
        return;
    }
    
    // 搜到当前设备
    if (isSuccess && [devInfo.deviceId isEqualToString:self.dataModel.DeviceId]) {
        [GosHUD dismiss];
            dispatch_async(dispatch_get_main_queue(), ^{
                [GosHUD showProcessHUDSuccessWithStatus:DPLocalizedString(@"GosComm_Set_Succeeded")];
            });
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.navigationController popToRootViewControllerAnimated:YES];
            });
    }
    // 虽然成功了，但是没搜到设备
    else if(isSuccess){
        [self.smartSDK extractInfoWithDevId:self.dataModel.DeviceId timeout:10000];
    }
    
    else{
        dispatch_async(dispatch_get_main_queue(), ^{
            [GosHUD dismiss];
            [KKAlertView shareView].contentView = [AlertAddFailView initWithDelegate:self];
            [[KKAlertView shareView] show];
            return ;
        });
 
    }
    self.requestNumber++;
}
#pragma mark - function
#pragma mark - actionFunction
- (void)backViewController{
    UIViewController *target = nil;
    for (UIViewController * controller in self.navigationController.viewControllers) {
        if ([controller isKindOfClass:[WiFiSettingOutLineVC class]]) {
            target = controller;
        }
    }
    if (target) {
        [self.navigationController popToViewController:target animated:YES];
    }
}
#pragma mark - delegate
- (void)AlertAddFailClick:(BackType) backType{
    if (backType == BackType_WiFiSetting) {
        [self backViewController];
    }else{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.navigationController popToRootViewControllerAnimated:YES];
        });
    }
}
- (IBAction)actionRedLightClick:(UIButton *)sender {
    [KKAlertView shareView].contentView = [AlertAddFailView initWithDelegate:self];
    [[KKAlertView shareView] show];
}
#pragma mark - lazy
- (iOSSmartSDK *)smartSDK{
    if (!_smartSDK) {
        _smartSDK = [iOSSmartSDK shareSmartSdk];
        _smartSDK.delegate = self;
    }
    return _smartSDK;
}
@end
