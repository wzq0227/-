//
//  MotionDetectFootView.m
//  Goscom
//
//  Created by 匡匡 on 2018/11/22.
//  Copyright © 2018 goscam. All rights reserved.
//

#import "MotionDetectFootView.h"
#import "iOSConfigSDKModel.h"

@interface MotionDetectFootView()
@property (weak, nonatomic) IBOutlet UILabel *areaTitleLab;
@property (weak, nonatomic) IBOutlet UILabel *promptLab;
@property (weak, nonatomic) IBOutlet UIButton *allSelectBtn;

@end
@implementation MotionDetectFootView

- (void)awakeFromNib{
    [super awakeFromNib];
    [self configUI];
}
- (void)configUI{
    NSString * tipsStr = DPLocalizedString(@"Setting_SelectAreaReminder");
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:tipsStr];
    NSTextAttachment *attch = [[NSTextAttachment alloc] init];
    attch.image = [UIImage imageNamed:@"icon_motion_52"];
    attch.bounds = CGRectMake(0, -5, 20, 20);
    
    NSAttributedString *string = [NSAttributedString attributedStringWithAttachment:attch];
    [attrStr appendAttributedString:string];
    self.promptLab.attributedText = attrStr;
    
    self.allSelectBtn.layer.cornerRadius = 20.0f;
    self.allSelectBtn.clipsToBounds = YES;
    self.areaTitleLab.text = DPLocalizedString(@"Setting_MoniterArea_SelectArea");
    [self.allSelectBtn setTitle:DPLocalizedString(@"GosComm_SelectAll") forState:UIControlStateNormal];
}
- (void)setModelData:(MotionDetectModel *)modelData{
    _modelData = modelData;
}

- (IBAction)actionAllSelectClick:(UIButton *)sender {
    if (self.modelData.enable == 0xffff) {
        self.modelData.enable = 0;
    }else{
        self.modelData.enable = 0xffff;
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(motionFootViewBackData:)]) {
        [self.delegate motionFootViewBackData:self.modelData];
    }
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    self = [[[NSBundle mainBundle] loadNibNamed:@"MotionDetectFootView" owner:self options:nil] lastObject];
    if (self) {
        self.frame = frame;
    }
    return self;
}


@end
