//
//  DeviceInfoNameVC.m
//  Goscom
//
//  Created by 匡匡 on 2018/11/23.
//  Copyright © 2018 goscam. All rights reserved.
//

#import "DeviceInfoNameVC.h"
#import "DeviceInfoCell.h"
#import "TableViewHeadView.h"
#import "iOSConfigSDKModel.h"
#import "UIViewController+CommonExtension.h"
#import "iOSConfigSDK.h"
#import "GosDevManager.h"
#import "DeviceInfoViewModel.h"
@interface DeviceInfoNameVC ()
<UITableViewDelegate,
UITableViewDataSource,
iOSConfigSDKParamDelegate>
@property (nonatomic, strong) NSArray * dataSourceArr;
@property (weak, nonatomic) IBOutlet UILabel *currentNameLab;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITableView *nameTableview;
@property (nonatomic, strong) iOSConfigSDK * configSDK;  

@end

@implementation DeviceInfoNameVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configUI];
    // Do any additional setup after loading the view from its nib.
    [self configTable];
}
#pragma mark -- config
- (void)configUI{
    self.title = DPLocalizedString(@"DevInfo_DevName");
    self.nameTextField.text = self.dataModel.DeviceName;
    [self configRightBtnTitle:DPLocalizedString(@"GosComm_Done") titleFont:nil titleColor:nil];
    self.currentNameLab.text = DPLocalizedString(@"DeviceName_CurrentName");
}

- (void)configTable{
    self.nameTableview.bounces = NO;
    [self.nameTableview registerNib:[UINib nibWithNibName:@"DeviceInfoCell" bundle:nil] forCellReuseIdentifier:@"DeviceInfoCell"];
    self.nameTableview.rowHeight = 50.0f;
    self.nameTableview.tableFooterView = [UIView new];
    self.nameTableview.backgroundColor = GOS_VC_BG_COLOR;
}

#pragma mark -- function
- (void)setDataModel:(DevDataModel *)dataModel{
    _dataModel = dataModel;
}
- (void)rightBtnClicked{
    if ([DeviceInfoViewModel compareNameWithHaveName:self.nameTextField.text]) {
        [self showTipsWithHaveDeviceName];
        return;
    };
    [self.configSDK modifyDevName:self.nameTextField.text streamUser:self.dataModel.StreamUser streamPassword:self.dataModel.StreamPassword withDevId:self.dataModel.DeviceId];
}

#pragma mark - 返回是否已经存在该账户名
- (void)showTipsWithHaveDeviceName{
    //    UIAlertController *alertview=[UIAlertController alertControllerWithTitle:@"" message:DPLocalizedString(@"CameraNameRepeat") preferredStyle:UIAlertControllerStyleAlert];
    //    UIAlertAction * defaultAction = [UIAlertAction actionWithTitle:DPLocalizedString(@"GosComm_Confirm") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    //    }];
    //    [alertview addAction:defaultAction];
    //
    //    dispatch_async(dispatch_get_main_queue(), ^{
    //        [self presentViewController:alertview animated:YES completion:nil];
    //    });
    [SVProgressHUD showErrorWithStatus:DPLocalizedString(@"CameraNameRepeat")];
}

#pragma mark -- actionFunction
#pragma mark - 修改设备属性（昵称、取流账号、取流密码）结果回调
- (void)modifyDevAttr:(BOOL)isSuccess
             deviceId:(NSString *)devId{
    GOS_WEAK_SELF;
    if (isSuccess)
    {
        if (![devId isEqualToString:self.dataModel.DeviceId])
        {
            return;
        }
       
        dispatch_async(dispatch_get_main_queue(), ^{
            
            GOS_STRONG_SELF;
            strongSelf.dataModel.DeviceName = strongSelf.nameTextField.text;
        });
        [GosDevManager updateDevice:self.dataModel];
        GOS_STRONG_SELF;
        if (strongSelf.delegate && [strongSelf.delegate respondsToSelector:@selector(modifyDeviceName:)]) {
            [strongSelf.delegate modifyDeviceName:strongSelf.dataModel];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kModifyDevInfoNotify
                                                                object:nil];
            [strongSelf.navigationController popViewControllerAnimated:YES];
        });
    }else{
        [GosHUD showScreenfulHUDErrorWithStatus:DPLocalizedString(@"ModifyFailure")];
    }
}
#pragma mark -- delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString * deviceName = self.dataSourceArr[indexPath.row];
    if ([DeviceInfoViewModel compareNameWithHaveName:deviceName]) {
        [self showTipsWithHaveDeviceName];
        return;
    }
    self.nameTextField.text = deviceName;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataSourceArr.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    DeviceInfoCell * cell = [tableView dequeueReusableCellWithIdentifier:@"DeviceInfoCell" forIndexPath:indexPath];
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    cell.dataLab.hidden = YES;
    cell.arrowImg.hidden = YES;
    cell.titleLab.text = self.dataSourceArr[indexPath.row];
    return cell;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    TableViewHeadView * headView = [[TableViewHeadView alloc] initWithFrame:CGRectMake(0, 0, GOS_SCREEN_H, 40)];
    [headView setTitleStr:DPLocalizedString(@"DeviceName_DefaultName")];
    return headView;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 40.0f;
}
#pragma mark -- lifestyle
#pragma mark -- lazy
- (NSArray *)dataSourceArr{
    if (!_dataSourceArr) {
        _dataSourceArr = @[DPLocalizedString(@"DeviceName_Default_LivingRoom"),
                           DPLocalizedString(@"DeviceName_Default_Bedroom"),
                           DPLocalizedString(@"DeviceName_Default_BabysRoom"),
                           DPLocalizedString(@"DeviceName_Default_Gate"),
                           DPLocalizedString(@"DeviceName_Default_Garage"),
                           DPLocalizedString(@"DeviceName_Default_Office")];
    }
    return _dataSourceArr;
}
- (iOSConfigSDK *)configSDK{
    if (!_configSDK) {
        _configSDK = [iOSConfigSDK shareCofigSdk];
        _configSDK.paramDelegate = self;
    }
    return _configSDK;
}
-(void)dealloc{
     [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
