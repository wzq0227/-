//
//  BabyMusicVC.m
//  Goscom
//
//  Created by 匡匡 on 2018/11/28.
//  Copyright © 2018 goscam. All rights reserved.
//

#import "BabyMusicVC.h"
#import "BabyMusicCell.h"
#import "UIViewController+CommonExtension.h"
#import "iOSConfigSDK.h"
#import "BabyMusicViewModel.h"
#import <AVFoundation/AVFoundation.h>
#import "BabyMusicModel.h"
@interface BabyMusicVC ()<
UITableViewDataSource,
UITableViewDelegate,
AVAudioPlayerDelegate,
iOSConfigSDKParamDelegate>
@property (weak, nonatomic) IBOutlet UITableView *musicTable;
@property (nonatomic, strong) iOSConfigSDK * configSDK;
/// 摇篮曲数组
@property (nonatomic, strong) NSArray * dataSouceArr;
/// audioPlay
@property (nonatomic, strong) AVAudioPlayer * audioPlay;
/// 摇篮曲播放状态
@property (nonatomic, assign) LullabyStatus lullabyStatus;
/// 摇篮曲序号
@property (nonatomic, assign) LullabyNumber lullabyNumber;
/// 是否正在播放音乐
@property (nonatomic, assign) BOOL isPlaying;
/// 选择的摇篮曲
@property (nonatomic, assign) NSInteger selectIndex;
@end

@implementation BabyMusicVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configUI];
    [self configNetData];
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    if ([SVProgressHUD isVisible]) {
        [SVProgressHUD dismiss];
    }
}
#pragma mark - config
- (void)configUI{
    self.title = DPLocalizedString(@"Setting_BabyMusic");
    self.musicTable.rowHeight = 44.0f;
    self.musicTable.tableFooterView = [UIView new];
    self.musicTable.backgroundColor = GOS_VC_BG_COLOR;
    self.musicTable.bounces = NO;
    [self configRightBtnTitle:DPLocalizedString(@"GosComm_Save") titleFont:nil titleColor:nil];
}
- (void)configNetData{
    self.dataSouceArr = [BabyMusicViewModel initDataWithAbility:self.abilityModel];
    [self.musicTable reloadData];
    [GosHUD showProcessHUDWithStatus:DPLocalizedString(@"SVPLoading")];
    [self.configSDK reqLullabyNumWithDevId:self.deviceID];
}
#pragma mark - 请求摇篮曲播放序号、播放状态结果回调
- (void)reqLullaby:(BOOL)isSuccess
            number:(LullabyNumber)lNum
        playStatus:(LullabyStatus)lStatus
          deviceId:(NSString *)devId{
    [GosHUD dismiss];
    if (isSuccess) {
        self.lullabyNumber = lNum;
        self.lullabyStatus = lStatus;
        [self handleRequstData];
    }else{
        GosLog(@"请求数据失败");
        [GosHUD showBottomHUDWithStatus:DPLocalizedString(@"GosComm_getData_fail")];
    }
}
#pragma mark - function
- (void)handleRequstData{
    self.isPlaying = self.lullabyStatus == LullabyStatus_playing?YES:NO;
    self.dataSouceArr = [BabyMusicViewModel modifySelectData:self.dataSouceArr lullabyNumber:self.lullabyNumber];
    [self refreshUI];
}
- (void)refreshUI{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.musicTable reloadData];
    });
}
#pragma mark - 保存点击事件
- (void)rightBtnClicked{
    UIAlertController *alertview=[UIAlertController alertControllerWithTitle:DPLocalizedString(@"GosComm_Save_title") message:@"" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction=[UIAlertAction actionWithTitle:DPLocalizedString(@"GosComm_Cancel") style:UIAlertActionStyleCancel handler:nil];
    //修改按钮
    if (cancelAction) {
        [cancelAction setValue:GOS_COLOR_RGB(0x999999) forKey:@"titleTextColor"];
    }
    __weak typeof(self) weakSelf = self;
    UIAlertAction *defultAction = [UIAlertAction actionWithTitle:DPLocalizedString(@"GosComm_Confirm") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        // 如果正在播放音乐，那就先去停止播放
        if (weakSelf.isPlaying) {
            [weakSelf closeCradlesong]; //  关闭音乐
        }else{  //  直接切换
            [weakSelf configCradleSong];
        }
    }];
    if (defultAction) {
        [defultAction setValue:GOS_COLOR_RGB(0x55AFFC) forKey:@"titleTextColor"];
    }
    [alertview addAction:cancelAction];
    [alertview addAction:defultAction];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:alertview animated:YES completion:nil];
    });
}

