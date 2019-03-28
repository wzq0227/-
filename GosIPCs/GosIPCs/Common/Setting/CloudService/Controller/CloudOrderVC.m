//
//  CloudOrderVC.m
//  Goscom
//
//  Created by 匡匡 on 2018/11/28.
//  Copyright © 2018 goscam. All rights reserved.
//  套餐订购界面

#import "CloudOrderVC.h"
#import "CloudOrderInfoCell.h"
#import "CloudOrderPayWayCell.h"
#import "TableViewHeadView.h"
#import "CloudServiceViewModel.h"
#import "CloudServiceModel.h"
#import "CloudOrderModel.h"
#import "iOSConfigSDKModel.h"
#import "PayOrderApiRespModel.h"    //  订单模型
#import "PayOrderApiManager.h"      //  创建订单Manager
#import <iOSPaymentSDK/iOSPaymentSDK.h>            //  支付SDK

#import "AlipayPaymentApiManager.h"     //  支付宝支付manager
#import "AlipayPaymentApiRespModel.h"   //  发往阿里支付模型

#import "WechatPaymentApiManager.h"     //  微信支付manager
#import "WechatPaymentApiRespModel.h"   //  微信支付回调模型

#import "PayPalPaymentApiManager.h"       //  paypal支付manager
#import "PayPalPaymentApiRespModel.h"   //  paypal回调模型

#import "AlipayCheckApiManager.h"       //  支付宝校验支付结果
#import "PayPalCheckApiManager.h"       //  paypal校验支付结果

#import "PayOrderPaymentResultApiManager.h"     //  验证支付订单manager
#import "PayOrderPaymentResultApiRespModel.h"   //  验证支付订单Model

@interface CloudOrderVC ()
<UITableViewDataSource,
UITableViewDelegate,
GosApiManagerCallBackDelegate,
iOSPaymentCallbackDelegate>
@property (weak, nonatomic) IBOutlet UITableView *orderTableView;
/// 支付方式    微信/支付宝/paypal
@property (nonatomic, assign) GosPaymentType paymentType;
/// Tableview数组数据
@property (nonatomic, strong) NSArray * dataSourceArr;
/// 在自己服务器上创建订单manager
@property (nonatomic, strong) PayOrderApiManager * orderApiManager;
/// 阿里支付manager
@property (nonatomic, strong) AlipayPaymentApiManager * alipayApiManager;
/// 微信支付manager
@property (nonatomic, strong) WechatPaymentApiManager * wechatPayApiManager;
/// paypal支付manager
@property (nonatomic, strong) PayPalPaymentApiManager * paypalPayApiManager;

/// 支付宝支付校验结果manager
@property (nonatomic, strong) AlipayCheckApiManager * alipayCheckApiManager;
/// paypal支付校验支付结果manager
@property (nonatomic, strong) PayPalCheckApiManager * payPalCheckApiManager;
/// 订单模型
@property (nonatomic, strong) PayOrderApiRespModel * orderApiRespModel;

/// 最后一步，支付结果查询
@property (nonatomic, strong) PayOrderPaymentResultApiManager * payOrderPaymentResultApiManager;
/// 支付结果查询模型
@property (nonatomic, strong) PayOrderPaymentResultApiRespModel * payOrderPaymentResultApiRespModel;
@end

@implementation CloudOrderVC
#pragma mark -- lifestyle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = DPLocalizedString(@"PackageOrder");
    [self configUI];
    [self configData];
}

#pragma mark -- config
- (void)configUI{
    self.orderTableView.bounces = NO;
    self.orderTableView.rowHeight = 50.0f;
    self.orderTableView.backgroundColor = GOS_VC_BG_COLOR;
}
- (void)configData{
    self.dataSourceArr = [CloudServiceViewModel initTableDataWithModel:self.cloudServiceModel];
    self.paymentType =[GosLoggedInUserInfo serverArea]==LoginServerChina?GosPaymentTypeWechat:GosPaymentTypePayPal;
    [self refreshTable];
}

