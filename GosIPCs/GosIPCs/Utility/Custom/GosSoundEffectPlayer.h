//
//  GosSoundEffectPlayer.h
//  GosIPCs
//
//  Created by ShenYuanLuo on 2018/12/22.
//  Copyright © 2018年 goscam. All rights reserved.
//

/*
 音效播放器控制类：可以循环播放、单次播放（含震动）、暂停播放、停止播放、设置声道/音量
 （使用单次播放外加循环控制，可以模拟多音效同时播放的效果）
 */

#import <Foundation/Foundation.h>

@interface GosSoundEffectPlayer : NSObject

/** 调节声道平衡 */
@property (nonatomic, readwrite, assign) float pan;
/** 调节音量 */
@property (nonatomic, readwrite, assign) float volume;

/*
 初始化一个实例
 
 @param filePath 音效文件路径
 @param outError 初始化失败信息
 
 @return ‘PushMsgSoundPlayer’实例
 */
- (instancetype)initWithFilePath:(NSString *)filePath
                           error:(NSError *__autoreleasing *)outError;

/*
 单次播放无震动
 */
- (void)playOnceNoVibrate;

/*
 单次播放并震动
 */
- (void)playOnceWithVibrate;

/*
 循环播放（无振动）
 */
- (void)playInfinite;

/*
 暂停播放
 */
- (void)pause;

/*
 停止播放
 */
- (void)stop;

@end
