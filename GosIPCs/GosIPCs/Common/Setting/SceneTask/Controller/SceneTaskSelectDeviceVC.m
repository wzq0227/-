//  SceneTaskSelectDeviceVC.m
//  Goscom
//
//  Create by 匡匡 on 2018/12/29.
//  Copyright © 2018 goscam. All rights reserved.

#import "SceneTaskSelectDeviceVC.h"
#import "SceneTaskSelectDeviceCell.h"
#import "UIScrollView+EmptyDataSet.h"
#import "iOSConfigSDK.h"
#import "SceneTaskViewModel.h"
#import "UIViewController+CommonExtension.h"

@interface SceneTaskSelectDeviceVC ()
<DZNEmptyDataSetSource,
DZNEmptyDataSetDelegate,
UITableViewDataSource,
UITableViewDelegate,
iOSConfigSDKIOTDelegate>
@property (weak, nonatomic) IBOutlet UITableView *selectTableView;
/// sdk
@property (nonatomic, strong) iOSConfigSDK * configSdk;
/// 模型数据
@property (nonatomic, strong) NSArray<SceneTaskModel *>* dataArr;
@end

@implementation SceneTaskSelectDeviceVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configData];
    [self configUI];
    
}
- (void)configUI{
    self.title = DPLocalizedString(@"Setting_SelectSensor");
    self.selectTableView.bounces = NO;
    self.selectTableView.emptyDataSetSource = self;
    self.selectTableView.emptyDataSetDelegate = self;
    self.selectTableView.tableFooterView = [UIView new];
    self.selectTableView.backgroundColor = GOS_VC_BG_COLOR;
    [self configRightBtnTitle:DPLocalizedString(@"GosComm_Done") titleFont:nil titleColor:nil];
}
- (void)configData{
    /// 请求服务器列表
    [GosHUD showProcessHUDWithStatus:DPLocalizedString(@"SVPLoading")];
    [self.configSdk reqIotSensorListOfDevice:self.devModel.DeviceId onAccount:[GosLoggedInUserInfo account]];
}
#pragma mark - 请求 IOT-传感器列表结果回调(服务器端)
- (void)reqIot:(BOOL)isSuccess
    sensorList:(NSArray<IotSensorModel *>*)sList
      deviceId:(NSString *)devId
     errorCode:(int)eCode{
    [GosHUD dismiss];
    if (isSuccess) {
        self.dataArr = [SceneTaskViewModel handleSceneTask:sList iotSceneTask:self.dataModel isTask:self.isTask];
        [self refreshTableView];
    }else{
        [GosHUD showScreenfulHUDErrorWithStatus:DPLocalizedString(@"GosComm_getData_fail")];
    }
}
- (void)rightBtnClicked{
    NSArray * dataArr = [SceneTaskViewModel handleDoneSelectIOT:self.dataArr];
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectSceneTaskIotModel:isTask:)]){
        [self.delegate didSelectSceneTaskIotModel:dataArr isTask:self.isTask];
    }
    GOS_WEAK_SELF;
    dispatch_async(dispatch_get_main_queue(), ^{
        
        GOS_STRONG_SELF;
        [strongSelf.navigationController popViewControllerAnimated:YES];
    });
}
- (void)refreshTableView{
    GOS_WEAK_SELF;
    dispatch_async(dispatch_get_main_queue(), ^{
        
        GOS_STRONG_SELF;
        [strongSelf.selectTableView reloadData];
    });
}
#pragma mark - tableview&delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    SceneTaskModel * model = self.dataArr[indexPath.row];
    [SceneTaskViewModel handleSelectTask:model tableArr:self.dataArr];
    [self refreshTableView];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArr.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [SceneTaskSelectDeviceCell cellWithTableView:tableView cellModel:self.dataArr[indexPath.row]];
}
#pragma mark - emptyDataDelegate
- (UIImage *)imageForEmptyDataSet:(UIScrollView *)scrollView {
    return [UIImage imageNamed:@"img_blankpage_camera"];
}
- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView {
    NSString * title = DPLocalizedString(@"Setting_HaveNoCarryout");
    NSDictionary *attributes = @{
                                 NSFontAttributeName:[UIFont systemFontOfSize:18.0f],
                                 NSForegroundColorAttributeName:GOS_COLOR_RGBA(198, 198, 198, 1)
                                 };
    return [[NSAttributedString alloc] initWithString:title attributes:attributes];
}


#pragma mark - lazy
- (iOSConfigSDK *)configSdk{
    if (!_configSdk) {
        _configSdk = [iOSConfigSDK shareCofigSdk];
        _configSdk.iotDelegate = self;
    }
    return _configSdk;
}

@end
