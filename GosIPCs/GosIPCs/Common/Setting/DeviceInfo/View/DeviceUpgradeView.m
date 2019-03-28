//  DeviceUpgradeView.m
//  Goscom
//
//  Create by 匡匡 on 2018/12/8.
//  Copyright © 2018 goscam. All rights reserved.

#import "DeviceUpgradeView.h"
#import "KKAlertView.h"
@interface DeviceUpgradeView()
@property (weak, nonatomic) IBOutlet UILabel *tipsLab;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (weak, nonatomic) IBOutlet UILabel *downloadLab;
@property (nonatomic, strong) NSTimer * autoUpdateProgressTimer;
/// 自动加的进度条数据
@property (nonatomic, assign) int autoTimeCount;

@end
@implementation DeviceUpgradeView

-(void)awakeFromNib{
    [super awakeFromNib];
    self.layer.cornerRadius = 5.0f;
    self.clipsToBounds = YES;
    self.progressView.layer.cornerRadius = 4.0f;
    self.progressView.clipsToBounds = YES;
    self.progressView.progressTintColor = GOS_COLOR_RGB(0x55AFFC);//设置已过进度部分的颜色
    self.progressView.trackTintColor = GOS_COLOR_RGB(0xE6E6E6);//设置未过进度部分的颜色
    self.autoTimeCount = 0;
    self.tipsLab.text = DPLocalizedString(@"Update_Tips_Downloading");
    self.downloadLab.text = DPLocalizedString(@"Update_Downloading");
    [self.cancelBtn setTitle:DPLocalizedString(@"GosComm_Cancel") forState:UIControlStateNormal];
    
    
}
//@param isSuccess 是否开始升级成功；YES：成功，NO：失败
//@param result 升级进度结果【说明】如下：
//0：准备开始升级；
//1：由于申请内存失败导致升级失败
//2：由于创建线程失败导致升级失败
//3：升级过程中出错
//4、5：升级完成
//100~200：表示升级进度百分比（如 108 表示当前升级进度 8%），其中 100~130 会实时回调回来，超过了 30% 时，由于设备下载固件成功，安装后需要重启，所以无法继续回调进度，因此 APP 端需要使用定时器模拟后面 30%~100% 的进度，当接收到 4、5 时，表明设备s安装固件并重启成功，表明升级完成
//-(void)setViewProgress:(float)viewProgress{
//    _viewProgress = viewProgress;
//    self.progressView.progress = viewProgress;
//}
///  把更新请求的result 和更新状态一起传进来
-(void) setUpgradeResult:(int) result andUpdateStage:(UpdateStage) updateStage{
    _upgradeResult = result;
    _updateStage = updateStage;
    if (result == 0) {      ///  准备开始升级，这个时候给出弹框
        
    }else if(result>=100 && result<=200){
        if (result >= 130) {        ///  做假数据  进度条自己走
            if (!_autoUpdateProgressTimer) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    _autoUpdateProgressTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(autoUpdateProgressTimerFunc) userInfo:nil repeats:YES];
                });
            }
        }else{                      /// 真实进度条
            self.progressView.progress = ((float)(result - 100) / 100.0f);
        }
    }else if(result==3){
        if (updateStage == UpdateStageDownloading ||
            updateStage == UpdateStageUpdating) {
//            [self showUpdateErrorInfo];     ///  弹出更新失败提示
            [self dissMissView];
        }
    }else if(result==4 || result==5){     ///    升级成功处理
        self.updateStage = UpdateStageSucceeded;
        dispatch_async(dispatch_get_main_queue(), ^{
            self.progressView.progress = 1.0f;
//            self.downloadLab.text = @"下载完成";
        });
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self dissMissView];
        });
    }else if(result <= 2){      ///1->请求下载失败，申请内存失败 2->请求下载失败,设备端创建线程失败
       [self dissMissView];
        
    }
    
}
-(void) autoUpdateProgressTimerFunc{
    if (self.updateStage == UpdateStageSucceeded||
        self.updateStage == UpdateStageFailed ||
        self.updateStage == UpdateStageCancelled) {
        [self stopProgressTimer];
        return;
    }
    
    if (self.autoTimeCount++ > 440) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [_autoUpdateProgressTimer invalidate];
            _autoUpdateProgressTimer = nil;
        });
    }
    int progress = 30 + self.autoTimeCount/440.0 *(99-30);
    if (progress>99) {
        progress = 99;
    }
    self.progressView.progress = ((float)progress) / 100.0f;
}
-(void) stopProgressTimer{
    if([_autoUpdateProgressTimer isValid]){
        [_autoUpdateProgressTimer invalidate];
        _autoUpdateProgressTimer = nil;
    }
}
- (IBAction)actionCancelClick:(id)sender {
    [self dissMissView];
    if (self.delegate && [self.delegate respondsToSelector:@selector(DeviceUpgradeCancel)]) {
        [self.delegate DeviceUpgradeCancel];
    }
}
-(void) dissMissView{
    KKAlertView * alert = (KKAlertView *)self.superview;
    [alert hide];
    [self stopProgressTimer];
}
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    self = [[[NSBundle mainBundle] loadNibNamed:@"DeviceUpgradeView" owner:self options:nil] lastObject];
    if (self) {
        self.frame = CGRectMake(0, 0, 300, 200);
    }
    return self;
}
@end
