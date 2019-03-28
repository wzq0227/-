//
//  ScanQRCodeManager.m
//  ULife3.5
//
//  Created by 罗乐 on 2018/9/13.
//  Copyright © 2018年 GosCam. All rights reserved.
//

#import "ScanQRCodeManager.h"
#import "iOSSmartSDK.h"
#import "iOSConfigSDK.h"
#import "GosLoggedInUserInfo.h"
#import "GosDevManager.h"
#import "SVProgressHUD.h"
#import "DeviceAddModel.h"

#import "AddDeviceFirstViewController.h"
//#import "DeviceManagement.h"
//#import "APModeNoVoiceTipVC.h"
//#import "AddDevice4GViewController.h"

@interface ScanQRCodeManager ()<
                                iOSSmartDelegate,
                                iOSConfigSDKDMDelegate
                                >

@property (nonatomic, assign) BOOL isShare;

@property (nonatomic, strong) iOSConfigSDK *configSDK;

@property (nonatomic, strong) NSArray <DevDataModel *>*devListArray;

@property (nonatomic, strong) DeviceAddModel *devAddModel;

@end

@implementation ScanQRCodeManager

- (void)dealloc
{
    GosLog(@"--------- ScanQRCodeManager dealloc ---------");
}

#pragma mark - 扫描二维码
- (void)startScanQrCode {
    [iOSSmartSDK shareSmartSdk].delegate = self;
    [[iOSSmartSDK shareSmartSdk] scanQrCodeWithShowType:ScaneQRVCShow_push autoDismiss:NO];
}

#pragma mark -- iOSSmartDelegate 解析二维码获取结果
- (void)scanResult:(BOOL)isSuccess
          deviceId:(NSString *)devId
          areaType:(DevAreaType)areaType
        deviceType:(DevType)devType
   supportAddStyle:(NSArray <NSNumber *>*)styleList
       forceUnBind:(BOOL)isSupport{
    if (NO == isSuccess)
    {
        GosLog(@"扫码 添加扫码失败：deviceId = %@, deviceType = %ld", devId, (long)devType);
        [SVProgressHUD showErrorWithStatus:DPLocalizedString(@"AddDEV_ScanError")];
        [self backToLastViewController];
    }
    else
    {
        GosLog(@"扫码 添加扫码成功：deviceId = %@, deviceType = %ld smartStyle=%@", devId, (long)devType,styleList);
        if (areaType == DevArea_domestic && [GosLoggedInUserInfo serverArea] != LoginServerChina)  // 国内设备
        {
            [SVProgressHUD showErrorWithStatus:DPLocalizedString(@"AddDEV_NotSuppotEN")];
            [self backToLastViewController];
            return;
        }
        else if (areaType == DevArea_overseas && [GosLoggedInUserInfo serverArea] == LoginServerChina) // 国外设备
        {
            [SVProgressHUD showErrorWithStatus:DPLocalizedString(@"AddDEV_NotSuppotCN")];
            [self backToLastViewController];
            return;
        }
        
        self.devAddModel.devId = devId;
        self.devAddModel.addStyleList = styleList;
        self.devAddModel.devType = (NSInteger)devType;
        self.devAddModel.devName = [self getDeviceName];
        self.devAddModel.account = [GosLoggedInUserInfo account];
        self.devAddModel.isHaveForceBind = isSupport;
        
        [SVProgressHUD showWithStatus:DPLocalizedString(@"SVPLoading")];
        if (styleList.count == 1 && styleList[0].integerValue == SupportAdd_share) {
            //如果是好友分享，直接添加好友分享
            [self AddSharefindDevciceState];
        }
        else {
            [self findDevciceState];
        }
    }
}

