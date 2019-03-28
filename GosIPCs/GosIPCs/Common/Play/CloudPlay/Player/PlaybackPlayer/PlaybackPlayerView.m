//  PlaybackPlayerView.m
//  GosIPCs
//
//  Create by daniel.hu on 2019/1/4.
//  Copyright © 2019年 goscam. All rights reserved.

#import "PlaybackPlayerView.h"

@implementation PlaybackPlayerView

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self commonConfig];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self commonConfig];
    }
    return self;
}

- (void)commonConfig {
    self.backgroundColor = [UIColor blackColor];
}


@end
