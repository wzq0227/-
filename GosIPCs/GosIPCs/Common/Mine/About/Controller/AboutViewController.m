//  AboutViewController.m
//  GosIPCs
//
//  Create by daniel.hu on 2018/11/20.
//  Copyright © 2018年 goscam. All rights reserved.

#import "AboutViewController.h"
#import "UIViewController+NavigationEdgeLayout.h"
#import "SimilarCellButton.h"
#import "MineWebViewController.h"

@interface AboutViewController ()
/// 图标
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
/// 应用名
@property (weak, nonatomic) IBOutlet UILabel *appNameLabel;
/// 版本号
@property (weak, nonatomic) IBOutlet UILabel *appVersionLabel;
/// 用户协议
@property (weak, nonatomic) IBOutlet SimilarCellButton *aggreementButton;

@end

@implementation AboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self config];

}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // 调整显示
    [self adjustDisplay];
    
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    // 恢复调整显示
    [self resumeAdjustDisplay];
}
#pragma mark - config method
/// 配置控件显示
- (void)config {
    
    // 标题
    self.title = DPLocalizedString(@"Mine_About");
    // icon
    self.iconImageView.image = GOS_IMAGE(@"icon_logo");
    // app名
    self.appNameLabel.font = GOS_FONT(16);
    self.appNameLabel.text = [GOS_INFO_DICTIONARY objectForKey:@"CFBundleName"];
    // 版本号
    self.appVersionLabel.font = GOS_FONT(14);
    self.appVersionLabel.text = [NSString stringWithFormat:@"%@: %@", DPLocalizedString(@"Mine_Version"), [GOS_INFO_DICTIONARY objectForKey:@"CFBundleShortVersionString"]];
    // 用户协议
    self.aggreementButton.titleString = DPLocalizedString(@"Mine_UserAgreement");
    
}

- (IBAction)aggreementButtonDidClick:(id)sender {
    // 跳转网页
    [self.navigationController pushViewController:[[MineWebViewController alloc] initWithMineWebDestination:MineWebDestinationUserAgreement] animated:YES];
}

@end
