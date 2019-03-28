//
//  GosSoundEffectPlayer.m
//  GosIPCs
//
//  Created by ShenYuanLuo on 2018/12/22.
//  Copyright © 2018年 goscam. All rights reserved.
//

#import "GosSoundEffectPlayer.h"
#import <AVFoundation/AVFoundation.h>

@interface GosSoundEffectPlayer()
{
    BOOL m_isPlayingAudioPlayer1;
}
/** 播放器1 */
@property (nonatomic, strong) AVAudioPlayer *audioPlayer1;
/** 播放器1 */
@property (nonatomic, strong) AVAudioPlayer *audioPlayer2;

@end

@implementation GosSoundEffectPlayer

- (instancetype)initWithFilePath:(NSString *)filePath
                           error:(NSError *__autoreleasing *)outError
{
    if ((self = [super init]))
    {
        NSURL *fileUrl    = [NSURL URLWithString:filePath];
        self.audioPlayer1 = [[AVAudioPlayer alloc] initWithContentsOfURL:fileUrl
                                                                   error:outError];
        self.audioPlayer2 = [[AVAudioPlayer alloc] initWithContentsOfURL:fileUrl
                                                                   error:outError];
        
        [self.audioPlayer1 prepareToPlay];
        [self.audioPlayer2 prepareToPlay];
    }
    return self;
}

#pragma mark -- 单次播放无震动
- (void)playOnceNoVibrate
{
    self.audioPlayer1.numberOfLoops = 0;
    self.audioPlayer2.numberOfLoops = 0;
    if (NO == m_isPlayingAudioPlayer1)
    {
        if (NO == self.audioPlayer1.isPlaying)
        {
            [self.audioPlayer1 play];
        }
        else
        {
            self.audioPlayer1.currentTime = 0.0f;
            m_isPlayingAudioPlayer1 = YES;
        }
    }
    else
    {
        if (NO == self.audioPlayer2.isPlaying)
        {
            [self.audioPlayer2 play];
        }
        else
        {
            self.audioPlayer2.currentTime = 0.0f;
            m_isPlayingAudioPlayer1 = NO;
        }
    }
}

#pragma mark -- 单次播放并震动
- (void)playOnceWithVibrate
{
    [self playOnceNoVibrate];
    [self vibrate];
}

#pragma mark -- 循环播放（无振动）
- (void)playInfinite
{
    [self.audioPlayer2 pause];
    self.audioPlayer1.currentTime   = 0.0f;
    self.audioPlayer1.numberOfLoops = -1;
    [self.audioPlayer1 play];
}

#pragma mark -- 暂停播放
- (void)pause
{
    [self.audioPlayer1 pause];
    [self.audioPlayer2 pause];
}

#pragma mark -- 停止播放
- (void)stop
{
    [self.audioPlayer1 stop];
    [self.audioPlayer2 stop];
}

#pragma mark -- 震动手机
- (void)vibrate
{
    AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
}

#pragma mark -- 设置声道平衡
- (void)setPan:(float)pan
{
    if (_pan != pan)
    {
        _pan = pan;
        self.audioPlayer1.pan = pan;
        self.audioPlayer2.pan = pan;
    }
}

#pragma mark -- 设置音量大小
- (void)setVolume:(float)volume
{
    if (_volume != volume)
    {
        _volume = volume;
        self.audioPlayer1.volume = volume;
        self.audioPlayer2.volume = volume;
    }
}

@end
