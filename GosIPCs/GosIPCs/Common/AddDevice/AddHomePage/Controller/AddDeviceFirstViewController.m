//
//  AddDeviceFirstViewController.m
//  ULife3.5
//
//  Created by 罗乐 on 2018/9/13.
//  Copyright © 2018年 GosCam. All rights reserved.
//

#import "AddDeviceFirstViewController.h"
#import "DeviceAddtionMethodTableViewCell.h"
#import "AddDeviceWiFiSettingViewController.h"
#import "AdddeviceLanConfigViewController.h"
#import "UIColor+GosColor.h"
#import "UIImageView+DeviceGIF.h"
//#import "APModeConfigTipsVC.h"
//#import "WringConfigureViewController.h"
//#import "UISettingManagement.h"
//#import "AddDeviceLANTipViewController.h"

@interface AddDeviceFirstViewController ()

@property (weak, nonatomic) IBOutlet UIView *selectDeviceAddtionMethodView;
@property (weak, nonatomic) IBOutlet UIImageView *deviceGIFImageView;
@property (weak, nonatomic) IBOutlet UIImageView *deviceDefaultImageView;
@property (weak, nonatomic) IBOutlet UILabel *tipOneLabel;
@property (weak, nonatomic) IBOutlet UILabel *tipTwoLabel;
@property (weak, nonatomic) IBOutlet UILabel *currentAddMethodLabel;
@property (weak, nonatomic) IBOutlet UIButton *nextBtn;

@property (nonatomic, strong) DeviceAddtionMethodTableViewCell *cell;


@end

@implementation AddDeviceFirstViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor gosGrayColor];
    [self initSubViews];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.cell) {
        [self setCellBackgroundColor];
    }
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self setSubviewsLayout];
}

#pragma mark - 控件相关
- (void)initSubViews {
    //设置控件显示文字
    self.title = DPLocalizedString(@"AddDEV_title");
    self.tipOneLabel.text = DPLocalizedString(@"AddDEV_tipOne");
    self.tipTwoLabel.text = DPLocalizedString(@"AddDEV_tipTwo");
    self.currentAddMethodLabel.text = DPLocalizedString(@"AddDEV_currentAddMethod");
    [self.nextBtn setTitle:DPLocalizedString(@"AddDEV_lightQuickFlash") forState:UIControlStateNormal];
    
    //添加当前选择添加方式cell
    if (self.devModel.addStyleList.count > 0) {
        self.cell = [[[NSBundle mainBundle] loadNibNamed:@"DeviceAddtionMethodTableViewCell" owner:self options:nil] objectAtIndex:0];
        NSNumber *addTypeNum = self.devModel.addStyleList[0];
        self.cell.addType = addTypeNum.integerValue;
        self.cell.isArrowHidden = YES;
        [self.selectDeviceAddtionMethodView insertSubview:self.cell atIndex:0];
//        [self.selectDeviceAddtionMethodView addSubview:self.cell];
    }
    
    //添加navigation右侧按钮
    [self addRightNavigationItem];
    
    //设置显示的gif图
    [self setDeviceGif];
}

#pragma mark -- 设置设备gif图
- (void)setDeviceGif {
    
    if ([self.deviceGIFImageView playGIFWithDeviceID:self.devModel.devId]) {
        self.deviceDefaultImageView.hidden = YES;
        self.deviceGIFImageView.hidden = NO;
    } else {
        self.deviceDefaultImageView.image = [UIImage imageNamed:@"addev_ScanDeiveQrCode.png"];
        self.deviceDefaultImageView.hidden = NO;
        self.deviceGIFImageView.hidden = YES;
    }
}

#pragma mark -- 添加右侧Item
- (void)addRightNavigationItem
{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.titleLabel.numberOfLines = 1;
    [btn.titleLabel setFont:[UIFont systemFontOfSize:13]];
    btn.titleLabel.adjustsFontSizeToFitWidth = YES;
    btn.titleLabel.minimumScaleFactor = 0.1;
    btn.titleLabel.textAlignment = NSTextAlignmentRight;
//    btn.bounds = CGRectMake(0, 0, 60, 40);
    [btn setTitle:DPLocalizedString(@"AddDEV_otherAddMethod") forState:UIControlStateNormal];
    [btn addTarget:self
                   action:@selector(goChooseAddMethodBtnAction:)
         forControlEvents:UIControlEventTouchUpInside];
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 44)];
    btn.frame = contentView.bounds;
    [contentView addSubview:btn];
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:contentView];
    
    NSString *version= [UIDevice currentDevice].systemVersion;
    if(version.doubleValue < 11.0) {
        UIBarButtonItem * spaceItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        spaceItem.width = -16;//这个值可以根据自己需要自己调整
        self.navigationItem.rightBarButtonItems = @[item,spaceItem];
    } else {
        self.navigationItem.rightBarButtonItem = item;
    }
}

