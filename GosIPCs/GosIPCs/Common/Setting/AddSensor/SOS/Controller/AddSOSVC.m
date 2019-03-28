//
//  AddSOSVC.m
//  Goscom
//
//  Created by 匡匡 on 2018/11/30.
//  Copyright © 2018 goscam. All rights reserved.
//  添加SOS按钮界面

#import "AddSOSVC.h"
#import "UIImage+GIF.h"
#import "CountDownCover.h"
#import "iOSConfigSDK.h"
static NSInteger const CountDownTime = 60;
@interface AddSOSVC ()<iOSConfigSDKIOTDelegate>
{
    BOOL m_mark;
    NSString * m_sensorId;
}
@property (weak, nonatomic) IBOutlet UIImageView *gifImg;
@property (weak, nonatomic) IBOutlet UILabel *tips1Lab;
@property (weak, nonatomic) IBOutlet UILabel *tips2Lab;
@property (weak, nonatomic) IBOutlet UIButton *addBtn;
/// sdk
@property (nonatomic, strong) iOSConfigSDK * iOSConfigSDK;
/// 定时器
@property (nonatomic, strong) NSTimer *sensorTimer;      /// 定时器
/// 模型
@property (nonatomic, strong) IotSensorModel * tempModel;
@end

@implementation AddSOSVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initParam];
    [self configUI];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"Setting_SOS" ofType:@"gif"];
    NSData* imageData = [NSData dataWithContentsOfFile:filePath];
    self.gifImg.image = [UIImage animatedGIFWithData:imageData];
}
-(void) initParam
{
    m_mark = NO;
    m_sensorId = @"";
}
#pragma mark -- lifestyle
#pragma mark -- config
-(void) configUI{
    self.title = DPLocalizedString(@"Setting_Sos");
    self.addBtn.layer.cornerRadius = 20.0f;
    self.addBtn.clipsToBounds = YES;
    [self.addBtn setTitle:DPLocalizedString(@"Setting_StartAddBtnTitle") forState:UIControlStateNormal];
    self.tips1Lab.text = DPLocalizedString(@"AddSosStep1");
    self.tips2Lab.text = DPLocalizedString(@"AddSosStep2");
}
#pragma mark -- function
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
    __weak typeof(self) weakSelf = self;
    /// NOTE :第一步 准备添加结果回调
    if (isSuccess) {
        // 启动定时器 加入RunLoop中
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!_sensorTimer) {
                weakSelf.sensorTimer = [NSTimer scheduledTimerWithTimeInterval:5.0f target:self selector:@selector(sosTiemrFunc:) userInfo:nil repeats:YES];
            }
        });
    }
}
-(void) sosTiemrFunc:(id)sender{
    [self.iOSConfigSDK checkStatusOfIotAddToDevice:self.dataModel.DeviceId];
}
#pragma mark - 查询添加 IOT 状态结果回调
- (void)addIotStatus:(AddIOTStatus)addStatus
           iotSensor:(NSString *)sensorId
            deviceId:(NSString *)devId
           errorCode:(int)eCode
{
    GosLog(@"返回结果 = %d",addStatus);
    __weak typeof(self) weakSelf = self;
    if (m_mark) {
        return;
    }
    /// NOTE: 第二步回调
    switch (addStatus) {
        case AddIot_success:{        //  准备添加  执行添加IOT操作
            [GosHUD dismiss];
            m_mark = YES;
            m_sensorId = sensorId;
            IotSensorModel * model = [[IotSensorModel alloc] init];
            model.iotSensorType = GosIot_sensorSOS;
            model.iotSensorId = sensorId;
            model.isAPNSOpen = YES;
            model.isSceneOpen = YES;
            /// 第三步 添加
            [weakSelf.iOSConfigSDK addIotSensor:model toDeviceId:self.dataModel.DeviceId];
        }break;
        case AddIot_timeout:{       //  超时
            m_mark = YES;
            IotSensorModel * model = [[IotSensorModel alloc] init];
            model.iotSensorType = GosIot_sensorSOS;
            model.iotSensorId = nil;
            model.isAPNSOpen = NO;
            model.isSceneOpen = NO;
            /// 添加
            [weakSelf.iOSConfigSDK addIotSensor:model toDeviceId:self.dataModel.DeviceId];
        }break;
        case AddIot_failure:        //  失败
        case AddIot_repeat:{        //  重复添加
            [CountDownCover dismiss];
            [self removeTimer];
            if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(callBackState:gosIOTType:sensorId:)]) {
                [weakSelf.delegate callBackState:addStatus gosIOTType:GosIot_sensorSOS sensorId:@""];
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
        [weakSelf.delegate callBackState:addresult gosIOTType:GosIot_sensorSOS sensorId:m_sensorId];
    }
    [self removeTimer];
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf.navigationController popViewControllerAnimated:YES];
    });
}

#pragma mark -- actionFunction
- (void)removeTimer{
    if (self.sensorTimer) {
        [_sensorTimer invalidate];
        _sensorTimer = nil;
    }
}
-(void)dealloc{
    [self removeTimer];
}
#pragma mark -- delegate
#pragma mark -- lazy
-(iOSConfigSDK *)iOSConfigSDK{
    if (!_iOSConfigSDK) {
        _iOSConfigSDK = [iOSConfigSDK shareCofigSdk];
        _iOSConfigSDK.iotDelegate = self;
    }
    return _iOSConfigSDK;
}
@end
