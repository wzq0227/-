//  ClipViewController.m
//  GosIPCs
//
//  Create by daniel.hu on 2019/2/27.
//  Copyright © 2019年 goscam. All rights reserved.

#import "ClipViewController.h"
#import "TFCardPlayer.h"
#import "PlaybackPlayer.h"
#import "GosPhotoHelper.h"
#import "NSString+GosFormatDate.h"
#import "VideoSlicesApiRespModel.h"

@interface ClipViewController () <TFCardPlayerDelegate, PlaybackPlayerDelegate, UIPickerViewDelegate, UIPickerViewDataSource>
#pragma mark - 数据
/// tf player
@property (nonatomic, strong) TFCardPlayer *tf_player;
/// pb player
@property (nonatomic, strong) PlaybackPlayer *pb_player;
/// 开始时间戳
@property (nonatomic, assign) NSTimeInterval startTimestamp;
/// 总时长，最开始由此构建picker数据，然后用此参数记录picker选择后的数据
@property (nonatomic, assign) NSUInteger duration;
/// 设备id
@property (nonatomic, copy) NSString *deviceId;
/// picker view的数据
@property (nonatomic, strong) NSDictionary *pickerDataDictionary;
/// 视频模型数组
@property (nonatomic, copy) NSArray *videos;
/// 开始时间点
@property (nonatomic, assign) NSUInteger startTime;
#pragma mark - 视图
/// 标题
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
/// 剪切名标题
@property (weak, nonatomic) IBOutlet UILabel *clipNameLabel;
/// 剪切名 文本框
@property (weak, nonatomic) IBOutlet UITextField *clipNameTextField;
/// 开始时间标题
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
/// 开始时间 详细
@property (weak, nonatomic) IBOutlet UILabel *detailTimeLabel;
/// 总时长标题
@property (weak, nonatomic) IBOutlet UILabel *durationLabel;
/// 总时长 按钮
@property (weak, nonatomic) IBOutlet UIButton *durationButton;
/// 分
@property (weak, nonatomic) IBOutlet UILabel *minLabel;
/// 秒
@property (weak, nonatomic) IBOutlet UILabel *secLabel;
/// picker view
@property (weak, nonatomic) IBOutlet UIPickerView *durationPickerView;

@end

@implementation ClipViewController
#pragma mark - initialization
- (instancetype)initWithDeviceId:(NSString *)deviceId
                  startTimestamp:(NSTimeInterval)startTimestamp
                        duration:(NSUInteger)duration {
    if (self = [super init]) {
        _deviceId = deviceId;
        _startTimestamp = startTimestamp;
        _duration = duration;
    }
    return self;
}

- (instancetype)initWithDeviceId:(NSString *)deviceId
                          videos:(NSArray<VideoSlicesApiRespModel *> *)videos
                  startTimestamp:(NSTimeInterval)startTimestamp
                       startTime:(NSUInteger)startTime
                        duration:(NSUInteger)duration {
    if (self = [super init]) {
        _deviceId = deviceId;
        _duration = duration;
        _startTime = startTime;
        _videos = [videos copy];
        _startTimestamp = startTimestamp;
    }
    return self;
}

#pragma mark - life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // 配置UI
    [self configUI];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // 配置导航栏
    [self configNavigation];
    // 初始化播放器
    [self initialPlayer];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    // 解决iOS11.0以上版本由TextField系统莫名导致的内存泄露
    [self fixedTextFieldLeak];
    
    // 销毁播放器
    [self destoryPlayer];
    
    [GosHUD dismiss];
}


