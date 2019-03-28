//
//  TFDownloadManager.m
//  GosIPCs
//
//  Created by shenyuanluo on 2019/1/5.
//  Copyright © 2019 goscam. All rights reserved.
//

#import "TFDownloadManager.h"
#import "iOSDevSDK.h"


#define TURN_TO_DUWNLOAD_OTHER_PROGRESS 0.5f

@interface TFDownloadManager() <
                                iOSDevDownloadDelegate
                               >

@property (nonatomic, readwrite, weak) id<TFDownloadManagerDelegate>delegate;
@property (nonatomic, readwrite, weak) iOSDevSDK *devSdk;
/** 下载队列 */
@property (nonatomic, readwrite, strong) dispatch_queue_t downloadQueue;
/** 是否正在下载 */
@property (nonatomic, readwrite, assign) BOOL isDownloading;
/** 当前下载进度 */
@property (nonatomic, readwrite, assign) float curProgress;
/** 下一下载媒体文件类型 */
@property (nonatomic, readwrite, assign) TFMediaFileType nextDownloadType;
/** 当前正在下载的 media */
@property (nonatomic, readwrite, strong) TFCRMediaModel *curDownloadMedia;
/** 需下载(视频)列表 */
@property (nonatomic, readwrite, strong) NSMutableArray<TFCRMediaModel*>*needDownloadVideoList;
/** 需下载(图片)列表 */
@property (nonatomic, readwrite, strong) NSMutableArray<TFCRMediaModel*>*needDownloadPhotoList;

@end

@implementation TFDownloadManager


#pragma mark - Public
+ (instancetype)shareManager
{
    static TFDownloadManager *g_manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        if (nil == g_manager)
        {
            g_manager = [[TFDownloadManager alloc] init];
        }
    });
    return g_manager;
}

- (instancetype)init
{
    if (self = [super init])
    {
        self.devSdk                  = [iOSDevSDK shareDevSDK];
        self.devSdk.downloadDelegate = self;
        dispatch_queue_attr_t bgAttr = dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL,
                                                                               QOS_CLASS_BACKGROUND,
                                                                               0);
        self.downloadQueue           = dispatch_queue_create("GosTFDownloadQueue", bgAttr);
        self.isDownloading           = NO;
    }
    return self;
}

- (void)dealloc
{
    GosLog(@"---------- TFDownloadManager dealloc ----------");
}

+ (void)configDeleagate:(id<TFDownloadManagerDelegate>)delegate
{
    if (!delegate)
    {
        return;
    }
    [[self shareManager] configDeleagate:delegate];
}

#pragma mark -- 开始下载 TF 卡录制媒体文件
+ (void)startDownloadMedia:(TFCRMediaModel *)media
{
    if (!media || IS_EMPTY_STRING(media.tfmFile.DeviceId)
        || IS_EMPTY_STRING(media.tfmFile.fileName))
    {
        GosLog(@"TFDownloadManager：无法开始下载 TF 卡媒体文件！");
        return;
    }
    [[self shareManager] startDownloadMedia:media];
}

#pragma mark -- 优先下载媒体类型文件列表
+ (void)priorityDownloadType:(TFMediaFileType)fileType
{
    [[self shareManager] priorityDownloadType:fileType];
}

#pragma mark -- 停止下载 TF 卡录制媒体(指定)文件
+ (void)stopDownloadMedia:(TFCRMediaModel *)media
{
    if (!media || IS_EMPTY_STRING(media.tfmFile.DeviceId)
        || IS_EMPTY_STRING(media.tfmFile.fileName))
    {
        GosLog(@"TFDownloadManager：无法停止下载 TF 卡媒体文件！");
        return;
    }
    [[self shareManager] stopDownloadMedia:media];
}

#pragma mark -- 停止下载 TF 卡媒体文件(指定)文件列表
+ (void)stopDownloadMediaList:(NSArray<TFCRMediaModel*>*)mediaList
{
    if (!mediaList || 0 == mediaList.count)
    {
        GosLog(@"TFDownloadManager：无法停止下载 TF 卡媒体文件(指定)文件列表！");
        return;
    }
    [[self shareManager] stopDownloadMediaList:mediaList];
}


