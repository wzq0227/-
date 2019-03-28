//
//  TFDownloadManager.h
//  GosIPCs
//
//  Created by shenyuanluo on 2019/1/5.
//  Copyright © 2019 goscam. All rights reserved.
//

/*
 TF 卡录制媒体文件下载管理 类
 （智能切换最新下载类型列表队列）
 */

#import <Foundation/Foundation.h>
#import "TFCRMediaModel.h"

NS_ASSUME_NONNULL_BEGIN

/** TF 卡录制文件下载状态 枚举 */
typedef NS_ENUM(NSInteger, TFDownloadStatus) {
    TFDownload_err                  = -1,       // 下载出错
    TFDownload_start                = 0,        // 开始下载
    TFDownload_ing                  = 1,        // 下载中
    TFDownload_end                  = 2,        // 下载完成
};

// 下载失败通知：@{kTFMediaKey : @"***"}
static NSString * const kTFMediaDownloadFailureNotify = @"TFMediaDownloadFaulureNotify";
// 下载成功通知：@{kTFMediaKey : @"***"}
static NSString * const kTFMediaDownloadSuccessNotify = @"TFMediaDownloadSuccessNotify";

@protocol TFDownloadManagerDelegate <NSObject>
/*
 下载进度回调
 */
- (void)downloadMedia:(TFCRMediaModel *)media
             progress:(float)progress;
@end

@interface TFDownloadManager : NSObject


+ (void)configDeleagate:(id<TFDownloadManagerDelegate>)delegate;

/*
 开始下载 TF 卡录制媒体文件（目前只支持单文件下载，多次请求时会先缓存，等待下载）
 
 @param media 媒体文件 Model
 */
+ (void)startDownloadMedia:(TFCRMediaModel *)media;

/*
 优先下载 TF 卡媒体类型文件列表（用于切换 ‘视频/图片’ 列表时）
 
 @param tfType 媒体文件类型，参见‘TFMediaFileType’
 */
+ (void)priorityDownloadType:(TFMediaFileType)fileType;

/*
 停止下载 TF 卡录制媒体(指定)文件
 
 @param media 媒体文件 Model
 */
+ (void)stopDownloadMedia:(TFCRMediaModel *)media;

/**
 停止下载 TF 卡媒体文件(指定)文件列表
 */
+ (void)stopDownloadMediaList:(NSArray<TFCRMediaModel*>*)mediaList;

/*
  停止下载 TF 卡录制媒体(所有)文件
 */
+ (void)stopAllDownload;

@end

NS_ASSUME_NONNULL_END
