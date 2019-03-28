//
//  PushImageManager.m
//  GosIPCs
//
//  Created by shenyuanluo on 2018/12/21.
//  Copyright © 2018 goscam. All rights reserved.
//

#import "PushImageManager.h"
#import "SDWebImageManager.h"
#import "MediaManager.h"


#define PIM_MUTEX_TIMEOUT  15    // 超时时间


/** 推送图片类型枚举 */
typedef NS_ENUM(NSInteger, PushImgType) {
    PushImg_unknown                 = -1,   // 未知
    PushImg_jpg                     = 0,    // JPG
    PushImg_png                     = 1,    // PNG
};


@interface PushImageManager()

/** 推送图片下载队列（串行） */
@property (nonatomic, readwrite, strong) dispatch_queue_t downloadImgQueue;
/** 推送图片保存队列（串行） */
@property (nonatomic, readwrite, strong) dispatch_queue_t saveImgQueue;
/** 删除图片保存队列（串行） */
@property (nonatomic, readwrite, strong) dispatch_queue_t rmvImgQueue;
/** 需要下载的推送消息（图片）列表 */
@property (nonatomic, readwrite, strong) NSMutableArray<PushMessage*>*needDownloadMsgList;
/** 需要删除的推送消息（图片）列表 */
@property (nonatomic, readwrite, strong) NSMutableArray<PushMessage*>*needRmvMsgList;
/** 需要下载的推送消息列表访问 锁 */
@property (nonatomic, readwrite, strong) GosReadWriteLock *downloadListRWLock;
/** 需要删除的推送消息列表访问 锁 */
@property (nonatomic, readwrite, strong) GosReadWriteLock *rmvListRWLock;

@end

@implementation PushImageManager

+ (instancetype)shareManager
{
    static PushImageManager *g_manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        if (nil == g_manager)
        {
            g_manager = [[PushImageManager alloc] init];
        }
    });
    return g_manager;
}

- (instancetype)init
{
    if (self = [super init])
    {
        dispatch_queue_attr_t bgAttr         = dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL,
                                                                                       QOS_CLASS_BACKGROUND, 0);
        self.downloadImgQueue                = dispatch_queue_create("GosPushImageDownloadQueue", bgAttr);
        self.saveImgQueue                    = dispatch_queue_create("GosPushImageSaveQueue", bgAttr);
        self.rmvImgQueue                     = dispatch_queue_create("GosPushImageRemoveQueue", bgAttr);
//        self.downloadListRWLock              = [[GosReadWriteLock alloc] init];
        self.downloadListRWLock.readTimeout  = PIM_MUTEX_TIMEOUT;
        self.downloadListRWLock.writeTimeout = PIM_MUTEX_TIMEOUT;
//        self.rmvListRWLock                   = [[GosReadWriteLock alloc] init];
        self.rmvListRWLock.readTimeout       = PIM_MUTEX_TIMEOUT;
        self.rmvListRWLock.writeTimeout      = PIM_MUTEX_TIMEOUT;
    }
    return self;
}

#pragma mark - Public
#pragma mark -- 下载推送消息图片
+ (void)downloadImageWithMsg:(PushMessage *)pushMsg
{
    if (!pushMsg
        || IS_EMPTY_STRING(pushMsg.deviceId)
        || IS_EMPTY_STRING(pushMsg.pushUrl))
    {
        GosLog(@"PushImageManager：无法下载设备（ID = %@）推送消息图片（URL = %@）！", pushMsg.deviceId, pushMsg.pushUrl);
        return;
    }
    dispatch_async([self downloadQueue], ^{
        
        [[PushImageManager shareManager] downloadImageWithMsg:pushMsg];
    });
}

#pragma mark -- 删除推送消息图片
+ (void)rmvPushImgOfMsg:(PushMessage *)pushMsg
{
    if (!pushMsg
        || IS_EMPTY_STRING(pushMsg.deviceId)
        || IS_EMPTY_STRING(pushMsg.pushUrl))
    {
        GosLog(@"PushImageManager：无法删除设备（ID = %@）推送消息图片（URL = %@）！", pushMsg.deviceId, pushMsg.pushUrl);
        return;
    }
    [[self shareManager] rmvPushImgOfMsg:pushMsg];
}