#pragma mark - config method
- (void)configUI {
    _titleLabel.text = DPLocalizedString(@"CLIP_Tip");
    _clipNameLabel.text = DPLocalizedString(@"CLIP_TitleName");
    _timeLabel.text = DPLocalizedString(@"CLIP_StartTimeTitle");
    _durationLabel.text = DPLocalizedString(@"CLIP_DurationTitle");
    _secLabel.text = DPLocalizedString(@"CLIP_MinTitle");
    _minLabel.text = DPLocalizedString(@"CLIP_SecTitle");
    
    // 8:08:08 2018/8/8
    _detailTimeLabel.text = [NSString stringWithTimestamp:_startTimestamp format:timeSlashDateFormatString];
    // 2018-8-8-8-08-08
    _clipNameTextField.text = [NSString stringWithTimestamp:_startTimestamp format:allWhippletreeDateFormatString];
    
    [self configWithDuration:_duration];
    // 隐藏picker
    [self hidePicker];
}

- (void)configNavigation {
    // 右上角按钮
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:DPLocalizedString(@"GosComm_Done") style:UIBarButtonItemStyleDone target:self action:@selector(rightBarButtonItemDidClick:)];
}

- (void)configWithDuration:(NSUInteger)duration {
    NSUInteger min = 0;
    NSUInteger sec = 0;
    // 解析成分钟与秒
    [self fetchTimeFromDuration:_duration toMinute:&min second:&sec];
    // 配置按钮显示
    [self configDurationButtonWithMinute:min second:sec];
    // 配置picker
    [self configPickerWithMinute:min second:sec];
}


#pragma mark - TFCardPlayerDelegate
/// 剪切成功
- (void)tf_player:(TFCardPlayer *)player didSucceedClipAtVideoFilePath:(NSString *)videoFilePath startTimestamp:(NSTimeInterval)startTimestamp duration:(NSUInteger)duration {
    
    [GosHUD showProcessHUDSuccessWithStatus:@"CLIP_SucceedTip"];
    
    // 延迟1s
    GOS_WEAK_SELF
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        GOS_STRONG_SELF
        // 保存到相册
        [GosPhotoHelper saveVideoToCustomAblumWithVideoPath:videoFilePath success:^{
            GosLog(@"剪切文件保存相册 成功");
        } fail:^{
            GosLog(@"剪切文件保存相册 失败");
        }];
        // 回上一页面
        [strongSelf.navigationController popViewControllerAnimated:YES];
    });
    
}

/// 剪切失败
- (void)tf_player:(TFCardPlayer *)player didFailedClipAtVideoFilePath:(NSString *)videoFilePath startTimestamp:(NSTimeInterval)startTimestamp duration:(NSUInteger)duration {
    
    [GosHUD showProcessHUDErrorWithStatus:@"CLIP_FailedTip"];
}


#pragma mark - PlaybackPlayerDelegate
- (void)pb_player:(PlaybackPlayer *)player didSucceedClipAtVideoFilePath:(NSString *)videoFilePath {
    
    [GosHUD showProcessHUDSuccessWithStatus:@"CLIP_SucceedTip"];
    
    // 延迟1s
    GOS_WEAK_SELF
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        GOS_STRONG_SELF
        // 保存到相册
        [GosPhotoHelper saveVideoToCustomAblumWithVideoPath:videoFilePath success:^{
            GosLog(@"剪切文件保存相册 成功");
        } fail:^{
            GosLog(@"剪切文件保存相册 失败");
        }];
        // 回上一页面
        [strongSelf.navigationController popViewControllerAnimated:YES];
    });
}

/// 剪切失败
- (void)pb_player:(PlaybackPlayer *)player didFailedClipAtVideoFilePath:(NSString *)videoFilePath {
    
    [GosHUD showProcessHUDErrorWithStatus:@"CLIP_FailedTip"];
}