#pragma mark -- function
- (void)refreshTable{
    GOS_WEAK_SELF;
    dispatch_async(dispatch_get_main_queue(), ^{
        GOS_STRONG_SELF;
        [strongSelf.orderTableView reloadData];
    });
}
#pragma mark -- actionFunction
#pragma mark - 确认订单点击
- (void)confirmOrder{
    // 判断支付是否可用
   if(GosPaymentErrorTypeNoError == [iOSPaymentSDK paymentIsAvailable:self.paymentType]){
       [GosHUD showProcessHUDWithStatus:DPLocalizedString(@"Setting_PayOrderGenerate")];
       ///第一步 支付可用，去生成订单
    [self.orderApiManager loadDataWithDeviceId:self.dataModel.DeviceId totalPrice:self.cloudServiceModel.currentPrice planId:self.cloudServiceModel.planId count:@"1"];
   }
}
#pragma mark - 生成订单回调
- (void)managerCallApiDidSuccess:(GosApiBaseManager *_Nonnull)manager{
    [GosHUD dismiss];
    /// 第二步
    if ([manager isEqual:self.orderApiManager]) {
        [GosHUD showProcessHUDWithStatus:DPLocalizedString(@"Setting_PayOrderPaycheck")];
        /// 回调得到订单模型
       self.orderApiRespModel = [manager fetchDataWithReformer:self.orderApiManager];
        /// 将订单模型发往服务器，得到去支付宝支付所需的参数
        if (self.paymentType == GosPaymentTypeAlipay) {
            [self.alipayApiManager loadDataWithPayOrder:self.orderApiRespModel];
        }else if(self.paymentType == GosPaymentTypeWechat){
            [self.wechatPayApiManager loadDataWithPayOrder:self.orderApiRespModel];
        }else if(self.paymentType == GosPaymentTypePayPal){
            [self.wechatPayApiManager loadDataWithPayOrder:self.orderApiRespModel];
        }
    }
    
    /// 第三步
    /// 回调得到阿里支付宝支付的订单模型
    if ([manager isEqual:self.alipayApiManager]) {
        AlipayPaymentApiRespModel * respModel = [manager fetchDataWithReformer:self.alipayApiManager];
        
        iOSPaymentAlipayOrder * alipayOrder = [[iOSPaymentAlipayOrder alloc] init];
        alipayOrder.signParam = respModel.signParam;
        
        [[iOSPaymentSDK sharedInstance] setDelegate:(id<iOSPaymentCallbackDelegate> _Nullable)self];
        [GosHUD showProcessHUDWithStatus:DPLocalizedString(@"Setting_PayOrderPaying")];
        [iOSPaymentSDK paymentHandleOrder:alipayOrder];
    }
    
    /// 回调得到微信支付的订单模型
    if ([manager isEqual:self.wechatPayApiManager]) {
        WechatPaymentApiRespModel * respModel = [manager fetchDataWithReformer:self.wechatPayApiManager];
        iOSPaymentWechatOrder * wechatOrder = [[iOSPaymentWechatOrder alloc] init];
        wechatOrder.partnerid = respModel.partnerid;
        wechatOrder.prepayid = respModel.prepayid;
        wechatOrder.noncestr = respModel.noncestr;
        wechatOrder.timestamp = respModel.timestamp;
        wechatOrder.package = respModel.package;
        wechatOrder.sign = respModel.sign;
        [[iOSPaymentSDK sharedInstance] setDelegate:(id<iOSPaymentCallbackDelegate> _Nullable)self];
        [GosHUD showProcessHUDWithStatus:DPLocalizedString(@"Setting_PayOrderPaying")];
        [iOSPaymentSDK paymentHandleOrder:wechatOrder];
    }
    
    /// 回调得到payple支付的订单模型
    if ([manager isEqual:self.paypalPayApiManager]) {
        PayPalPaymentApiRespModel * respModel = [manager fetchDataWithReformer:self.paypalPayApiManager];
        
        iOSPaymentPayPalOrder * payPalOrder = [[iOSPaymentPayPalOrder alloc] init];
        payPalOrder.authToken = respModel.payPalToken;
        payPalOrder.amount = self.orderApiRespModel.totalPrice;
        [[iOSPaymentSDK sharedInstance] setDelegate:(id<iOSPaymentCallbackDelegate> _Nullable)self];
        [GosHUD showProcessHUDWithStatus:DPLocalizedString(@"Setting_PayOrderPaying")];
        [iOSPaymentSDK paymentHandleOrder:payPalOrder];
    }
    
   /// 第四部 校验订单  只有支付宝和paypal才有
    if([manager isEqual:self.alipayCheckApiManager]){
        NSNumber * resultNumber = [manager fetchDataWithReformer:self.alipayCheckApiManager];
        if ([resultNumber boolValue]) {
            GosLog(@"还差一步支付宝支付大功告成");
            [GosHUD showProcessHUDWithStatus:DPLocalizedString(@"Setting_PayOrderPayResult")];
            [self.payOrderPaymentResultApiManager loadDataWithPayOrder:self.orderApiRespModel];
        }else{
            [GosHUD showScreenfulHUDErrorWithStatus:DPLocalizedString(@"PackagePayBuy_Fail")];
            GosLog(@"失败=支付宝支付死在倒数第二步");
        }
    }
    
    
    if([manager isEqual:self.payPalCheckApiManager]){
        NSNumber * resultNumber = [manager fetchDataWithReformer:self.payPalCheckApiManager];
        if ([resultNumber boolValue]) {
            [GosHUD showProcessHUDWithStatus:DPLocalizedString(@"Setting_PayOrderPayResult")];
            [self.payOrderPaymentResultApiManager loadDataWithPayOrder:self.orderApiRespModel];
            GosLog(@"还差一步paypal大功告成");

        }else{
            [GosHUD showScreenfulHUDErrorWithStatus:DPLocalizedString(@"PackagePayBuy_Fail")];
            GosLog(@"失败=paypal死在倒数第二步");
        }
    }
    
    /// 最后一步，支付订单结果查询
    if ([manager isEqual:self.payOrderPaymentResultApiManager]) {
        [GosHUD dismiss];
        self.payOrderPaymentResultApiRespModel = [manager fetchDataWithReformer:self.payOrderPaymentResultApiManager];
        if (CloudServicePaymentStatusTypeSuccess == self.payOrderPaymentResultApiRespModel.cloudServicePaymentStatusType) {
            [GosHUD showScreenfulHUDSuccessWithStatus:DPLocalizedString(@"PackagePay_Success")];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.navigationController popToRootViewControllerAnimated:YES];
            });
        }else{
            [GosHUD showScreenfulHUDErrorWithStatus:DPLocalizedString(@"PackagePayBuy_Fail")];
        }
    }
}

