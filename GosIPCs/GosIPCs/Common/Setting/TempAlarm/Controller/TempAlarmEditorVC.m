//
//  TempAlarmEditorVC.m
//  Goscom
//
//  Created by 匡匡 on 2018/11/22.
//  Copyright © 2018 goscam. All rights reserved.
//  具体的温度报警设置界面

#import "TempAlarmEditorVC.h"
#import "TempAlarmModel.h"
#import "TempAlarmTypeCell.h"
#import "TempAlarmViewModel.h"
#import "TempAlarmPickerView.h"
#import "iOSConfigSDK.h"
#import "UIViewController+CommonExtension.h"
@interface TempAlarmEditorVC ()
<UITableViewDelegate,
UITableViewDataSource,
TempAlarmTypeCellDelegate,
iOSConfigSDKParamDelegate,
TempAlarmPickerViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tempAlramTableview;
@property (nonatomic, strong) iOSConfigSDK *configSdk;
@property (nonatomic, strong) TempAlarmViewModel * viewModel;
@property (nonatomic, strong) NSArray * dataSourceArr;
/// 真实的footView
@property (nonatomic, strong)  TempAlarmPickerView * footView;
/// 皮囊footView
@property (nonatomic, strong) UIView * tableFootView;
@end

@implementation TempAlarmEditorVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configTableview];
    [self configSetSDK];
    [self configUI];
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
    self.title = DPLocalizedString(@"Setting_TempAlarmSetting");
    [self configRightBtnTitle:DPLocalizedString(@"GosComm_Save") titleFont:nil titleColor:nil];
}
- (void)configTableview{
    [self.tempAlramTableview registerNib:[UINib nibWithNibName:@"TempAlarmTypeCell" bundle:nil] forCellReuseIdentifier:@"TempAlarmTypeCell"];
    self.tempAlramTableview.bounces = NO;
    self.tempAlramTableview.tableFooterView = self.tableFootView;
    self.tempAlramTableview.backgroundColor = GOS_VC_BG_COLOR;
}

- (void)configSetSDK{
    self.configSdk = [iOSConfigSDK shareCofigSdk];
    self.configSdk.paramDelegate = self;
}
- (void)setTempDataModel:(TemDetectModel *)tempDataModel{
    _tempDataModel = tempDataModel;
    self.dataSourceArr = [self.viewModel handleTabledataModel:tempDataModel];
    [self.viewModel pickerViewData:self.dataSourceArr dataPickview:self.footView];
    [self.tempAlramTableview reloadData];
}

#pragma mark -- function
- (void)rightBtnClicked{
    UIAlertController *alertview=[UIAlertController alertControllerWithTitle:DPLocalizedString(@"GosComm_Save_title") message:@"" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction=[UIAlertAction actionWithTitle:DPLocalizedString(@"GosComm_Cancel") style:UIAlertActionStyleCancel handler:nil];
    //修改按钮
    if (cancelAction) {
        [cancelAction setValue:GOS_COLOR_RGB(0x999999) forKey:@"titleTextColor"];
    }
    __weak typeof(self) weakSelf = self;
    UIAlertAction *defultAction = [UIAlertAction actionWithTitle:DPLocalizedString(@"GosComm_Save") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [GosHUD showProcessHUDWithStatus:DPLocalizedString(@"SVPLoading")];
        [weakSelf.configSdk configTemDetect:weakSelf.tempDataModel withDeviceId:weakSelf.deviceId];
    }];
    if (defultAction) {
        [defultAction setValue:GOS_COLOR_RGB(0x55AFFC) forKey:@"titleTextColor"];
    }
    [alertview addAction:cancelAction];
    [alertview addAction:defultAction];
    [self presentViewController:alertview animated:YES completion:nil];
}

#pragma mark -- actionFunction

#pragma mark -- delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.dataSourceArr.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [[self.dataSourceArr objectAtIndex:section] count];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44.0f;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [TempAlarmTypeCell cellModelWithTableView:tableView indexPath:indexPath model:[[self.dataSourceArr objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] delegate:self];
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.01f;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (section == 2) {
        return 40.01f;
    }
    return 10.0f;
}
#pragma mark -- cell按钮和switch点击 代理回调
- (void)switchStateDidChange:(TempAlarmTypeCell *) cell{
    [self.viewModel cellActionWithCellModel:cell.dataModel dataSourceArr:self.dataSourceArr temDetectModel:self.tempDataModel];
    [self.viewModel pickerViewData:self.dataSourceArr dataPickview:self.footView];
    [self nslogData];
    [self.tempAlramTableview reloadData];
}
#pragma mark -- pickerViewd滚动停止 代理回调
- (void)pickerViewSelectRow:(TempAlarmPickModel *) rowData{
    [self.viewModel modifyPickViewModelData:rowData dataArr:self.dataSourceArr temDetectModel:self.tempDataModel];
    [self nslogData];
    [self.tempAlramTableview reloadData];
}

- (void)nslogData{
    GosLog(@"选择的是0是摄氏度  1是华氏度  %ld\n",(long)self.tempDataModel.temType);
    GosLog(@"上下限温度打开  0全关  1上开下闭  2上关下开  3 上下开%ld",(long)self.tempDataModel.enableType);
    GosLog(@"上限温度=%lf",self.tempDataModel.upperLimitsTem);
    GosLog(@"下限温度=%lf",self.tempDataModel.lowerLimitsTem);
}
#pragma mark - 设置温度侦测参数结果回调
- (void)configTemDetect:(BOOL)isSuccess
               deviceId:(NSString *)devId{
    [GosHUD dismiss];
    if (isSuccess) {
        [GosHUD showScreenfulHUDSuccessWithStatus:DPLocalizedString(@"GosComm_Set_Succeeded")];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.navigationController popViewControllerAnimated:YES];
        });
    }else{
        [GosHUD showScreenfulHUDErrorWithStatus:DPLocalizedString(@"GosComm_Set_Failed")];
    }
}

#pragma mark -- lifestyle
#pragma mark -- lazy

- (TempAlarmViewModel *)viewModel{
    if (!_viewModel) {
        _viewModel = [[TempAlarmViewModel alloc] init];
    }
    return _viewModel;
}
- (UIView *)tableFootView{
    if (!_tableFootView) {
        _tableFootView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, GOS_SCREEN_W, 300)];
        [_tableFootView addSubview:self.footView];
    }
    return _tableFootView;
}
- (TempAlarmPickerView *)footView{
    if (!_footView) {
        _footView = [[TempAlarmPickerView alloc] initWithFrame:CGRectMake(0, 0, GOS_SCREEN_W, 300)];
        _footView.delegate = self;
    }
    return _footView;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
