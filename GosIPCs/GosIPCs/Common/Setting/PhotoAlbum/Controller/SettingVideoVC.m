//
//  SettingVideoVC.m
//  Goscom
//
//  Created by 匡匡 on 2018/11/20.
//  Copyright © 2018 goscam. All rights reserved.
//

#import "SettingVideoVC.h"
#import "MediaManager.h"
#import <AVFoundation/AVFoundation.h>
@interface SettingVideoVC ()
/// 播放器
@property (nonatomic, strong) AVPlayer * player;
/// 播放器ITem
@property (nonatomic, strong) AVPlayerItem * playerItem;

@end

@implementation SettingVideoVC
#pragma mark -- lifestyle
- (void)viewDidLoad {
    [super viewDidLoad];
    //    NSString *str = [[NSBundle mainBundle] resourcePath];
    //    ? ? NSString *filePath = [NSString stringWithFormat:@"%@%@",str,@"/v.mp4"];
    //
    
    
}

-(void)setDataModel:(MediaFileModel *)dataModel{
    _dataModel = dataModel;
    
//    NSURL *movieURL = [NSURL fileURLWithPath:dataModel.filePath];
//    //         AVAsset *movieAsset = [AVURLAsset URLAssetWithURL:sourceMovieURL options:nil];
//    //         AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:movieAsset];
//    self.playerItem= [AVPlayerItem playerItemWithURL:movieURL];
//    self.player = [AVPlayer playerWithPlayerItem:self.playerItem];
//    AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
////    playerLayer.frame= self.view.bounds;
//    playerLayer.frame = CGRectMake(0, (GOS_SCREEN_H - ((float)GOS_SCREEN_W) / 16.0f * 9.0f)/2.0f, GOS_SCREEN_W, ((float)GOS_SCREEN_W) / 16.0f * 9.0f);
//    playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
//    [self.view.layer addSublayer:playerLayer];
//    [self.player play];
    
    
    
    //初始化视频播放地址
  
    NSURL *mediaUrl = [NSURL fileURLWithPath:dataModel.filePath];
    // 初始化播放单元
    AVPlayerItem *item = [AVPlayerItem playerItemWithURL:mediaUrl];
    
    //初始化播放器对象
    self.player = [[AVPlayer alloc]initWithPlayerItem:item];
    
    //显示画面
    AVPlayerLayer *layer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    
    
    //视频填充模式
    layer.videoGravity = AVLayerVideoGravityResizeAspect;
    
    //设置画布frame
    layer.frame = CGRectMake(0, GOS_SCREEN_H/2-250/2, GOS_SCREEN_W, 250);
    //添加到当前视图
    [self.view.layer addSublayer:layer];
   
}


#pragma mark -- config

#pragma mark -- function
#pragma mark -- actionFunction
#pragma mark -- delegate


#pragma mark -- lazy
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
