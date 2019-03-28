//
//  TimeCheckVC.m
//  Goscom
//
//  Created by 匡匡 on 2018/11/22.
//  Copyright © 2018 goscam. All rights reserved.
//  摄像头时间校验界面

#import "TimeCheckVC.h"
#import "iOSConfigSDK.h"

@interface TimeCheckVC ()<iOSConfigSDKParamDelegate>
@property (weak, nonatomic) IBOutlet UILabel *tipsLab;
@property (weak, nonatomic) IBOutlet UIButton *timeCheckBtn;
@property (weak, nonatomic) IBOutlet UIView *showView;  //  弹出的View
@property (weak, nonatomic) IBOutlet UIImageView *faceImg;  //  脸表情img
@property (weak, nonatomic) IBOutlet UILabel *promptLab;    //  校验成功or失败label

@property (nonatomic, strong) iOSConfigSDK *configSdk;
@property (nonatomic, strong) NtpTimeModel * dataModel;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imgTopLength;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *confirmBtnBottonLength;

@end

@implementation TimeCheckVC
#pragma mark -- lifestyle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = DPLocalizedString(@"Setting_TimeCheck");
    [self configUI];
    [self configNetSdk];
    // Do any additional setup after loading the view from its nib.
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    if ([SVProgressHUD isVisible]) {
        [SVProgressHUD dismiss];
    }
}

#pragma mark -- config
- (void)configUI{
    self.timeCheckBtn.layer.cornerRadius = 20.0f;
    self.timeCheckBtn.clipsToBounds = YES;
    self.showView.layer.cornerRadius = 8.0f;
    self.showView.clipsToBounds = YES;
    self.showView.hidden = YES;
    self.tipsLab.text = DPLocalizedString(@"CameraTimeCheck_Tips_Title");
    [self.timeCheckBtn setTitle:DPLocalizedString(@"Setting_TimeCheck") forState:UIControlStateNormal];
    self.imgTopLength.constant = 150.0f/667.0f*GOS_SCREEN_H;
    self.confirmBtnBottonLength.constant = 100.0f/667.0f*GOS_SCREEN_H;
}
- (void)configNetSdk{
    [GosHUD showProcessHUDWithStatus:DPLocalizedString(@"SVPLoading")];
    [self.configSdk reqNtpTimeOfDevId:self.devDataModel.DeviceId];
}
#pragma mark -- function
- (void)showPromptView:(BOOL) isSuccess{
    GOS_WEAK_SELF;
    dispatch_async(dispatch_get_main_queue(), ^{
        GOS_STRONG_SELF;
        if (isSuccess) {
            strongSelf.promptLab.text = DPLocalizedString(@"CameraTimeCheck_OpResult_Succeeded");
            strongSelf.faceImg.image = [UIImage imageNamed:@"icon_SmileFace"];  //  笑脸
        }else{
            strongSelf.promptLab.text = DPLocalizedString(@"CameraTimeCheck_OpResult_Failed");
            strongSelf.faceImg.image = [UIImage imageNamed:@"icon_SadFace"];  //  哭脸
        }
        strongSelf.showView.hidden = NO;
        strongSelf.timeCheckBtn.enabled = YES;
        strongSelf.timeCheckBtn.alpha = 1.0f;
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        GOS_STRONG_SELF;
        strongSelf.showView.hidden = YES;
    });
}
#pragma mark -- actionFunction
- (IBAction)timeCheckClick:(UIButton *)sender {
    /// 当前时间戳为0，就没必要执行校验了
    if (self.dataModel.currentSec <=0) {
        return;
    }
    sender.enabled = NO;
    sender.alpha = 0.5;
    [GosHUD showProcessHUDWithStatus:DPLocalizedString(@"SVPLoading")];
    [self.configSdk configNtpTime:self.dataModel withDeviceId:self.devDataModel.DeviceId];
}
#pragma mark -- delegate
#pragma mark - 请求 NTP 时间参数结果回调
- (void)reqNtpTime:(BOOL)isSuccess
          deviceId:(NSString *)devId
         timeParam:(NtpTimeModel *)ntModel{
    [GosHUD dismiss];
    if (isSuccess) {
        self.dataModel = ntModel;
        /// NOTE: 获取当前时间戳
        time_t seconds = time((time_t *)NULL);
        struct tm *local_time = NULL;
        local_time = localtime(&seconds);
        static char str_time[100];
        strftime(str_time, sizeof(str_time), "%Y-%m-%d,%H:%M:%S", local_time);
        self.dataModel.currentSec = (unsigned int)seconds;
    }else{
        [GosHUD showScreenfulHUDErrorWithStatus:DPLocalizedString(@"GosComm_Set_Failed")];
    }
}
#pragma mark - 设置 NTP 时间参数结果回调
- (void)configNtpTime:(BOOL)isSuccess
             deviceId:(NSString *)devId{
    [GosHUD dismiss];
    [self showPromptView:isSuccess];
}

#pragma mark -- lazy
-(iOSConfigSDK *)configSdk{
    if (!_configSdk) {
        _configSdk = [iOSConfigSDK shareCofigSdk];
        _configSdk.paramDelegate = self;
    }
    return _configSdk;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
