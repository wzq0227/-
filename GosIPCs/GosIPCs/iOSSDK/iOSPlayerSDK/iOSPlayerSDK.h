//
//  iOSPlayerSDK.h
//  iOSPlayerSDK
//
//  Created by shenyuanluo on 2018/1/5.
//  Copyright © 2018年 goscam. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "iOSPlayerSDKDefine.h"


@protocol iOSPlayerSDKDelegate <NSObject>
@optional

/**
 录像回调
 
 @param deviceId 设备 ID
 @param rState 录像状态，参见‘RecordState’
 @param duration 录像时长（当录像成功时返回）
 */
- (void)deviceId:(NSString *)deviceId
     recordState:(RecordState)rState
      recordTime:(unsigned int)duration;

/**
 录音回调

 @param recPath 录音文件保存路径
 @param isSuccess 是否录制成功；YES：成功，NO：失败
 */
- (void)recordAudioPath:(NSString *)recPath
              isSuccess:(BOOL)isSuccess;

/**
 消除回音的音频数据回调
 
 @param audioBuf 去除回音后的音频数据
 @param size 音频数据大小
 */
- (void)echoCancelData:(unsigned char*)audioBuf
                  size:(unsigned int)size;

/**
 Swipe 手势回调
 
 @param sDirection 手势移动方向
 @param mSpace 手势移动距离
 */
- (void)swipeGesDirection:(SwipeGesDirection)sDirection
                moveSpace:(CGFloat)mSpace;

/**
 解码 H264 结果状态回调（云存储录制）
 
 @param state 解码状态，参见‘DecodeH264FileState’
 @param data 返回的数据
 */
- (void)decodeH264State:(DecodeH264FileState)state
                   data:(long)data;

/**
 解码 H264 流结果状态回调（SD 卡录制）
 
 @param state 解码状态，参见‘DecodeH264FileState’
 */
- (void)decodeH264StreamState:(DecodeH264StreamState)state;



/**
 VR 解码数据回调（临时解决方法）
 
 @param buffer YUV 数据缓存
 @param length 数据长度
 @param width YUV-帧宽度
 @param height YUV-帧高度
 */
- (void)vrYUVData:(unsigned char*)buffer
           length:(long)length
            width:(unsigned int)width
           height:(unsigned int)height;

@end

@interface iOSPlayerSDK : NSObject

@property (nonatomic, weak) id<iOSPlayerSDKDelegate>delegate;

/**
 创建 iOSPlayerSDK 实例

 @param devId 设备 ID
 @param pView 视频播放 View
 @param isRatio 是否保持比例播放视频；YES：是，NO：按照 View 大小播放
 @return 实例对象
 */
- (instancetype)initWithDeviceId:(NSString *)devId
                      onPlayView:(UIView *)pView
                       ratioPlay:(BOOL)isRatio;

- (instancetype)initWithDeviceId:(NSString *)devId
                    onVRPlayView:(UIView *)pView;

/**
 重新调整视频播放 View 大小（例如：横竖屏切换时）

 @param nSize 调整后大小
 */
- (void)resize:(CGSize)nSize;

/**
 添加视频数据进行解码播放

 @param vBuffer 视频数据
 @param dLen 数据长度
 @param timeStamp 视频帧时间戳
 @param frameNo 视频帧号
 @param frameRate 视频帧率
 @param iFrame 是否是 I 帧；YES：是，NO：否
 @param devId 设备 ID
 */
- (void)addVideoData:(unsigned char*)vBuffer
              length:(unsigned int)dLen
           timeStamp:(unsigned int)timeStamp
             frameNo:(unsigned int)frameNo
           frameRate:(unsigned int)frameRate
            isIframe:(BOOL)iFrame
            deviceId:(NSString *)devId;

/**
 添加音频数据进行解码播放

 @param aBuffer 音频数据
 @param dLen 数据长度
 @param frameNo 音频帧号
 @param devId 设备 ID
 @param acType 音频编码类型
 */
- (void)addAudioData:(unsigned char*)aBuffer
              length:(unsigned int)dLen
             frameNo:(unsigned int)frameNo
            deviceId:(NSString *)devId
            codeType:(PlayerAudioCodeType)acType;

