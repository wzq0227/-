//
//  TempAlarmVC.m
//  Goscom
//
//  Created by 匡匡 on 2018/11/20.
//  Copyright © 2018 goscam. All rights reserved.
//

#import "TempAlarmVC.h"
#import "TempAlarmEditorVC.h"
#import "iOSConfigSDK.h"
#import "UIViewController+CommonExtension.h"

@interface TempAlarmVC ()<iOSConfigSDKParamDelegate>
@property (nonatomic, strong) iOSConfigSDK *configSdk;
@property (weak, nonatomic) IBOutlet UILabel *upTempLab;    //  上限温度
@property (weak, nonatomic) IBOutlet UILabel *downTempLab;  //  下限温度
@property (weak, nonatomic) IBOutlet UILabel *upTempTipsLab;    //  上限温度提示
@property (weak, nonatomic) IBOutlet UILabel *downTempTipsLab;  //  下限温度提示

@property (nonatomic, strong) NSString * upTempStr;         //  上限温度Str
@property (nonatomic, strong) NSString * downTempStr;       // 下限温度
@property (nonatomic, strong) TemDetectModel * dataModel;   // 数据模型
@property (nonatomic, strong) UIButton * rightBtn;   // 右侧小按钮
@end

@implementation TempAlarmVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self configUI];
    [self configData];
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    if ([SVProgressHUD isVisible]) {
        [SVProgressHUD dismiss];
    }
}
#pragma mark -- config
- (void)configUI{
    self.title = DPLocalizedString(@"Setting_TempAlarmSetting");
    [self configRightBtnTitle:DPLocalizedString(@"GosComm_Edit") titleFont:nil titleColor:nil];
    self.upTempTipsLab.text = DPLocalizedString(@"temperature_ceiling");
    self.downTempTipsLab.text = DPLocalizedString(@"Temperature_floor");
    self.view.backgroundColor = GOS_VC_BG_COLOR;
    self.rightBtn.enabled = NO;
}
- (void)configData{
    [GosHUD showProcessHUDWithStatus:DPLocalizedString(@"SVPLoading")];
    [self.configSdk reqTemDetectOfDevId:self.deviceID];
}

#pragma mark -- function
- (void)refreshUI{
    GOS_WEAK_SELF;
    dispatch_async(dispatch_get_main_queue(), ^{
        GOS_STRONG_SELF;
        strongSelf.rightBtn.enabled = YES;
        strongSelf.upTempStr = [NSString stringWithFormat:@"%0.lf%@",self.dataModel.upperLimitsTem,self.dataModel.temType == Temperature_C?@"°C":@"°F"];
        strongSelf.downTempStr = [NSString stringWithFormat:@"%0.lf%@",self.dataModel.lowerLimitsTem,self.dataModel.temType == Temperature_C?@"°C":@"°F"];
        strongSelf.upTempLab.text = self.upTempStr;
        strongSelf.downTempLab.text = self.downTempStr;
    });
}
#pragma mark -- actionFunction
- (void)rightBtnClicked{
    TempAlarmEditorVC * vc = [[TempAlarmEditorVC alloc] init];
    vc.deviceId = self.deviceID;
    vc.tempDataModel = self.dataModel;
    [self.navigationController pushViewController:vc animated:YES];
}
#pragma mark -- delegate
- (void)reqTemDetect:(BOOL)isSuccess
            deviceId:(NSString *)devId
         detectParam:(TemDetectModel *)tDetect{
    [GosHUD dismiss];
    if (isSuccess) {
        self.dataModel = tDetect;
        [self refreshUI];
    }
}
#pragma mark -- lifestyle
#pragma mark -- lazy
- (iOSConfigSDK *)configSdk{
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
