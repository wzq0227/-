//
//  AddSoundLightAlarmVC.m
//  Goscom
//
//  Created by 匡匡 on 2018/11/30.
//  Copyright © 2018 goscam. All rights reserved.
//  添加声光报警器界面

#import "AddSoundLightAlarmVC.h"
#import "UIImage+GIF.h"
#import "CountDownCover.h"
#import "iOSConfigSDK.h"
static NSInteger const CountDownTime = 60;
@interface AddSoundLightAlarmVC ()<iOSConfigSDKIOTDelegate>
@property (weak, nonatomic) IBOutlet UIImageView * gifImg;
@property (weak, nonatomic) IBOutlet UILabel *tips1Lab;
@property (weak, nonatomic) IBOutlet UILabel *tips2Lab;
@property (weak, nonatomic) IBOutlet UILabel *tips3Lab;
@property (weak, nonatomic) IBOutlet UIButton *addBtn;
/// SDK
@property (nonatomic, strong) iOSConfigSDK * iOSConfigSDK;
/// 模型
@property (nonatomic, strong) IotSensorModel * tempModel;
@end

@implementation AddSoundLightAlarmVC

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"Setting_lightAlarm" ofType:@"gif"];
    NSData* imageData = [NSData dataWithContentsOfFile:filePath];
    self.gifImg.image = [UIImage animatedGIFWithData:imageData];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self configUI];
}
#pragma mark - lifestyle
#pragma mark - config
- (void)configUI{
    self.title = DPLocalizedString(@"Setting_AudibleAlarm");
    self.addBtn.layer.cornerRadius = 20.0f;
    self.addBtn.clipsToBounds = YES;
    [self.addBtn setTitle:DPLocalizedString(@"Setting_StartAddBtnTitle") forState:UIControlStateNormal];
    self.tips1Lab.text = DPLocalizedString(@"AddAudibleAlarmStep1");
    self.tips2Lab.text = DPLocalizedString(@"AddAudibleAlarmStep2");
    self.tips3Lab.text = DPLocalizedString(@"AddAudibleAlarmStep3");
    
}
#pragma mark -- function
#pragma mark -- actionFunction
- (IBAction)actionStartClick:(UIButton *)sender {
    __weak typeof(self) weakSelf = self;
    [CountDownCover showTime:CountDownTime finish:^(BOOL isTimeEnd) {}];
    // 配对声光报警器（目前逻辑：一个设备只能配对一个声光报警器）
    [weakSelf.iOSConfigSDK pairStrobeSirenToDevice:self.dataModel.DeviceId];
}
#pragma mark - 配对声光报警器结果回调
- (void)pairStrobeSiren:(AddIOTStatus)iStatus
              iotSensor:(NSString *)sensorId
               deviceId:(NSString *)devId
              errorCode:(int)eCode{
    __weak typeof(self) weakSelf = self;
    switch (iStatus) {
        case AddIot_timeout:
        case AddIot_failure:
        case AddIot_repeat:
        case AddIot_respone:{
            
        }break;
        case AddIot_success: {
           
        }break;
           
        default:
            break;
    }
    if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(callBackState:gosIOTType:sensorId:)]) {
        [weakSelf.delegate callBackState:iStatus gosIOTType:GosIot_sensorAudibleAlarm sensorId:sensorId];
    }
    [CountDownCover dismiss];
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf.navigationController popViewControllerAnimated:YES];
    });
}

#pragma mark -- delegate
#pragma mark -- lazy
- (iOSConfigSDK *)iOSConfigSDK{
    if (!_iOSConfigSDK) {
        _iOSConfigSDK = [iOSConfigSDK shareCofigSdk];
        _iOSConfigSDK.iotDelegate = self;
        
    }
    return _iOSConfigSDK;
}
- (void)dealloc{
    GosLog(@"----  %s ----", __PRETTY_FUNCTION__);
}
@end
