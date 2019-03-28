//  PlaybackPlayerDataHandler.m
//  Goscom
//
//  Create by daniel.hu on 2019/2/16.
//  Copyright © 2019年 goscam. All rights reserved.

#import "PlaybackPlayerDataHandler.h"
#import "TokenCheckApiManager.h"
#import "CloudDownloadFileApiManager.h"
#import "TokenCheckApiRespModel.h"
#import "VideoSlicesApiRespModel.h"
#import "PlaybackPlayerMediaHelper.h"
#import "GosThreadTimer.h"

@interface PlaybackPlayerDataHandler () <GosApiManagerCallBackDelegate>
#pragma mark - api manager
/// 获取TOKEN 管理者
@property (nonatomic, strong) TokenCheckApiManager *tokenCheckApiManager;
/// 文件下载 管理者
@property (nonatomic, strong) CloudDownloadFileApiManager *cloudDownloadFileApiManager;
/// 接收到的Token
@property (nonatomic, strong) TokenCheckApiRespModel *receivedTokenModel;

#pragma mark - received
/// 外部接收到的video
@property (nonatomic, copy) __block VideoSlicesApiRespModel *receivedVideoModel;
/// 设备id
@property (nonatomic, copy) NSString *deviceId;

#pragma mark - preview
/// 预览图存储路径
@property (nonatomic, copy) NSString *previewFilePath;
/// 预览图源文件路径
@property (nonatomic, copy) NSString *previewVideoFilePath;
/// 预览图开始时间戳
@property (nonatomic, assign) NSTimeInterval previewStartTimestamp;
/// 从0开始的时间点
@property (nonatomic, assign) NSUInteger onTime;

#pragma mark - play
/// H264文件路径
@property (nonatomic, copy) NSString *videoFilePath;
/// 开始时间戳
@property (nonatomic, assign) NSTimeInterval startTimestamp;
/// 总时长
@property (nonatomic, assign) NSUInteger duration;

#pragma mark - clip
/// 剪切存储目标路径
@property (nonatomic, copy) NSString *clipFilePath;
/// 剪切开始时间
@property (nonatomic, assign) NSUInteger clipStartTime;
/// 剪切总时长
@property (nonatomic, assign) NSUInteger clipDuration;
/// 获取剪切数据 多线程组
@property (nonatomic, strong) dispatch_group_t clipFetchGroup;
/// 获取剪切数据 队列（串行）
@property (nonatomic, strong) dispatch_queue_t clipFetchQueue;
/// 获取剪切数据 信号量
@property (nonatomic, strong) dispatch_semaphore_t clipSemaphore;

#pragma mark - task
/// 下载进程id
@property (nonatomic, assign) NSInteger downloadTaskId;
/// 获取token进程id
@property (nonatomic, assign) NSInteger fetchTokenTaskId;

#pragma mark - other
/// 获取Token的定时器
@property (nonatomic, strong) GosThreadTimer *fetchTokenTimer;


@end

@implementation PlaybackPlayerDataHandler
#pragma mark - initialization
- (instancetype)initWithDeviceId:(NSString *)deviceId {
    if (self = [super init]) {
        _deviceId = deviceId;
        _fetchTokenTaskId = NSIntegerMax;
        _downloadTaskId = NSIntegerMax;
        _onTime = NSUIntegerMax;
    }
    return self;
}


