//
//  TFCRMediaListTableViewCell.m
//  Goscom
//
//  Created by shenyuanluo on 2019/1/2.
//  Copyright © 2019 goscam. All rights reserved.
//

#import "TFCRMediaListTableViewCell.h"


@interface TFCRMediaListTableViewCell()
@property (weak, nonatomic) IBOutlet EnlargeClickButton *selectedBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *iconLeftMargin;
@property (weak, nonatomic) IBOutlet UILabel *fileDateLabel;
@property (weak, nonatomic) IBOutlet UIImageView *fileIconImgView;
@property (weak, nonatomic) IBOutlet UILabel *fileNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *fileSizeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *fileDownloadImgView;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *downloadingActivity;
@property (weak, nonatomic) IBOutlet UILabel *downloadPercentLabel;
@property (nonatomic, readwrite, strong) UIImage *downloadImg;
@property (nonatomic, readwrite, strong) UIImage *failureImg;
@property (nonatomic, readwrite, strong) UIImage *selectedImg;
@property (nonatomic, readwrite, strong) UIImage *unSelectedImg;
@property (nonatomic, readwrite, strong) UIImage *videoMotionImg;
@property (nonatomic, readwrite, strong) UIImage *pirMotionImg;
@property (nonatomic, readwrite, strong) UIImage *pirVideoMotionImg;
@property (nonatomic, readwrite, strong) UIImage *audioMotionImg;
@property (nonatomic, readwrite, strong) UIImage *ioMotionImg;
@property (nonatomic, readwrite, strong) UIImage *lowTempImg;
@property (nonatomic, readwrite, strong) UIImage *hightTempImg;
@property (nonatomic, readwrite, strong) UIImage *lowHumImg;
@property (nonatomic, readwrite, strong) UIImage *hightHumImg;
@property (nonatomic, readwrite, strong) UIImage *lowWBGTImg;
@property (nonatomic, readwrite, strong) UIImage *hightWBGTImg;
@property (nonatomic, readwrite, strong) UIImage *lowPowerImg;
@property (nonatomic, readwrite, strong) UIImage *callingImg;

@end

@implementation TFCRMediaListTableViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.progressView.trackTintColor    = GOS_WHITE_COLOR;
    self.progressView.progressTintColor = GOSCOM_THEME_START_COLOR;
    self.downloadingActivity.hidden     = YES;
    self.selectedBtn.hidden = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (void)setMediaData:(TFCRMediaModel *)mediaData
{
    if (!mediaData)
    {
        return;
    }
    _mediaData = mediaData;
    self.fileDateLabel.text = mediaData.tfmFile.fileDate;
    self.fileNameLabel.text = mediaData.tfmFile.showName;
    self.fileSizeLabel.text = mediaData.mediaFileSize;
    [self configFileIconWithType:mediaData.tfmFile.alarmType];
    if (NO == mediaData.isDownloading)
    {
        [self configDowloadFlagImg:NO == mediaData.hasDownload ? StopDowloadReason_notYet : StopDowloadReason_success];
    }
    else
    {
        [self startDownload];
    }
}

- (void)setIsEditing:(BOOL)isEditing
{
    if (_isEditing == isEditing)
    {
        return;
    }
    _isEditing = isEditing;
    [self configIconLeftMargin:isEditing];
}

- (void)setHasSelected:(BOOL)hasSelected
{
    if (_hasSelected == hasSelected)
    {
        return;
    }
    _hasSelected = hasSelected;
    [self configSelectedBtn:hasSelected];
}

- (void)startDownload
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        self.progressView.hidden         = NO;
        self.downloadPercentLabel.hidden = NO;
        self.fileDownloadImgView.hidden  = YES;
        self.downloadingActivity.hidden  = NO;
        [self.downloadingActivity startAnimating];
        [self downloading:0];
    });
}

- (void)downloading:(float)progress
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        self.downloadPercentLabel.text = [NSString stringWithFormat:@"%d%@", (int)(progress * 100), @"%"];
        self.progressView.progress     = progress;
    });
}

- (void)endDownload:(StopDowloadReasonType)reason
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self.downloadingActivity stopAnimating];
        self.downloadingActivity.hidden  = YES;
        self.progressView.hidden         = YES;
        self.downloadPercentLabel.hidden = YES;
        
        [self configDowloadFlagImg:reason];
    });
}

#pragma mark -- 设置消息 icon
- (void)configFileIconWithType:(TFMediaAlarmType)pmType
{
    UIImage *iconImg = nil;
    switch (pmType)
    {
        case TFMediaAlarm_unknown:          iconImg = self.videoMotionImg;      break;  // 未知
        case TFMediaAlarm_videoMotion:      iconImg = self.videoMotionImg;      break;  // 移动侦测
        case TFMediaAlarm_pirMotion:        iconImg = self.pirMotionImg;        break;  // PIR 侦测报警
        case TFMediaAlarm_pirVideoMotion:   iconImg = self.pirVideoMotionImg;   break;  // 警戒
        case TFMediaAlarm_audioMotion:      iconImg = self.audioMotionImg;      break;  // 声音告警
        case TFMediaAlarm_io:               iconImg = self.ioMotionImg;         break;  // IO 告警
        case TFMediaAlarm_lowTemp:          iconImg = self.lowTempImg;          break;  // 温度下限报警
        case TFMediaAlarm_hightTemp:        iconImg = self.hightTempImg;        break;  // 温度上限报警
        case TFMediaAlarm_lowHum:           iconImg = self.lowHumImg;           break;  // 低湿度 告警
        case TFMediaAlarm_hightHum:         iconImg = self.hightHumImg;         break;  // 高湿度 告警
        case TFMediaAlarm_lowWBGT:          iconImg = self.lowWBGTImg;          break;  // 低湿球黑球温度 告警
        case TFMediaAlarm_hightWBGT:        iconImg = self.hightWBGTImg;        break;  // 高湿球黑球温度 告警
        case TFMediaAlarm_lowPower:         iconImg = self.lowPowerImg;         break;  // 低电量报警
        case TFMediaAlarm_calling:          iconImg = self.callingImg;          break;  // 按铃
        
            
        default:
            break;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        
        self.fileIconImgView.image = iconImg;
    });
}

