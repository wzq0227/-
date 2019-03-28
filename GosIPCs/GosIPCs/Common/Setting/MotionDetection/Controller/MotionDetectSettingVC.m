//
//  MotionDetectSettingVC.m
//  Goscom
//
//  Created by 匡匡 on 2018/11/22.
//  Copyright © 2018 goscam. All rights reserved.
//  运动检测界面

#import "MotionDetectSettingVC.h"
#import "MotionDetectSwitchCell.h"
#import "SensitivitySettingCell.h"
#import "MoniterAreaCell.h"
#import "MotionDetectFootView.h"
#import "iOSConfigSDK.h"
#import "TableViewHeadView.h"
#import "UIViewController+CommonExtension.h"
#import "VoiceMonitonModel.h"
#import "MediaManager.h"
#import "NSString+GosSize.h"
@interface MotionDetectSettingVC ()<UITableViewDelegate,
UITableViewDataSource,
iOSConfigSDKParamDelegate,
MoniterAreaCellDelegate,
MotionDetectFootViewDelegate,
MotionDetectSwitchDelegate,
SensitivitySettingDelegate>
@property (weak, nonatomic) IBOutlet UITableView *motionTableview;
@property (nonatomic, strong) iOSConfigSDK *configSdk;
@property (nonatomic, strong) MotionDetectModel * modelData;
@property (nonatomic, strong) MotionDetectFootView * footView;   // 脚视图
@property (nonatomic, strong) VoiceMonitonModel * cellModel;   //   cell模型
@property (nonatomic, strong) MediaManager * mediaManage;   // mediaManage
@property (nonatomic, strong) UIImage * bgImg;   // 背景img
@end

@implementation MotionDetectSettingVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configUI];
    [self configTable];
    [self configNetData];
    // Do any additional setup after loading the view from its nib.
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    if ([SVProgressHUD isVisible]) {
        [SVProgressHUD dismiss];
    }
}
#pragma mark -- config
- (void)configTable{
    UIView * tableFootView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, GOS_SCREEN_W, 180)];
    [tableFootView addSubview:self.footView];
    self.motionTableview.bounces = NO;
    self.motionTableview.tableFooterView = tableFootView;
    self.motionTableview.backgroundColor = GOS_VC_BG_COLOR;
}
- (void)configNetData{
    [GosHUD showProcessHUDWithStatus:DPLocalizedString(@"SVPLoading")];
    [self.configSdk reqMotionDetectOfDevId:self.dataModel.DeviceId];
    self.bgImg = [MediaManager coverWithDevId:self.dataModel.DeviceId fileName:@"Cover" deviceType:(GosDeviceType)self.dataModel.DeviceType position:PositionMain];
}
- (void)configUI{
    self.title = DPLocalizedString(@"Setting_MotionDetection");
    [self configRightBtnTitle:DPLocalizedString(@"GosComm_Save") titleFont:nil titleColor:nil];
}
#pragma mark -- function
- (void)refreshUI{
    GOS_WEAK_SELF;
    dispatch_async(dispatch_get_main_queue(), ^{
        GOS_STRONG_SELF;
        [strongSelf.footView setModelData:strongSelf.modelData];
        [strongSelf.motionTableview reloadData];
    });
}
- (void)rightBtnClicked{
    UIAlertController *alertview=[UIAlertController alertControllerWithTitle:DPLocalizedString(@"GosComm_Save_title") message:@"" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction=[UIAlertAction actionWithTitle:DPLocalizedString(@"GosComm_Cancel") style:UIAlertActionStyleCancel handler:nil];
    //修改按钮
    if (cancelAction) {
        [cancelAction setValue:GOS_COLOR_RGB(0x999999) forKey:@"titleTextColor"];
    }
    GOS_WEAK_SELF;
    UIAlertAction *defultAction = [UIAlertAction actionWithTitle:DPLocalizedString(@"GosComm_Confirm") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        GOS_STRONG_SELF;
        [GosHUD showProcessHUDWithStatus:DPLocalizedString(@"SVPLoading")];
        [strongSelf.configSdk configMotionDetect:strongSelf.modelData withDevId:strongSelf.dataModel.DeviceId];
    }];
    if (defultAction) {
        [defultAction setValue:GOS_COLOR_RGB(0x55AFFC) forKey:@"titleTextColor"];
    }
    [alertview addAction:cancelAction];
    [alertview addAction:defultAction];
    dispatch_async(dispatch_get_main_queue(), ^{
        GOS_STRONG_SELF;
        [strongSelf presentViewController:alertview animated:YES completion:nil];
    });
}
#pragma mark -- actionFunction
#pragma mark -- delegate
#pragma mark - 请求设备运动侦测参数结果回调
- (void)reqMotionDetect:(BOOL)isSuccess
               deviceId:(NSString *)devId
            detectParam:(MotionDetectModel *)mDetect{
    [GosHUD dismiss];
    if (isSuccess) {
        self.modelData = mDetect;
        self.cellModel.isON = mDetect.isMotionDetectOn;
        [self refreshUI];
    }else{
        [GosHUD showScreenfulHUDErrorWithStatus:DPLocalizedString(@"GosComm_getData_fail")];
    }
}
#pragma mark - 设置设备运动侦测参数结果回调
- (void)configMotionDetect:(BOOL)isSuccess
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
#pragma mark -- 运动检测开关代理回调
- (void)MotionDetectSwitchDidChange:(BOOL) isOn{
    self.modelData.isMotionDetectOn = isOn;
}
#pragma mark -- 运动灵敏度改变代理回调
- (void)sensitivitySettingDidUpdate:(DetectLevel) tlevel{
    self.modelData.motionLevel = tlevel;
}
#pragma mark -- 选择区域后的代理回调
- (void)moniterSelectAreaBack:(MotionDetectModel *) cellModel{
    self.modelData = cellModel;
}
#pragma mark -- footview 全选代理回调
- (void)motionFootViewBackData:(MotionDetectModel *) dataModel{
    self.modelData = dataModel;
    [self refreshUI];
}

