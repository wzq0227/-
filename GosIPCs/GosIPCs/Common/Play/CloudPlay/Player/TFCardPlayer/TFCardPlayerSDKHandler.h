//  TFCardPlayerSDKHandler.h
//  GosIPCs
//
//  Create by daniel.hu on 2019/2/19.
//  Copyright © 2019年 goscam. All rights reserved.

#import <Foundation/Foundation.h>
#import "iOSConfigSDKDefine.h"
#import "iOSDevSDKDefine.h"


NS_ASSUME_NONNULL_BEGIN
@protocol TFCardPlayerSDKHandlerDelegate;

/**
 封装iOSDevSDK 与 iOSPlayerSDK 关于TF卡流播 核心逻辑
 */
@interface TFCardPlayerSDKHandler : NSObject
/// 代理
@property (nonatomic, weak) id<TFCardPlayerSDKHandlerDelegate> delegate;

/**
 初始化
 
 @param deviceId 设备id
 @param playView 播放视图
 */
- (instancetype)initWithDeviceId:(NSString *)deviceId
                        playView:(UIView *)playView;

/**
 开始播放
 
 @param startTimestamp 开始播放时间戳
 */
- (void)sdk_handler_startPlayWithStartTimestamp:(NSTimeInterval)startTimestamp;

/**
 获取预览图
 
 @param imageFilePath 预览图存储路径
 @param timestamp 预览图时间戳
 */
- (void)sdk_handler_fetchPreviewWithImageFilePath:(NSString *)imageFilePath
                                      atTimestamp:(NSTimeInterval)timestamp;

/**
 获取截图
 
 @param imageFilePath 截图存储路径
 */
- (void)sdk_handler_snapshotWithImageFilePath:(NSString *)imageFilePath;

/**
 开始剪切
 
 @param videoFilePath 剪切文件存储路径
 @param startTimestamp 剪切开始时间戳
 @param duration 剪切总时长
 */
- (void)sdk_handler_startClipWithVideoFilePath:(NSString *)videoFilePath
                                startTimestamp:(NSTimeInterval)startTimestamp
                                      duration:(NSUInteger)duration;

/** 开启声音 */
- (void)sdk_handler_openVoice;

/** 关闭声音 */
- (void)sdk_handler_closeVoice;

/** 初始化播放器 */
- (void)sdk_handler_initialPlayer;

/** 销毁播放器 */
- (void)sdk_handler_destoryPlayer;

/**
 重置播放视图尺寸
 
 @param size CGSize播放视图尺寸
 */
- (void)sdk_handler_resize:(CGSize)size;

@end


#pragma mark - TFCardPlayerSDKHandlerDelegate
/**
 TFCardPlayerSDKHandler代理
 */
@protocol TFCardPlayerSDKHandlerDelegate <NSObject>
/**
 设备在线状态 和 设备连接状态的更新
 
 @param handler TFCardPlayerSDKHandler
 @param deviceId 设备id
 @param deviceStatus 设备在线状态 参考"DevStatusType"
 @param connectState 设备连接状态 参考"DeviceConnState"
 */
- (void)sdk_handler:(TFCardPlayerSDKHandler *)handler
           deviceId:(NSString *)deviceId
didChangedDeviceState:(DevStatusType)deviceStatus
       connectState:(DeviceConnState)connectState;

/**
 预览图保存
 
 @param handler TFCardPlayerSDKHandler
 @param deviceId 设备id
 @param imageFilePath 预览图存储路径
 @param timestamp 时间戳
 @param isSucceed 是否成功
 */
- (void)sdk_handler:(TFCardPlayerSDKHandler *)handler
           deviceId:(NSString *)deviceId
didSavedPreviewAtImageFilePath:(NSString *)imageFilePath
          timestamp:(NSTimeInterval)timestamp
          isSucceed:(BOOL)isSucceed;

/**
 开启播放失败

 @param handler TFCardPlayerSDKHandler
 @param deviceId 设备id
 @param startTimestamp 播放开始时间戳
 */
- (void)sdk_handler:(TFCardPlayerSDKHandler *)handler
           deviceId:(NSString *)deviceId
didFailedPlayAtStartTimestamp:(NSTimeInterval)startTimestamp;

/**
 开始播放
 
 @param handler TFCardPlayerSDKHandler
 @param deviceId 设备id
 @param startTimestamp 播放开始时间戳
 */
- (void)sdk_handler:(TFCardPlayerSDKHandler *)handler
           deviceId:(NSString *)deviceId
didStartPlayAtStartTimestamp:(NSTimeInterval)startTimestamp;

/**
 播放中
 
 @param handler TFCardPlayerSDKHandler
 @param deviceId 设备id
 @param playingTimestamp 正在播放的时间戳
 @param startTimestamp 播放开始时间戳
 */
- (void)sdk_handler:(TFCardPlayerSDKHandler *)handler
           deviceId:(NSString *)deviceId
didPlayingAtTimestamp:(NSTimeInterval)playingTimestamp
     startTimestamp:(NSTimeInterval)startTimestamp;

/**
 结束播放
 
 @param handler TFCardPlayerSDKHandler
 @param deviceId 设备id
 @param startTimestamp 播放开始时间戳
 */
- (void)sdk_handler:(TFCardPlayerSDKHandler *)handler
           deviceId:(NSString *)deviceId
didEndedPlayAtStartTimestamp:(NSTimeInterval)startTimestamp;

/**
 播放开始缓冲中
 
 @param handler TFCardPlayerSDKHandler
 @param deviceId 设备id
 @param startTimestamp 播放开始时间戳
 */
- (void)sdk_handler:(TFCardPlayerSDKHandler *)handler
           deviceId:(NSString *)deviceId
playStartLoadingAtStartTimestamp:(NSTimeInterval)startTimestamp;

/**
 播放结束缓冲中
 
 @param handler TFCardPlayerSDKHandler
 @param deviceId 设备id
 @param startTimestamp 播放开始时间戳
 */
- (void)sdk_handler:(TFCardPlayerSDKHandler *)handler
           deviceId:(NSString *)deviceId
playEndedLoadingAtStartTimestamp:(NSTimeInterval)startTimestamp;

/**
 完成剪切
 
 @param handler TFCardPlayerSDKHandler
 @param deviceId 设备id
 @param videoFilePath 剪切后的文件存储路径
 @param startTimestamp 剪切开始时间戳
 @param duration 总时长
 @param isSucceed 是否成功
 */
- (void)sdk_handler:(TFCardPlayerSDKHandler *)handler
           deviceId:(NSString *)deviceId
didClipAtVideoFilePath:(NSString *)videoFilePath
     startTimestamp:(NSTimeInterval)startTimestamp
           duration:(NSUInteger)duration
          isSucceed:(BOOL)isSucceed;


/**
 完成截图

 @param handler TFCardPlayerSDKHandler
 @param deviceId 设备id
 @param imageFilePath 截图保存路径
 @param isSucceed 是否成功
 */
- (void)sdk_handler:(TFCardPlayerSDKHandler *)handler
           deviceId:(NSString *)deviceId
didSnapshotAtImageFilePath:(NSString *)imageFilePath
          isSucceed:(BOOL)isSucceed;

@end

NS_ASSUME_NONNULL_END
