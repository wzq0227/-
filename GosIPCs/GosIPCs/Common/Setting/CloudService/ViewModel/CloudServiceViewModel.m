//  CloudServiceViewModel.m
//  Goscom
//
//  Create by 匡匡 on 2018/12/20.
//  Copyright © 2018 goscam. All rights reserved.

#import "CloudServiceViewModel.h"
#import "PayPackageTypesApiRespModel.h"
#import "CloudServiceModel.h"
#import "GosLoggedInUserInfo.h"
#import "CloudOrderModel.h"


@implementation CloudServiceViewModel
#pragma mark - 初始化数组数据
+ (NSArray <CloudServiceModel *> *)initTableDataWithDataArr:(NSArray <PayPackageTypesApiRespModel *> *) normalData{
    NSMutableArray * dataArr = [[NSMutableArray alloc] init];
    [normalData enumerateObjectsUsingBlock:^(PayPackageTypesApiRespModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CloudServiceModel * model = [[CloudServiceModel alloc] init];
        model.dataLife = obj.dataLife;
        model.serviceLife = obj.serviceLife;
        model.dataLifeString = [NSString stringWithFormat:@"%@%@",obj.dataLife,DPLocalizedString(@"CS_PackageType_Days")];
        model.serviceLifeString = [CloudServiceViewModel getPackageTypeUnit:obj.serviceLife];
        model.normalPrice = [NSString stringWithFormat:@"%@%@",[GosLoggedInUserInfo serverArea]==LoginServerChina?@"￥":@"$",obj.originalPrice];
        model.currentPriceString = [NSString stringWithFormat:@"%@%@",[GosLoggedInUserInfo serverArea]==LoginServerChina?@"￥":@"$",obj.price];
        model.planId = obj.planId;
        model.currentPrice = obj.price;
        model.select = idx == 0?YES:NO;
        [dataArr addObject:model];
    }];
    return dataArr;
}

#pragma mark - 获取云录制套餐当前选中的模型
+ (CloudServiceModel *)getCurrentSelectModel:(NSArray <CloudServiceModel *> *) tableArr{
    __block CloudServiceModel * returnModel = nil;
    [tableArr enumerateObjectsUsingBlock:^(CloudServiceModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.isSelect) {
            returnModel = obj;
            *stop = YES;
        }
    }];
    return returnModel;
}
#pragma mark - 把套餐天数换算成月年
+ (NSString *)getPackageTypeUnit:(NSString *)serviceLife{
    NSInteger unit = [serviceLife intValue] /30;
    if (unit<12) {
        return [NSString stringWithFormat:@"%d%@",unit,DPLocalizedString(@"CS_PackageType_Month")];
    }else if(unit >=12 && unit <24){
        return [NSString stringWithFormat:@"1%@",DPLocalizedString(@"CS_PackageType_Year")];
    }
    return @"未定义";
}

#pragma mark - 修改选中的套餐
+ (void)modifySelectState:(CloudServiceModel *)selectModel
             tableDataArr:(NSArray <CloudServiceModel *> *) tableArr{
    [tableArr enumerateObjectsUsingBlock:^(CloudServiceModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.select = NO;
        if ([obj isEqual:selectModel]) {
            obj.select = YES;
        }
    }];
}