#pragma mark -停止下载 TF 卡录制媒体(所有)文件
+ (void)stopAllDownload
{
    [[self shareManager] stopAllDownload];
}


#pragma mark - Private
#pragma mark -- 设置代理
- (void)configDeleagate:(id<TFDownloadManagerDelegate>)delegate
{
    self.delegate = delegate;
}

#pragma mark -- 开始下载 TF 卡录制媒体文件
- (void)startDownloadMedia:(TFCRMediaModel *)media
{
    if (!media || IS_EMPTY_STRING(media.tfmFile.DeviceId)
        || IS_EMPTY_STRING(media.tfmFile.fileName))
    {
        GosLog(@"TFDownloadManager：无法开始下载 TF 卡媒体文件！");
        return;
    }
    GOS_WEAK_SELF;
    dispatch_async(self.downloadQueue, ^{
        
        GOS_STRONG_SELF;
        if (NO == strongSelf.isDownloading) // 未有下载
        {
            GosLog(@"TFDownloadManager：开始下载 TF 卡媒体文件（%@）！", media.tfmFile.fileName);
            strongSelf.isDownloading    = YES;
            strongSelf.curProgress      = 0;
            strongSelf.curDownloadMedia = [media copy];
            BOOL ret = [strongSelf.devSdk startDownloadRecFileName:media.tfmFile.fileName
                                                        saveAtPath:media.mediaFilePath
                                                         withDevId:media.tfmFile.DeviceId];
            if (NO == ret)
            {
                GosLog(@"TFDownloadManager：开始下载 TF 卡媒体文件（%@）失败！", media.tfmFile.fileName);
                [strongSelf handleDownloadFailure:media.tfmFile.DeviceId];
            }
            else
            {
                GosLog(@"TFDownloadManager：开始下载 TF 卡媒体文件（%@）成功！", media.tfmFile.fileName);
            }
        }
        else    // 正在下载，先缓存
        {
            GosLog(@"TFDownloadManager：已有 TF 卡媒体文件下载中，执行策略。。。");
            if (media.tfmFile.fileType != strongSelf.curDownloadMedia.tfmFile.fileType)    // 类型不同，考虑是否转至下载另一类型
            {
                if ((TFMediaFile_video == strongSelf.curDownloadMedia.tfmFile.fileType
                     && TURN_TO_DUWNLOAD_OTHER_PROGRESS <= strongSelf.curProgress) // 视频，超过 50%，等待下载完成
                    || (TFMediaFile_photo == strongSelf.curDownloadMedia.tfmFile.fileType)) // 图片，等待当前下载完成
                {
                    GosLog(@"TFDownloadManager：文件类型变换了，等待当前下载 TF 卡媒体文件完成再切换！");
                    switch (media.tfmFile.fileType)
                    {
                        case TFMediaFile_video:
                        {
                            if (strongSelf.nextDownloadType == media.tfmFile.fileType)
                            {
                                GosLog(@"TFDownloadManager：文件（%@）类型变换了且与下次下载类型相同，则添加到队尾，等待下载！", media.tfmFile.fileName);
                                [strongSelf.needDownloadVideoList addObject:media];
                            }
                            else
                            {
                                GosLog(@"TFDownloadManager：文件（%@）类型刚刚开始变换了且与下次下载类型不相同，则添加到队头，等待下载！", media.tfmFile.fileName);
                                [strongSelf.needDownloadVideoList insertObject:media atIndex:0];
                            }
                        }
                            break;
                        case TFMediaFile_photo:
                        {
                            if (strongSelf.nextDownloadType == media.tfmFile.fileType)
                            {
                                GosLog(@"TFDownloadManager：文件（%@）类型变换了且与下次下载类型相同，则添加到队尾，等待下载！", media.tfmFile.fileName);
                                 [strongSelf.needDownloadPhotoList addObject:media];
                            }
                            else
                            {
                                GosLog(@"TFDownloadManager：文件（%@）类型刚刚开始变换了且与下次下载类型不相同，则添加到队头，等待下载！", media.tfmFile.fileName);
                                [strongSelf.needDownloadPhotoList insertObject:media atIndex:0];
                            }
                        }
                            break;
                        default: break;
                    }
                }
                else    // 直接停止当前下载
                {
                    GosLog(@"TFDownloadManager：文件类型变换了，停止当前下载 TF 卡媒体文件（%@）！", strongSelf.curDownloadMedia.tfmFile.fileName);
                    [strongSelf.devSdk stopDownloadRecOfDevice:strongSelf.curDownloadMedia.tfmFile.DeviceId];
                    [NSThread sleepForTimeInterval:0.05];    // 睡一会，切换下载
                    // 将当前下载的添加到缓存，重新等待下载
                    switch (strongSelf.curDownloadMedia.tfmFile.fileType)
                    {
                        case TFMediaFile_video: [strongSelf.needDownloadVideoList insertObject:strongSelf.curDownloadMedia atIndex:0]; break;
                        case TFMediaFile_photo:   [strongSelf.needDownloadPhotoList insertObject:strongSelf.curDownloadMedia atIndex:0]; break;
                        default: break;
                    }
                    // 切换下载
                    GosLog(@"TFDownloadManager：文件类型变换了，马上下载 TF 卡新媒体文件（%@）！", media.tfmFile.fileName);
                    strongSelf.isDownloading    = YES;
                    strongSelf.curProgress      = 0;
                    strongSelf.curDownloadMedia = [media copy];
                    BOOL ret = [strongSelf.devSdk startDownloadRecFileName:media.tfmFile.fileName
                                                                saveAtPath:media.mediaFilePath
                                                                 withDevId:media.tfmFile.DeviceId];
                    if (NO == ret)
                    {
                        GosLog(@"TFDownloadManager：开始下载 TF 卡媒体文件（%@）失败！", media.tfmFile.fileName);
                        [strongSelf handleDownloadFailure:media.tfmFile.DeviceId];
                    }
                    else
                    {
                        GosLog(@"TFDownloadManager：开始下载 TF 卡媒体文件（%@）成功！", media.tfmFile.fileName);
                    }
                }
            }
            else
            {
                GosLog(@"TFDownloadManager：文件类型没有变，直接缓存文件（%@）！", media.tfmFile.fileName);
                switch (media.tfmFile.fileType)
                {
                    case TFMediaFile_video: [strongSelf.needDownloadVideoList addObject:media]; break;
                    case TFMediaFile_photo:   [strongSelf.needDownloadPhotoList addObject:media]; break;
                    default: break;
                }
            }
        }
        strongSelf.nextDownloadType = media.tfmFile.fileType;
    });
}

