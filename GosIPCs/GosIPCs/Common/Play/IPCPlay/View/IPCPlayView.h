//
//  IPCPlayView.h
//  GosIPCs
//
//  Created by shenyuanluo on 2018/12/8.
//  Copyright © 2018 goscam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SYFullScreenView.h"


#define CENTER_VIEW_SHOW_INTERVAL 3     // 中间控制视图显示时长（单位：秒）


NS_ASSUME_NONNULL_BEGIN

/* 云台转动方向枚举 */
typedef NS_ENUM(NSInteger, GosPTZDirection) {
    GosPTZD_left                = 0,    // 转左
    GosPTZD_right               = 1,    // 转右
    GosPTZD_up                  = 2,    // 转上
    GosPTZD_down                = 3,    // 转下
};


@protocol IPCPlayViewDelegate <NSObject>
@optional
/*
 摇篮曲按钮点击事件回调
 */
- (void)lullabyBtnAction;

/*
 录像按钮点击事件回调
 */
- (void)recordVideoBtnAction;

/*
 控制台 View 显示按钮点击事件回调
 */
- (void)ptzViewBtnAction;

/*
 视频质量切换按钮点击事件回调
 */
- (void)videoQualityBtnAction;

/*
 声音按钮点击事件回调
 */
- (void)audioBtnAction;

/*
 对讲按钮'TouchDown'事件回调
 */
- (void)talkbackBtnTouchDownAction;

/*
 对讲按钮'TouchDragExit'事件回调
 */
- (void)talkbackBtnToucDragExitAction;

/*
 对讲按钮'TouchUpInside'事件回调
 */
- (void)talkbackBtnAction;

/*
 拍照按钮点击事件回调
 */
- (void)snapshotBtnAction;

/*
 云台控制按钮点击事件回调
 */
- (void)ptzBtnAction:(GosPTZDirection)direction;
@end

@interface IPCPlayView : UIView

@property (nonatomic, readwrite, weak) id<IPCPlayViewDelegate>delegate;

/** 视频显示 View */
@property (nonatomic, readwrite, strong) SYFullScreenView *videoShowView;
/** 预览图片 imgView */
@property (nonatomic, readwrite, strong) UIImageView *previewImgView;
/** 设备掉线提示 View */
@property (nonatomic, readwrite, strong) UILabel *offlineTipsLabel;
/** 视频加载提示 View */
@property (nonatomic, readwrite, strong) UIActivityIndicatorView *loadingIndicator;
/** 摇篮曲按钮 */
@property (nonatomic, readwrite, strong) EnlargeClickButton *lullabyBtn;
/** 录像提示红点 View */
@property (nonatomic, readwrite, strong) UIView *recordingView;
/** 录像提示 REG Label */
@property (nonatomic, readwrite, strong) UILabel *recordingLabel;
/** 录像按钮 */
@property (nonatomic, readwrite, strong) EnlargeClickButton *recordVideoBtn;
/** 控制台View 显示按钮 */
@property (nonatomic, readwrite, strong) EnlargeClickButton *ptzViewBtn;
/** 视频质量切换按钮 */
@property (nonatomic, readwrite, strong) EnlargeClickButton *videoQualityBtn;
/** 温度指示 ImageView */
@property (nonatomic, readwrite, strong) UIImageView *tempImgView;
/** 温度度数 Label */
@property (nonatomic, readwrite, strong) UILabel *tempLabel;
/** 声音按钮 */
@property (nonatomic, readwrite, strong) EnlargeClickButton *audioBtn;
/** 对讲按钮 */
@property (nonatomic, readwrite, strong) EnlargeClickButton *talkbackBtn;
/** 拍照按钮 */
@property (nonatomic, readwrite, strong) EnlargeClickButton *snapshotBtn;
/** 设备是否在线 YES 在线  NO 离线 */
@property (nonatomic, assign) BOOL isOffLine;

/*
 显示中间控制 View（录像、云台、画质、温度）；5s 后自动隐藏
 */
- (void)showCenterCtrlView;

/*
 设置声音按钮 Icon
 
 @param isOpen 是否开启声音；YES：开启，NO：关闭
 */
- (void)configSoundBtnIcon:(BOOL)isOpen;

/*
 设置云台控制视图是否隐藏
 */
- (void)configPTZViewHidden:(BOOL)isHidden;

/**
 设置录像按钮样式(录像为红，不录像为白)
 
 @param isSelect YES 为选中  NO 为不选中
 */
- (void)configRecordSelect:(BOOL)isSelect;


/**
 录像时REG文字显示
 
 @param isHidden YES 隐藏 NO 显示
 */
- (void)configRecoringLabeHidden:(BOOL)isHidden;


/**
 是否有云台控制能力集
 
 @param hasPTZ YES 有 NO 没有
 */
- (void)configHasPTZ:(BOOL)hasPTZ;


/**
 设置对讲按钮状态 bykuangweiqun 2019-03-08
 
 @param isFullDuplex 是否是全双工
 @param isTalkingOnHalfDuplex 是否正在对讲（半双工）
 @param hasConnected 设备是否已经建立连接
 */
- (void)configTalkBtnIcon:(BOOL)isFullDuplex
      TalkingOnHalfDuplex:(BOOL)isTalkingOnHalfDuplex
             hasConnected:(BOOL)hasConnected;
@end

NS_ASSUME_NONNULL_END