#pragma mark - 支付结果代理回调
- (void)payment:(GosPaymentType)paymentType status:(GosPaymentStatus)status userInfo:(NSDictionary *_Nullable)userInfo{
    [GosHUD dismiss];
    /// 支付失败 
    if (status == GosPaymentStatusPaymentFailure) {
        [GosHUD showScreenfulHUDErrorWithStatus:DPLocalizedString(@"PackagePay_fail")];
        return;
    }else if(status == GosPaymentStatusPaymentCancel){
        [GosHUD showScreenfulHUDErrorWithStatus:DPLocalizedString(@"PackagePay_Cancel")];
        return;
    }
    if (status != GosPaymentStatusPaymentSuccess) {
        return;
    }
    switch (paymentType) {
        case GosPaymentTypeAlipay:{ //  支付宝支付回调校验
             iOSPaymentAlipayResult * resultModel = userInfo[kiOSPaymentCallbackUserInfoKeyResult];
            [GosHUD showProcessHUDWithStatus:DPLocalizedString(@"Setting_PayOrderResultcheck")];
            [self.alipayCheckApiManager loadDataWithMemo:resultModel.memo result:resultModel.result resultStatus:resultModel.resultStatus];
           
        }break;
        case GosPaymentTypeWechat:{  //  微信支付回调校验
            GosLog(@"不用校验，直接查询订单结果");
            [GosHUD showProcessHUDWithStatus:DPLocalizedString(@"Setting_PayOrderResultcheck")];
            [self.payOrderPaymentResultApiManager loadDataWithPayOrder:self.orderApiRespModel];
            
        }break;
        case GosPaymentTypePayPal:{ //  paypal支付回调校验
             iOSPaymentPayPalResult * resultModel = userInfo[kiOSPaymentCallbackUserInfoKeyResult];
            [GosHUD showProcessHUDWithStatus:DPLocalizedString(@"Setting_PayOrderResultcheck")];
            [self.payPalCheckApiManager loadDataWithOrderNumber:self.orderApiRespModel.orderNo amount:self.orderApiRespModel.totalPrice nonce:resultModel.nonce];
        }break;
        default:
            break;
    }

}

- (void)managerCallApiDidFailed:(GosApiBaseManager *_Nonnull)manager{
    [GosHUD dismiss];
    [GosHUD showScreenfulHUDErrorWithStatus:DPLocalizedString(@"PackagePayOrder_Fail")];
    if ([manager isEqual:self.orderApiManager]) {
        GosLog(@"失败=创建订单失败");
    }
    if ([manager isEqual:self.alipayApiManager]){
        GosLog(@"失败=生成支付宝订单失败");
    }
    if ([manager isEqual:self.wechatPayApiManager]) {
        GosLog(@"失败=生成微信支付的订单失败");
    }
    if ([manager isEqual:self.paypalPayApiManager]) {
        GosLog(@"失败=生成payple支付的订单失败");
    }
}

