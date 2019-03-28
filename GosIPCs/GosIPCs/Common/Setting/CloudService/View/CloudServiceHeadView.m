//
//  CloudServiceHeadView.m
//  Goscom
//
//  Created by 匡匡 on 2018/11/20.
//  Copyright © 2018 goscam. All rights reserved.
//

#import "CloudServiceHeadView.h"

@interface CloudServiceHeadView ()
@property (weak, nonatomic) IBOutlet UILabel *packageTypeLab;   //  套餐类型
@property (weak, nonatomic) IBOutlet UILabel *priceLab;     //  价格
@property (weak, nonatomic) IBOutlet UILabel *saveLifeLab;  //  录像保存（循环）

@end

@implementation CloudServiceHeadView


- (void)awakeFromNib{
    [super awakeFromNib];
    self.packageTypeLab.text = DPLocalizedString(@"CS_PackageType_PackageType");
    self.priceLab.text = DPLocalizedString(@"CS_PackageType_Price");
    self.saveLifeLab.text = DPLocalizedString(@"CS_PackageType_DataLife");
}

#pragma mark - lifyCycle
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    self = [[[NSBundle mainBundle] loadNibNamed:@"CloudServiceHeadView" owner:self options:nil] lastObject];
    if (self) {
        self.frame = CGRectMake(0, 0, GOS_SCREEN_W, 50);
    }
    return self;
}


@end