#pragma mark - 设置摇篮曲播放序号结果回调
- (void)configLullabyNum:(BOOL)isSuccess
                deviceId:(NSString *)devId{
    [GosHUD dismiss];
    if (isSuccess) {
        GosLog(@"设置摇篮曲成功");
        // 设置摇篮曲序号成功，打开摇篮曲
        if (self.isPlaying) {
            
        }else{
            [self openCradlesong];
        }
        
    }else{
        GosLog(@"设置摇篮曲失败");
    }
}
#pragma mark - 设置开关属性结果回调
- (void)configSwitch:(BOOL)isSuccess
                type:(SwitchType)sType
            deviceId:(NSString *)devId{
    [GosHUD dismiss];
    if (isSuccess) {
        // 如果当前是开的，那么现在就关
        if (self.isPlaying) {
            self.isPlaying = NO;
            [self delayOpenOradleSong];
        }else{
            self.isPlaying = YES;
            [GosHUD showScreenfulHUDSuccessWithStatus:DPLocalizedString(@"GosComm_Set_Succeeded")];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.navigationController popViewControllerAnimated:YES];
            });
            GosLog(@"整个流程结束");
        }
        GosLog(@"设置开关成功");
    }else{
        GosLog(@"设置开关失败");
        [GosHUD showScreenfulHUDErrorWithStatus:DPLocalizedString(@"GosComm_Set_Failed")];
    }
}

#pragma mark - 设置摇篮曲序号
- (void)configCradleSong{
    [GosHUD showProcessHUDWithStatus:DPLocalizedString(@"SVPLoading")];
    [self.configSDK configLullabyNum:self.lullabyNumber widthDevId:self.deviceID];
}
#pragma mark - 关闭摇篮曲
- (void)closeCradlesong{
    [GosHUD showProcessHUDWithStatus:DPLocalizedString(@"SVPLoading")];
    [self.configSDK configSwitch:Switch_lullaby state:NO withDevId:self.deviceID];
}
#pragma mark - 开启摇篮曲
- (void)openCradlesong{
    [GosHUD showProcessHUDWithStatus:DPLocalizedString(@"SVPLoading")];
    [self.configSDK configSwitch:Switch_lullaby state:YES withDevId:self.deviceID];
}
#pragma mark -- 延时播摇篮曲（用于切换时）
- (void)delayOpenOradleSong{
    __weak typeof(self)weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        __strong typeof(weakSelf)strongSelf = weakSelf;
        if (!strongSelf){
            return ;
        }
        GosLog(@"Lullabies ===== 延时播放下一首 - 开始配置音乐！");
        [strongSelf configCradleSong];
    });
}

#pragma mark -- actionFunction
#pragma mark - 切换播放摇篮曲（音乐）
- (void)switchPlayMusic:(NSInteger) index{
    [self.audioPlay stop];
    self.audioPlay.currentTime = 0;
    
    BabyMusicModel * model = self.dataSouceArr[index];
    NSString *soundPath = [[NSBundle mainBundle]pathForResource:model.titleStr ofType:@"aac"];
    if (!soundPath || soundPath.length < 1) {
        return;
    }
    NSURL *soundUrl = [NSURL fileURLWithPath:soundPath];
    //初始化播放器对象
    self.audioPlay = [[AVAudioPlayer alloc]initWithContentsOfURL:soundUrl error:nil];
    self.audioPlay.volume = 0.5;//范围为（0到1）；
    //设置循环次数，如果为负数，就是无限循环
    self.audioPlay.numberOfLoops = 1;
    //设置播放进度
    self.audioPlay.currentTime = 0;
    
    //准备播放
    [self.audioPlay prepareToPlay];
    if (![self.audioPlay isPlaying]) {
        [self.audioPlay play];
    }
    
}
#pragma mark -- tableView&delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.selectIndex == indexPath.row && [self.audioPlay isPlaying]) {
        return;
    }
    /// 用于标记点击同一个，不作处理
    self.selectIndex = indexPath.row;
    BabyMusicModel * model = [self.dataSouceArr objectAtIndex:indexPath.row];
    self.lullabyNumber = model.lullabyNumber;
    
    [BabyMusicViewModel modifyChangeBabyMusic:self.dataSouceArr withIndex:self.selectIndex lullabyNumber:self.lullabyNumber];
    /// 播放选中的摇篮曲
    [self switchPlayMusic:self.selectIndex];
    [self refreshUI];
    
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [BabyMusicCell cellWithTableView:tableView indexPath:indexPath cellModel:[self.dataSouceArr objectAtIndex:indexPath.row]];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataSouceArr.count;
}
#pragma mark - setting
- (void)setAbilityModel:(AbilityModel *)abilityModel{
    _abilityModel = abilityModel;
}
#pragma mark - 销毁播放器
- (void)destructionAudioPlay{
    [self.audioPlay stop];
    self.audioPlay.currentTime = 0;
    self.audioPlay = nil;
}
#pragma mark - lifestyle
- (void)dealloc{
    [self destructionAudioPlay];
    GosLog(@"--%s---",__PRETTY_FUNCTION__);
}
#pragma mark -- lazy
-(iOSConfigSDK *)configSDK{
    if (!_configSDK) {
        _configSDK = [iOSConfigSDK shareCofigSdk];
        _configSDK.paramDelegate = self;
    }
    return _configSDK;
}
@end