#pragma mark -- 优先下载媒体类型文件列表
- (void)priorityDownloadType:(TFMediaFileType)fileType
{
    if (fileType == self.curDownloadMedia.tfmFile.fileType
        || NO == self.isDownloading)
    {
        GosLog(@"当前下载媒体文件类型与优先设置相同 或 没有任务在下载，无需处理！");
        return;
    }
    GOS_WEAK_SELF;
    dispatch_async(self.downloadQueue, ^{
        
        GOS_STRONG_SELF;
        if ((TFMediaFile_video == strongSelf.curDownloadMedia.tfmFile.fileType
             && TURN_TO_DUWNLOAD_OTHER_PROGRESS > strongSelf.curProgress)) // 视频，小 50%，则直接停止下载
        {
            GosLog(@"TFDownloadManager：优先下载媒体类型设置，等待当前下载 TF 卡媒体(视频)文件（%@）进度小于 0.5 直接停止下载！", strongSelf.curDownloadMedia.tfmFile.fileName);
            
            [strongSelf.devSdk stopDownloadRecOfDevice:strongSelf.curDownloadMedia.tfmFile.DeviceId];
            // 将当前下载的添加到缓存，重新等待下载
            switch (strongSelf.curDownloadMedia.tfmFile.fileType)
            {
                case TFMediaFile_video: [strongSelf.needDownloadVideoList insertObject:strongSelf.curDownloadMedia atIndex:0]; break;
                case TFMediaFile_photo:   [strongSelf.needDownloadPhotoList insertObject:strongSelf.curDownloadMedia atIndex:0]; break;
                default: break;
            }
            strongSelf.isDownloading    = NO;
            strongSelf.curDownloadMedia = nil;
            strongSelf.curProgress      = 0;
            [NSThread sleepForTimeInterval:0.05];    // 睡一会，切换下载
            
            // 修改为当前优先下载的文件
            switch (fileType)
            {
                case TFMediaFile_video:
                {
                    GosLog(@"TFDownloadManager：文件类型变换了，马上下载 TF 卡新媒体类型（视频）文件！");
                    strongSelf.curDownloadMedia = [strongSelf.needDownloadVideoList objectAtIndex:0];
                }
                    break;
                case TFMediaFile_photo:
                {
                    GosLog(@"TFDownloadManager：文件类型变换了，马上下载 TF 卡新媒体类型（图片）文件！");
                    strongSelf.curDownloadMedia = [strongSelf.needDownloadPhotoList objectAtIndex:0];
                }
                    break;
                    
                default:
                    break;
            }
            strongSelf.curProgress   = 0;
            strongSelf.isDownloading = YES;
            BOOL ret = [strongSelf.devSdk startDownloadRecFileName:strongSelf.curDownloadMedia.tfmFile.fileName
                                                        saveAtPath:strongSelf.curDownloadMedia.mediaFilePath
                                                         withDevId:strongSelf.curDownloadMedia.tfmFile.DeviceId];
            if (NO == ret)
            {
                GosLog(@"TFDownloadManager：开始下载 TF 卡媒体文件（%@）失败！", strongSelf.curDownloadMedia.tfmFile.fileName);
                [strongSelf handleDownloadFailure:strongSelf.curDownloadMedia.tfmFile.DeviceId];
            }
            else
            {
                GosLog(@"TFDownloadManager：开始下载 TF 卡媒体文件（%@）成功！", strongSelf.curDownloadMedia.tfmFile.fileName);
            }
        }
        self.nextDownloadType = fileType;
    });
}

