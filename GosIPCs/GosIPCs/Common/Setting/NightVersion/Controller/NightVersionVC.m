//
//  NightVersionVC.m
//  Goscom
//
//  Created by 匡匡 on 2018/11/26.
//  Copyright © 2018 goscam. All rights reserved.
//  夜视界面

#import "NightVersionVC.h"
#import "iOSConfigSDK.h"

@interface NightVersionVC ()<iOSConfigSDKParamDelegate>
@property (weak, nonatomic) IBOutlet UILabel *manualLab;
@property (weak, nonatomic) IBOutlet UILabel *autoLab;
@property (weak, nonatomic) IBOutlet UISwitch *manualSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *autoSwitch;
@property (nonatomic, strong) iOSConfigSDK *configSdk;
@property (nonatomic, strong) NightVisionModel * dataModel;   // 数据模型
@end

@implementation NightVersionVC

#pragma mark -- lifestyle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self configUI];
    [self configNetSet];
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    if ([SVProgressHUD isVisible]) {
        [SVProgressHUD dismiss];
    }
}
#pragma mark -- config
- (void)configUI{
    self.title = DPLocalizedString(@"Setting_NightVersion");
    self.manualLab.text = DPLocalizedString(@"NightVersion_Switch");
    self.autoLab.text = DPLocalizedString(@"NightVersion_Auto");
}
- (void)configNetSet{
    [GosHUD showProcessHUDWithStatus:DPLocalizedString(@"loading")];
    [self.configSdk reqNightVisionWithDevId:self.deviceID];
}
#pragma mark -- config
#pragma mark -- function
- (void)refreshData{
    GOS_WEAK_SELF;
    dispatch_async(dispatch_get_main_queue(), ^{
        GOS_STRONG_SELF;
        strongSelf.manualSwitch.on = strongSelf.dataModel.isManual;
        strongSelf.autoSwitch.on = strongSelf.dataModel.isAuto;
    });
}
- (void)submitData{
    [GosHUD showProcessHUDWithStatus:DPLocalizedString(@"loading")];
    [self.configSdk configNightVision:self.dataModel withDeviceId:self.deviceID];
}

#pragma mark -- actionFunction
- (IBAction)actionAutoOrOpen:(UISwitch *)sender {
    switch (sender.tag) {
        case 10:{       //  夜视开关
            self.manualSwitch.on = sender.on;
            self.dataModel.isManual = sender.on;
            self.dataModel.isAuto = !sender.on;
        }break;
        case 11:{       //  自动
            self.autoSwitch.on = sender.on;
            self.dataModel.isManual = !sender.on;
            self.dataModel.isAuto = sender.on;
        }break;
        default:
            break;
    }
    [self refreshData];
    [self submitData];
}
#pragma mark -- delegate
#pragma mark - 设置夜视参数结果回调
- (void)configNightVision:(BOOL)isSuccess
                 deviceId:(NSString *)devId{
    [GosHUD dismiss];
    if (isSuccess) {
        GosLog(@"设置夜视成功");
    }else{
        [GosHUD showScreenfulHUDErrorWithStatus:DPLocalizedString(@"GosComm_Set_Failed")];
    }
}
#pragma mark - 请求夜视参数结果回调
- (void)reqNightVision:(BOOL)isSuccess
              deviceId:(NSString *)devId
               nvParam:(NightVisionModel *)nvModel{
    [GosHUD dismiss];
    if (isSuccess) {
        self.dataModel = nvModel;
        [self refreshData];
    }else{
        [GosHUD showScreenfulHUDErrorWithStatus:DPLocalizedString(@"GosComm_getData_fail")];
    }
}
#pragma mark -- lazy
- (iOSConfigSDK *)configSdk{
    if (!_configSdk) {
        _configSdk = [iOSConfigSDK shareCofigSdk];
        _configSdk.paramDelegate = self;
    }
    return _configSdk;
}
@end