#pragma mark - public method
- (void)data_handler_fetchPreviewFilePathWithVideoModel:(VideoSlicesApiRespModel *)videoModel
                                                 onTime:(NSUInteger)onTime {
    
    // H264文件是否存在
    BOOL videoExist = [self videoFileExistWithVideoModel:videoModel];
    
    if (videoExist) {
        // 判断预览图是否存在
        BOOL previewExist = [self previewFileExistWithVideoModel:videoModel onTime:onTime];
        
        NSString *previewFilePath = [self previewFilePathWithVideoModel:videoModel onTime:onTime];
        NSTimeInterval startTimestamp = [videoModel.startTime doubleValue];
        
        if (previewExist) {
            // H264文件存在，存在预览图
            if (_delegate && [_delegate respondsToSelector:@selector(data_handler:previewExistAtImageFilePath:startTimestamp:onTime:)]) {
                [_delegate data_handler:self
            previewExistAtImageFilePath:previewFilePath startTimestamp:startTimestamp onTime:onTime];
            }
            
        } else {
            // H264文件存在，不存在预览图
            NSString *videoFilePath = [self videoFilePathWithVideoModel:videoModel];
            
            if (_delegate && [_delegate respondsToSelector:@selector(data_handler:previewNotExistAtImageFilePath:videoFilePath:startTimestamp:onTime:)]) {
                [_delegate data_handler:self
         previewNotExistAtImageFilePath:previewFilePath
                          videoFilePath:videoFilePath
                         startTimestamp:startTimestamp
                                 onTime:onTime];
            }
        }
    } else {
        // H264文件不存在
        _receivedVideoModel = videoModel;
        
        NSString *videoFilePath = [self videoFilePathWithVideoModel:videoModel];
        NSString *previewFilePath = [self previewFilePathWithVideoModel:videoModel onTime:onTime];
        
        // 预览图源文件H264路径
        _previewVideoFilePath = videoFilePath;
        // 预览图存储
        _previewFilePath = previewFilePath;
        _previewStartTimestamp = [videoModel.startTime doubleValue];
        _onTime = onTime;
        
        // 下载视频文件
        [self downloadVideoProcess];
    }
}

- (void)data_handler_fetchVideoFilePathWithVideoModel:(VideoSlicesApiRespModel *)videoModel {
    // H264文件是否存在
    BOOL videoExist = [self videoFileExistWithVideoModel:videoModel];
    
    if (videoExist) {
        // H264文件存在
        if (_delegate && [_delegate respondsToSelector:@selector(data_handler:videoExistAtVideoFilePath:startTimestamp:duration:)]) {
            
            NSString *videoFilePath = [self videoFilePathWithVideoModel:videoModel];
            NSTimeInterval startTimestamp = [videoModel.startTime doubleValue];
            NSUInteger duration = (NSUInteger)ABS(([videoModel.endTime doubleValue] - [videoModel.startTime doubleValue]));
            
            [_delegate data_handler:self
          videoExistAtVideoFilePath:videoFilePath
                     startTimestamp:startTimestamp
                           duration:duration];
        }
    } else {
        // H264文件不存在
        // 此逻辑处理 在播放完上一H264文件后，自动播放下一视频
        _receivedVideoModel = videoModel;
        _videoFilePath = [self videoFilePathWithVideoModel:videoModel];
        _startTimestamp = [videoModel.startTime doubleValue];
        _duration = (NSUInteger)ABS(([videoModel.endTime doubleValue] - [videoModel.startTime doubleValue]));
        
        if (_delegate && [_delegate respondsToSelector:@selector(data_handler:videoNotExistAtVideoFilePath:startTimestamp:duration:)]) {
            
            NSTimeInterval startTimestamp = [videoModel.startTime doubleValue];
            NSUInteger duration = (NSUInteger)ABS(([videoModel.endTime doubleValue] - [videoModel.startTime doubleValue]));
            
            [_delegate data_handler:self
       videoNotExistAtVideoFilePath:_videoFilePath
                     startTimestamp:startTimestamp
                           duration:duration];
        }
        
        // 下载视频文件
        [self downloadVideoProcess];
    }
}

- (NSString *)data_handler_fetchSnapshotFilePath {
    return [self snapshotFilePath];
}