#pragma mark -- 自动下载下一个
- (void)autoDownloadNext
{
    switch (self.nextDownloadType)
    {
        case TFMediaFile_video:
        {
            if (0 < self.needDownloadVideoList.count)
            {
                GosLog(@"TFDownloadManager：自动开始下载下一个 TF 卡媒体(视频)文件(%@)", self.needDownloadVideoList[0].tfmFile.fileName);
                [self startDownloadMedia:self.needDownloadVideoList[0]];
                [self.needDownloadVideoList removeObjectAtIndex:0]; // 同步移除缓存
            }
            else if (0 < self.needDownloadPhotoList.count)
            {
                GosLog(@"TFDownloadManager：(视频文件列表一下子完成)自动开始下载下一个 TF 卡媒体(图片)文件(%@)",  self.needDownloadPhotoList[0].tfmFile.fileName);
                [self startDownloadMedia:self.needDownloadPhotoList[0]];
                [self.needDownloadPhotoList removeObjectAtIndex:0]; // 同步移除缓存
            }
            else
            {
                GosLog(@"TFDownloadManager：所有缓存的 TF 卡媒体(视频、图片)文件都已经下载完！");
            }
        }
            break;
            
        case TFMediaFile_photo:
        {
            if (0 < self.needDownloadPhotoList.count)
            {
                GosLog(@"TFDownloadManager：自动开始下载下一个 TF 卡媒体(图片)文件(%@)", self.needDownloadPhotoList[0].tfmFile.fileName);
                [self startDownloadMedia:self.needDownloadPhotoList[0]];
                [self.needDownloadPhotoList removeObjectAtIndex:0]; // 同步移除缓存
            }
            else if (0 < self.needDownloadVideoList.count)
            {
                GosLog(@"TFDownloadManager：(图片文件列表一下子完成)自动开始下载下一个 TF 卡媒体(视频)文件(%@)",  self.needDownloadVideoList[0].tfmFile.fileName);
                [self startDownloadMedia:self.needDownloadVideoList[0]];
                [self.needDownloadVideoList removeObjectAtIndex:0]; // 同步移除缓存
            }
            else
            {
                GosLog(@"TFDownloadManager：所有缓存的 TF 卡媒体(视频、图片)文件都已经下载完！");
            }
        }
            break;
            
        default:
            break;
    }
}

