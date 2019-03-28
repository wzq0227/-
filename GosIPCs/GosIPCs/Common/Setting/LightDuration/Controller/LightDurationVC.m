//
//  LightDurationVC.m
//  Goscom
//
//  Created by 匡匡 on 2018/11/27.
//  Copyright © 2018 goscam. All rights reserved.
//  灯照时长界面

#import "LightDurationVC.h"
#import "LightDurationCell.h"
#import "iOSConfigSDK.h"
#import "TableViewHeadView.h"
#import "LightDurationFootView.h"
#import "GosPickerView.h"
#import "LightDurationViewModel.h"
#import "LightDurationModel.h"
#import "UIViewController+CommonExtension.h"
#import "iOSConfigSDK.h"
#import "TimePickerView.h"

@interface LightDurationVC ()
<iOSConfigSDKParamDelegate,
UITableViewDelegate,
UITableViewDataSource,
TimePickerViewDelegate,
LightDurationCellDelegate,
LightDurationFootViewDelegate>
@property (nonatomic, strong) iOSConfigSDK *configSdk;
@property (weak, nonatomic) IBOutlet UITableView *lightTableview;
@property (nonatomic, strong) NSArray * dataSouceArr;   // 数据来源
@property (nonatomic, strong) UIView * tableFootview;   // 皮囊脚视图
@property (nonatomic, strong) LightDurationFootView * footView;   // 真正的脚视图
/// 灯照时长原始模型
@property (nonatomic, strong) LampDurationModel * lampDurationModel;
/// 选择的开或关
@property (nonatomic, assign) OnOffTimeType timeType;
@end

@implementation LightDurationVC
#pragma mark -- lifestyle
- (void)viewDidLoad {
    [super viewDidLoad];
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
    self.title = DPLocalizedString(@"Setting_LightDuration");
    [self configRightBtnTitle:DPLocalizedString(@"GosComm_Save") titleFont:nil titleColor:nil];
    self.lightTableview.bounces = NO;
    self.lightTableview.rowHeight = 44.0f;
    self.lightTableview.tableFooterView = self.tableFootview;
    [self.lightTableview.tableFooterView setHidden:YES];
    self.lightTableview.backgroundColor = GOS_VC_BG_COLOR;
}
- (void)configNetData{
    [GosHUD showProcessHUDWithStatus:DPLocalizedString(@"SVPLoading")];
    [self.configSdk reqLampDurationOfDevId:self.dataModel.DeviceId];
}
#pragma mark -- function
- (void)refreshUI{
    GOS_WEAK_SELF;
    dispatch_async(dispatch_get_main_queue(), ^{
        GOS_STRONG_SELF;
        [strongSelf.footView setLampDurationModel:strongSelf.lampDurationModel];
        [strongSelf.lightTableview.tableFooterView setHidden:NO];
        [strongSelf.lightTableview reloadData];
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
        [strongSelf.configSdk configLampDuration:strongSelf.lampDurationModel withDeviceId:strongSelf.dataModel.DeviceId];
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
#pragma mark - 改变开启或关闭时间回调
- (void)timePickerFinish{
    [self refreshUI];
}
#pragma mark - 请求灯照时长参数结果回调
- (void)reqLampDuration:(BOOL)isSuccess
               deviceId:(NSString *)devId
                ldParam:(LampDurationModel *)ldModel{
    [GosHUD dismiss];
    if (isSuccess) {
        self.lampDurationModel = ldModel;
        self.dataSouceArr = [LightDurationViewModel handleDataWithDurationModel:self.lampDurationModel];
        [self refreshUI];
    }else{
        [GosHUD showScreenfulHUDErrorWithStatus:DPLocalizedString(@"GosComm_getData_fail")];
    }
}
#pragma mark - 设置灯照时长参数结果回调
- (void)configLampDuration:(BOOL)isSuccess
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
        dispatch_async(dispatch_get_main_queue(), ^{
            [GosHUD showScreenfulHUDErrorWithStatus:DPLocalizedString(@"GosComm_Set_Failed")];
        });
    }
}
#pragma mark - 选择周日-周一回调
- (void)lightDurationSelectDay:(int) selectDay{
    [LightDurationViewModel handleSelectDayWithSelectDay:selectDay DurationModel:self.lampDurationModel tableDataArr:self.dataSouceArr];
    [self refreshUI];
}
#pragma mark - 开关改变回调
- (void)LightDurationSwitch:(BOOL) isOn{
    [LightDurationViewModel handleSwitchWithOn:isOn tableDataArr:self.dataSouceArr ampDurationModel:self.lampDurationModel];
    [self refreshUI];
}
#pragma mark -- actionFunction
#pragma mark -- delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    LightDurationModel * cellModel = [self.dataSouceArr objectAtIndex:indexPath.row];
    if (cellModel.editType == lightDurationEditType_NoEdit) {
        return;
    }
    if (indexPath.row == 1) {
        self.timeType = OnOffTimeType_ON;
        [TimePickerView sharePickerViewWithTimeType:self.timeType tableDataArr:self.dataSouceArr lampDurationModel:self.lampDurationModel delegate:self];
        GosLog(@"输出开启时间");
    }else if(indexPath.row == 2){
        self.timeType = OnOffTimeType_OFF;
        [TimePickerView sharePickerViewWithTimeType:self.timeType tableDataArr:self.dataSouceArr lampDurationModel:self.lampDurationModel delegate:self];
        GosLog(@"输出关闭时间");
    }
    
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataSouceArr.count;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (self.dataSouceArr.count >0) {
        return 1;
    }
    return 0;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [LightDurationCell cellWithTableView:tableView indexPath:indexPath cellModel:[self.dataSouceArr objectAtIndex:indexPath.row] delegate:self];
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    TableViewHeadView * headView = [[TableViewHeadView alloc] initWithFrame:CGRectMake(0, 0, GOS_SCREEN_W, 40.0f)];
    headView.titleLab.text = DPLocalizedString(@"LightDuration_Setting");
    return headView;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 40.0f;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.1f;
}

#pragma mark -- lazy
- (UIView *)tableFootview{
    if (!_tableFootview) {
        self.footView = [[LightDurationFootView alloc] initWithFrame:CGRectMake(0, 0, GOS_SCREEN_W, 110)];
        self.footView.delegate = self;
        _tableFootview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, GOS_SCREEN_W, 110)];
        [_tableFootview addSubview:self.footView];
        
    }
    return _tableFootview;
}
- (iOSConfigSDK *)configSdk{
    if (!_configSdk) {
        _configSdk = [iOSConfigSDK shareCofigSdk];
        _configSdk.paramDelegate = self;
    }
    return _configSdk;
}
@end