- (void)data_handler_fetchClipFilePathWithVideos:(NSArray<VideoSlicesApiRespModel *> *)videos
                                        fileName:(NSString *)fileName
                                       startTime:(NSUInteger)startTime
                                        duration:(NSUInteger)duration {

    // 剪切目标文件路径
    NSString *clipFilePath = [self clipFilePathWithVideoModel:nil
                                                     fileName:fileName
                                                    startTime:startTime];
    _clipFilePath = clipFilePath;
    _clipStartTime = startTime;
    _clipDuration = duration;
    
    if (!_clipFetchGroup) {
        _clipFetchGroup = dispatch_group_create();
    }
    if (!_clipFetchQueue) {
        _clipFetchQueue = dispatch_queue_create("FetchClipDownloadQueue", DISPATCH_QUEUE_SERIAL);
    }
    if (!_clipSemaphore) {
        _clipSemaphore = dispatch_semaphore_create(1);
    }
    // 判断是否都已经存在文件
    BOOL existNoFile = NO;
    for (VideoSlicesApiRespModel *model in videos) {
        BOOL fileExist = [self videoFileExistWithVideoModel:model];
        // 如果不存在就去下载
        if (!fileExist) {
            existNoFile = YES;
            
            dispatch_group_enter(self.clipFetchGroup);
            GOS_WEAK_SELF
            dispatch_group_async(self.clipFetchGroup, self.clipFetchQueue, ^{
                GOS_STRONG_SELF
                dispatch_semaphore_wait(strongSelf.clipSemaphore, DISPATCH_TIME_FOREVER);
                GosLog(@"下载一次");
                // 请求下载
                strongSelf.receivedVideoModel = model;
                
                [strongSelf downloadVideoProcess];
            });
        }
    }
    
    if (existNoFile) {
        // 存在未下载
        GOS_WEAK_SELF
        dispatch_group_notify(self.clipFetchGroup, self.clipFetchQueue, ^{
            GOS_STRONG_SELF
            GosLog(@"下载完成");
            // 到此处说明下载完成了
            // 组装视频文件
            NSString *tempFilePath = [strongSelf combineVideoFileToTemporaryForClipWithVideos:videos];
            if (strongSelf.delegate && [strongSelf.delegate respondsToSelector:@selector(data_handler:clipVideoFilePath:startTime:totalTime:fromOriginVideoFilePath:)]) {
                [strongSelf.delegate data_handler:self
                                clipVideoFilePath:strongSelf.clipFilePath
                                        startTime:strongSelf.clipStartTime
                                        totalTime:strongSelf.clipDuration
                          fromOriginVideoFilePath:tempFilePath];
            }
            // 重置参数
            [strongSelf resetClipParameters];
        });
    } else {
        GosLog(@"已经下载过了");
        // 到此处说明都已经下载过了
        // 组装视频文件
        NSString *tempFilePath = [self combineVideoFileToTemporaryForClipWithVideos:videos];
        if (_delegate && [_delegate respondsToSelector:@selector(data_handler:clipVideoFilePath:startTime:totalTime:fromOriginVideoFilePath:)]) {
            [_delegate data_handler:self
                  clipVideoFilePath:_clipFilePath
                          startTime:_clipStartTime
                          totalTime:_clipDuration
            fromOriginVideoFilePath:tempFilePath];
        }
        // 重置参数
        [self resetClipParameters];
    }
    
}

- (BOOL)data_handler_fileExistAtFilePath:(NSString *)filePath {
    return [PlaybackPlayerMediaHelper fileExistWithFilePath:filePath];
}

- (void)data_handler_clean {
    // 取消正在请求
    [self.cloudDownloadFileApiManager cancelRequestWithRequestId:_downloadTaskId];
    [self.tokenCheckApiManager cancelRequestWithRequestId:_fetchTokenTaskId];
    // 重置参数
    [self resetParameters];
    // 摧毁定时器
    [self destoryFetchTokenThread];
}


