//
//  SetDevNameAlertManager.m
//  Goscom
//
//  Created by 罗乐 on 2019/1/3.
//  Copyright © 2019 goscam. All rights reserved.
//

#import "SetDevNameAlertManager.h"
//#import "DeviceAddModel.h"
#import "LMJDropdownMenu.h"
#import "iOSConfigSDK.h"

@interface SetDevNameAlertManager () <
                                     UITextFieldDelegate,
                                     LMJDropdownMenuDelegate,
                                     iOSConfigSDKParamDelegate
                                     >
/** 设备添加成功后修改设备名称相关控件 */
@property (nonatomic, strong) UITextField *textField;

@property (nonatomic, strong) LMJDropdownMenu *menu;

@property (nonatomic, strong) UIAlertController *alert;

@property (nonatomic, strong) NSArray <NSString *> *titleArr;

@property (nonatomic, strong) iOSConfigSDK *configSDK;

@end

@implementation SetDevNameAlertManager

#pragma mark - 弹出设备添加成功后设备命名alert
- (void)showRenameAlertWithViewController:(UIViewController *)vc{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:DPLocalizedString(@"AddDEV_AddSuccess")
                                                                   message:DPLocalizedString(@"AddDEV_SetNameTip")
                                                            preferredStyle:UIAlertControllerStyleAlert];
    GOS_WEAK_SELF
    UIAlertAction* okAction = [UIAlertAction actionWithTitle:DPLocalizedString(@"AddDEV_Confirm")
                                                       style:UIAlertActionStyleDefault
         handler:^(UIAlertAction * action) {
             GOS_STRONG_SELF
             [strongSelf removeNotification];
             
             NSString *name;
             for(UITextField *text in strongSelf.alert.textFields){
                 GosLog(@"deviceName = %@", text.text);
                 name = [text.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
             }
             
             strongSelf.alert = nil;
             
             if (name.length <= 0) {
                 dispatch_async(dispatch_get_main_queue(), ^{
                     [SVProgressHUD showErrorWithStatus:DPLocalizedString(@"AddDEV_NameNullTip")];
                 });
                 strongSelf.deviceModel = nil;
                 return ;
             }
             
//             NSArray *deviceArray = [[DeviceManagement sharedInstance] deviceListArray];
//
//             for (DeviceDataModel *model in deviceArray) {
//                 if ([name isEqualToString:model.DeviceName]
//                     && ![strongSelf.deviceModel.DeviceId isEqualToString:model.DeviceId]) {
//                     [SVProgressHUD showErrorWithStatus:DPLocalizedString(@"AddDEV_NameReUse")];
//                     strongSelf.deviceModel = nil;
//                     return;
//                 }
//             }
//             strongSelf.resultBlock(YES);
             [strongSelf.configSDK modifyDevName:name
                                      streamUser:@"admin"
                                  streamPassword:@"goscam123"
                                       withDevId:[NSString stringWithString:strongSelf.deviceModel.DeviceId]];
         }];
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        GOS_STRONG_SELF
        textField.placeholder = DPLocalizedString(@"AddDEV_InputNameTip");
        textField.text = strongSelf.deviceModel.DeviceName;
        textField.delegate = strongSelf;
        
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        [btn setImage:[UIImage imageNamed:@"addDev_arrow_down"] forState:UIControlStateNormal];
        [btn addTarget:strongSelf action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
        [textField setRightView:btn];
        strongSelf.textField = textField;
        strongSelf.textField.rightViewMode = UITextFieldViewModeAlways;
    }];
    
    [alert addAction:okAction];
    
    self.alert = alert;
    [self addNotification];
    [vc presentViewController:alert animated:YES completion:nil];
}

#pragma mark - iOSConfigSDKParamDelegate
- (void)modifyDevAttr:(BOOL)isSuccess
             deviceId:(NSString *)devId {
    self.resultBlock(isSuccess);
}

#pragma mark - 下拉菜单按钮Action
- (void)btnAction:(UIButton *)btn {
    if (self.menu == nil) {
        CGRect frame = [self.textField convertRect:self.textField.bounds toView:self.alert.view];
        frame.origin.y += frame.size.height;
        frame.size.height = 1;
        self.menu = [[LMJDropdownMenu alloc] initWithFrame:frame];
        [self.alert.view addSubview:self.menu];
        [self.menu setMenuTitles:self.titleArr rowHeight:30];
        self.menu.isNeedShowDropMenuAfterInit = YES;
        self.menu.delegate = self;
        btn.selected = YES;
        return;
    }
    [self.menu changeMenuStatus];
    
}

#pragma mark - LMJDropdownMenuDelegate
- (void)dropdownMenu:(LMJDropdownMenu *)menu selectedCellNumber:(NSInteger)number {
    self.textField.text = DPLocalizedString(self.titleArr[number]);
}

- (void)dropdownMenuWillShow:(LMJDropdownMenu *)menu {
    CGRect bounds = self.alert.view.subviews[0].bounds;
    bounds.size.height += 30 * (self.titleArr.count - 2);
    self.alert.view.bounds = bounds;
    UIButton *btn = (UIButton *)self.textField.rightView;
    [btn setImage:[UIImage imageNamed:@"addDev_arrow_up"] forState:UIControlStateNormal];
}

- (void)dropdownMenuWillHidden:(LMJDropdownMenu *)menu {
    CGRect bounds = self.alert.view.subviews[0].bounds;
    self.alert.view.bounds = bounds;
    UIButton *btn = (UIButton *)self.textField.rightView;
    [btn setImage:[UIImage imageNamed:@"addDev_arrow_down"] forState:UIControlStateNormal];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    [self.menu hideDropDown];
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    [self.menu hideDropDown];
    return YES;
}

#pragma mark - 键盘监听
- (void)addNotification {
    // 添加键盘修改输入法监听
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(inputModeDidChange:) name:UITextInputCurrentInputModeDidChangeNotification object:nil];
}

- (void)removeNotification {
    // 移除键盘修改输入法监听
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextInputCurrentInputModeDidChangeNotification object:nil];
}

- (void)inputModeDidChange:(NSNotification*) notification {
    [self.menu hideDropDown];
}

#pragma mark - 懒加载
- (NSArray<NSString *> *)titleArr {
    if (_titleArr == nil) {
        _titleArr = @[ DPLocalizedString(@"DeviceName_Default_LivingRoom"),
                       DPLocalizedString(@"DeviceName_Default_Bedroom"),
                       DPLocalizedString(@"DeviceName_Default_BabysRoom"),
                       DPLocalizedString(@"DeviceName_Default_Gate"),
                       DPLocalizedString(@"DeviceName_Default_Garage"),
                       DPLocalizedString(@"DeviceName_Default_Office")
                       ];
    }
    return _titleArr;
}

- (iOSConfigSDK *)configSDK {
    if (!_configSDK) {
        _configSDK = [iOSConfigSDK shareCofigSdk];
        _configSDK.paramDelegate = self;
    }
    return _configSDK;
}
@end
