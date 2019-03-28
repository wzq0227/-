//
//  MediaHeader.h
//  MediaManager
//
//  Created by shenyuanluo on 2017/7/21.
//  Copyright © 2017年 goscam. All rights reserved.
//

#ifndef MediaHeader_h
#define MediaHeader_h

/** 视频 画面位置枚举 */
typedef NS_ENUM(NSInteger, PositionType) {
    PositionMain                = 0,               // 主界面（针对普通 IPC）
    PositionTopLeft             = 1,               // 左上角（针对 NVR）
    PositionTopRight            = 2,               // 右上角（针对 NVR）
    PositionBottomLeft          = 3,               // 左下角（针对 NVR）
    PositionBottomRight         = 4,               // 右下角（针对 NVR）
};

/** 设备类型枚举 */
typedef NS_ENUM(NSInteger, GosDeviceType) {
    GosDeviceUnkown             = 0,                // 未知类型
    GosDeviceIPC                = 1,                // 普通 IPC
    GosDeviceNVR                = 2,                // NVR
    GosDevice180                = 4,                // 全景180
    GosDevice360                = 3,                // 全景360
};


/** 媒体类型枚举 */
typedef NS_ENUM(NSInteger, GosMediaType) {
    GosMediaCover               = 0,                // 封面（最后一帧图像，只保留最新一份） - jpg
    GosMediaSnapshot            = 1,                // 拍照                           - jpg
    GosMediaRecord              = 2,                // 录像                           - mp4
    GosMediaCloudH264           = 3,                // 云存储裸流（h264）               - h264
    GosMediaCloudCrop           = 4,                // 云存储裁剪                      - mp4
    GosMediaCloudPreview        = 5,                // 云存储裸流（h264）预览图          - jpg
    GosMediaTFCardPreview       = 6,                // TF 卡录像（视频流）预览图          - jpg
    GosMediaTFCardCrop          = 7,                // TF 卡裁剪                       - mp4
    GosMediaPushImage           = 8,                // 推送消息图片                     - jpg
    GosMediaTFRecVideo          = 9,                // TF 卡录制视频                    - mp4
    GosMediaTFRecPhoto          = 10,               // TF 卡抓拍图片                    - jpg
};



#endif /* MediaHeader_h */
