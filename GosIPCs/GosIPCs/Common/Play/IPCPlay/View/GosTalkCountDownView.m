//
//  GosTalkCountDownView.m
//  ULife3.5
//
//  Created by Goscam on 2018/4/11.
//  Copyright © 2018年 GosCam. All rights reserved.
//

#import "GosTalkCountDownView.h"
#import "Masonry.h"

@interface GosTalkCountDownView()
{
    
}

@property (strong, nonatomic)  UILabel *remainSecsLabel;

@property (strong, nonatomic)  UIColor *bgColor;

@property (strong, nonatomic)  UIColor *trackColor;

@property (strong, nonatomic)  UIColor *progressColor;

@end



@implementation GosTalkCountDownView{

}


-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        _totalSeconds = 50;
        _remainSeconds = 50;
        
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    // Drawing code
    
    
    
    [self refreshProgressView];
}


- (void)configView{
    
    if (!self.remainSecsLabel.superview) {
        self.backgroundColor = self.bgColor;
        self.layer.cornerRadius = 5;
        self.clipsToBounds = YES;
        
        [self addSubview: self.remainSecsLabel];
        [self.remainSecsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self);
        }];
    }
}

- (void)refreshProgressView{
    
    CGFloat midAngle = 2*M_PI*(_totalSeconds- _remainSeconds)/_totalSeconds ;
    
    CGFloat centerX = self.frame.size.width/2;;
    CGFloat centerY = self.frame.size.height/2;
    
    CGFloat radius = 20;
    CGFloat lineWidth = 5;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    UIBezierPath *progerssPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(centerX, centerY) radius:radius startAngle:-M_PI_2 endAngle:-M_PI_2+midAngle clockwise:YES];
    CGContextAddPath(context, progerssPath.CGPath);
    CGContextSetStrokeColorWithColor(context, self.progressColor.CGColor);
    CGContextSetFillColorWithColor(context,[UIColor clearColor].CGColor);
    CGContextSetLineWidth(context, lineWidth);
    CGContextStrokePath(context);
    
    UIBezierPath *remainProgerssPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake( centerX,  centerY) radius:radius startAngle:-M_PI_2+midAngle endAngle:-M_PI_2+2*M_PI clockwise:YES];
    CGContextAddPath(context, remainProgerssPath.CGPath);
    CGContextSetStrokeColorWithColor(context, self.trackColor.CGColor);
    CGContextSetFillColorWithColor(context,[UIColor clearColor].CGColor);
    CGContextSetLineWidth(context, lineWidth);
    CGContextStrokePath(context);
    
}




- (void)setRemainSeconds:(NSUInteger)remainSeconds{
    _remainSeconds  = remainSeconds;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.remainSecsLabel.text = [NSString stringWithFormat:@"%lus",(unsigned long)_remainSeconds];
    });
}



//MARK : - Lazy Load
-(UILabel*)remainSecsLabel{
    if (!_remainSecsLabel) {
        _remainSecsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 40, 20)];
        _remainSecsLabel.textAlignment = NSTextAlignmentCenter;
        _remainSecsLabel.textColor = GOS_COLOR_RGBA(133, 133, 133, 1);
        _remainSecsLabel.font = [UIFont systemFontOfSize:13];
    }
    return _remainSecsLabel;
}

-(UIColor*)bgColor{
    if (!_bgColor) {
        _bgColor =  GOS_COLOR_RGBA(242, 249, 254, 1);
    }
    return _bgColor;
}


-(UIColor*)trackColor{
    if (!_trackColor) {
        _trackColor = GOS_COLOR_RGBA(106, 174, 246, 1);
    }
    return _trackColor;
}

-(UIColor*)progressColor{
    if (!_progressColor) {
        _progressColor = GOS_COLOR_RGBA(242, 249, 254, 1);

    }
    return _progressColor;
}

@end
