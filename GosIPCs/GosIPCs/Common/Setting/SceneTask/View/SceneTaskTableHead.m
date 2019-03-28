//  SceneTaskTableHead.m
//  Goscom
//
//  Create by 匡匡 on 2018/12/27.
//  Copyright © 2018 goscam. All rights reserved.

#import "SceneTaskTableHead.h"
@interface SceneTaskTableHead()
@property (weak, nonatomic) IBOutlet UILabel *titlemarkLab;

@end
@implementation SceneTaskTableHead

-(void)awakeFromNib{
    [super awakeFromNib];
    self.titlemarkLab.text = DPLocalizedString(@"Setting_SceneTaskTitle");
}

#pragma mark - lifeStyle
- (instancetype)initWithFrame:(CGRect)frame {
self = [super initWithFrame:frame];
    self = [[[NSBundle mainBundle] loadNibNamed:@"SceneTaskTableHead" owner:self options:nil] lastObject];
    if (self) {
        self.frame = frame;
    }
    return self;
}
@end