#pragma mark - 获取设备默认名称
- (NSString *)getDeviceName
{
    NSString *devName;
    BOOL isHaveCamera=NO;
    NSMutableArray * MaxArr =  [[NSMutableArray alloc]init];
    for ( DevDataModel  * md  in self.devListArray ) {
        if (md.DeviceName.length>6) {
            NSString * str =[md.DeviceName  substringToIndex:6];
            GosLog(@"前面 6 位  ：%@",str);
            if ([str isEqualToString:DPLocalizedString(@"AddDEV_DEVName")]) {
                NSString * numberStr = [md.DeviceName substringFromIndex:6];
                GosLog(@"后面的 %@",numberStr);
                numberStr = [NSString stringWithFormat:@"%d",[numberStr intValue]];
                
                if ([self deptNumInputShouldNumber:numberStr]){
                    [MaxArr addObject:numberStr];
                }
            }
        }
        else if (md.DeviceName.length == 6){
            if ([md.DeviceName isEqualToString:DPLocalizedString(@"AddDEV_DEVName")]) {
                isHaveCamera=YES;
            }
        }
    }
    NSArray *result = [MaxArr sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        
//        GosLog(@"%@~%@",obj1,obj2);
        NSNumber *num1,*num2;
        num1 = [NSNumber numberWithInteger:[(NSString *)obj1 intValue]];
        num2 = [NSNumber numberWithInteger:[(NSString *)obj2 intValue]];
        // 因为数组元素是字符串，比较大小的话会有问题比如 字符串9会比字符串11大
        // 之前添加的时候用正则判断了是否是0~9的字符串，所以这里直接转为NSNumber即可比较
        // 后续使用数组中最后一个数字，即最大值，所以使用升序排序
        return [num1 compare:num2];
        
    }];
    
//    GosLog(@"result=%@",result);
    if (result.count==0){
        if (isHaveCamera ) {
            devName = [NSString stringWithFormat:@"%@1",DPLocalizedString(@"AddDEV_DEVName")];;
        }
        else{
            devName = DPLocalizedString(@"AddDEV_DEVName");
        }
    }
    else{
        devName = [NSString stringWithFormat:@"%@%d",DPLocalizedString(@"AddDEV_DEVName"),[result[result.count-1] intValue]+1];
    }
    return devName;
}

- (BOOL) deptNumInputShouldNumber:(NSString *)str   //判断是否为数字组成
{
    NSString *regex = @"[0-9]*";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
    if ([pred evaluateWithObject:str]) {
        return YES;
    }
    return NO;
}

#pragma mark - 从CBS查询设备是否被绑定
#pragma mark --普通添加
-(void)findDevciceState
{
    self.isShare = NO;
    [self queryDeviecBindStatus];
}

#pragma mark -- 好友分享
-(void)AddSharefindDevciceState
{
    self.isShare = YES;
    [self queryDeviecBindStatus];
}

#pragma mark -- 查询设备绑定状态
- (void)queryDeviecBindStatus{
    [self.configSDK queryBindWithDeviceId:self.devAddModel.devId account:self.devAddModel.account];
}

#pragma mark -- iOSConfigSDKDMDelegate 查询设备绑定状态回调
- (void)queryBind:(BOOL)isSuccess
         deviceId:(NSString *)devId
           status:(DevBindStatus)bStatus
        errorCode:(int)eCode {
    
    if (isSuccess) {
        
        self.devAddModel.bStatus = bStatus;
        
        switch (bStatus)
        {
            case DevBind_no:   // 未绑定IROUTER_DEVICE_BIND_NOEXIST
            {
                dispatch_async(dispatch_get_main_queue(),^{
                    if (self.isShare) {
                        [SVProgressHUD showErrorWithStatus:DPLocalizedString(@"AddDEV_NotSupportScan")];
                        [self backToLastViewController];
                    } else {
                        [SVProgressHUD dismissWithDelay:1];
                        [self nextWithDeviceID:devId];
                    }
                });
            } break;
                
            case DevBind_owner:    // 已被本账号以拥有方式绑定 IROUTER_DEVICE_BIND_DUPLICATED
            {
                dispatch_async(dispatch_get_main_queue(),^{
                    [SVProgressHUD showErrorWithStatus:DPLocalizedString(@"AddDEV_BindDuplicated")];
                    [self backToLastViewController];
                });
            } break;
                
            case DevBind_shared:    // 已被本账号以分享方式绑定
            {
                dispatch_async(dispatch_get_main_queue(),^{
                    [SVProgressHUD showErrorWithStatus:DPLocalizedString(@"AddDEV_BindDuplicated_share")];
                    [self backToLastViewController];
                });
            } break;
                
            case DevBind_binded:     // 被其他账号绑定 IROUTER_DEVICE_BIND_INUSE
            {
                dispatch_async(dispatch_get_main_queue(),^{
                    if (self.isShare) {
                        [SVProgressHUD dismiss];
                        [self addFriendShareNext];
                    } else {
                        if (self.devAddModel.isHaveForceBind) {//支持硬解绑 --直接跳转
                            [self nextWithDeviceID:devId];
                            [SVProgressHUD dismiss];
                        } else {
                            [SVProgressHUD showErrorWithStatus:DPLocalizedString(@"AddDEV_BindByOther")];
                            [self backToLastViewController];
                        }
                    }
                });
            } break;
                
            case DevBind_notExist:    // 设备不存在 IROUTER_DEVICE_BIND_INUSE
            {
                dispatch_async(dispatch_get_main_queue(),^{
                    [SVProgressHUD showErrorWithStatus:DPLocalizedString(@"AddDEV_DEVNotExit")];
                    [self backToLastViewController];
                });
            } break;
                
            default:
                dispatch_async(dispatch_get_main_queue(),^{
                    [SVProgressHUD showErrorWithStatus:DPLocalizedString(@"AddDEV_NetTimeOut")];
                    [self backToLastViewController];
                });
                break;
        }
    } else {
        dispatch_async(dispatch_get_main_queue(),^{
            [SVProgressHUD showErrorWithStatus:DPLocalizedString(@"AddDEV_NetTimeOut")];
            [self backToLastViewController];
        });
    }
}

