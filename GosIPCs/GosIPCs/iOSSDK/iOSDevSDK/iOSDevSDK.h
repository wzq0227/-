//
//  iOSDevSDK.h
//  iOSDevSDK
//
//  Created by shenyuanluo on 2018/1/5.
//  Copyright © 2018年 goscam. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "iOSDevSDKDefine.h"


@protocol iOSDevConnDelegate <NSObject>

@optional

/**
 设备连接状态回调
 
 @param deviceId 设备 ID
 @param devConnState 连接状态，参见‘DeviceConnState’
 */
- (void)deviceId:(NSString *)deviceId
    devConnState:(DeviceConnState)devConnState;
@end


@protocol iOSDevSDKDelegate <NSObject>

@optional

/**
 打开流状态回调
 
 @param deviceId 设备 ID
 @param sState 开流状态，参见‘OpenStreamState’
 @param errType 失败类型，参见‘StreamErrorType’
 */
- (void)deviceId:(NSString *)deviceId
 openStreamState:(OpenStreamState)sState
       errorType:(StreamErrorType)errType;

/**
 关闭流状态回调
 
 @param deviceId 设备 ID
 @param cState 关流状态，参见‘CloseStreamState’
 @param errType 失败类型，参见‘StreamErrorType’
 */
- (void)deviceId:(NSString *)deviceId
closeStreamState:(CloseStreamState)cState
       errorType:(StreamErrorType)errType;

/**
 视频数据回调
 
 @param deviceId 设备 ID
 @param vBuffer 数据内容
 @param dLen 数据长度
 @param frameNo 帧序号
 @param timeStamp 帧时间戳
 @param fRate 帧率
 @param fType 帧类型，参见‘VideoFrameType’
 @param avChn AV 通道号
 */
- (void)deviceId:(NSString *)deviceId
       videoData:(unsigned char*)vBuffer
          length:(unsigned int)dLen
         frameNo:(unsigned int)frameNo
       timeStamp:(unsigned int)timeStamp
       frameRate:(unsigned int)fRate
       frameType:(VideoFrameType)fType
       avChannel:(int)avChn;

/**
 音频数据回调
 
 @param deviceId 设备 ID
 @param aBuffer 数据内容
 @param dLen 数据长度
 @param frameNo 帧序号
 @param acType 编码类型，参见‘AudioCodeType’
 */
- (void)deviceId:(NSString *)deviceId
       audioData:(unsigned char*)aBuffer
          length:(unsigned int)dLen
         frameNo:(unsigned int)frameNo
        codeType:(AudioCodeType)acType;

/**
 查询视频质量回调

 @param deviceId 设备 ID
 @isChecked 是否查询成功；YES：成功，NO：失败
 @param vqType 视频质量，参见‘VideoQualityType’
 */
- (void)deviceid:(NSString *)deviceId
       isChecked:(BOOL)isChecked
    videoQuality:(VideoQualityType)vqType;

/**
 对讲操作回调

 @param deviceId 设备 ID
 @param tEvent 对讲操作类型，参见‘TalkEvent’
 @param tState 对讲状态类型，参见‘TalkState’
 */
- (void)deviceId:(NSString *)deviceId
       talkEvent:(TalkEvent)tEvent
       talkState:(TalkState)tState;

@required

@end


@protocol iOSDevDownloadDelegate <NSObject>

@optional
/**
 下载 Record List 文件 结果回调
 
 @param deviceId 设备 ID
 @param isDownload 开始下载是否成功；YES：成功，NO：失败
 @param progress 下载进度
 @param dStatus 下载状态，参见‘DownloadRecStatus’
 @param fSize 下载文件总大小
 */
- (void)deviceId:(NSString *)deviceId
      isDownload:(BOOL)isDownload
        progress:(float)progress
          status:(DownloadRecStatus)dStatus
        fileSize:(long)fSize;
@end


@protocol iOSDevOperateDelegate <NSObject>

@optional

/**
 SD 卡回放操作回调
 
 @param isSuccess 是否操作成功；YES：成功，NO：失败
 @param eType 事件类型，参见‘SDCarPBEventType’
 */
- (void)sdCarPlayBack:(BOOL)isSuccess
          ofEventType:(SDCarPBEventType)eType;

@end

@interface iOSDevSDK : NSObject

@property (nonatomic, weak) id<iOSDevConnDelegate> connDelegate;
@property (nonatomic, weak) id<iOSDevSDKDelegate>delegate;
@property (nonatomic, weak) id<iOSDevDownloadDelegate>downloadDelegate;
@property (nonatomic, weak) id<iOSDevOperateDelegate>operateDelegate;

