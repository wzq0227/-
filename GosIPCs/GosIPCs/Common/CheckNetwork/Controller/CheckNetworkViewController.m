//
//  CheckNetworkViewController.m
//  GosIPCs
//
//  Created by shenyuanluo on 2018/11/19.
//  Copyright © 2018 goscam. All rights reserved.
//

#import "CheckNetworkViewController.h"
#import "GosThreadTimer.h"      //  定时器
#import "UIView+GosGradient.h"
#import "CheckNetworkHeadView.h"
#import "CheckNetworkCell.h"
#import "CheckNetworkFootView.h"
#import "FeedbackViewController.h"
#import "iOSConfigSDK.h"
#import "CheckNetResultModel.h"
#import "NetCheckViewModel.h"
#import "MonitorNetwork.h"      //  网络监测
#import "MeasurNetTools.h"      //  网络测速
#import "QBTools.h"
#include <arpa/inet.h>
#include <ifaddrs.h>
#include <net/if.h>
#include <net/if_dl.h>

// 超时时间（单位：秒）
#define  CHECK_Timeout_INTERVAL   10
@interface CheckNetworkViewController ()<UITableViewDelegate,
UITableViewDataSource,
iOSConfigSDKCheckDelegate>
{
    BOOL m_isConfigGradient;        //  渐变色
    NSInteger m_timeout;            //  超时时间
    NSMutableArray *m_dataSourceArr;
    NSMutableArray *m_checkSucceArr;  //  检测成功的个数
    checkNetState m_checkNetstate;    //  网络检测状态
}
/** 视频数据检查定时器 */
//@property (nonatomic, readwrite, strong) GosThreadTimer *netCheckTimer;
/// <#describtion#>
@property (nonatomic, strong) NSTimer * netCheckTimer;

/// tableview
@property (weak, nonatomic) IBOutlet UITableView *netTableView;
/// 皮囊头视图
@property (nonatomic, strong) UIView * tableHeadView;
/// 头视图
@property (nonatomic, strong) CheckNetworkHeadView * headView;
/// 皮囊头视图
@property (nonatomic, strong) UIView * tableFootView;
/// 脚视图
@property (nonatomic, strong) CheckNetworkFootView * footView;
/// SDK
@property (nonatomic, strong) iOSConfigSDK * iOSconfigsdk;
@end
@implementation CheckNetworkViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initParam];
    [self getCurrentNetState];      //  获取当前网络状态
    [self configUI];
//    [self createCheckNetTimer];
    self.iOSconfigsdk = [iOSConfigSDK shareCofigSdk];
    self.iOSconfigsdk.checkDelegate = self;
}
#pragma mark -- 获取当前上行下行速度
- (void)getCurrentNetSpeed{
    GOS_WEAK_SELF;
    MeasurNetTools * meaurNet = [[MeasurNetTools alloc] initWithblock:^(float speed) {
        GOS_STRONG_SELF;
        NSString* speedStr = [NSString stringWithFormat:@"%@/S", [QBTools formattedFileSize:speed]];
        GosLog(@"即使速度%@", speedStr);
        GosLog(@"上行速度%@", [weakSelf getInterfaceBytes]);
        [strongSelf.headView setUploadStr:[strongSelf getInterfaceBytes] downStr:speedStr];
    } finishMeasureBlock:^(float speed) {
        GOS_STRONG_SELF;
        //         NSString* speedStr = [NSString stringWithFormat:@"%@/S", [QBTools formattedFileSize:speed]];
        //        GosLog(@"平均速度为：%@",speedStr);
    } failedBlock:^(NSError *error) {
        
    }];
    [meaurNet startMeasur];
}

