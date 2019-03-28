//
//  CloudServiceVC.m
//  Goscom
//
//  Created by 匡匡 on 2018/11/20.
//  Copyright © 2018 goscam. All rights reserved.
//  云录制套餐界面

#import "CloudServiceVC.h"
#import "CloudServiceCell.h"
#import "CloudServiceHeadView.h"
#import "CloudServiceFootView.h"
#import "CloudOrderVC.h"
#import "iOSConfigSDKModel.h"
#import "PayPackageTypesApiManager.h"       // 付费列表数据manager
#import "PayPackageTypesApiRespModel.h"     // 付费列表数据模型

#import "FreePackageTypesApiManager.h"      // 免费试用manager
#import "FreePackageTypesApiRespModel.h"    //  免费试用模型

#import "FreeOrderApiManager.h"             //  免费试用订单创建
#import "FreeOrderApiRespModel.h"           //  免费试用支付订单模型

#import "FreeOrderPaymentResultApiManager.h"        //  查询免费订单支付结果manager
#import "FreeOrderPaymentResultApiRespModel.h"      // 查询免费订单支付结果模型

#import "CloudServiceViewModel.h"       //  ViewModel
#import "CloudServiceModel.h"           //  模型

@interface CloudServiceVC ()
<UITableViewDelegate,
UITableViewDataSource,
CloudServiceFootViewDelegate,
GosApiManagerCallBackDelegate>
@property (weak, nonatomic) IBOutlet UITableView * CloudServiceTableview;
@property (nonatomic, strong) NSMutableArray * dataSourceArray;
/// 云套餐列表list manager
@property (nonatomic, strong) PayPackageTypesApiManager * payApiManager;
/// 获取是否支持免费试用manager
@property (nonatomic, strong) FreePackageTypesApiManager * freeApiManager;
/// 免费订单order/manager
@property (nonatomic, strong) FreeOrderApiManager * freeOrderApiManager;
/// 免费订单返回的模型
@property (nonatomic, strong) FreePackageTypesApiRespModel * freePackageTypesApiRespModel;
/// 查询免费订单支付结果
@property (nonatomic, strong) FreeOrderPaymentResultApiManager * freeOrderPaymentResultApiManager;
/// 脚视图
@property (nonatomic, strong) CloudServiceFootView * footView;
/// 数据模型
@property (nonatomic, strong) NSArray * dataSourceArr;
@end

