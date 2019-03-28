//
//  SensitivitySettingCell.m
//  Goscom
//
//  Created by 匡匡 on 2018/11/22.
//  Copyright © 2018 goscam. All rights reserved.
//

#import "SensitivitySettingCell.h"
#import "iOSConfigSDK.h"
@interface SensitivitySettingCell()
@property (weak, nonatomic) IBOutlet UISlider *sensitivitySlider;
@property (weak, nonatomic) IBOutlet UIView *leftView;
@property (weak, nonatomic) IBOutlet UIView *rightView;
@property (weak, nonatomic) IBOutlet UIView *middleView;
@property (weak, nonatomic) IBOutlet UILabel *tips1Lab;     //  低
@property (weak, nonatomic) IBOutlet UILabel *tips2Lab;     //  默认
@property (weak, nonatomic) IBOutlet UILabel *tips3Lab;     //  高
@end
@implementation SensitivitySettingCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self configUI];
}
- (void)configUI{
    self.sensitivitySlider.continuous = NO;
    [self.sensitivitySlider addTarget:self action:@selector(didEndDragingSlider:) forControlEvents:UIControlEventValueChanged];
    self.sensitivitySlider.minimumTrackTintColor = [UIColor clearColor];
    self.sensitivitySlider.maximumTrackTintColor = [UIColor clearColor];
    UIImage * image = [UIImage imageNamed:@"icon_circle_default_detection"];
    //    UIImage *imagea=[self OriginImage:[UIImage imageNamed:@"icon_circle_default_detection"] scaleToSize:CGSizeMake(30, 30)];
    [self.sensitivitySlider setThumbImage:image forState:UIControlStateNormal];
    
    self.leftView.layer.cornerRadius = 4.0f;
    self.leftView.clipsToBounds = YES;
    self.rightView.layer.cornerRadius = 4.0f;
    self.rightView.clipsToBounds = YES;
    self.middleView.layer.cornerRadius = 4.0f;
    self.middleView.clipsToBounds = YES;
    
    self.tips1Lab.text = DPLocalizedString(@"Setting_Sensitivity_Low");
    self.tips2Lab.text = DPLocalizedString(@"Setting_Sensitivity_Default");
    self.tips3Lab.text = DPLocalizedString(@"Setting_Sensitivity_High");
}
+ (instancetype)cellModelWithTableView:(UITableView *)tableView
                             indexPath:(NSIndexPath *) indexPath
                           detectLevel:(DetectLevel) tlevel
                              delegate:(id<SensitivitySettingDelegate>)delegate{
    [tableView registerNib:[UINib nibWithNibName:@"SensitivitySettingCell" bundle:nil] forCellReuseIdentifier:@"SensitivitySettingCell"];
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    SensitivitySettingCell * cell = [tableView dequeueReusableCellWithIdentifier:@"SensitivitySettingCell"];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    cell.tlevel = tlevel;
    cell.delegate = delegate;
    return cell;
}

- (void)setTlevel:(DetectLevel)tlevel{
    _tlevel = tlevel;
    switch (tlevel) {
        case Detect_low:{
            self.sensitivitySlider.value = 1;
        }break;
        case Detect_middle:{
            self.sensitivitySlider.value = 2;
        }break;
        case Detect_high:{
            self.sensitivitySlider.value = 3;
        }break;
        default:
            break;
    }
}

- (void)didEndDragingSlider:(id)sender{
    CGFloat value = self.sensitivitySlider.value;
    DetectLevel leve = self.tlevel;
    if (value < 1.5) {
        [self.sensitivitySlider setValue:1 animated:YES];
        leve = Detect_low;
        
    }
    else if (value >= 1.5 && value <2.5){
        [self.sensitivitySlider setValue:2 animated:YES];
        leve = Detect_middle;
    }
    else {
        [self.sensitivitySlider setValue:3 animated:YES];
        leve = Detect_high;
    }
    self.tlevel = leve;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(sensitivitySettingDidUpdate:)]) {
        [self.delegate sensitivitySettingDidUpdate:self.tlevel];
    }
}
/*
 对原来的图片的大小进行处理
 @param image 要处理的图片
 @param size  处理过图片的大小
 */
- (UIImage *)OriginImage:(UIImage *)image scaleToSize:(CGSize)size{
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0,0, size.width, size.height)];
    UIImage *scaleImage=UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaleImage;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