#pragma mark - tableView&delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        return;
    }
    CloudOrderPayWayTypeModel * typeModel = self.dataSourceArr[indexPath.section];
    [CloudServiceViewModel modifyPayWayWithModel:typeModel.sectionArr[indexPath.row] payWayArr:typeModel.sectionArr paymentType:&_paymentType];
    [self refreshTable];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    CloudOrderPayWayTypeModel * typeModel = self.dataSourceArr[indexPath.section];
    if ([typeModel.sectionTitle isEqualToString:DPLocalizedString(@"PackageInformation")]) {
        CloudOrderModel * model = typeModel.sectionArr[indexPath.row];
        return [CloudOrderInfoCell cellWithTableView:tableView cellModel:model indexPath:indexPath];
    }else{
        CloudOrderPayWayModel * model = typeModel.sectionArr[indexPath.row];
        return [CloudOrderPayWayCell cellWithTableView:tableView cellModel:model indexPath:indexPath];
    }
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    CloudOrderPayWayTypeModel * typeModel = self.dataSourceArr[section];
    return typeModel.sectionArr.count;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.dataSourceArr.count;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    TableViewHeadView * headView = [[TableViewHeadView alloc] initWithFrame:CGRectMake(0, 0, GOS_SCREEN_W, 40)];
     CloudOrderPayWayTypeModel * typeModel = self.dataSourceArr[section];
    [headView setTitleStr:typeModel.sectionTitle];
    return headView;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    CloudOrderPayWayTypeModel * typeModel = self.dataSourceArr[section];
    if ([typeModel.sectionTitle isEqualToString:DPLocalizedString(@"PackageChoosePaymentType")]) {
        UIView * footView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, GOS_SCREEN_W, 120)];
        footView.backgroundColor = GOS_VC_BG_COLOR;
        UIButton * comfirmBtn = [[UIButton alloc] initWithFrame:CGRectMake(30, 40, GOS_SCREEN_W - 60, 40)];
        comfirmBtn.backgroundColor = GOS_COLOR_RGBA(85, 175, 252, 1);
        comfirmBtn.titleLabel.textColor = [UIColor whiteColor];
        comfirmBtn.titleLabel.font = GOS_FONT(16);
        [comfirmBtn setTitle:DPLocalizedString(@"PackageConfirmPay") forState:UIControlStateNormal];
        comfirmBtn.layer.cornerRadius = 20.0f;
        comfirmBtn.clipsToBounds = YES;
        [comfirmBtn addTarget:self action:@selector(confirmOrder) forControlEvents:UIControlEventTouchUpInside];
        [footView addSubview:comfirmBtn];
        return footView;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 40.0f;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
     CloudOrderPayWayTypeModel * typeModel = self.dataSourceArr[section];
    if ([typeModel.sectionTitle isEqualToString:DPLocalizedString(@"PackageChoosePaymentType")]) {
        return 80.0f;
    }
    return 0.1f;
}
#pragma mark -- lazy
- (PayOrderApiManager *)orderApiManager{
    if (!_orderApiManager) {
        _orderApiManager = [[PayOrderApiManager alloc] init];
        _orderApiManager.delegate = self;
    }
    return _orderApiManager;
}
- (AlipayPaymentApiManager *)alipayApiManager{
    if (!_alipayApiManager) {
        _alipayApiManager = [[AlipayPaymentApiManager alloc] init];
        _alipayApiManager.delegate = self;
    }
    return _alipayApiManager;
}
- (WechatPaymentApiManager *)wechatPayApiManager{
    if (!_wechatPayApiManager) {
        _wechatPayApiManager = [[WechatPaymentApiManager alloc] init];
        _wechatPayApiManager.delegate = self;
    }
    return _wechatPayApiManager;
}
- (PayPalPaymentApiManager *)paypalPayApiManager{
    if (!_paypalPayApiManager) {
        _paypalPayApiManager = [[PayPalPaymentApiManager alloc] init];
        _paypalPayApiManager.delegate = self;
    }
    return _paypalPayApiManager;
}
- (AlipayCheckApiManager *)alipayCheckApiManager{
    if (!_alipayCheckApiManager) {
        _alipayCheckApiManager = [[AlipayCheckApiManager alloc] init];
        _alipayCheckApiManager.delegate = self;
    }
    return _alipayCheckApiManager;
}
- (PayPalCheckApiManager *)payPalCheckApiManager{
    if (!_payPalCheckApiManager) {
        _payPalCheckApiManager = [[PayPalCheckApiManager alloc] init];
        _payPalCheckApiManager.delegate = self;
    }
    return _payPalCheckApiManager;
}
- (PayOrderPaymentResultApiManager *)payOrderPaymentResultApiManager{
    if (!_payOrderPaymentResultApiManager) {
        _payOrderPaymentResultApiManager = [[PayOrderPaymentResultApiManager alloc] init];
        _payOrderPaymentResultApiManager.delegate = self;
    }
    return _payOrderPaymentResultApiManager;
}
@end
