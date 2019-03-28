//
//  VoiceDetectVC.m
//  Goscom
//
//  Created by 匡匡 on 2018/11/27.
//  Copyright © 2018 goscam. All rights reserved.
//  声音检测界面

#import "VoiceDetectVC.h"
#import "iOSConfigSDK.h"
#import "SensitivitySettingCell.h"      //  灵敏度cell
#import "MotionDetectSwitchCell.h"      //  开关cell
#import "TableViewHeadView.h"
#import "VoiceDetectFootView.h"
#import "UIViewController+CommonExtension.h"
#import "VoiceMonitonModel.h"
@interface VoiceDetectVC ()
<iOSConfigSDKParamDelegate,
UITableViewDelegate,
UITableViewDataSource,
SensitivitySettingDelegate,
MotionDetectSwitchDelegate>
@property (weak, nonatomic) IBOutlet UITableView *voiceTableview;
@property (nonatomic, strong) iOSConfigSDK *configSdk;
@property (nonatomic, strong) VoiceMonitonModel * dataModel;   // 数据模型
@end

@implementation VoiceDetectVC
#pragma mark -- lifestyle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self configUI];
    [self configNetData];
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    if ([SVProgressHUD isVisible]) {
        [SVProgressHUD dismiss];
    }
}
#pragma mark -- config
- (void)configUI{
    self.title = DPLocalizedString(@"Setting_VoiceDetection");
    [self configRightBtnTitle:DPLocalizedString(@"GosComm_Save") titleFont:nil titleColor:nil];
    self.voiceTableview.bounces = NO;
    self.voiceTableview.backgroundColor = GOS_VC_BG_COLOR;
}
- (void)configNetData{
    [GosHUD showProcessHUDWithStatus:DPLocalizedString(@"SVPLoading")];
    [self.configSdk reqAllParamOfDevId:self.devDataModel.DeviceId];
}

#pragma mark -- 运动灵敏度改变代理回调
- (void)sensitivitySettingDidUpdate:(DetectLevel) tlevel{
    self.dataModel.dLevel = tlevel;
}
#pragma mark -- 运动检测开关代理回调
- (void)MotionDetectSwitchDidChange:(BOOL) isOn{
    self.dataModel.isON = isOn;
}
#pragma mark -- function
- (void)rightBtnClicked{
    GosLog(@"保存点击");
    UIAlertController *alertview=[UIAlertController alertControllerWithTitle:DPLocalizedString(@"GosComm_Save_title") message:@"" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction=[UIAlertAction actionWithTitle:DPLocalizedString(@"GosComm_Cancel") style:UIAlertActionStyleCancel handler:nil];
    if (cancelAction) {
        [cancelAction setValue:GOS_COLOR_RGB(0x999999) forKey:@"titleTextColor"];
    }
    __weak typeof(self) weakSelf = self;
    UIAlertAction *defultAction = [UIAlertAction actionWithTitle:DPLocalizedString(@"GosComm_Confirm") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [GosHUD showProcessHUDWithStatus:DPLocalizedString(@"SVPLoading")];
        [weakSelf.configSdk configVoiceDetect:weakSelf.dataModel.dLevel state:weakSelf.dataModel.isON withDevId:weakSelf.devDataModel.DeviceId];
    }];
    if (defultAction) {
        [defultAction setValue:GOS_COLOR_RGB(0x55AFFC) forKey:@"titleTextColor"];
    }
    [alertview addAction:cancelAction];
    [alertview addAction:defultAction];
    [self presentViewController:alertview animated:YES completion:nil];
}
- (void)refreshUI{
    GOS_WEAK_SELF;
    dispatch_async(dispatch_get_main_queue(), ^{
        GOS_STRONG_SELF;
        [strongSelf.voiceTableview reloadData];
    });
}
#pragma mark -- actionFunction
#pragma mark - 请求设备所有参数结果回调
- (void)reqAllParam:(BOOL)isSuccess
           deviceId:(NSString *)devId
              param:(AllParamModel *)paramModel{
    [GosHUD dismiss];
    if (isSuccess) {
        self.dataModel.isON = paramModel.isAudioAlarmOn;
        self.dataModel.dLevel = paramModel.audioAlarmLevel;
        [self refreshUI];
    }else{
        [GosHUD showScreenfulHUDErrorWithStatus:DPLocalizedString(@"GosComm_getData_fail")];
    }
}
#pragma mark - 设置声音侦测结果回调
- (void)configVoiceDetect:(BOOL)isSuccess
                 deviceId:(NSString *)devId{
    [GosHUD dismiss];
    if (isSuccess) {
        GOS_WEAK_SELF;
        [GosHUD showScreenfulHUDSuccessWithStatus:DPLocalizedString(@"GosComm_Set_Succeeded")];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            GOS_STRONG_SELF;
            [strongSelf.navigationController popViewControllerAnimated:YES];
        });
    }else{
        [GosHUD showScreenfulHUDErrorWithStatus:DPLocalizedString(@"GosComm_Set_Failed")];
    }
}

#pragma mark -- delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        return [MotionDetectSwitchCell cellWithTableView:tableView indexPath:indexPath cellModel:self.dataModel delegate:self];
    }else{
        return [SensitivitySettingCell cellModelWithTableView:tableView indexPath:indexPath detectLevel:self.dataModel.dLevel delegate:self];
    }
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (section == 1) {
        TableViewHeadView * headView = [[TableViewHeadView alloc] initWithFrame:CGRectMake(0, 0, GOS_SCREEN_W, 40.0f)];
        headView.titleLab.text = DPLocalizedString(@"Setting_VoiceSensitivity");
        return headView;
    }
    return nil;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    if (section == 1) {
        VoiceDetectFootView * fooView = [[VoiceDetectFootView alloc] initWithFrame:CGRectMake(0, 0, GOS_SCREEN_W, 80.0f)];
        return fooView;
    }
    return nil;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        return 44.0f;
    }
    return 60.0f;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 1) {
        return 40.0f;
    }
    return 0.1f;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (section == 1) {
        return 80.0f;
    }
    return 0.1f;
}
#pragma mark -- lazy
- (VoiceMonitonModel *)dataModel{
    if (!_dataModel) {
        _dataModel = [[VoiceMonitonModel alloc] init];
        _dataModel.titleStr = DPLocalizedString(@"Setting_VoiceDetection");
        _dataModel.iconImgStr = @"icon_voice_detection_32";
    }
    return _dataModel;
}
- (iOSConfigSDK *)configSdk{
    if (!_configSdk) {
        _configSdk = [iOSConfigSDK shareCofigSdk];
        _configSdk.paramDelegate = self;
    }
    return _configSdk;
}

@end