#pragma mark --获取推送消息图片
+ (UIImage *)imgOfPushMsg:(PushMessage *)pushMsg
                    exist:(BOOL *)isExist
{
    if (!pushMsg
        || IS_EMPTY_STRING(pushMsg.deviceId))
    {
        GosLog(@"PushImageManager：无法获取设备（ID = %@）推送消息图片（URL = %@）！", pushMsg.deviceId, pushMsg.pushUrl);
        *isExist = NO;
        return nil;
    }
    if (IS_EMPTY_STRING(pushMsg.pushUrl))
    {
        GosLog(@"PushImageManager：无法获取设备（ID = %@）推送消息图片（URL = %@），使用封面！", pushMsg.deviceId, pushMsg.pushUrl);
        *isExist = YES; // URL 不存在，无法下载，则使用封面
       return [MediaManager coverWithDevId:pushMsg.deviceId
                                  fileName:nil
                                deviceType:GosDeviceIPC
                                  position:PositionMain];
    }
    return [[self shareManager] imgOfPushMsg:pushMsg
                                       exist:isExist];
}


#pragma mark -- 推送消息是否正在下载中
+ (BOOL)isDownloadingOfMsg:(PushMessage *)pushMsg
{
    if (!pushMsg
        || IS_EMPTY_STRING(pushMsg.deviceId)
        || IS_EMPTY_STRING(pushMsg.pushUrl))
    {
        GosLog(@"PushImageManager：无法查询设备（ID = %@）推送消息图片（URL = %@）是否正在下载中！", pushMsg.deviceId, pushMsg.pushUrl);
        return NO;
    }
    return [[self shareManager] isDownloadingOfMsg:pushMsg];
}


#pragma mark - Private
#pragma mark - 推送图片下载
- (void)downloadImageWithMsg:(PushMessage*)pushMsg
{
    if (!pushMsg
        || IS_EMPTY_STRING(pushMsg.deviceId)
        || IS_EMPTY_STRING(pushMsg.pushUrl))
    {
        GosLog(@"PushImageManager：无法下载设备（ID = %@）推送消息图片（URL = %@）！", pushMsg.deviceId, pushMsg.pushUrl);
        return;
    }
    __block BOOL isExist = NO;
    [self.downloadListRWLock lockWrite];
    [self.needDownloadMsgList enumerateObjectsWithOptions:NSEnumerationConcurrent
                                               usingBlock:^(PushMessage * _Nonnull obj,
                                                            NSUInteger idx,
                                                            BOOL * _Nonnull stop)
    {
        if ([obj isEqual:pushMsg])
        {
            isExist = YES;
            *stop   = NO;
        }
    }];
    if (YES == isExist)
    {
        GosLog(@"PushImageManager：设备（ID = %@）推送消息图片（URL = %@）正在下载中，无需再次下载！", pushMsg.deviceId, pushMsg.pushUrl);
        return;
    }
    [self.needDownloadMsgList addObject:pushMsg];
    [self.downloadListRWLock unLockWrite];
    
    GOS_WEAK_SELF;
    SDWebImageManager *manager = [SDWebImageManager sharedManager] ;
    [[manager imageDownloader] downloadImageWithURL:[NSURL URLWithString:pushMsg.pushUrl]
                                            options:SDWebImageDownloaderProgressiveDownload
                                           progress:^(NSInteger receivedSize,
                                                      NSInteger expectedSize,
                                                      NSURL * _Nullable targetURL)
     {
         GosPrintf("推送图片（URL = %s)已下载：%ld，总大小：%ld", pushMsg.pushUrl.UTF8String, (long)receivedSize, (long)expectedSize);
     }
                                          completed:^(UIImage * _Nullable image,
                                                      NSData * _Nullable data,
                                                      NSError * _Nullable error,
                                                      BOOL finished)
     {
         GOS_STRONG_SELF;
         if (YES == finished)
         {
             if (noErr == error)
             {
                 GosLog(@"PushImageManager：推送图片（URL = %@）已下载完成", pushMsg.pushUrl);
                 [strongSelf.rmvListRWLock lockWrite];
                 __block BOOL isNeedRmv = NO;
                 [strongSelf.needRmvMsgList enumerateObjectsWithOptions:NSEnumerationConcurrent
                                                             usingBlock:^(PushMessage * _Nonnull obj,
                                                                          NSUInteger idx,
                                                                          BOOL * _Nonnull stop)
                  {
                      if ([obj isEqual:pushMsg]) // 已标记为删除，不需要保存图片了
                      {
                          isNeedRmv = YES;
                          *stop     = YES;
                      }
                  }];
                 if (NO == isNeedRmv)   // 需要保存
                 {
                     [strongSelf saveImage:image
                                 ofPushMsg:pushMsg
                                  withType:PushImg_jpg];
                 }
                 else   // 已标记为删除，不需要保存图片了
                 {
                     GosLog(@"PushImageManager：设备（ID = %@）推送消息图片（URL = %@）已标记为删除，不需要保存图片了！", pushMsg.deviceId, pushMsg.pushUrl);
                     [strongSelf.needRmvMsgList removeObject:pushMsg];
                     [strongSelf notifyDownloadResult:NO
                                            ofPushMsg:pushMsg];
                 }
                 [strongSelf.rmvListRWLock unLockWrite];
             }
             else
             {
                 GosLog(@"PushImageManager：推送图片（URL = %@）下载失败：%@", pushMsg.pushUrl, error.localizedDescription);
                 [strongSelf.downloadListRWLock lockWrite];
                 [strongSelf.needDownloadMsgList removeObject:pushMsg];
                 [strongSelf.downloadListRWLock unLockWrite];
                 [strongSelf notifyDownloadResult:NO
                                        ofPushMsg:pushMsg];
             }
         }
     }];
    
}