/**
 开启音频播放
 */
- (void)startVoiceWidthDevId:(NSString *)devId;

/**
 关闭音频播放
 */
- (void)stopVoiceWidthDevId:(NSString *)devId;

/**
 拍照

 @param imgFilePath 图片保存路径
 @param devId 设备 ID
 @return 拍照是否成功；YES：成功，NO：失败
 */
- (BOOL)snapshotAtPath:(NSString *)imgFilePath
              deviceId:(NSString *)devId;
/**
 设置 SD 卡裸流文件操作类型
 
 @param type 操作类型，参见‘SDH264StreamOperationType’
 @param filePath 保存文件路径
 @param devId 设备 ID
 @return 设置是否成功；YES：成功，NO：失败
 */
- (BOOL)configSdH264OperationType:(SDH264StreamOperationType)type
                     saveFilePath:(NSString *)filePath
                     withDeviceId:(NSString *)devId;

/**
 开始解码 H264 文件
 
 @param filePath H264 文件保存路径
 @param devId 设备 ID
 @return 开始解码是否成功；YES：成功，NO：失败
 */
- (BOOL)startDecodeH246:(NSString *)filePath
              withDevId:(NSString *)devId;

- (BOOL)pre_startDecodeH246:(NSString *)filePath
                  withDevId:(NSString *)devId;

/**
 停止解码 H264 文件
 
 @param devId 设备 ID
 @return 停止解码是否成功；YES：成功，NO：失败
 */
- (BOOL)stopDecodeH246WithDevId:(NSString *)devId;

- (BOOL)pre_stopDecodeH246WithDevId:(NSString *)devId;

/**
 保存 H264 指定时间的预览图
 
  @param imgPath 预览图保存路径
 @param time 距离文件起始点(0秒)的指定时间（单位：秒）
 @param devId 设备 ID
 @return 预览图保存是否成功；YES：成功，NO：失败
 */
- (BOOL)saveH264PreviewToPath:(NSString *)imgPath
                       onTime:(unsigned int)time
                    withDevId:(NSString *)devId;

- (BOOL)pre_saveH264PreviewToPath:(NSString *)imgPath
                           onTime:(unsigned int)time
                        withDevId:(NSString *)devId;

/**
 剪切 H264 并转换为 Mp4
 
 @param h264Path H264 文件路径
 @param mp4Path Mp4 保存文件路径
 @param startTime 剪切起始时间
 @param duration 剪切时长
 */
- (BOOL)convertH264:(NSString *)h264Path
              toMp4:(NSString *)mp4Path
           fromTime:(unsigned int)startTime
         toDuration:(unsigned int)duration
          withDevId:(NSString *)devId;

/**
 设置是否自动渲染（解码 H264 文件时）
 
 @param autoRender 是否自动渲染；YES：渲染，NO：不渲染
 */
- (void)configAutoRender:(BOOL)autoRender;

/**
 开始录像
 
 @param videoFilePath 视频保存路径
 @param devId 设备 ID
 */
- (void)startRecordVideoAtPath:(NSString *)videoFilePath
                      deviceId:(NSString *)devId;

/**
 停止录像

 @param devId 设备 ID
 */
- (void)stopRecordVideoWidthDevId:(NSString *)devId;

/**
 开始录音
 */
- (void)startRecordAudio;

/**
 停止录音
 */
- (void)stopRecordAudio;

/**
 打开回音消除
 */
- (void)openEchoCanceller;

/**
 关闭回音消除
 */
- (void)closeEchoCanceller;

/**
 设置捏合放大功能

 @param isEnable 是否开启；YES：开启，NO：关闭
 @param minScale 最小缩放倍数
 @param maxScale 最大缩放倍数
 */
- (void)enableScale:(BOOL)isEnable
           minScale:(CGFloat)minScale
           maxScale:(CGFloat)maxScale;

/**
 释放 PlayerSDK 资源（停止播放时，必须调用，否则会循环引用导致内存泄漏）
 */
- (void)releasePlayer;
@end
