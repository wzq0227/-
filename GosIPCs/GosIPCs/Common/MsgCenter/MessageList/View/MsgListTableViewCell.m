//
//  MsgListTableViewCell.m
//  GosIPCs
//
//  Created by ShenYuanLuo on 2018/12/17.
//  Copyright © 2018年 goscam. All rights reserved.
//

#import "MsgListTableViewCell.h"

@interface MsgListTableViewCell()

@property (weak, nonatomic) IBOutlet EnlargeClickButton *selectedBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *iconLeftMargin;

@property (weak, nonatomic) IBOutlet UIImageView *iconImgView;
@property (weak, nonatomic) IBOutlet UIView *hasReadedView;
@property (weak, nonatomic) IBOutlet UILabel *msgTitleLabel
;
@property (weak, nonatomic) IBOutlet UIView *seperateLineView;
@property (weak, nonatomic) IBOutlet UILabel *msgTimeLabel;
/** 高亮提示cell（新内容，。。。） */
@property (weak, nonatomic) IBOutlet UIView *highLightIndicatorView;

@property (nonatomic, readwrite, strong) UIImage *selectedImg;
@property (nonatomic, readwrite, strong) UIImage *unSelectedImg;
@property (nonatomic, readwrite, strong) UIImage *videoMotionImg;
@property (nonatomic, readwrite, strong) UIImage *pirMotionImg;
@property (nonatomic, readwrite, strong) UIImage *pirVideoMotionImg;
@property (nonatomic, readwrite, strong) UIImage *audioMotionImg;
@property (nonatomic, readwrite, strong) UIImage *lowTempImg;
@property (nonatomic, readwrite, strong) UIImage *hightTempImg;
@property (nonatomic, readwrite, strong) UIImage *lowPowerImg;
@property (nonatomic, readwrite, strong) UIImage *callingImg;
@property (nonatomic, readwrite, strong) UIImage *iotLowPowerImg;
@property (nonatomic, readwrite, strong) UIImage *iotDoorOpenImg;
@property (nonatomic, readwrite, strong) UIImage *iotDoorCloseImg;
@property (nonatomic, readwrite, strong) UIImage *iotDoorBreakImg;
@property (nonatomic, readwrite, strong) UIImage *iotPirImg;
@property (nonatomic, readwrite, strong) UIImage *iotSosImg;

@end

@implementation MsgListTableViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.backgroundColor = GOS_WHITE_COLOR;
    self.contentView.backgroundColor = GOS_WHITE_COLOR;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (void)setMsgListCellData:(PushMessage *)msgListCellData
{
    if (!msgListCellData)
    {
        return;
    }
    _msgListCellData = msgListCellData;
    
    [self configMsgIconWithType:msgListCellData.pmsgType];
    [self configHasReadedViewHidden:msgListCellData.hasReaded];
    
    self.msgTitleLabel.text = msgListCellData.deviceName;
    self.msgTimeLabel.text  = msgListCellData.pushTime;
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

- (void)setHiddenSeperateLine:(BOOL)hiddenSeperateLine
{
    if (_hiddenSeperateLine == hiddenSeperateLine)
    {
        return;
    }
    _hiddenSeperateLine = hiddenSeperateLine;
    dispatch_async(dispatch_get_main_queue(), ^{
        
        self.seperateLineView.hidden = hiddenSeperateLine;
    });
}

- (void)setIsShowIndicatorView:(BOOL)isShowIndicatorView
{
    if (_isShowIndicatorView == isShowIndicatorView)
    {
        return;
    }
    _isShowIndicatorView = isShowIndicatorView;
    dispatch_async(dispatch_get_main_queue(), ^{
        
        self.highLightIndicatorView.hidden = !isShowIndicatorView;
    });
}

- (void)setSelectedBtnAction:(SelectedBtnActionBlock)selectedBtnAction
{
    _selectedBtnAction = selectedBtnAction;
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

#pragma mark -- 设置消息 icon
- (void)configMsgIconWithType:(PushMsgType)pmType
{
    UIImage *iconImg = nil;
    switch (pmType)
    {
        case PushMsg_move:                  iconImg = self.videoMotionImg;  break;  // 移动侦测
        case PushMsg_guard:                 iconImg = self.videoMotionImg;  break;  // 警戒
        case PushMsg_pir:                   iconImg = self.pirMotionImg;    break;  // PIR 侦测报警
        case PushMsg_tempUpperLimit:        iconImg = self.hightTempImg;    break;  // 温度上限报警
        case PushMsg_tempLowerLimit:        iconImg = self.lowTempImg;      break;  // 温度下限报警
        case PushMsg_voice:                 iconImg = self.audioMotionImg;  break;  // 声音报警
        case PushMsg_bellRing:              iconImg = self.callingImg;      break;  // 按铃
        case PushMsg_lowBattery:            iconImg = self.lowPowerImg;     break;  // 低电量报警
        case PushMsg_iotSensorLowBattery:   iconImg = self.iotLowPowerImg;  break;  // IOT 设备低电报警
        case PushMsg_iotSensorDoorOpen:     iconImg = self.iotDoorOpenImg;  break;  // IOT 设备开门报警
        case PushMsg_iotSensorDoorClose:    iconImg = self.iotDoorCloseImg; break;  // IOT 设备关门报警
        case PushMsg_iotSensorDoorBreak:    iconImg = self.iotDoorBreakImg; break;  // IOT 设备防拆报警
        case PushMsg_iotSensorPirAlarm:     iconImg = self.iotPirImg;       break;  // IOT 设备 PIR 报警
        case PushMsg_iotSensorSosAlarm:     iconImg = self.iotSosImg;       break;  // IOT 设备 SOS 报警
            
        default:
            break;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
       
        self.iconImgView.image = iconImg;
    });
}

- (void)configHasReadedViewHidden:(BOOL)isHidden
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        self.hasReadedView.hidden = isHidden;
    });
}
- (IBAction)selectedBtnAction:(id)sender
{
    if (self.selectedBtnAction)
    {
        self.selectedBtnAction(!self.hasSelected);
    }
}

#pragma mark - 懒加载
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

- (UIImage *)iotLowPowerImg
{
    if (!_iotLowPowerImg)
    {
        _iotLowPowerImg = GOS_IMAGE(@"icon_iot_sensor_low_battery");
    }
    return _iotLowPowerImg;
}

- (UIImage *)iotDoorOpenImg
{
    if (!_iotDoorOpenImg)
    {
        _iotDoorOpenImg = GOS_IMAGE(@"icon_iot_sensor_door_open");
    }
    return _iotDoorOpenImg;
}


- (UIImage *)iotDoorCloseImg
{
    if (!_iotDoorCloseImg)
    {
        _iotDoorCloseImg = GOS_IMAGE(@"icon_iot_sensor_door_close");
    }
    return _iotDoorCloseImg;
}

- (UIImage *)iotDoorBreakImg
{
    if (!_iotDoorBreakImg)
    {
        _iotDoorBreakImg = GOS_IMAGE(@"icon_iot_sensor_door_break");
    }
    return _iotDoorBreakImg;
}

- (UIImage *)iotPirImg
{
    if (!_iotPirImg)
    {
        _iotPirImg = GOS_IMAGE(@"icon_iot_sensor_pir");
    }
    return _iotPirImg;
}

- (UIImage *)iotSosImg
{
    if (!_iotSosImg)
    {
        _iotSosImg = GOS_IMAGE(@"icon_iot_sensor_sos");
    }
    return _iotSosImg;
}

@end