#pragma mark - GosApiManagerCallBackDelegate
- (void)managerCallApiDidSuccess:(GosApiBaseManager *)manager {
    if (manager == self.tokenCheckApiManager) {
        id result = [manager fetchDataWithReformer:self.tokenCheckApiManager];
        // 设置token
        if (result) { _receivedTokenModel = result; }
        
        // 有videoModel 的时候才下载
        if (result && _receivedVideoModel) {
            tryDownloadTimes = 0;
            // 下载Video
            [self requestVideoWithDeviceId:_deviceId
                                tokenModel:_receivedTokenModel
                                videoModel:_receivedVideoModel];
        }
    } else if (manager == self.cloudDownloadFileApiManager) {
        // 下载成功
        // 重置下载视频信息
        [self resetVideoModel];
        // 当前下载的文件路径
        NSString *downloadFilePath = manager.response.filePath.path;
        
        if (_clipFilePath) {
            GosLog(@"下载成功：获取剪切文件");
            // 剪切下载逻辑
            dispatch_semaphore_signal(self.clipSemaphore);
            dispatch_group_leave(self.clipFetchGroup);
            
        } else if ([downloadFilePath isEqualToString:_previewVideoFilePath]) {
            GosLog(@"下载成功：获取预览图");
            // 进入此处表示在获取预览图发现没有视频文件，以_onTime != NSUIntegerMax作为判断标志
            // 说明此前调用-data_handler_fetchPreviewWithVideoModel:onTime:
            if (_delegate && [_delegate respondsToSelector:@selector(data_handler:previewNotExistAtImageFilePath:videoFilePath:startTimestamp:onTime:)]) {
                [_delegate data_handler:self
         previewNotExistAtImageFilePath:_previewFilePath
                          videoFilePath:_previewVideoFilePath
                         startTimestamp:_previewStartTimestamp
                                 onTime:_onTime];
            }
            
        } else if ([downloadFilePath isEqualToString:_videoFilePath]) {
            GosLog(@"下载成功：获取视频文件");
            // 进入此处表示只是获取视频文件
            // 说明此前调用-data_handler_fetchVideoWithVideoModel:
            if (_delegate && [_delegate respondsToSelector:@selector(data_handler:videoExistAtVideoFilePath:startTimestamp:duration:)]) {
                [_delegate data_handler:self
              videoExistAtVideoFilePath:_videoFilePath
                         startTimestamp:_startTimestamp
                               duration:_duration];
            }
        } else {
            GosLog(@"下载成功：丢弃处理 路径——%@", downloadFilePath);
        }
    }
}
// 重试下载
static int tryDownloadTimes = 0;
- (void)managerCallApiDidFailed:(GosApiBaseManager *)manager {
    if (manager == self.tokenCheckApiManager) {
        GosLog(@"获取Token失败");
        [self requestTokenWithDeviceId:_deviceId];
        
    } else if (manager == self.cloudDownloadFileApiManager) {
        // 下载失败
        GosLog(@"下载失败");
        tryDownloadTimes ++;
        if (tryDownloadTimes >= 2) {
            [self resetVideoModel];
            return ;
        }
        
        // 可能是TOKEN有问题，就重新获取TOKEN
        [self requestTokenWithDeviceId:_deviceId];
        // 下载Video
//        [self requestVideoWithDeviceId:_deviceId
//                            tokenModel:_receivedTokenModel
//                            videoModel:_receivedVideoModel];

    }
    
}

#pragma mark - media helper (PlaybackPlayerMediaHelper)
/// 判断下载的H264文件目标文件是否已存在
- (BOOL)videoFileExistWithVideoModel:(VideoSlicesApiRespModel *)videoModel {
    return [PlaybackPlayerMediaHelper videoFileExistWithDeviceId:_deviceId
                                                      videoModel:videoModel];
}

/// 获取H264下载路径
- (NSString *)videoFilePathWithVideoModel:(VideoSlicesApiRespModel *)videoModel {
    return [PlaybackPlayerMediaHelper videoFilePathWithDeviceId:_deviceId
                                                     videoModel:videoModel];
}

/// 判断预览图文件是否已存在
- (BOOL)previewFileExistWithVideoModel:(VideoSlicesApiRespModel *)videoModel
                              onTime:(NSUInteger)onTime {
    return [PlaybackPlayerMediaHelper previewFileExistWithDeviceId:_deviceId
                                                        videoModel:videoModel
                                                            onTime:onTime];
}

/// 获取预览图下载路径
- (NSString *)previewFilePathWithVideoModel:(VideoSlicesApiRespModel *)videoModel
                                   onTime:(NSUInteger)onTime {
    return [PlaybackPlayerMediaHelper previewFilePathWithDeviceId:_deviceId
                                                       videoModel:videoModel
                                                           onTime:onTime];
}

/// 获取截图路径
- (NSString *)snapshotFilePath {
    return [PlaybackPlayerMediaHelper snapshotFilePathWithDeviceId:_deviceId];
}

/// 获取剪切文件路径
- (NSString *)clipFilePathWithVideoModel:(VideoSlicesApiRespModel *)videoModel
                                fileName:(NSString *)fileName
                               startTime:(NSUInteger)startTime {
    // 如filename未空，则使用默认名
    if (IS_EMPTY_STRING(fileName)) {
        fileName = [PlaybackPlayerMediaHelper clipFileNameWithVideoModel:videoModel startTime:startTime];
    }
    return [PlaybackPlayerMediaHelper clipFilePathWithDeviceId:_deviceId
                                                      fileName:fileName];
}

/// 判断临时文件是否已存在
- (BOOL)temporaryVideoFileForClipExist {
    return [PlaybackPlayerMediaHelper temporaryVideoFileForClipExist];
}

/// 获取临时文件路径
- (NSString *)temporaryVideoFilePathForClip {
    return [PlaybackPlayerMediaHelper temporaryVideoFilePathForClip];
}

