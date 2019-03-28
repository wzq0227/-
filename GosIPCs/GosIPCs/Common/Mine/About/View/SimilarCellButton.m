//  SimilarCellButton.m
//  GosIPCs
//
//  Create by daniel.hu on 2018/12/4.
//  Copyright © 2018年 goscam. All rights reserved.

#import "SimilarCellButton.h"

@interface SimilarCellButton ()
/// 标题
@property (nonatomic, strong) IBOutlet UILabel *cellTitleLabel;
/// 指向性图片
@property (nonatomic, strong) IBOutlet UIImageView *indicateImageView;
@end

@implementation SimilarCellButton
- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self addSubview:self.cellTitleLabel];
        [self addSubview:self.indicateImageView];
        
        [self.indicateImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.mas_centerY);
            make.right.mas_equalTo(self.mas_right).offset(-15);
        }];
        
        [self.cellTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.mas_left).offset(16);
            make.top.mas_equalTo(self.mas_top);
            make.bottom.mas_equalTo(self.mas_bottom);
        }];
    }
    return self;
}
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.cellTitleLabel];
        [self addSubview:self.indicateImageView];
        
        [self.indicateImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.mas_centerY);
            make.right.mas_equalTo(self.mas_right).offset(-15);
        }];
        
        [self.cellTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.mas_left).offset(15);
            make.top.mas_equalTo(self.mas_top);
            make.bottom.mas_equalTo(self.mas_bottom);
        }];
        
    }
    return self;
}
- (void)setTitleString:(NSString *)titleString {
    _titleString = titleString;
    self.cellTitleLabel.text = titleString;
}

- (UILabel *)cellTitleLabel {
    if (!_cellTitleLabel) {
        _cellTitleLabel = [[UILabel alloc] init];
        _cellTitleLabel.textColor = GOS_COLOR_RGB(0x1A1A1A);
        _cellTitleLabel.textAlignment = NSTextAlignmentLeft;
        _cellTitleLabel.font = GOS_FONT(14);
    }
    return _cellTitleLabel;
}
- (UIImageView *)indicateImageView {
    if (!_indicateImageView) {
        _indicateImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_more"]];
    }
    return _indicateImageView;
}
@end