- (void)initParam
{
    m_isConfigGradient      = NO;
    m_timeout               = 0;
    m_dataSourceArr = [@[] mutableCopy];
    m_checkSucceArr = [@[] mutableCopy];
    m_checkNetstate = checkNetState_Detecting;
}
- (void) configUI{
    self.title = DPLocalizedString(@"AddDEV_networkCheck");
    self.netTableView.tableHeaderView = self.tableHeadView;
    //    self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
    [self.navigationController.navigationBar setBackgroundColor:GOS_COLOR_RGB(0x68A5FE)];
    self.netTableView.rowHeight = 44.0f;
//    self.automaticallyAdjustsScrollViewInsets = NO;
    self.netTableView.tableFooterView = [UIView new];

}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.navigationController.navigationBar setBackgroundImage:[self createImageWithColor:GOS_COLOR_RGB(0x68A5FE)] forBarMetrics:0];
        UIView *backgroundView = [self.navigationController.navigationBar subviews].firstObject;
        for (UIView *view in backgroundView.subviews) {
            if (CGRectGetHeight([view frame]) <= 1) {
                view.hidden = YES;
            }
        }
    });
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear: animated];
    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:1];
    UIView *backgroundView = [self.navigationController.navigationBar subviews].firstObject;
    for (UIView *view in backgroundView.subviews) {
        if (CGRectGetHeight([view frame]) <= 1) {
            view.hidden = NO;
        }
    }
}
- (UIImage *)createImageWithColor: (UIColor *) color{
    CGRect rect = CGRectMake(0.0f,0.0f,1.0f,1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context =UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *myImage =UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return myImage;
}

- (void)configData{
    [self.iOSconfigsdk queryCBSAddress];
}
#pragma mark -- 创建音视频流检查定时器
- (void)createCheckNetTimer
{
    GOS_WEAK_SELF;
    if (!weakSelf.netCheckTimer) {
        weakSelf.netCheckTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(timeoutAdd) userInfo:nil repeats:YES];
    }
}
- (void)timeoutAdd{
    if (m_timeout++ == CHECK_Timeout_INTERVAL) {
        m_checkNetstate = checkNetState_Fail;
        /// 将当前网络状态给头视图和脚视图
        [self setHeadFootViewState];
        [self removeTimer];
        m_timeout = 0;
    }
}
- (void)removeTimer{
    if (self.netCheckTimer) {
        [_netCheckTimer invalidate];
        _netCheckTimer = nil;
    }
}
- (void)getCurrentNetState{
    CurNetworkStatus netWorkStatus = [MonitorNetwork currentStatus];
    switch (netWorkStatus) {
        case CurNetwork_unknow:{
            m_checkNetstate = checkNetState_Fail;
            /// 将当前网络状态给头视图和脚视图
            [self setHeadFootViewState];
        }break;
        case CurNetwork_2G:
        case CurNetwork_3G:
        case CurNetwork_4G:
        case CurNetwork_wifi:{
            m_checkNetstate = checkNetState_Detecting;
            /// 将当前网络状态给头视图
            [self setHeadViewState];
            [self configData];
            [self getCurrentNetSpeed];
        }
        default:
            break;
    }
}

#pragma mark -- 显示头视图和脚视图
- (void)setHeadFootViewState{
    GOS_WEAK_SELF;
    dispatch_async(dispatch_get_main_queue(), ^{
        GOS_STRONG_SELF;
        [strongSelf.headView setCheckNetState:m_checkNetstate];
        [strongSelf.footView setCheckNetState:m_checkNetstate];
        strongSelf.netTableView.tableFooterView = strongSelf.tableFootView;
    });
}
- (void)setHeadViewState{
    GOS_WEAK_SELF;
    dispatch_async(dispatch_get_main_queue(), ^{
        GOS_STRONG_SELF;
        [strongSelf.headView setCheckNetState:m_checkNetstate];
    });
}
#pragma mark - 网络检测  第一步请求
- (void)configCheckData:(NSArray<ServerAddressInfo*>*) list{
    m_dataSourceArr = [NetCheckViewModel handleTableArr:list];
    GOS_WEAK_SELF;
    [list enumerateObjectsUsingBlock:^(ServerAddressInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        GOS_STRONG_SELF;
        [strongSelf.iOSconfigsdk checkServer:obj isReachable:^(BOOL isReachable) {
            if (isReachable) {
                [m_checkSucceArr addObject:@(YES)];
            }
            [NetCheckViewModel handleCheckState:isReachable withCheckModel:obj withTableArr:m_dataSourceArr];
            [strongSelf refreshTable];
        }];
        
        // 如果到了最后一个了，就去判断诊断结果
        if (idx+1 == m_dataSourceArr.count) {
            [self getCheckResult];
        }
        //        if (stop) {
        //            [self getCheckResult];
        //        }
    }];
}
#pragma mark -- 得到诊断结果
- (void)getCheckResult{
    if (m_checkSucceArr.count == m_dataSourceArr.count) {
        m_checkNetstate = checkNetState_Success;
    }else{
        m_checkNetstate = checkNetState_Fail;
    }
    [self setHeadFootViewState];
}

- (void)refreshTable{
    GOS_WEAK_SELF;
    dispatch_async(dispatch_get_main_queue(), ^{
        GOS_STRONG_SELF;
        [strongSelf.netTableView reloadData];
    });
}

