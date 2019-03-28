//  PlaybackMaskControl.m
//  GosIPCs
//
//  Create by daniel.hu on 2019/1/22.
//  Copyright © 2019年 goscam. All rights reserved.

#import "PlaybackMaskControl.h"
#import "NSString+GosFormatDate.h"



#pragma mark - PlaybackMaskControlPreview 预览视图 (Public)

@interface PlaybackMaskControlPreview : UIView
@property (nonatomic, strong) UIButton *playButton;
@property (nonatomic, strong) UIActivityIndicatorView *activityView;
@property (nonatomic, strong) UIImageView *coverImageView;
@property (nonatomic, strong) UILabel *timeLabel;
@end

#pragma mark - PlaybackMaskControl (Private)
@interface PlaybackMaskControl ()
/// 中心详情标签
@property (nonatomic, strong) UILabel *centerDetailLabel;
/// 菊花信
@property (nonatomic, strong) UIActivityIndicatorView *activityView;
/// 预览视图
@property (nonatomic, strong) PlaybackMaskControlPreview *previewView;

@end

@implementation PlaybackMaskControl

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.previewView];
        [self addSubview:self.activityView];
        [self addSubview:self.centerDetailLabel];
        
        [self.previewView mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.left.top.right.bottom.equalTo(self);
            make.bottom.centerX.equalTo(self);
            make.width.equalTo(@(120));
            make.height.equalTo(@(90));
        }];
        
        [self.activityView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.centerY.equalTo(self);
            make.width.height.equalTo(@(50));
        }];
        
        [self.centerDetailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.centerY.equalTo(self);
        }];
        
//        self.state = PlaybackMaskControlStateDefault;
        self.mainState = PlaybackMaskControlMainStateDefault;
        self.extraState = PlaybackMaskControlExtraStateDefault;
    }
    return self;
}


#pragma mark - getters and setters
- (PlaybackMaskControlPreview *)previewView {
    if (!_previewView) {
        _previewView = [[PlaybackMaskControlPreview alloc] init];
    }
    return _previewView;
}

- (UIActivityIndicatorView *)activityView {
    if (!_activityView) {
        _activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    }
    return _activityView;
}

- (UILabel *)centerDetailLabel {
    if (!_centerDetailLabel) {
        _centerDetailLabel = [[UILabel alloc] init];
        _centerDetailLabel.textColor = [UIColor whiteColor];
        _centerDetailLabel.font = GOS_FONT(14);
        _centerDetailLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _centerDetailLabel;
}

- (void)setMainState:(PlaybackMaskControlMainState)mainState {
    _mainState = mainState;
    
    switch (mainState) {
        case PlaybackMaskControlMainStateDefault:
            [self.activityView stopAnimating];
            [self.activityView setHidden:YES];
            
            self.centerDetailLabel.hidden = YES;
            break;
        case PlaybackMaskControlMainStateLoading:
            [self.activityView setHidden:NO];
            [self.activityView startAnimating];
            
            self.centerDetailLabel.hidden = YES;
            break;
        case PlaybackMaskControlMainStateShowingState:
            [self.activityView stopAnimating];
            [self.activityView setHidden:YES];
            
            self.centerDetailLabel.hidden = NO;
            break;
        default:
            break;
    }
}

- (void)setExtraState:(PlaybackMaskControlExtraState)extraState {
    _extraState = extraState;
    
    switch (extraState) {
        case PlaybackMaskControlExtraStateDefault:
            // everything hidden
            self.previewView.hidden = YES;
            self.previewView.playButton.hidden = YES;
            self.previewView.timeLabel.hidden = YES;
            self.previewView.coverImageView.hidden = YES;
            
            [self.previewView.activityView stopAnimating];
            [self.previewView.activityView setHidden:YES];
            break;
        case PlaybackMaskControlExtraStatePreviewLoading:
            // preview loading
            self.previewView.hidden = NO;
            
            self.previewView.playButton.hidden = YES;
            self.previewView.timeLabel.hidden = YES;
            self.previewView.coverImageView.hidden = YES;
            
            [self.previewView.activityView setHidden:NO];
            [self.previewView.activityView startAnimating];
            break;
        case PlaybackMaskControlExtraStatePreviewPlay:
            // preview play
            self.previewView.hidden = NO;
            
            self.previewView.playButton.hidden = NO;
            self.previewView.timeLabel.hidden = NO;
            self.previewView.coverImageView.hidden = NO;
            
            [self.previewView.activityView stopAnimating];
            [self.previewView.activityView setHidden:YES];
            break;
        default:
            break;
    }
}

- (UIButton *)previewPlayButton {
    return self.previewView.playButton;
}

- (void)setPreviewImage:(UIImage *)previewImage {
    self.previewView.coverImageView.image = previewImage;
}

- (void)setPreviewTimestamp:(NSTimeInterval)previewTimestamp {
    _previewTimestamp = previewTimestamp;
    
    self.previewView.timeLabel.text = [NSString stringWithTimestamp:previewTimestamp format:timeOnlyDateFormatString];
}

- (void)setCenterDetailString:(NSString *)centerDetailString {
    self.centerDetailLabel.text = centerDetailString;
}

@end



#pragma mark - PlaybackMaskControlPreview 预览视图 (Private)

@implementation PlaybackMaskControlPreview
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setBackgroundColor:[UIColor blackColor]];
        
        [self addSubview:self.coverImageView];
        [self addSubview:self.timeLabel];
        [self addSubview:self.playButton];
        [self addSubview:self.activityView];
        
        [self.coverImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.right.bottom.equalTo(self);
        }];
        
        [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.left.right.equalTo(self);
            make.height.equalTo(@(30));
        }];
        
        [self.playButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.right.bottom.equalTo(self);
        }];
        
        [self.activityView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.centerY.equalTo(self);
            make.width.height.equalTo(@(50));
        }];
        
        
    }
    return self;
}

#pragma mark - getters and setters
- (UIActivityIndicatorView *)activityView {
    if (!_activityView) {
        _activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        _activityView.hidesWhenStopped = YES;
    }
    return _activityView;
}

- (UILabel *)timeLabel {
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc] init];
        _timeLabel.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.5];
        _timeLabel.textColor = [UIColor whiteColor];
        _timeLabel.font = GOS_FONT(14);
        _timeLabel.textAlignment = NSTextAlignmentRight;
    }
    return _timeLabel;
}

- (UIImageView *)coverImageView {
    if (!_coverImageView) {
        _coverImageView = [[UIImageView alloc] init];
    }
    return _coverImageView;
}

- (UIButton *)playButton {
    if (!_playButton) {
        _playButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_playButton setImage:GOS_IMAGE(@"icon_play_mine") forState:UIControlStateNormal];
    }
    return _playButton;
}

@end