#pragma mark -- 停止下载 TF 卡录制媒体文件
- (void)stopDownloadMedia:(TFCRMediaModel *)media
{
    if (!media || IS_EMPTY_STRING(media.tfmFile.DeviceId)
        || IS_EMPTY_STRING(media.tfmFile.fileName))
    {
        GosLog(@"TFDownloadManager：无法停止下载 TF 卡媒体文件！");
        return;
    }
    GOS_WEAK_SELF;
    dispatch_async(self.downloadQueue, ^{
        
        GOS_STRONG_SELF;
        if (NO == strongSelf.isDownloading) // 未有下载
        {
            GosLog(@"TFDownloadManager：没有下载 TF 卡媒体文件任务，无需停止下载！");
            return;
        }
        if (NO == [media isEqual:strongSelf.curDownloadMedia])
        {
            [strongSelf rmvNeedDownloadMedia:media];
        }
        else    // 正在下载
        {
            GosLog(@"TFDownloadManager：停止正在下载的下载 TF 卡媒体文件（%@）！", strongSelf.curDownloadMedia.tfmFile.fileName);
            [strongSelf.devSdk stopDownloadRecOfDevice:strongSelf.curDownloadMedia.tfmFile.DeviceId];
            [strongSelf rmvNonFinishMedia:strongSelf.curDownloadMedia];
            
            strongSelf.isDownloading    = NO;
            strongSelf.curDownloadMedia = nil;
            strongSelf.curProgress      = 0;
            // 下载下一个
            [strongSelf autoDownloadNext];
        }
    });
}

#pragma mark -- 停止下载 TF 卡媒体文件(指定)文件列表
- (void)stopDownloadMediaList:(NSArray<TFCRMediaModel*>*)mediaList
{
    if (!mediaList || 0 == mediaList.count)
    {
        GosLog(@"TFDownloadManager：无法停止下载 TF 卡媒体文件(指定)文件列表！");
        return;
    }
    GOS_WEAK_SELF;
    dispatch_async(self.downloadQueue, ^{
        
        GOS_STRONG_SELF;
        for (int i = 0; i < mediaList.count; i++)
        {
            @autoreleasepool
            {
                TFCRMediaModel *media = mediaList[i];
                if (NO == [media isEqual:strongSelf.curDownloadMedia])
                {
                    [strongSelf rmvNeedDownloadMedia:media];
                }
                else    // 正在下载
                {
                    GosLog(@"TFDownloadManager：停止正在下载的下载 TF 卡媒体文件（%@）！", strongSelf.curDownloadMedia.tfmFile.fileName);
                    [strongSelf.devSdk stopDownloadRecOfDevice:strongSelf.curDownloadMedia.tfmFile.DeviceId];
                    [strongSelf rmvNonFinishMedia:strongSelf.curDownloadMedia];
                    
                    strongSelf.isDownloading    = NO;
                    strongSelf.curDownloadMedia = nil;
                    strongSelf.curProgress      = 0;
                }
            }
        }
        GosLog(@"TFDownloadManager：完成停止下载 TF 卡媒体文件(指定)文件列表，开始自动下载下一个");
        // 下载下一个
        [strongSelf autoDownloadNext];
    });
}

