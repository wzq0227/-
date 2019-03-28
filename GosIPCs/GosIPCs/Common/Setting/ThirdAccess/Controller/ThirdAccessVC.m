//
//  ThirdAccessVC.m
//  Goscom
//
//  Created by 匡匡 on 2018/11/28.
//  Copyright © 2018 goscam. All rights reserved.
//

#import "ThirdAccessVC.h"
#import "ThirdAccessCell.h"
#import "ThirdAccessModel.h"
#import "ThirdAccessViewModel.h"
#import "iOSConfigSDKModel.h"

@interface ThirdAccessVC ()<UITableViewDelegate,
UITableViewDataSource,
ThirdAccessCellDelegate>

@property (weak, nonatomic) IBOutlet UITableView *thirdTableview;
/// 数据模型
@property (nonatomic, strong) NSArray * dataSourceArr;
///
@property (nonatomic, assign) AccessThirdPartySupport thirdPartySupport;
@end

@implementation ThirdAccessVC
#pragma mark -- lifestyle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self configTitle];
    [self configTable];
    // Do any additional setup after loading the view from its nib.
}

#pragma mark -- config
- (void)configTitle{
    self.title = DPLocalizedString(@"Setting_Alexa");
}
- (void)configTable{
    self.thirdTableview.bounces = NO;
    self.thirdTableview.tableFooterView = [UIView new];
    self.thirdTableview.rowHeight = GOS_SCREEN_W/25.0*16;
    self.thirdTableview.backgroundColor = GOS_VC_BG_COLOR;
}
- (void)setAbilityModel:(AbilityModel *)abilityModel{
    _abilityModel = abilityModel;
    self.thirdPartySupport = abilityModel.hasAlexa;
    self.dataSourceArr = [ThirdAccessViewModel initDataArrWithAbility:self.thirdPartySupport];
    [self refreshUI];
}
#pragma mark -- function
- (void)refreshUI{
    GOS_WEAK_SELF;
    dispatch_async(dispatch_get_main_queue(), ^{
        GOS_STRONG_SELF;
        [strongSelf.thirdTableview reloadData];
    });
}
#pragma mark -- actionFunction
#pragma mark -- delegate
#pragma mark - cell点击代理跳转
- (void)thirdAccessJumpClick:(NSURL *) jumpUrl{
    if ([[UIApplication sharedApplication]canOpenURL:jumpUrl]) {
        [[UIApplication sharedApplication]openURL:jumpUrl];
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [ThirdAccessCell cellWithTableView:tableView indexPath:indexPath cellModel:[self.dataSourceArr objectAtIndex:indexPath.section]delegate:self];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.dataSourceArr.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 20.1f;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 20.1f;
}
- (void)dealloc{
    GosLog(@"----  %s ----", __PRETTY_FUNCTION__);
}
#pragma mark -- lazy
/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
