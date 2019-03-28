//
//  VoiceDetectFootView.m
//  Goscom
//
//  Created by 匡匡 on 2018/11/27.
//  Copyright © 2018 goscam. All rights reserved.
//

#import "VoiceDetectFootView.h"
@interface VoiceDetectFootView()
@property (weak, nonatomic) IBOutlet UILabel *tipsLab;

@end
@implementation VoiceDetectFootView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    self = [[[NSBundle mainBundle] loadNibNamed:@"VoiceDetectFootView" owner:self options:nil] lastObject];
    if (self) {
        self.frame = frame;
    }
    return self;
}
- (void)awakeFromNib{
    [super awakeFromNib];
    
    NSString * tipsStr = DPLocalizedString(@"Setting_Voice_Tips");
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:tipsStr];
    NSTextAttachment *attch = [[NSTextAttachment alloc] init];
    attch.image = [UIImage imageNamed:@"icon_voice_detection_32"];
    attch.bounds = CGRectMake(0, -5, 20, 20);
    
    NSAttributedString *string = [NSAttributedString attributedStringWithAttachment:attch];
    [attrStr appendAttributedString:string];
    self.tipsLab.attributedText = attrStr;
}


@end