- (void)setCellBackgroundColor {
    switch (self.cell.addType) {
        case SupportAdd_wifi:{
            self.selectDeviceAddtionMethodView.backgroundColor = GOS_COLOR_RGB(0xE8F7FE);
        }
            break;
        case SupportAdd_scan:{
            self.selectDeviceAddtionMethodView.backgroundColor = GOS_COLOR_RGB(0xF3FEF5);
        }
            break;
        case SupportAdd_apMode:
        case SupportAdd_apNew :{ //新版ap添加兼容旧版ap添加
            self.selectDeviceAddtionMethodView.backgroundColor = GOS_COLOR_RGB(0xFEF3FA);
        }
            break;
        case SupportAdd_wlan:{
            self.selectDeviceAddtionMethodView.backgroundColor = GOS_COLOR_RGB(0xFEF9F3);
        }
            break;
        default:
            break;
    }
}

- (void)setSubviewsLayout {
    if (self.cell) {
        self.cell.isNeedResetFrame = NO;
        self.cell.frame = self.selectDeviceAddtionMethodView.bounds;
        self.cell.backgroundColor = [UIColor clearColor];
        self.cell.contentView.backgroundColor = [UIColor clearColor];
    }
    
    self.selectDeviceAddtionMethodView.layer.cornerRadius = self.selectDeviceAddtionMethodView.frame.size.height * 0.1f;
    self.nextBtn.backgroundColor = GOSCOM_THEME_START_COLOR;
    self.nextBtn.titleLabel.minimumScaleFactor = 0.1;
    self.nextBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.nextBtn.layer.cornerRadius = self.nextBtn.bounds.size.height / 2.f;
    
    NSString *version= [UIDevice currentDevice].systemVersion;
    if(version.doubleValue >= 11.0) {
        UINavigationItem * item= self.navigationItem;
        NSArray * array = item.rightBarButtonItems;
        if (array && array.count!=0){
            //这里需要注意,你设置的第一个leftBarButtonItem的customeView不能是空的,也就是不要设置UIBarButtonSystemItemFixedSpace这种风格的item
            UIBarButtonItem * buttonItem=array[0];
            UIView * view = [[[buttonItem.customView superview] superview] superview];
            NSArray * arrayConstraint = view.constraints;
            for (NSLayoutConstraint * constant in arrayConstraint) {
                if (fabs(constant.constant)==16) {
                    constant.constant=0;
                }
            }
        }
    }
}
#pragma mark - btnAction
//MARK:取消选择添加方法按钮点击功能，改为使用右上角navigationBtn点击，如果需要重新启用该功能，在xib中连接下面的三个方法
- (IBAction)goChooseAddMethodBtnTouchDowm:(UIButton *)sender {
    self.selectDeviceAddtionMethodView.backgroundColor = GOS_COLOR_RGB(0xDCDDDD);
}

- (IBAction)goChooseAddMethodBtnTouchUpOutside:(UIButton *)sender {
    self.selectDeviceAddtionMethodView.backgroundColor = [UIColor whiteColor];
}

- (ChooseAddMethodViewController *)getChooseAddMethodViewController {
    ChooseAddMethodViewController *vc = [[ChooseAddMethodViewController alloc] init];
    vc.addMethodArr = self.devModel.addStyleList;
    vc.resultBlock = ^(SupportAddStyle addType) {
        self.cell.addType = addType;
    };
    return vc;
}

- (IBAction)goChooseAddMethodBtnAction:(UIButton *)sender {
    self.selectDeviceAddtionMethodView.backgroundColor = [UIColor whiteColor];
    ChooseAddMethodViewController * vc = [self getChooseAddMethodViewController];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)nextBtnAction:(id)sender {
    switch (self.cell.addType) {
        case SupportAdd_wifi:{
            AddDeviceWiFiSettingViewController *vc = [[AddDeviceWiFiSettingViewController alloc] init];
            vc.devModel = self.devModel;
            vc.addMethodType = SupportAdd_wifi;
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case SupportAdd_scan:{
            AddDeviceWiFiSettingViewController *vc = [[AddDeviceWiFiSettingViewController alloc] init];
            vc.devModel = self.devModel;
            vc.addMethodType = SupportAdd_scan;
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case SupportAdd_apMode:
        case SupportAdd_apNew :{ //新版ap添加兼容旧版ap添加
            AddDeviceWiFiSettingViewController *vc = [[AddDeviceWiFiSettingViewController alloc] init];
            vc.devModel = self.devModel;
            vc.addMethodType = SupportAdd_apNew;
            [self.navigationController pushViewController:vc animated:NO];
        }
            break;
        case SupportAdd_wlan:{
            AdddeviceLanConfigViewController *vc = [[AdddeviceLanConfigViewController alloc] init];
            vc.devModel = self.devModel;
            [self.navigationController pushViewController:vc animated:YES];
            
        }
            break;
            
        default:
            break;
    }
}

@end