/**
 初始化单例
 */
+ (instancetype)shareDevSDK;

/*
 设置传输协议和服务器地址（一般只初始化一次）
 
 @param tpType 传输协议，参见‘TransportProType’
 @param serverIps 负载均衡分派服务器地址，多个地址以分号间隔，如：192.168.0.1:9999; 192.168.0.2:9999
 @return 是否设置成功；YES:成功，NO:失败
 */
- (BOOL)setTransportType:(TransportProType)tpType
           serverAddress:(NSString *)serverIps;

/**
 设置项目类型
 
 @param pType 项目类型，参见‘ProjectType’
 */
- (void)setProjectType:(ProjectType)pType;

/**
 启用日志
 
 @param isEnable 是否启用日志；YES:启用，NO：不启用
 */
- (void)enableLog:(BOOL)isEnable;

/**
 连接设备（到指定平台）
 
 @param deviceId 设备 ID
 @param password 设备密码
 @param npType 平台类型，参见‘NetProType’
 @param userParam 用户自定义参数（默认传：0）
 */
- (void)connDevId:(NSString *)deviceId
         password:(NSString *)password
       toPlatform:(NetProType)npType
    withUserParam:(long)userParam;

/**
 关闭设备连接
 
 @param deviceId 设备 ID
 */
- (void)disConnDevId:(NSString *)deviceId;

/*
 关闭所有设备连接（APP 退出时）
 */
- (void)disConnAllDevice;

/**
 打开数据流（Audio + Video）
 
 @param sType 设备数据流类型，参见‘DeviceStreamType’
 @param deviceId 设备 ID
 @param streamPwd 流加密密码（默认：@"user"）
 */
- (void)openStreamOfType:(DeviceStreamType)sType
               withDevId:(NSString *)deviceId
                password:(NSString *)streamPwd;

/**
 关闭数据流（Audio + Video）
 
 @param sType 设备数据流类型，参见‘DeviceStreamType’
 @param deviceId 设备 ID
 */
- (void)closeStreamOfType:(DeviceStreamType)sType
                withDevId:(NSString *)deviceId;

/**
 查询视频质量

 @param deviceId 设备ID
 */
- (void)checkQualityWithDevId:(NSString *)deviceId;

/**
 切换视频质量

 @param deviceId 设备 ID
 @param vqType 视频质量，参见‘VideoQualityType’
 */
- (void)switchWithDevId:(NSString *)deviceId
              toQuality:(VideoQualityType)vqType;

/**
 开启对讲

 @param deviceId 设备 ID
 */
- (void)startTalkWithDevId:(NSString *)deviceId;

/**
 发送对讲语音文件

 @param filePath 语音文件路径
 @param deviceId 设备 ID
 */
- (void)sendTalkFile:(NSString *)filePath
           withDevId:(NSString *)deviceId;

/**
 发送(实时)对讲语音数据
 
 @param buffer 语音数据
 @param size 数据大小
 @param deviceId 设备 ID
 */
- (void)sendTalkData:(unsigned char*)buffer
                size:(unsigned int)size
           withDevId:(NSString *)deviceId;

/**
 停止对讲

 @param deviceId 设备 ID
 */
- (void)stopTalkWithDevId:(NSString *)deviceId;

/**
 云台转动控制

 @param direction 转动方向，参见‘PTZCtrTurnDirection’
 @param deviceId 设备 ID
 */
- (void)ptzCtrTurnTo:(PTZCtrTurnDirection)direction
           withDevId:(NSString *)deviceId;

/**
 开始下载 Record List 文件

 @param fileName 文件名称
 @param savePath 保存路径
 @param deviceId 设备 ID
 @return 开始下载是否成功；YES：成功，NO：失败
 */
- (BOOL)startDownloadRecFileName:(NSString *)fileName
                      saveAtPath:(NSString *)savePath
                       withDevId:(NSString *)deviceId;

/**
 停止下载 Record List 文件
 
 @param deviceId 设备 ID
 */
- (void)stopDownloadRecOfDevice:(NSString *)deviceId;

/**
 SD 卡录像（视频流）回放操作
 
 @param eType 事件类型，参见‘SDCarPBEventType’
 @param startTime 请求起始时间
 @param duration 时长
 @param deviceId 设备 ID
 */
- (void)sdCarPlayBackWithEventType:(SDCarPBEventType)eType
                         startTime:(unsigned int)startTime
                          duration:(int)duration
                         withDevId:(NSString *)deviceId;

@end
