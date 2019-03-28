//
//  iOSPlayerSDKDefine.h
//  iOSPlayerSDK
//
//  Created by shenyuanluo on 2018/3/12.
//  Copyright © 2018年 goscam. All rights reserved.
//

#ifndef iOSPlayerSDKDefine_h
#define iOSPlayerSDKDefine_h


/** 录像操作状态 枚举 */
typedef NS_ENUM(NSInteger, RecordState) {
    Record_unknown                  = -2,       // 未知
    Record_faiure                   = -1,       // 录像失败
    Record_success                  = 0,        // 录像成功
    Record_time                     = 1,        // 录像时间
    Record_end                      = 2,        // 录像结束
};

/** 手势滑动方向 枚举 */
typedef NS_ENUM(NSInteger, SwipeGesDirection) {
    SwipeGes_up                     = 0,        // 上移
    SwipeGes_down                   = 1,        // 下移
    SwipeGes_left                   = 2,        // 左移
    SwipeGes_right                  = 3,        // 右移
};

/** 音频帧‘编码’类型 枚举 */
typedef NS_ENUM(NSInteger, PlayerAudioCodeType) {
    PlayerAudioCode_unknown         = 0,        // 未知
    PlayerAudioCode_aac             = 51,       // AAC
    PlayerAudioCode_g711a           = 52,       // G711-A 律
    PlayerAudioCode_g711u           = 53,       // G711-μ 律
    PlayerAudioCode_pcm             = 54,       // pcm
};

/** 解码 H264 文件状态枚举 */
typedef NS_ENUM(NSInteger, DecodeH264FileState) {
    DecodeH264_unknow               = -1,       // 未知
    DecodeH264_duration             = 0,        // 已获取总时长（此时可以获取预览图）
    DecodeH264_curTime              = 1,        // 当前播放时长
    DecodeH264_preview              = 2,        // 已获得预览图
    DecodeH264_finish               = 3,        // 解码结束
    DecodeH264_cutFinish            = 4,        // 剪切 H264（转换为 Mp4）完成
};

/** 解码 H264 流状态枚举 */
typedef NS_ENUM(NSInteger, DecodeH264StreamState) {
    DecodeH264Stream_unknow         = -1,       // 未知
    DecodeH264Stream_loading        = 0,        // 历史流加载中
    DecodeH264Stream_loadSuccess    = 1,        // 历史流加载完成
    DecodeH264Stream_startPlay      = 2,        // 历史流播放开始
    DecodeH264Stream_finishPlay     = 3,        // 历时流播放完成
    DecodeH264Stream_captureSuccess = 4,        // 历史流截图完成
    DecodeH264Stream_cutSuccess     = 5,        // 历时流剪切完成
};

/** 设置 SD 卡裸流文件操作类型枚举 */
typedef NS_ENUM(NSInteger, SDH264StreamOperationType) {
    SDH264StreamOperation_unknow    = -1,       // 未知
    SDH264StreamOperation_preview   = 0,        // 获取预览图
    SDH264StreamOperation_cut       = 1,        // 获取剪切图片
    SDH264StreamOperation_playBack  = 2,        // 回放
};

#endif /* iOSPlayerSDKDefine_h */