+ (NSArray <CloudOrderPayWayTypeModel *> *)initTableDataWithModel:(CloudServiceModel *) dataModel{
    
    CloudOrderPayWayTypeModel * typeModel1 = [[CloudOrderPayWayTypeModel alloc] init];
    typeModel1.sectionTitle = DPLocalizedString(@"PackageInformation");
    
    CloudOrderModel * nameModel = [[CloudOrderModel alloc] init];
    nameModel.leftTitleStr = DPLocalizedString(@"PackageNameInfo");
    //    nameModel.rightTitleStr = [NSString stringWithFormat:@"暂时未定"];
    nameModel.rightTitleStr = [CloudServiceViewModel exchangeTitleStringWithModel:dataModel];
    
    CloudOrderModel * priceModel = [[CloudOrderModel alloc] init];
    priceModel.leftTitleStr = DPLocalizedString(@"PackageUnitPrice");
    priceModel.rightTitleStr = dataModel.currentPriceString;
    
    CloudOrderModel * numberModel = [[CloudOrderModel alloc] init];
    numberModel.leftTitleStr = DPLocalizedString(@"PackageQuantity");
    numberModel.rightTitleStr = @"x1";
    
    CloudOrderModel * combinedModel = [[CloudOrderModel alloc] init];
    combinedModel.leftTitleStr = DPLocalizedString(@"PackageTotalPrice");
    combinedModel.rightTitleStr = dataModel.currentPriceString;
    
    CloudOrderModel * payMoneyModel = [[CloudOrderModel alloc] init];
    payMoneyModel.leftTitleStr = DPLocalizedString(@"PackageNeedToPay");
    payMoneyModel.rightTitleStr = dataModel.currentPriceString;
    payMoneyModel.rightTitleColor = GOS_COLOR_RGB(0xFF640F);
    typeModel1.sectionArr = @[nameModel,priceModel,numberModel,combinedModel,payMoneyModel];
    
    
    CloudOrderPayWayTypeModel * typeModel2 = [[CloudOrderPayWayTypeModel alloc] init];
    typeModel2.sectionTitle = DPLocalizedString(@"PackageChoosePaymentType");
    // 中国  支付宝和微信
    if ([GosLoggedInUserInfo serverArea]==LoginServerChina) {
        
        CloudOrderPayWayModel * wechatPay = [[CloudOrderPayWayModel alloc] init];
        wechatPay.paymentType = GosPaymentTypeWechat;
        wechatPay.iconImg = [UIImage imageNamed:@"icon_wechat"];
        wechatPay.payWayNameStr = DPLocalizedString(@"PaymentTypeWeChat");
        wechatPay.select = YES;
        
        
        CloudOrderPayWayModel * aliPay = [[CloudOrderPayWayModel alloc] init];
        aliPay.paymentType = GosPaymentTypeAlipay;
        aliPay.iconImg = [UIImage imageNamed:@"icon_alipay"];
        aliPay.payWayNameStr = DPLocalizedString(@"PaymentTypeAliPay");
        aliPay.select = NO;
        
        typeModel2.sectionArr = @[wechatPay,aliPay];
    }else{
        CloudOrderPayWayModel * PayPal = [[CloudOrderPayWayModel alloc] init];
        PayPal.paymentType = GosPaymentTypePayPal;
        PayPal.iconImg = [UIImage imageNamed:@"icon_paypal"];
        PayPal.payWayNameStr = DPLocalizedString(@"PaymentTypePayPal");
        PayPal.select = YES;
        typeModel2.sectionArr = @[PayPal];
    }
    return @[typeModel1,typeModel2];
    
}


+ (NSString *)exchangeTitleStringWithModel:(CloudServiceModel *) model{
    return [NSString stringWithFormat:@"%@%@%@%@",model.dataLifeString,DPLocalizedString(@"PackageTypeDays_Time1"),model.serviceLifeString,DPLocalizedString(@"PackageTypeDays_Time2")];
}
#pragma mark - 改变支付方式
+ (void)modifyPayWayWithModel:(CloudOrderPayWayModel *) model
                    payWayArr:(NSArray <CloudOrderPayWayModel *>*) payWayArr
                  paymentType:(GosPaymentType *) paymentType{
    __block GosPaymentType type = *paymentType;
    
    [payWayArr enumerateObjectsUsingBlock:^(CloudOrderPayWayModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.select = NO;
        if ([obj isEqual:model]) {
            obj.select = YES;
            type = obj.paymentType;
        }
    }];
    *paymentType = type;
}
@end