#pragma mark - UIPickerViewDelegate, UIPickerViewDataSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return [self.pickerDataDictionary count];
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    id obj = [self.pickerDataDictionary objectForKey:@(component)];

    if ([obj isKindOfClass:[NSArray class]]) {
        return [obj count];
    } else if ([obj isKindOfClass:[NSDictionary class]]) {
        return [[obj objectForKey:@([pickerView selectedRowInComponent:0])] count];
    } else {
        return 0;
    }
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [[self fetchPickerDataForRow:row forComponent:component] stringValue]?:@"";
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    
    if (component == 0) {
        // 更新 1系列的数据
        [pickerView selectRow:0 inComponent:1 animated:NO];
        [pickerView reloadComponent:1];
        
    } else {
        // 取出picker的分秒
        NSUInteger min = [[self fetchPickerDataForRow:[pickerView selectedRowInComponent:0] forComponent:0] unsignedIntegerValue];
        NSUInteger sec = [[self fetchPickerDataForRow:row forComponent:component] unsignedIntegerValue];
        
        // 更新值
        [self updateParametersWithMinute:min second:sec];
        // 更新UI
        [self configDurationButtonWithMinute:min second:sec];
        // 隐藏picker
        GOS_WEAK_SELF
        [UIView animateWithDuration:0.2 animations:^{
            GOS_STRONG_SELF
            [strongSelf hidePicker];
        }];
        
    }
}


#pragma mark - event response
- (void)rightBarButtonItemDidClick:(id)sender {
    if (IS_EMPTY_STRING(self.clipNameTextField.text)) {
        GosLog(@"文件名不能为空");
        [GosHUD showProcessHUDErrorWithStatus:@"CLIP_FileNameEmptyTip"];
        return ;
    }
    if (_duration == 0) {
        GosLog(@"时长不能为空");
        [GosHUD showProcessHUDErrorWithStatus:@"CLIP_DurationZeroTip"];
        return ;
    }
    // loading
    [GosHUD showProcessHUDForLoading];
    // 剪切文件名
    NSString *clipFilename = self.clipNameTextField.text;
    
    // 开始剪切
    [self startClipWithFileName:clipFilename];;
}

- (IBAction)durationButtonDidClick:(id)sender {
    if ([self isHiddenPicker]) {
        [self showPickerWithDuration:_duration];
    } else {
        [self hidePicker];
    }
}


#pragma mark - private method
// duration -> minute, second
- (void)fetchTimeFromDuration:(NSUInteger)duration toMinute:(NSUInteger *)minute second:(NSUInteger *)second {
    *minute = duration / 60;
    *second = duration % 60;
}

- (void)updateParametersWithMinute:(NSUInteger)minute second:(NSUInteger)second {
    _duration = minute * 60 + second;
}

/// 配置durationButton
- (void)configDurationButtonWithMinute:(NSUInteger)minute second:(NSUInteger)second {
    [_durationButton setTitle:[NSString stringWithFormat:@"%02zd:%02zd", minute, second] forState:UIControlStateNormal];
}

/// 配置picker
- (void)configPickerWithMinute:(NSUInteger)minute second:(NSUInteger)second {
    self.pickerDataDictionary = [self generatePickerDictionaryWithMinute:minute second:second];
    [self.durationPickerView reloadAllComponents];
}

/// 更新picker
- (void)updatePickerWithMinute:(NSUInteger)minute second:(NSUInteger)second {
    NSUInteger minRow = [[self.pickerDataDictionary objectForKey:@(0)] indexOfObject:@(minute)];
    NSUInteger secRow = [[[self.pickerDataDictionary objectForKey:@(1)] objectForKey:@(minute)] indexOfObject:@(second)];
    [_durationPickerView selectRow:minRow inComponent:0 animated:NO];
    [_durationPickerView selectRow:secRow inComponent:1 animated:NO];
    
    [_durationPickerView reloadAllComponents];
}

