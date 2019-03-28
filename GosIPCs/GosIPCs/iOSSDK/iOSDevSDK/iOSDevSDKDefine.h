//
//  iOSDevSDKDefine.h
//  iOSDevSDK
//
//  Created by shenyuanluo on 2018/3/12.
//  Copyright © 2018年 goscam. All rights reserved.
//

#ifndef iOSDevSDKDefine_h
#define iOSDevSDKDefine_h


/** App 与设备连接状态 枚举 */
typedef NS_ENUM(NSInteger, DeviceConnState) {
    DeviceDisConnFailure            = -2,       // 断开连接失败
    DeviceConnFailure               = -1,       // 连接失败
    DeviceConnUnConn                = 0,        // 未连接
    DeviceConnecting                = 1,        // 正在连接
    DeviceConnSuccess               = 2,        // 连接成功
};

/** 设备数据流类型 枚举 */
typedef NS_ENUM(NSInteger, DeviceStreamType) {
    DeviceStream_unknow             = -1,       // 未知
    DeviceStream_video              = 0,        // 视频流
    DeviceStream_audio              = 1,        // 音频流
    DeviceStream_all                = 2,        // 音视频流
    DeviceStream_live               = 3,        // 直播流（4.0）
    DeviceStream_rec                = 4,        // 历史流（TF 卡录像）
};

/** 打开流状态 枚举 */
typedef NS_ENUM(NSInteger, OpenStreamState) {
    OpenStreamUnknown               = -2,       // 未知
    OpenStreamFailure               = -1,       // 开流失败
    OpenStreamSuccess               = 0,        // 开流成功
};

/** 关闭流状态 枚举 */
typedef NS_ENUM(NSInteger, CloseStreamState) {
    CloseStreamUnknown               = -2,       // 未知
    CloseStreamFailure               = -1,       // 关流失败
    CloseStreamSuccess               = 0,        // 关流成功
};

/** 操作流失败类型 枚举 */
typedef NS_ENUM(NSInteger, StreamErrorType) {
    StreamError_unknown             = -2,       // 未知
    StreamError_disConn             = -1,       // 设备未连接成功
    StreamError_No                  = 0,        // 未发生错误
    StreamError_Closed              = 1,        // 流已关闭
};

/** 视频帧类型 枚举 */
typedef NS_ENUM(NSInteger, VideoFrameType) {
    VideoFrame_unknown              = 0,        // 未知
    VideoFrame_iFrame               = 1,        // I 帧
    VideoFrame_pFrame               = 2,        // P 帧
    VideoFrame_bFrame               = 3,        // B 帧
    VideoFrame_recIFrame            = 4,        // 录像 I 帧
    VideoFrame_recPFrame            = 5,        // 录像 P 帧
    VideoFrame_recBFrame            = 6,        // 录像 B 帧
    VideoFrame_recEndFrame          = 7,        // 录像完成(不带数据)
    VideoFrame_cutIFrame            = 8,        // 剪接 I 帧
    VideoFrame_cutPFrame            = 9,        // 剪接 P 帧
    VideoFrame_cutBFrame            = 10,       // 剪接 B 帧
    VideoFrame_cutEndFrame          = 11,       // 剪接完成(不带数据)
    VideoFrame_prviewIFrame         = 12,       // 预览图
    VideoFrame_recStartFrame        = 13,       // 开始播放历时流（不带数据）
    VideoFrame_endFrame             = 14,       //
};

/** 视频帧‘编码’类型 枚举 */
typedef NS_ENUM(NSInteger, VideoCodeType) {
    VideoCode_unknown               = 0,        // 未知
    VideoCode_h264                  = 11,       // H264
    VideoCode_h265                  = 13,       // H265
    VideoCode_mpeg4                 = 14,       // MPEG-4
    VideoCode_mjpeg                 = 15,       // MJPEG
    VideoCode_jpeg                  = 16,       // JPEG
};

/** 音频帧‘编码’类型 枚举 */
typedef NS_ENUM(NSInteger, AudioCodeType) {
    AudioCode_unknown               = 0,        // 未知
    AudioCode_aac                   = 51,       // AAC
    AudioCode_g711a                 = 52,       // G711-A 律
    AudioCode_g711u                 = 53,       // G711-μ 律
    AudioCode_pcm                   = 54,       // pcm
};

/** 视频质量 枚举 */
typedef NS_ENUM(NSInteger, VideoQualityType) {
    VideoQuality_unknown            = -1,       // 未知
    VideoQuality_HD                 = 0,        // 高清
    VideoQuality_SD                 = 1,        // 标清
};

/** 对讲操作类型 枚举 */
typedef NS_ENUM(NSInteger, TalkEvent) {
    Talk_start                      = 0,        // 开启对讲
    Talk_stop                       = 1,        // 停止对讲
    Talk_sendFile                   = 2,        // 发送对讲文件
};

/** 对讲状态类型 枚举 */
typedef NS_ENUM(NSInteger, TalkState) {
    Talk_unknown                    = -1,       // 未知
    Talk_Failure                    = 0,        // 失败
    Talk_success                    = 1,        // 成功
};

/** 云台转动方向 枚举 */
typedef NS_ENUM(NSInteger, PTZCtrTurnDirection) {
    PTZCtrTurn_up                   = 0,        // 向上转动
    PTZCtrTurn_down                 = 1,        // 向下转动
    PTZCtrTurn_left                 = 2,        // 向左转动
    PTZCtrTurn_right                = 3,        // 向右转动
};

/** Record List 文件下载状态 枚举 */
typedef NS_ENUM(NSInteger, DownloadRecStatus) {
    DownloadRec_err                 = -1,       // 下载出错
    DownloadRec_start               = 0,        // 开始下载
    DownloadRec_ing                 = 1,        // 下载中
    DownloadRec_end                 = 2,        // 下载完成
};

/* 传输协议类型（初始化时指定） */
typedef NS_ENUM(NSInteger, TransportProType) {
    TransportPro_All                = 0,        // 启用所有（打洞、转发。。。）
    TransportPro_P2P                = 1,        // 只打洞
    TransportPro_Relay              = 2,        // 只转发
};

/** 平台类型枚举 */
typedef NS_ENUM(NSInteger, NetProType) {
    NetPro_TUTK                    = 0x01,     // TUTK
    NetPro_P2P                     = 0x02,     // 4.0 p2p
    NetPro_TCP                     = 0x03,     // 4.0 tcp
};

/* 项目类型枚举 */
typedef NS_ENUM(NSInteger, ProjectType) {
    Project_Default                 = 0,        // 默认项目
    Project_DoorLamp                = 1,        // 门灯项目
};

/* SD 卡回放事件类型 */
typedef NS_ENUM(NSInteger, SDCarPBEventType) {
    SDCarPBEvent_unknow             = -1,       // 未知
    SDCarPBEvent_preview            = 0,        // 获取预览图
    SDCarPBEvent_playback           = 1,        // 开始回放
    SDCarPBEvent_clip               = 2,        // 裁剪视频
    SDCarPBEvent_stop               = 3,        // 停止回放
};


#endif /* iOSDevSDKDefine_h */
