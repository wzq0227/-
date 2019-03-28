//
//  GOSPanoramaPlayer.h
//  GOSPanoramaPlayer
//
//  Created by zhuochuncai on 17/7/17.
//  Copyright © 2017年 Gospell. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>

/**
 矫正模式吊装
 
 - CorrectionModeStandard: 矫正模式标准，最初的，体验中心的参数
 - CorrectionModeShiftRight: 矫正模式右移，生产后出了问题，要APP端调整
 */
typedef NS_ENUM(NSUInteger, CorrectionMode) {
    CorrectionModeShiftRight = 0,
    CorrectionModeStandard,
};


/**
 矫正模式侧装
 
 - CorrectionModeStandard: 矫正模式标准，最初的，体验中心的参数
 - CorrectionModeShiftRight: 矫正模式右移，生产后出了问题，要APP端调整
 */
typedef NS_ENUM(NSUInteger, CorrectionMode180) {
    CorrectionMode180_ShiftRight = 0,
    CorrectionMode180_Standard,
};


@interface GOSPanoramaPlayer : GLKView

@property(nonatomic,assign) int clickDouble;
@property(nonatomic,assign) int touchStatus;
@property(nonatomic,assign) int tx;
@property(nonatomic,assign) int ty;
@property(nonatomic,assign) int clickSig;
@property(nonatomic,assign) int autoRotSig;
@property(nonatomic,assign) float zoomSig0;
@property(nonatomic,assign) float zoomSig1;
@property(nonatomic,assign) float zoomSig2;

@property (assign, nonatomic)  CorrectionMode correctMode;

@property (assign, nonatomic)  CorrectionMode180 correctMode_180;

@property (assign, nonatomic)  BOOL enterFullScreen;

@property(nonatomic,strong)GLKView *delegateView;
/**
 初始化函数
 
 @param W 传入视频的宽度
 @param H 传入视频的高度
 */
- (void)gosPanorama_initWithWidth:(int)W height:(int)H disWidth:(int)disWidth disHeight:(int)disHeight initialMode:(int)mode;


//step(int touchStatus, int tx,int ty, int clickSig, int autoRotSignal,float zoomSig0,float zoomSig1,float zoomSig2,int disold,byte[] yuv);
- (void)gosPanorama_stepWithTouchStatus:(int) touchStatus
                                     tx:(int) tx
                                     ty:(int) ty
                               clickSig:(int) clickSig
                          autoRotSignal:(int) autoRotSignal
                               zoomSig0:(float) zoomSig0
                               zoomSig1:(float) zoomSig1
                               zoomSig2:(float) zoomSig2
                                 disold:(int) disold
                                yuvData:(UInt8 *)yuvData
                            clickDouble:(int)clickDouble;

- (void)gosPanorama_updateWithYUVData:(UInt8 *)yuvData;

/**
 更新视频显示画面的宽高
 
 @param width 宽
 @param height 高
 */
- (void)gosPanorama_updateDisplayWidth:(int)width height:(int)height;


/**
 更新视频drawable的宽高
 
 @param width 宽
 @param height 高
 */
- (void)gosPanorama_updateVideoWidth:(int)width height:(int)height;



/**
 更新视频显示模式
 */
- (void)gosPanorama_updateClickSignal;


/**
 更新缩放、拖拽等手势信号
 */
- (void)gosPanorama_updateMotionSignal;

@end