#pragma mark -- 查询 CBS 服务器地址结果回调 第一步回调
- (void)queryCBS:(BOOL)isSuccess
     addressList:(NSArray<ServerAddressInfo*>*)aList{
    if (isSuccess) {
        GosLog(@"成功--成功");
        [self configCheckData:aList];
    }else{
        GosLog(@"成功--失败");
        m_checkNetstate = checkNetState_Fail;
        [self setHeadFootViewState];
    }
}


#pragma mark - 添加渐变色
- (void)viewWillLayoutSubviews
{
    if (NO == m_isConfigGradient)
    {
        self.netTableView.backgroundColor = [UIColor clearColor];
        m_isConfigGradient = YES;
        [self.view gradientStartColor:GOS_COLOR_RGB(0x68A5FE)
                             endColor:GOS_COLOR_RGB(0x51B1FB)
                         cornerRadius:0
                            direction:GosGradientTopToBottom];
        
    }
}
#pragma mark - actionFunction
#pragma mark -- 重新添加或重新检测点击
- (void)addAgainOrRepeat{
    /// 重新添加
    if (m_checkNetstate == checkNetState_Success) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    /// 重新检测
    else if(m_checkNetstate == checkNetState_Fail){
        [m_dataSourceArr removeAllObjects];
//        [self createCheckNetTimer];
        [self getCurrentNetState];
    }
}
#pragma mark -- 意见反馈点击
- (void)feedBack{
    _headView.checkNetState = checkNetState_Fail;
    FeedbackViewController * vc = [[FeedbackViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}
/*获取网络流量信息*/
- (NSString *)getInterfaceBytes {
    struct ifaddrs *ifa_list = 0, *ifa;
    if (getifaddrs(&ifa_list) == -1) {
        return 0;
    }
    uint32_t iBytes = 0;
    uint32_t oBytes = 0;
    for (ifa = ifa_list; ifa; ifa = ifa->ifa_next) {
        if (AF_LINK != ifa->ifa_addr->sa_family)
            continue;
        if (!(ifa->ifa_flags & IFF_UP) && !(ifa->ifa_flags & IFF_RUNNING))
            continue;
        if (ifa->ifa_data == 0)
            continue;
        /* Not a loopback device. */
        if (strncmp(ifa->ifa_name, "lo", 2)) {
            struct if_data *if_data = (struct if_data *)ifa->ifa_data;
            //下行
            iBytes += if_data->ifi_ibytes;
            //上行
            oBytes += if_data->ifi_obytes;
        }
    }
    freeifaddrs(ifa_list);
    return [NSString stringWithFormat:@"%@/S", [QBTools formattedFileSize:oBytes/1024]];
}

#pragma mark - tableView&delegatrer
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return m_dataSourceArr.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    CheckNetResultModel * model = m_dataSourceArr[indexPath.row];
    return [CheckNetworkCell cellWithTableView:tableView indexPath:indexPath cellModel:model];
}
#pragma mark - lifyStyle
//在页面消失的时候就让navigationbar还原样式
//- (void)viewWillDisappear:(BOOL)animated{
//    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
//    [self.navigationController.navigationBar setShadowImage:nil];
//}
//- (void)viewWillAppear:(BOOL)animated {
//    [super viewWillAppear:animated];
//    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
//    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
//}
#pragma mark - lazy
- (UIView *)tableHeadView{
    if (!_tableHeadView) {
        _tableHeadView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, GOS_SCREEN_W, 400)];
        _headView = [[CheckNetworkHeadView alloc] initWithFrame:CGRectMake(0, 0, GOS_SCREEN_W, 400)];
        _headView.checkNetState = checkNetState_Success;
        [_tableHeadView addSubview:_headView];
    }
    return _tableHeadView;
}
- (UIView *)tableFootView{
    if (!_tableFootView) {
        _tableFootView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, GOS_SCREEN_W, 140)];
        _footView = [[CheckNetworkFootView alloc] initWithFrame:CGRectMake(0, 0, GOS_SCREEN_W, 140)];
        _footView.checkNetState = m_checkNetstate;
        [_footView.addAgainBtn addTarget:self action:@selector(addAgainOrRepeat) forControlEvents:UIControlEventTouchUpInside];
        [_footView.feedBackInfoBtn addTarget:self action:@selector(feedBack) forControlEvents:UIControlEventTouchUpInside];
        _footView.loginAgain = self.loginAgain;
        [_tableFootView addSubview:_footView];
    }
    return _tableFootView;
}
- (iOSConfigSDK *)iOSconfigsdk{
    if (!_iOSconfigsdk) {
        _iOSconfigsdk = [iOSConfigSDK shareCofigSdk];
        _iOSconfigsdk.checkDelegate = self;
    }
    return _iOSconfigsdk;
}
@end