#pragma mark - request method
- (void)requestTokenWithDeviceId:(NSString *)deviceId {
    // 先取消
    [self.tokenCheckApiManager cancelRequestWithRequestId:_fetchTokenTaskId];
    // 在请求
    _fetchTokenTaskId = [self.tokenCheckApiManager loadDataWithDeviceId:deviceId];
    
}

- (void)requestVideoWithDeviceId:(NSString *)deviceId
                      tokenModel:(TokenCheckApiRespModel *)tokenModel
                      videoModel:(VideoSlicesApiRespModel *)videoModel {
    // H264文件存储路径
    NSString *filePath = [PlaybackPlayerMediaHelper videoFilePathWithDeviceId:deviceId videoModel:videoModel];
    NSURL *fileURL = [NSURL fileURLWithPath:filePath];
    
    // 先取消
//    [self.cloudDownloadFileApiManager cancelRequestWithRequestId:_downloadTaskId];
    // 再下载
    _downloadTaskId = [self.cloudDownloadFileApiManager loadDataWithTokenModel:tokenModel
                                                                    videoModel:videoModel
                                                          destionationFilePath:fileURL];
}


#pragma mark - private method
- (void)downloadVideoProcess {
    if (!_receivedTokenModel) {
        // 不存在Token就获取
        [self createFetchTokenThread];
        
    } else if (_receivedTokenModel) {
        tryDownloadTimes = 0;
        // 下载Video
        [self requestVideoWithDeviceId:_deviceId
                            tokenModel:_receivedTokenModel
                            videoModel:_receivedVideoModel];
    }
}

- (void)createFetchTokenThread {
    if (_fetchTokenTimer) { return ; }
    // 先请求一次
    [self requestTokenWithDeviceId:_deviceId];
    // 再创建定时器，获取Token
    self.fetchTokenTimer = [[GosThreadTimer alloc] initWithInterval:60 forAction:@selector(fetchTokenAction) forModl:NSDefaultRunLoopMode withName:@"fetchToken" onTarget:self];
    
    [self.fetchTokenTimer resume];
}

- (void)destoryFetchTokenThread {
    if (!_fetchTokenTimer) return ;
    
    GosLog(@"摧毁获取Token线程")
    [_fetchTokenTimer destroy];
    _fetchTokenTimer = nil;
    
}

- (void)fetchTokenAction {
    [self requestTokenWithDeviceId:_deviceId];
}

- (void)resetVideoModel {
    _receivedVideoModel = nil;
}

- (void)resetParameters {
    _receivedVideoModel = nil;
    _receivedTokenModel = nil;
    _fetchTokenTaskId = NSIntegerMax;
    _downloadTaskId = NSIntegerMax;
    _onTime = NSUIntegerMax;
}

- (void)resetClipParameters {
    _clipFilePath = nil;
    _clipDuration = 0;
    _clipStartTime = 0;
}

- (void)deleteTemporaryFileForClip {
    if ([self temporaryVideoFileForClipExist]) {
        NSString *filePath = [self temporaryVideoFilePathForClip];
        
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
    }
}

- (NSString *)combineVideoFileToTemporaryForClipWithVideos:(NSArray <VideoSlicesApiRespModel *> *)videos{
    //先删除
    [self deleteTemporaryFileForClip];
    
    NSString *filePath = [self temporaryVideoFilePathForClip];
    //写文件
    NSMutableData *writer = [[NSMutableData alloc] init];
    
    for (VideoSlicesApiRespModel *model in videos) {
        NSString *path = [self videoFilePathWithVideoModel:model];
        NSData *fileData = [NSData dataWithContentsOfFile:path];
        [writer appendData:fileData];
    }
    [writer writeToFile:filePath atomically:YES];
    [writer resetBytesInRange:NSMakeRange(0, writer.length)];
    [writer setLength:0];
    
    return filePath;
}

#pragma mark - getters and setters
- (CloudDownloadFileApiManager *)cloudDownloadFileApiManager {
    if (!_cloudDownloadFileApiManager) {
        _cloudDownloadFileApiManager = [[CloudDownloadFileApiManager alloc] init];
        _cloudDownloadFileApiManager.delegate = self;
    }
    return _cloudDownloadFileApiManager;
}

- (TokenCheckApiManager *)tokenCheckApiManager {
    if (!_tokenCheckApiManager) {
        _tokenCheckApiManager = [[TokenCheckApiManager alloc] init];
        _tokenCheckApiManager.delegate = self;
    }
    return _tokenCheckApiManager;
}

@end