#pragma mark --停止所有下载
- (void)stopAllDownload
{
    GOS_WEAK_SELF;
    dispatch_async(self.downloadQueue, ^{
        
        GOS_STRONG_SELF;
        if (NO == strongSelf.isDownloading) // 未有下载
        {
            GosLog(@"TFDownloadManager：没有下载 TF 卡媒体文件任务，无需停止！");
            return;
        }
        GosLog(@"TFDownloadManager：停止所有下载 TF 卡媒体文件！");
        [strongSelf.devSdk stopDownloadRecOfDevice:strongSelf.curDownloadMedia.tfmFile.DeviceId];
        [strongSelf rmvNonFinishMedia:strongSelf.curDownloadMedia];
        [strongSelf.needDownloadVideoList removeAllObjects];
        [strongSelf.needDownloadPhotoList removeAllObjects];
        strongSelf.isDownloading    = NO;
        strongSelf.curDownloadMedia = nil;
        strongSelf.curProgress      = 0;
    });
}

#pragma mark -- 删除排队等待下载的媒体文件
- (void)rmvNeedDownloadMedia:(TFCRMediaModel *)media
{
    if (!media)
    {
        return;
    }
    switch (media.tfmFile.fileType)
    {
        case TFMediaFile_video:
        {
            for (int i = 0; i < self.needDownloadVideoList.count; i++)
            {
                if ([media isEqual:self.needDownloadVideoList[i]])
                {
                    GosLog(@"TFDownloadManager：停止排队等待下载 TF 卡媒体(视频)文件（%@）！", media.tfmFile.fileName);
                    [self.needDownloadVideoList removeObjectAtIndex:i];
                    break;
                }
            }
        }
            break;
            
        case TFMediaFile_photo:
        {
            for (int i = 0; i < self.needDownloadPhotoList.count; i++)
            {
                if ([media isEqual:self.needDownloadPhotoList[i]])
                {
                    GosLog(@"TFDownloadManager：停止排队等待下载 TF 卡媒体(图片)文件（%@）！", media.tfmFile.fileName);
                    [self.needDownloadPhotoList removeObjectAtIndex:i];
                    break;
                }
            }
        }
            break;
            
        default:
            break;
    }
}

#pragma mark -- 处理下载失败结果
- (void)handleDownloadFailure:(NSString *)devId
{
    if (NO == [devId isEqualToString:self.curDownloadMedia.tfmFile.DeviceId])
    {
        GosLog(@"TFDownloadManager：TF 卡媒体文件下载失败设备（ID = %@）与正在下载设备（ID = %@）不匹配，无需处理！", devId, self.curDownloadMedia.tfmFile.DeviceId);
        return;
    }
    [self rmvNonFinishMedia:self.curDownloadMedia];

    // 发送下载失败通知
    NSDictionary *dict = @{kTFMediaKey : self.curDownloadMedia};
    [[NSNotificationCenter defaultCenter] postNotificationName:kTFMediaDownloadFailureNotify
                                                        object:dict];
    // 下载下一个
    GOS_WEAK_SELF;
    dispatch_async(self.downloadQueue, ^{
        
        GOS_STRONG_SELF;
        strongSelf.isDownloading    = NO;
        strongSelf.curDownloadMedia = nil;
        strongSelf.curProgress      = 0;
        [strongSelf autoDownloadNext];
    });
}