#pragma mark -- 删除推送消息图片
- (void)rmvPushImgOfMsg:(PushMessage *)pushMsg
{
    if (!pushMsg
        || IS_EMPTY_STRING(pushMsg.deviceId)
        || IS_EMPTY_STRING(pushMsg.pushUrl))
    {
        GosLog(@"PushImageManager：无法删除设备（ID = %@）推送消息图片（URL = %@）！", pushMsg.deviceId, pushMsg.pushUrl);
        return;
    }
    GOS_WEAK_SELF;
    dispatch_async(self.rmvImgQueue, ^{
        
        GOS_STRONG_SELF;
        BOOL isDownloading = [strongSelf isDownloadingOfMsg:pushMsg];
        if (NO == isDownloading)    // 已完成下载
        {
            NSString *imgName  = [pushMsg.pushUrl lastPathComponent];
            NSString *imgPath =  [MediaManager pathWithDevId:pushMsg.deviceId
                                                    fileName:imgName
                                                   mediaType:GosMediaPushImage
                                                  deviceType:GosDeviceIPC
                                                    position:PositionMain];
            NSFileManager *fileManager = [NSFileManager defaultManager];
            BOOL isDir = NO;
            BOOL isExist = [fileManager fileExistsAtPath:imgPath
                                             isDirectory:&isDir];
            if (YES == isExist && NO == isDir)
            {
                NSError *error = nil;
                [fileManager removeItemAtPath:imgPath
                                        error:&error];
                if (error)
                {
                    GosLog(@"PushImageManager：删除设备（ID = %@）推送消息图片（URL = %@）失败：%@", pushMsg.deviceId, pushMsg.pushUrl, error.localizedDescription);
                }
                else
                {
                    GosLog(@"PushImageManager：删除设备（ID = %@）推送消息图片（URL = %@）成功！", pushMsg.deviceId, pushMsg.pushUrl);
                }
            }
            else
            {
                GosLog(@"PushImageManager：设备（ID = %@）推送消息图片（URL = %@）不存在，无法删除！", pushMsg.deviceId, pushMsg.pushUrl);
            }
        }
        else    // 正在下载中，将其标记为已删除
        {
            [strongSelf.rmvListRWLock lockWrite];
            [strongSelf.needRmvMsgList addObject:pushMsg];
            [strongSelf.rmvListRWLock unLockWrite];
        }
    });
}

- (UIImage *)imgOfPushMsg:(PushMessage *)pushMsg
                    exist:(BOOL *)isExist
{
    if (!pushMsg
        || IS_EMPTY_STRING(pushMsg.deviceId)
        || IS_EMPTY_STRING(pushMsg.pushUrl))
    {
        GosLog(@"PushImageManager：无法获取设备（ID = %@）推送消息图片（URL = %@）！", pushMsg.deviceId, pushMsg.pushUrl);
        *isExist = NO;
        return nil;
    }
    NSString *imgName = [pushMsg.pushUrl lastPathComponent];
    UIImage *retImg = [MediaManager pushImageWithDevId:pushMsg.deviceId
                                              fileName:imgName
                                            deviceType:GosDeviceIPC
                                              position:PositionMain
                                                 exist:isExist];
    return retImg;
}

