//
//  DeviiceAddtionMethodTableViewCell.m
//  ULife3.5
//
//  Created by 罗乐 on 2018/9/13.
//  Copyright © 2018年 GosCam. All rights reserved.
//

#import "DeviceAddtionMethodTableViewCell.h"

@interface DeviceAddtionMethodTableViewCell ()
@property (weak, nonatomic) IBOutlet UIImageView *methodImageView;
@property (weak, nonatomic) IBOutlet UILabel *methodNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *methodDetialLabel;
@property (weak, nonatomic) IBOutlet UIImageView *arrowImgView;

@end

@implementation DeviceAddtionMethodTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setFrame:(CGRect)frame {
    CGRect newFrame = frame;
    if (self.isNeedResetFrame) {
        CGFloat offset = frame.size.height / 9.f;
        newFrame.size.height = frame.size.height - offset;
        newFrame.origin.y    = frame.origin.y + offset;
        self.contentView.layer.cornerRadius = newFrame.size.height * 0.1f;
        self.contentView.layer.masksToBounds = YES;
        self.layer.cornerRadius = newFrame.size.height * 0.1f;
        self.layer.masksToBounds = YES;
        self.backgroundColor = [UIColor clearColor];
    }
    [super setFrame:newFrame];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setAddType:(SupportAddStyle)addType {
    _addType = addType;
    dispatch_async(dispatch_get_main_queue(), ^{
        switch (addType) {
            case SupportAdd_wifi:
                self.methodNameLabel.text = DPLocalizedString(@"AddDEV_WiFiAdd");
                self.methodDetialLabel.text = DPLocalizedString(@"AddDEV_WiFiAdd_tip");
                self.methodImageView.image = [UIImage imageNamed:@"addDev_WiFiAdd"];
                break;
            case SupportAdd_scan:
                self.methodNameLabel.text = DPLocalizedString(@"AddDEV_QRCodeAdd");
                self.methodDetialLabel.text = DPLocalizedString(@"AddDEV_QRCodeAdd_tip");
                self.methodImageView.image = [UIImage imageNamed:@"addDev_QRCodeAdd"];
                break;
            case SupportAdd_apNew:
            case SupportAdd_apMode:
                self.methodNameLabel.text = DPLocalizedString(@"AddDEV_APAdd");
                self.methodDetialLabel.text = DPLocalizedString(@"AddDEV_APAdd_tip");
                self.methodImageView.image = [UIImage imageNamed:@"addDev_APAdd"];
                break;
            case SupportAdd_wlan:
                self.methodNameLabel.text = DPLocalizedString(@"AddDEV_LanAdd");
                self.methodDetialLabel.text = DPLocalizedString(@"AddDEV_LanAdd_tip");
                self.methodImageView.image = [UIImage imageNamed:@"addDev_LanAdd"];
                break;
            default:
                break;
        }
    });
    
}

- (BOOL)isArrowHidden {
    return self.arrowImgView.hidden;
}

- (void)setIsArrowHidden:(BOOL)isArrowHidden {
    self.arrowImgView.hidden = isArrowHidden;
}

@end