#pragma mark -- 处理成功下载结果
- (void)handleDevice:(NSString *)devId
      downloadResult:(DownloadRecStatus)status
            progress:(float)progress
{
    if (NO == [devId isEqualToString:self.curDownloadMedia.tfmFile.DeviceId])
    {
        GosLog(@"TFDownloadManager：TF 卡媒体文件下载结果设备（ID = %@）与正在下载设备（ID = %@）不匹配，无需处理！", devId, self.curDownloadMedia.tfmFile.DeviceId);
        return;
    }
    switch (status)
    {
        case DownloadRec_start: // 开始下载
        {
            GosLog(@"TFDownloadManager：开始下载设备（ID = %@）TF 卡录制文件（%@）成功！", self.curDownloadMedia.tfmFile.DeviceId, self.curDownloadMedia.tfmFile.fileName);
        }
            break;
            
        case DownloadRec_ing:   // 下载中
        {
//            GosLog(@"TFDownloadManager：设备（ID = %@）TF 卡录制文件下载进度：%f", self.curDownloadMedia.tfmFile.DeviceId, progress);
            if (self.delegate && [self.delegate respondsToSelector:@selector(downloadMedia:progress:)])
            {
                [self.delegate downloadMedia:self.curDownloadMedia
                                    progress:progress];
            }
        }
            break;
            
        case DownloadRec_end:   // 下载完成
        {
            GosLog(@"TFDownloadManager：设备（ID = %@）TF 卡录制文件（%@）下载完成！", self.curDownloadMedia.tfmFile.DeviceId, self.curDownloadMedia.tfmFile.fileName);
            
            // 发送下载成功通知
            NSDictionary *dict = @{kTFMediaKey : self.curDownloadMedia};
            [[NSNotificationCenter defaultCenter] postNotificationName:kTFMediaDownloadSuccessNotify
                                                                object:dict];
            
            // 下载下一个
            GOS_WEAK_SELF;
            dispatch_async(self.downloadQueue, ^{
                
                GOS_STRONG_SELF;
                strongSelf.isDownloading    = NO;
                strongSelf.curDownloadMedia = nil;
                strongSelf.curProgress      = 0;
                [strongSelf autoDownloadNext];
            });
        }
            break;
            
        default:
            break;
    }
}

#pragma mark -- 移除未下载完整的文件
- (void)rmvNonFinishMedia:(TFCRMediaModel *)media
{
    if (!media || IS_EMPTY_STRING(media.mediaFilePath))
    {
        GosLog(@"TFDownloadManager：无法移除未下载完整的 TF 卡媒体文件！");
        return;
    }
    NSFileManager *manager    = [NSFileManager defaultManager];
    BOOL isDir                = NO;
    BOOL isExist              = NO;
    NSError *error            = nil;
    isExist = [manager fileExistsAtPath:media.mediaFilePath isDirectory:&isDir];
    if (YES == isExist && NO == isDir)
    {
        [manager removeItemAtPath:media.mediaFilePath error:&error];
        if (error)
        {
            GosLog(@"TFDownloadManager：移除未下载完整的 TF 卡媒体文件(%@)失败：%@", media.mediaFilePath, error.localizedDescription);
        }
        else
        {
            GosLog(@"TFDownloadManager：移除未下载完整的 TF 卡媒体文件(%@)成功！", media.mediaFilePath);
        }
    }
}


#pragma mark - 懒加载
- (NSMutableArray<TFCRMediaModel *> *)needDownloadVideoList
{
    if (!_needDownloadVideoList)
    {
        _needDownloadVideoList = [NSMutableArray arrayWithCapacity:0];
    }
    return _needDownloadVideoList;
}

- (NSMutableArray<TFCRMediaModel *> *)needDownloadPhotoList
{
    if (!_needDownloadPhotoList)
    {
        _needDownloadPhotoList = [NSMutableArray arrayWithCapacity:0];
    }
    return _needDownloadPhotoList;
}


#pragma mark - iOSDevDownloadDelegate
- (void)deviceId:(NSString *)deviceId
      isDownload:(BOOL)isDownload
        progress:(float)progress
          status:(DownloadRecStatus)dStatus
        fileSize:(long)fSize
{
    GOS_WEAK_SELF;
    if (NO == isDownload)
    {
        GosLog(@"TFDownloadManager：下载设备（ID = %@）TF 卡录制文件（%@）失败！", deviceId, self.curDownloadMedia.tfmFile.fileName);
        dispatch_async(self.downloadQueue, ^{
            
            GOS_STRONG_SELF;
            [strongSelf handleDownloadFailure:deviceId];
        });
    }
    else
    {
        GOS_WEAK_SELF;
        dispatch_async([QueueManager bgQueue], ^{
            
            GOS_STRONG_SELF;
            strongSelf.curProgress = progress;
            [strongSelf handleDevice:deviceId
                      downloadResult:dStatus
                            progress:progress];
        });
    }
}

@end
