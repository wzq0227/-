//  CheckNetworkHeadView.m
//  Goscom
//
//  Create by 匡匡 on 2019/1/7.
//  Copyright © 2019 goscam. All rights reserved.

#import "CheckNetworkHeadView.h"
#import "UIView+MJExtension.h"
#import "UIView+GosClipView.h"
#import "UIView+GosGradient.h"
@interface CheckNetworkHeadView()
/// 当前测试网络状况：Label
@property (weak, nonatomic) IBOutlet UILabel *titleTipLab;
/// 网络检测大图片
@property (weak, nonatomic) IBOutlet UIImageView * checkNetImg;
/// 检测中
@property (weak, nonatomic) IBOutlet UILabel *checkNetIngLab;
/// 底部提示
@property (weak, nonatomic) IBOutlet UILabel *buttonTipsLab;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *checkNetImgWidth;

@end

@implementation CheckNetworkHeadView

- (void)awakeFromNib{
    [super awakeFromNib];
    self.checkNetImg.layer.cornerRadius = self.checkNetImg.mj_w/2.0f;
    self.checkNetImg.clipsToBounds = YES;
    self.titleTipLab.text = DPLocalizedString(@"NetCheckTopTip");
    self.checkNetIngLab.text = DPLocalizedString(@"NetCheckDetectIng");
//    [self addGradient];
    
}
- (void)setCheckNetState:(checkNetState)checkNetState{
    _checkNetState = checkNetState;
    switch (checkNetState) {
        case checkNetState_Detecting:{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.checkNetImg setImage:[UIImage imageNamed:@"network_test"]];
//                self.checkNetImg.mj_w = self.checkNetImg.mj_h = 230.0f;
//                self.checkNetImgWidth.constant = 230.0f;
                self.titleTipLab.hidden = YES;
                self.checkNetIngLab.hidden = NO;
                self.checkNetIngLab.font = GOS_FONT(16);
                self.buttonTipsLab.text = DPLocalizedString(@"NetCheckSuccessfulTip");
                self.checkNetIngLab.textAlignment = NSTextAlignmentCenter;
                [self startAnimation];
            });
        }break;
        case checkNetState_Success:{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.checkNetImg setImage:[UIImage imageNamed:@"img_smileface"]];
//                self.checkNetImg.mj_w = self.checkNetImg.mj_h = 193.0f;
//                self.checkNetImgWidth.constant = 193.0f;
                self.checkNetIngLab.hidden = YES;
//                self.buttonTipsLab.text = @"上行：15/MB/S          下行：10/MB/S";
                self.checkNetIngLab.font = GOS_FONT(14);
                self.checkNetIngLab.textAlignment = NSTextAlignmentCenter;
                self.titleTipLab.hidden = NO;
                [self endAnimation];
            });
        }break;
        case checkNetState_Fail:{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.checkNetImg setImage:[UIImage imageNamed:@"img_sadface"]];
//                self.checkNetImg.mj_w = self.checkNetImg.mj_h = 193.0f;
//                self.checkNetImgWidth.constant = 193.0f;
                self.checkNetIngLab.font = GOS_FONT(14);
                self.checkNetIngLab.hidden = YES;
                self.buttonTipsLab.textAlignment = NSTextAlignmentLeft;
                self.titleTipLab.hidden = NO;
                self.buttonTipsLab.text = DPLocalizedString(@"NetCheckFailedTip");
                [self endAnimation];
            });
        }break;
        default:
            break;
    }
}

/// 设置上行下行d速度
- (void)setUploadStr:(NSString *) uploadStr
             downStr:(NSString *) downStr{
    switch (self.checkNetState) {
        case checkNetState_Detecting:{
            
        }break;
            
        case checkNetState_Fail:{
            
        }break;
            
        case checkNetState_Success:{
            self.buttonTipsLab.text = [NSString stringWithFormat:@"%@:%@    %@:%@",DPLocalizedString(@"Network_UploadSpeed"),uploadStr,DPLocalizedString(@"Network_DownSpeed"),downStr];
        }break;
            
        default:
            break;
    }
}


//-(void) addGradient{
//    if (NO == m_isConfigGradient)
//    {
//        m_isConfigGradient = YES;
//    [self gradientStartColor:GOS_COLOR_RGB(0x74A7F7)
//                         endColor:GOS_COLOR_RGB(0x7EB7F7)
//                     cornerRadius:0
//                        direction:GosGradientTopToBottom];
//    }
//}
#pragma mark - 转圈动画
- (void)startAnimation
{
    CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat:M_PI * 2.0];
    rotationAnimation.duration = 2;
    rotationAnimation.cumulative = YES;
    rotationAnimation.repeatCount =ULLONG_MAX;
    rotationAnimation.removedOnCompletion=NO;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.checkNetImg.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
    });
}
#pragma mark - 结束动画
- (void)endAnimation
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.checkNetImg.layer removeAllAnimations];
    });
}
#pragma mark - lifeStyle
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    self = [[[NSBundle mainBundle] loadNibNamed:@"CheckNetworkHeadView" owner:self options:nil] lastObject];
    if (self) {
        self.frame = frame;
    }
    return self;
}
@end
