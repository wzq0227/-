//
//  WiFiSettingVC.m
//  Goscom
//
//  Created by 匡匡 on 2018/11/29.
//  Copyright © 2018 goscam. All rights reserved.
//

#import "WiFiSettingVC.h"
#import "WiFiSettingOnlineVC.h"     //  已添加在线
#import "WiFiSettingOutLineVC.h"        //  已添加不在线
#import "GosHUDView.h"
#import "iOSConfigSDKModel.h"
@interface WiFiSettingVC ()
@property (weak, nonatomic) IBOutlet UILabel *onlineLab;    //  已添加在线文字
@property (weak, nonatomic) IBOutlet UILabel *outLineLab;   //  已添加不在线文字

@end

@implementation WiFiSettingVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configUI];
    
}
- (void)configUI{
    self.title = DPLocalizedString(@"Setting_WiFiSetting");
    self.onlineLab.text = DPLocalizedString(@"WiFiSetting_DeviceOnLine");
    self.outLineLab.text = DPLocalizedString(@"WiFiSetting_DeviceOffLine");
}

- (IBAction)actionTypeClick:(UIButton *)sender {
    switch (sender.tag) {
        case 10:{
            WiFiSettingOnlineVC * vc = [[WiFiSettingOnlineVC alloc] init];
            vc.dataModel = self.dataModel;
            [self.navigationController pushViewController:vc animated:YES];
        }break;
        case 11:{
            WiFiSettingOutLineVC * vc = [[WiFiSettingOutLineVC alloc] init];
            vc.dataModel = self.dataModel;
            [self.navigationController pushViewController:vc animated:YES];
        }break;
            
        default:
            break;
    }
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