#pragma mark - <TableViewDelegate>
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        return [MotionDetectSwitchCell cellWithTableView:tableView indexPath:indexPath cellModel:self.cellModel delegate:self];
    }else if(indexPath.section == 1){
        return [SensitivitySettingCell cellModelWithTableView:tableView indexPath:indexPath detectLevel:self.modelData.motionLevel delegate:self];
    }else{
        return [MoniterAreaCell cellModelWithTableView:tableView indexPath:indexPath cellModel:self.modelData bgImg:self.bgImg delegate:self];
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        return 44.0f;
    }else if(indexPath.section == 1){
        return 60.0f;
    }
    else{
        return ((GOS_SCREEN_W - 24) / 16 * 9 + 50);
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section !=0) {
        return 40.0f;
    }
    return 0.1f;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.1f;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    TableViewHeadView * headView = [[TableViewHeadView alloc] initWithFrame:CGRectMake(0, 0, GOS_SCREEN_W, 40)];
    if (section == 1) {
        headView.titleLab.text = DPLocalizedString(@"Setting_MotionSensitivity");
        return headView;
    }else if(section == 2){
        headView.titleLab.text = DPLocalizedString(@"Setting_MoniterArea");
        return headView;
    }
    return nil;
}

#pragma mark -- lifestyle
#pragma mark -- lazy
- (MotionDetectFootView *)footView{
    if (!_footView) {
        _footView = [[MotionDetectFootView alloc] initWithFrame:CGRectMake(0, 0, GOS_SCREEN_W, 180)];
        //        NSString * title = DPLocalizedString(@"Setting_SelectAreaReminder");
        //        CGSize size = [NSString sizeWithString:title font:[UIFont systemFontOfSize:12] forMaxSize:CGSizeMake(GOS_SCREEN_W-40, GOS_SCREEN_H)];
        _footView.delegate = self;
    }
    return _footView;
}
- (VoiceMonitonModel *)cellModel{
    if (!_cellModel) {
        _cellModel = [[VoiceMonitonModel alloc] init];
        _cellModel.titleStr = DPLocalizedString(@"Setting_MotionDetection");
        _cellModel.iconImgStr = @"icon_motion_32";
    }
    return _cellModel;
}
- (iOSConfigSDK *)configSdk{
    if (!_configSdk) {
        _configSdk = [iOSConfigSDK shareCofigSdk];
        _configSdk.paramDelegate = self;
    }
    return _configSdk;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
- (void)dealloc{
    GosLog(@"---%s---",__PRETTY_FUNCTION__);
}
@end