/// 生产Picker数据字典
- (NSDictionary *)generatePickerDictionaryWithMinute:(NSUInteger)minute second:(NSUInteger)second {
    NSMutableDictionary *result = [NSMutableDictionary dictionaryWithCapacity:minute+1];
    NSMutableArray *minArray = [NSMutableArray arrayWithCapacity:minute+1];
    NSMutableDictionary *secDictionary = [NSMutableDictionary dictionaryWithCapacity:second];
    for (int i = 0; i <= minute; i++) {
        NSArray *temp = nil;
        if (i == minute) {
            // 0 ~ sec
            temp = [self generateArrayFromZeroToMax:second];
        } else {
            // 0 ~ 59
            temp = [self generateArrayFromZeroToMax:59];
        }
        // 添加分数组
        [minArray addObject:@(i)];
        // 添加秒字典 例子：@{@(0):[@(0), @(1), @(2)......@(second) or @(60)];
        [secDictionary addEntriesFromDictionary:@{@(i):[temp copy]}];
    }
    
    [result addEntriesFromDictionary:@{
                                       @(0):[minArray copy],
                                       @(1):[secDictionary copy]
                                       }];
    return result;
}

/// 取picker数据
- (id)fetchPickerDataForRow:(NSInteger)row forComponent:(NSInteger)component {
    id obj = [self.pickerDataDictionary objectForKey:@(component)];
    
    if ([obj isKindOfClass:[NSArray class]]) {
        return [obj objectAtIndex:row];
    } else if ([obj isKindOfClass:[NSDictionary class]]) {
        return [[obj objectForKey:@([self.durationPickerView selectedRowInComponent:0])] objectAtIndex:row];
    } else {
        return nil;
    }
}

/// 生产从0到max的数组
- (NSArray *)generateArrayFromZeroToMax:(NSUInteger)max {
    NSMutableArray *temp = [NSMutableArray arrayWithCapacity:max+1];
    for (int j = 0; j <= max; j++) {
        [temp addObject:@(j)];
    }
    return [temp copy];
}

- (void)showPickerWithDuration:(NSUInteger)duration {
    NSUInteger min = 0;
    NSUInteger sec = 0;
    // 解析成分钟与秒
    [self fetchTimeFromDuration:duration toMinute:&min second:&sec];
    // 更新picker
    [self updatePickerWithMinute:min second:sec];
    
    _durationPickerView.hidden = NO;
    _minLabel.hidden = NO;
    _secLabel.hidden = NO;
}

- (void)hidePicker {
    _durationPickerView.hidden = YES;
    _minLabel.hidden = YES;
    _secLabel.hidden = YES;
}

- (BOOL)isHiddenPicker {
    return _durationPickerView.hidden == YES;
}

/// 解决iOS11.0以上系统的TextField内存泄露的问题
- (void)fixedTextFieldLeak {
    [_clipNameTextField removeFromSuperview];
    _clipNameTextField = nil;
}

- (void)initialPlayer {
    if (_videos) {
        [self.pb_player pb_player_initialPlayer];
    } else {
        [self.tf_player tf_player_initialPlayer];
    }
}

- (void)destoryPlayer {
    if (_videos) {
        [self.pb_player pb_player_destoryPlayer];
    } else {
        [self.tf_player tf_player_destoryPlayer];
    }
}

- (void)startClipWithFileName:(NSString *)fileName {
    if (_videos) {
        [self.pb_player pb_player_startClipWithVideos:_videos
                                             fileName:fileName
                                            startTime:_startTime
                                             duration:_duration];
    } else {
        // 开始剪切
        [self.tf_player tf_player_startClipWithFileName:fileName
                                         startTimestamp:_startTimestamp
                                               duration:_duration];
    }
}

#pragma mark - getters and setters
- (TFCardPlayer *)tf_player {
    if (!_tf_player) {
        _tf_player = [[TFCardPlayer alloc] initWithDeviceId:_deviceId];
        _tf_player.delegate = self;
    }
    return _tf_player;
}

- (PlaybackPlayer *)pb_player {
    if (!_pb_player) {
        _pb_player = [[PlaybackPlayer alloc] initWithDeviceId:_deviceId];
        _pb_player.delegate = self;
    }
    return _pb_player;
}

@end