- (void)configIconLeftMargin:(BOOL)isEditing
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        self.selectedBtn.hidden = !isEditing;
        if (NO == isEditing)
        {
            self.iconLeftMargin.constant = 15.0f;
        }
        else
        {
            self.iconLeftMargin.constant = 48.0f;
        }
    });
}

- (void)configSelectedBtn:(BOOL)isSelected
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        UIImage *img = nil;
        if (NO == isSelected)
        {
            img = self.unSelectedImg;
        }
        else
        {
            img = self.selectedImg;
        }
        [self.selectedBtn setImage:img forState:UIControlStateNormal];
    });
}

- (void)configDowloadFlagImg:(StopDowloadReasonType)reason
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        switch (reason)
        {
            case StopDowloadReason_cancel:
            {
                self.fileDownloadImgView.hidden = NO;
                self.fileDownloadImgView.image  = self.downloadImg;
            }
                break;
                
            case StopDowloadReason_failure:
            {
                self.fileDownloadImgView.hidden = NO;
                self.fileDownloadImgView.image  = self.failureImg;
            }
                break;
                
            case StopDowloadReason_notYet:
            {
                self.fileDownloadImgView.hidden = NO;
                self.fileDownloadImgView.image  = self.downloadImg;
            }
                break;
                
            case StopDowloadReason_success:
            {
                self.fileDownloadImgView.hidden = YES;
                self.fileDownloadImgView.image  = nil;
            }
                break;
                
            default:
                break;
        }
    });
}

- (IBAction)selectedBtnAction:(id)sender
{
    if (self.selectedBtnActionBlock)
    {
        self.selectedBtnActionBlock(!self.hasSelected);
    }
}

#pragma mark - 懒加载
- (UIImage *)downloadImg
{
    if (!_downloadImg)
    {
        _downloadImg = GOS_IMAGE(@"icon_download");
    }
    return _downloadImg;
}

- (UIImage *)failureImg
{
    if (!_failureImg)
    {
        _failureImg = GOS_IMAGE(@"icon_fail");
    }
    return _failureImg;
}

- (UIImage *)selectedImg
{
    if (!_selectedImg)
    {
        _selectedImg = GOS_IMAGE(@"icon_check-circle");
    }
    return _selectedImg;
}

- (UIImage *)unSelectedImg
{
    if (!_unSelectedImg)
    {
        _unSelectedImg = GOS_IMAGE(@"icon_uncheck-circle");
    }
    return _unSelectedImg;
}

- (UIImage *)videoMotionImg
{
    if (!_videoMotionImg)
    {
        _videoMotionImg = GOS_IMAGE(@"icon_motion_52");
    }
    return _videoMotionImg;
}

- (UIImage *)pirMotionImg
{
    if (!_pirMotionImg)
    {
        _pirMotionImg = GOS_IMAGE(@"icon_infrared");
    }
    return _pirMotionImg;
}

- (UIImage *)pirVideoMotionImg
{
    if (!_pirVideoMotionImg)
    {
        _pirVideoMotionImg = GOS_IMAGE(@"icon_motion_52");
    }
    return _pirVideoMotionImg;
}

- (UIImage *)audioMotionImg
{
    if (!_audioMotionImg)
    {
        _audioMotionImg = GOS_IMAGE(@"icon_VoiceDetection");
    }
    return _audioMotionImg;
}

- (UIImage *)ioMotionImg
{
    if (!_ioMotionImg)
    {
        _ioMotionImg = GOS_IMAGE(@"");
    }
    return _ioMotionImg;
}

- (UIImage *)lowTempImg
{
    if (!_lowTempImg)
    {
        _lowTempImg = GOS_IMAGE(@"temp_lower_limit");
    }
    return _lowTempImg;
}

- (UIImage *)hightTempImg
{
    if (!_hightTempImg)
    {
        _hightTempImg = GOS_IMAGE(@"temp_upper_limit");
    }
    return _hightTempImg;
}

- (UIImage *)lowHumImg
{
    if (!_lowHumImg)
    {
        _lowHumImg = GOS_IMAGE(@"");
    }
    return _lowHumImg;
}

- (UIImage *)hightHumImg
{
    if (!_hightHumImg)
    {
        _hightHumImg = GOS_IMAGE(@"");
    }
    return _hightHumImg;
}

- (UIImage *)lowWBGTImg
{
    if (!_lowWBGTImg)
    {
        _lowWBGTImg = GOS_IMAGE(@"");
    }
    return _lowWBGTImg;
}

- (UIImage *)hightWBGTImg
{
    if (!_hightWBGTImg)
    {
        _hightWBGTImg = GOS_IMAGE(@"");
    }
    return _hightWBGTImg;
}

- (UIImage *)lowPowerImg
{
    if (!_lowPowerImg)
    {
        _lowPowerImg = GOS_IMAGE(@"icon_low_battery");
    }
    return _lowPowerImg;
}

- (UIImage *)callingImg
{
    if (!_callingImg)
    {
        _callingImg = GOS_IMAGE(@"icon_bell_ring");
    }
    return _callingImg;
}


@end