@implementation CloudServiceVC
#pragma mark -- lifestyle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = DPLocalizedString(@"Setting_CloudService");
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
    [self.CloudServiceTableview registerNib:[UINib nibWithNibName:@"CloudServiceCell" bundle:nil] forCellReuseIdentifier:@"CloudServiceCell"];
    self.CloudServiceTableview.rowHeight = 50.0f;
    self.CloudServiceTableview.backgroundColor = GOS_VC_BG_COLOR;
    self.CloudServiceTableview.bounces = NO;
}
- (void)configData{
    [GosHUD showProcessHUDWithStatus:DPLocalizedString(@"SVPLoading")];
    [self.apiManager loadData];
    [self.freeApiManager loadDataWithDeviceId:self.dataModel.DeviceId];
    [self.payApiManager loadData];
}
- (void)refreshUI{
    GOS_WEAK_SELF;
    dispatch_async(dispatch_get_main_queue(), ^{
        GOS_STRONG_SELF;
        [strongSelf.CloudServiceTableview reloadData];
    });
}
#pragma mark - mangeder&delegate
- (void)managerCallApiDidSuccess:(GosApiBaseManager *_Nonnull)manager{
    [GosHUD dismiss];
    /// 获取是否支出免费订单
    if (manager == self.freeApiManager) {
        self.freePackageTypesApiRespModel = [manager fetchDataWithReformer:self.freeApiManager];
        /// 目前这样写有一定的局限性，因为免费试用天数和循环天使未知，现在已写死，后期修改可在这修改
        [self.footView setFreeApiRespModel:self.freePackageTypesApiRespModel];
    }
    /// 获取云套餐列表数据
    else if(manager == self.payApiManager){
        NSArray <PayPackageTypesApiRespModel *> * dataArr = [manager fetchDataWithReformer:self.payApiManager];
        self.dataSourceArr = [CloudServiceViewModel initTableDataWithDataArr:dataArr];
    }
    /// 返回创建免费试用的订单
    else if(manager == self.freeOrderApiManager){
        FreeOrderApiRespModel * respModel = [manager fetchDataWithReformer:self.freeOrderApiManager];
        // 订单支付成功 查询订单
        [GosHUD showProcessHUDWithStatus:DPLocalizedString(@"Setting_PayOrderResultQuery")];
        if (respModel.cloudServicePaymentStatusType == CloudServicePaymentStatusTypeProcess) {
            [self.freeOrderPaymentResultApiManager loadDataWithPayOrder:respModel];
        }
    }
    /// 查询免费订单结果
    else if(manager == self.freeOrderPaymentResultApiManager){
//        FreeOrderPaymentResultApiRespModel * respModel = [manager fetchDataWithReformer:self.freeOrderPaymentResultApiManager];
        /// 订单支付成功
        BOOL result = [[manager fetchDataWithReformer:self.freeOrderPaymentResultApiManager] boolValue];
        if (result) {
            [self showSuccess:DPLocalizedString(@"Setting_payFreeOrderSuccess")];
            self.footView.freeUserBtn.hidden = YES;
        }
    }
    [self refreshUI];
    
}
- (void)managerCallApiDidFailed:(GosApiBaseManager *_Nonnull)manager{
    [GosHUD dismiss];
    /// 获取是否支出免费订单
    if (manager == self.freeApiManager) {
        GosLog(@"失败=获取是否支持免费试用出错");
        [self showFail:DPLocalizedString(@"GosComm_getData_fail")];
    }
    /// 获取云套餐列表数据
    else if(manager == self.payApiManager){
        GosLog(@"失败=获取列表数据出错");
        [self showFail:DPLocalizedString(@"GosComm_getData_fail")];
    }
    /// 返回创建免费试用的订单
    else if(manager == self.freeOrderApiManager){
        GosLog(@"失败=创建免费试用订单出错");
        [self showFail:DPLocalizedString(@"Setting_payFreeOrderFail")];
    }
    /// 查询免费订单结果
    else if(manager == self.freeOrderPaymentResultApiManager){
        GosLog(@"失败=查询免费订单结果出错");
        [self showFail:DPLocalizedString(@"Setting_payFreeOrderFail")];
    }
}
#pragma mark -- function
-(void) showSuccess:(NSString *) tips{
    dispatch_async(dispatch_get_main_queue(), ^{
         [GosHUD showScreenfulHUDSuccessWithStatus:tips];
    });
}
-(void) showFail:(NSString *) tips{
    dispatch_async(dispatch_get_main_queue(), ^{
        [GosHUD showScreenfulHUDErrorWithStatus:tips];
    });
}
#pragma mark -- actionFunction
#pragma mark -- delegate
#pragma mark - 免费试用+支付点击
-(void) CloudServiceFootViewBtnClick:(cloudServiceOrderType) payType{
    switch (payType) {
        case cloudServiceOrderType_FreeDay:{  // 免费试用点击
            [GosHUD showProcessHUDWithStatus:DPLocalizedString(@"Setting_PayOrderGenerate")];
            [self.freeOrderApiManager loadDataWithDeviceId:self.dataModel.DeviceId planId:self.freePackageTypesApiRespModel.planId];
        }break;
        case cloudServiceOrderType_Pay:{  // 支付点击
            CloudOrderVC * vc = [[CloudOrderVC alloc] init];
            vc.dataModel = self.dataModel;
            vc.cloudServiceModel = [CloudServiceViewModel getCurrentSelectModel:self.dataSourceArr];
            [self.navigationController pushViewController:vc animated:YES];
        }break;
        default:
            break;
    }
}

#pragma mark - tableView&Delegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    CloudServiceModel * model = self.dataSourceArr[indexPath.row];
    [CloudServiceViewModel modifySelectState:model tableDataArr:self.dataSourceArr];
    [self refreshUI];
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataSourceArr.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [CloudServiceCell cellWithTableView:tableView andCellModel:self.dataSourceArr[indexPath.row]];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (self.dataSourceArr.count >0) {
        CloudServiceHeadView * headView = [[CloudServiceHeadView alloc] init];
        return headView;
    }
    return nil;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    if (self.dataSourceArr.count >0) {
        return self.footView;
    }
    return nil;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 50.01;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (self.freePackageTypesApiRespModel) {
        return 260.01;
    }
    return 150;
}
#pragma mark -- lazy
-(PayPackageTypesApiManager *)apiManager{
    if (!_payApiManager) {
        _payApiManager = [[PayPackageTypesApiManager alloc] init];
        _payApiManager.delegate = self;
    }
    return _payApiManager;
}
-(FreePackageTypesApiManager *)freeApiManager{
    if (!_freeApiManager) {
        _freeApiManager = [[FreePackageTypesApiManager alloc] init];
        _freeApiManager.delegate = self;
    }
    return _freeApiManager;
}
-(CloudServiceFootView *)footView{
    if (!_footView) {
        _footView = [[CloudServiceFootView alloc] initWithFrame:CGRectMake(0, 0, GOS_SCREEN_W, 260)];
        _footView.delegate = self;
    }
    return _footView;
}
-(FreeOrderApiManager *)freeOrderApiManager{
    if (!_freeOrderApiManager) {
        _freeOrderApiManager = [[FreeOrderApiManager alloc] init];
        _freeOrderApiManager.delegate = self;
    }
    return _freeOrderApiManager;
}
-(FreeOrderPaymentResultApiManager *)freeOrderPaymentResultApiManager{
    if (!_freeOrderPaymentResultApiManager) {
        _freeOrderPaymentResultApiManager = [[FreeOrderPaymentResultApiManager alloc] init];
        _freeOrderPaymentResultApiManager.delegate = self;
    }
    return _freeOrderPaymentResultApiManager;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