#pragma mark -- 推送消息是否正在下载中
- (BOOL)isDownloadingOfMsg:(PushMessage *)pushMsg
{
    if (!pushMsg
        || IS_EMPTY_STRING(pushMsg.deviceId)
        || IS_EMPTY_STRING(pushMsg.pushUrl))
    {
        GosLog(@"PushImageManager：无法查询设备（ID = %@）推送消息图片（URL = %@）是否正在下载中！", pushMsg.deviceId, pushMsg.pushUrl);
        return NO;
    }
    [self.downloadListRWLock lockRead];
    __block BOOL isExist = NO;
    [self.needDownloadMsgList enumerateObjectsWithOptions:NSEnumerationConcurrent
                                               usingBlock:^(PushMessage * _Nonnull obj,
                                                            NSUInteger idx,
                                                            BOOL * _Nonnull stop)
    {
        if ([obj.deviceId isEqual:pushMsg])
        {
            isExist = YES;
            *stop   = YES;
        }
    }];
    [self.downloadListRWLock unLockRead];
    return isExist;
}


#pragma mark -- 保存已下载图片到沙盒
- (void)saveImage:(UIImage *)image
        ofPushMsg:(PushMessage *)pushMsg
         withType:(PushImgType)piType
{
    if (!pushMsg
        || IS_EMPTY_STRING(pushMsg.deviceId)
        || IS_EMPTY_STRING(pushMsg.pushUrl))
    {
        GosLog(@"PushImageManager：无法保存设备（ID = %@）推送消息图片（URL = %@）到沙盒中！", pushMsg.deviceId, pushMsg.pushUrl);
        return;
    }
    GOS_WEAK_SELF;
    dispatch_async(self.saveImgQueue, ^{
        
        GOS_STRONG_SELF;
        NSString *imgName  = [pushMsg.pushUrl lastPathComponent];
        NSString *savePath =  [MediaManager pathWithDevId:pushMsg.deviceId
                                                 fileName:imgName
                                                mediaType:GosMediaPushImage
                                               deviceType:GosDeviceIPC
                                                 position:PositionMain];
        BOOL ret = NO;
        switch (piType)
        {
            case PushImg_unknown:
            {
                ret = [UIImageJPEGRepresentation(image, 0) writeToFile:savePath
                                                            atomically:YES];
            }
                break;
                
            case PushImg_jpg:
            {
                ret = [UIImageJPEGRepresentation(image, 0) writeToFile:savePath
                                                            atomically:YES];
            }
                break;
                
            case PushImg_png:
            {
                ret = [UIImagePNGRepresentation(image)writeToFile:savePath
                                                       atomically:YES];
            }
                break;
                
            default:
                break;
        }
        if (YES == ret)
        {
            GosLog(@"PushImageManager：推送图片（URL = %@）已保存到沙盒！", pushMsg.pushUrl);
            [strongSelf.downloadListRWLock lockWrite];
            [strongSelf.needDownloadMsgList removeObject:pushMsg];
            [strongSelf.downloadListRWLock unLockWrite];
            [strongSelf notifyDownloadResult:YES
                                   ofPushMsg:pushMsg];
        }
    });
}

#pragma mark -- 发送下载结果通知
- (void)notifyDownloadResult:(BOOL)isSuccess
                   ofPushMsg:(PushMessage *)pushMsg
{
    if (!pushMsg || IS_EMPTY_STRING(pushMsg.deviceId) || IS_EMPTY_STRING(pushMsg.pushUrl))
    {
        GosLog(@"PushImageManager：无法发送推送图片下载结果通知：pushMsg = nil or deviceId = nil");
        return;
    }
    NSString *imgName  = [pushMsg.pushUrl lastPathComponent];
    NSDictionary *notifyData = @{@"DeviceId"       : pushMsg.deviceId,
                                 @"PushImgName"    : imgName,
                                 @"DownloadResult" : @(isSuccess)};
    [[NSNotificationCenter defaultCenter] postNotificationName:PUSH_IMG_DOWNLOAD_RESULT_NOTIFY
                                                        object:notifyData];
}

+ (dispatch_queue_t)downloadQueue
{
    return [PushImageManager shareManager].downloadImgQueue;
}


#pragma mark - 懒加载
- (NSMutableArray<PushMessage *> *)needDownloadMsgList
{
    if (!_needDownloadMsgList)
    {
        _needDownloadMsgList = [NSMutableArray arrayWithCapacity:0];
    }
    return _needDownloadMsgList;
}

- (NSMutableArray<PushMessage *> *)needRmvMsgList
{
    if (!_needRmvMsgList)
    {
        _needRmvMsgList = [NSMutableArray arrayWithCapacity:0];
    }
    return _needRmvMsgList;
}

@end
