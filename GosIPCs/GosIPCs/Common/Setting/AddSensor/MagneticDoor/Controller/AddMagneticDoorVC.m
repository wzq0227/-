//
//  AddMagneticDoorVC.m
//  Goscom
//
//  Created by 匡匡 on 2018/11/30.
//  Copyright © 2018 goscam. All rights reserved.
//  添加门磁界面

#import "AddMagneticDoorVC.h"
#import "UIImage+GIF.h"
#import "CountDownCover.h"
#import "iOSConfigSDK.h"

static NSInteger const CountDownTime = 60;
@interface AddMagneticDoorVC ()<iOSConfigSDKIOTDelegate>
{
    BOOL m_mark;
    NSString * m_sensorId;
}
@property (weak, nonatomic) IBOutlet UIImageView *gifImg;
@property (weak, nonatomic) IBOutlet UILabel *tips1Lab;
@property (weak, nonatomic) IBOutlet UILabel *tips2Lab;
@property (weak, nonatomic) IBOutlet UILabel *tips3Lab;
@property (weak, nonatomic) IBOutlet UIButton *addBtn;
/// sdk
@property (nonatomic, strong) iOSConfigSDK * iOSConfigSDK;
/// 定时器
@property (nonatomic, strong) NSTimer *sensorTimer;      /// 定时器
@end

@implementation AddMagneticDoorVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initParam];
    [self configUI];
    
    // Do any additional setup after loading the view from its nib.
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"Setting_MagneticDoor" ofType:@"gif"];
    NSData* imageData = [NSData dataWithContentsOfFile:filePath];
    self.gifImg.image = [UIImage animatedGIFWithData:imageData];
}
#pragma mark -- lifestyle
#pragma mark -- config
- (void)configUI{
    self.title = DPLocalizedString(@"Setting_Magnetic");
    self.addBtn.layer.cornerRadius = 20.0f;
    self.addBtn.clipsToBounds = YES;
    self.tips1Lab.text = DPLocalizedString(@"AddMagneticStep1");
    self.tips2Lab.text = DPLocalizedString(@"AddMagneticStep2");
    self.tips3Lab.text = DPLocalizedString(@"AddMagneticStep3");
    [self.addBtn setTitle:DPLocalizedString(@"Setting_StartAddBtnTitle") forState:UIControlStateNormal];
}
- (void)initParam
{
    m_mark = NO;
    m_sensorId = @"";
}
#pragma mark -- function
#pragma mark -- actionFunction
- (IBAction)actionStartClick:(UIButton *)sender {
    __weak typeof(self) weakSelf = self;
    [CountDownCover showTime:CountDownTime finish:^(BOOL isTimeEnd) {
        [weakSelf removeTimer];
    }];
    /// NOTE:准备添加 第一步
    [self.iOSConfigSDK prepareAddIotToDevice:self.dataModel.DeviceId];
}

#pragma mark - 准备添加 IOT 结果回调
- (void)prepareAddIot:(BOOL)isSuccess
             deviceId:(NSString *)devId
            errorCode:(int)eCode{
    /// NOTE :第一步 准备添加结果回调
    [GosHUD dismiss];
    __weak typeof(self) weakSelf = self;
    if (isSuccess) {
        // 启动定时器 加入RunLoop中
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!_sensorTimer) {
                weakSelf.sensorTimer = [NSTimer scheduledTimerWithTimeInterval:5.0f target:self selector:@selector(sosTiemrFunc:) userInfo:nil repeats:YES];
            }
        });
    }
}
- (void)sosTiemrFunc:(id)sender{
    [self.iOSConfigSDK checkStatusOfIotAddToDevice:self.dataModel.DeviceId];
}

#pragma mark - 查询添加 IOT 状态结果回调
- (void)addIotStatus:(AddIOTStatus)addStatus
           iosSensor:(NSString *)sensorId
            deviceId:(NSString *)devId
           errorCode:(int)eCode{
    GosLog(@"返回结果 = %d",addStatus);
    __weak typeof(self) weakSelf = self;
    if (m_mark) {
        return;
    }
    /// NOTE: 第二步回调
    switch (addStatus) {
        case AddIot_success:{        //  准备添加  执行添加IOT操作
            IotSensorModel * model = [[IotSensorModel alloc] init];
            model.iotSensorType = GosIot_sensorMagnetic;
            model.iotSensorId = sensorId;
            model.isAPNSOpen = YES;
            model.isSceneOpen = YES;
            /// 第三步 添加
            [weakSelf.iOSConfigSDK addIotSensor:model toDeviceId:weakSelf.dataModel.DeviceId];
        }break;
        case AddIot_timeout:{       //  超时
            IotSensorModel * model = [[IotSensorModel alloc] init];
            model.iotSensorType = GosIot_sensorMagnetic;
            model.iotSensorId = nil;
            model.isAPNSOpen = NO;
            model.isSceneOpen = NO;
            /// 添加
            [weakSelf.iOSConfigSDK addIotSensor:model toDeviceId:weakSelf.dataModel.DeviceId];
        }break;
        case AddIot_failure:        //  失败
        case AddIot_repeat:{        //  重复添加
            [CountDownCover dismiss];
            [self removeTimer];
            if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(callBackState:gosIOTType:sensorId:)]) {
                [weakSelf.delegate callBackState:addStatus gosIOTType:GosIot_sensorMagnetic sensorId:@""];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.navigationController popViewControllerAnimated:YES];
            });
        }break;
        case AddIot_respone:{        // ’准备添加‘回复还没准备好添加 IOT（则继续查询）
            
        }break;
        default:
            break;
    }
}
#pragma mark - 添加 IOT 状态结果回调(设备端)
- (void)addIot:(BOOL)isSuccess
      deviceId:(NSString *)devId
     errorCode:(int)eCode{
    [CountDownCover dismiss];
    /// 第三步 添加回调
    __weak typeof(self) weakSelf = self;
    AddIOTStatus addresult = isSuccess?AddIot_success:AddIot_failure;
    if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(callBackState:gosIOTType:sensorId:)]) {
        [weakSelf.delegate callBackState:addresult gosIOTType:GosIot_sensorMagnetic sensorId:m_sensorId];
    }
    [self removeTimer];
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf.navigationController popViewControllerAnimated:YES];
    });
}
- (void)removeTimer{
    if (self.sensorTimer) {
        [_sensorTimer invalidate];
        _sensorTimer = nil;
    }
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
    [self removeTimer];
    GosLog(@"----  %s ----", __PRETTY_FUNCTION__);
}
@end