#pragma mark - 分享添加绑定
- (void)addFriendShareNext{
    DevDataModel *devModel = [[DevDataModel alloc] init];
    devModel.DeviceId = self.devAddModel.devId;
    devModel.DeviceName = self.devAddModel.devName;
    devModel.DeviceType = self.devAddModel.devType;
    devModel.DeviceOwner = DevOwn_share;
    [self.configSDK bindDevice:devModel toAccount:[GosLoggedInUserInfo account]];
}

#pragma mark -- iOSConfigSDKDMDelegate 分享添加绑定回调
- (void)bind:(BOOL)isSuccess
    deviceId:(NSString *)devId
   errorCode:(int)eCode {
    if (isSuccess) {
        dispatch_async(dispatch_get_main_queue(), ^{
//            NSNotification *notification =[NSNotification notificationWithName:REFRESH_DEV_LIST_NOTIFY object:nil];
//            [[NSNotificationCenter defaultCenter] postNotification:notification];
            
            [UIView animateWithDuration:0.1 animations:^{
                [SVProgressHUD showSuccessWithStatus:DPLocalizedString(@"AddDEV_AddSuccess")];
            } completion:^(BOOL finished) {
                [self backToLastViewController];
            }];
        });
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD showErrorWithStatus:DPLocalizedString(@"AddDEV_AddFailed")];
            [self backToLastViewController];
        });
    }
}


#pragma mark - 页面跳转
#pragma mark -- 返回上一个页面
- (void)backToLastViewController {
    dispatch_async(dispatch_get_main_queue(), ^{
//        [self.navigationController popViewControllerAnimated:YES];
        [[iOSSmartSDK shareSmartSdk] removeScanVC];
    });
}
#pragma mark  -- 跳转设备添加第一个页面
- (void)nextWithDeviceID:(NSString *)deviceID {
    
//    DevDataModel *model = [DevDataModel new];
//    model.DeviceId         = deviceID;
//    model.DeviceName       = self.deviceName;
//    model.DeviceType       = (NSInteger)self.devType;
//    model.DeviceOwner      = DevOwn_owner;
    //        model.smartStyle       = smartStyle;//16
    //        model.isHasEnthnet     = self.isHasEnthnet;
    //        model.isHasForceBind = self.isHaveForceBind;
    //        model.BindStatus       = self.BindStatus;
    
    //    if (smartStyle == SmartConnect18) {
    //         AddDevice4GViewController *vc = [[AddDevice4GViewController alloc] init];
    //        vc.devModel = model;
    //        [self.navigationController pushViewController:vc animated:YES];
    //    } else {
            AddDeviceFirstViewController * vc = [[AddDeviceFirstViewController alloc]init];
            vc.devModel= self.devAddModel;
            [self.navigationController pushViewController:vc animated:NO];
    //    }
    //移除二维码扫描viewController
    NSMutableArray *tempArr = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
    [tempArr removeObjectAtIndex:tempArr.count-2];//倒数第二个为二维码扫描viewController
    [self.navigationController setViewControllers:tempArr];
}

#pragma mark - lazy load
- (iOSConfigSDK *)configSDK {
    if (!_configSDK) {
        _configSDK = [iOSConfigSDK shareCofigSdk];
        _configSDK.dmDelegate = self;
    }
    return _configSDK;
}

- (NSArray<DevDataModel *> *) devListArray {
    if (!_devListArray) {
        _devListArray = [GosDevManager deviceList];
    }
    return _devListArray;
}

- (DeviceAddModel *)devAddModel {
    if (!_devAddModel) {
        _devAddModel = [[DeviceAddModel alloc] init];
    }
    return _devAddModel;
}

@end
