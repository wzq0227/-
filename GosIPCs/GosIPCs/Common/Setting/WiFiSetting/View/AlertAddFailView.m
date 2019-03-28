//
//  AlertAddFailView.m
//  Goscom
//
//  Created by 匡匡 on 2018/11/29.
//  Copyright © 2018 goscam. All rights reserved.
//

#import "AlertAddFailView.h"
#import "KKAlertView.h"
@interface AlertAddFailView()
@property (weak, nonatomic) IBOutlet UILabel *titleLab; // 如果添加不成功，解决方法：
@property (weak, nonatomic) IBOutlet UILabel *tips1Lab; // 1. 确认WiFi名称和密码是否有特殊字符，
@property (weak, nonatomic) IBOutlet UIButton *back1Btn; // 返回设备列表页面
@property (weak, nonatomic) IBOutlet UIButton *back2Btn; // 返回配置WiFi页面
/// 标记字符用来返回高度，中文或英文
@property (nonatomic, strong) NSString * backListStr1;

@end
@implementation AlertAddFailView

+ (instancetype)initWithDelegate:(id<AlertAddFailViewDelegate>) delegate{
    AlertAddFailView * view = [[AlertAddFailView alloc] init];
    view.delegate = delegate;
    return view;
}
- (IBAction)actionBackClick:(UIButton *)sender {
    
    KKAlertView * alert = (KKAlertView *)self.superview;
    [alert hide];
    switch (sender.tag) {
        case 10:{
            self.backType = BackType_DeviceList;
        }break;
        case 11:{
            self.backType = BackType_WiFiSetting;
        }break;
            
        default:
            break;
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(AlertAddFailClick:)]) {
        [self.delegate AlertAddFailClick:self.backType];
    }
}

- (void)awakeFromNib{
    [super awakeFromNib];
    [self configUI];
    
}
- (void)configUI{
    self.layer.cornerRadius = 5;
    self.clipsToBounds = YES;
    self.titleLab.text = DPLocalizedString(@"Configure_show_tip2");
    self.tips1Lab.text = DPLocalizedString(@"Configure_show_tip");
    [self.back1Btn setTitle:DPLocalizedString(@"Configure_BackToDevListVC") forState:UIControlStateNormal];
    [self.back2Btn setTitle:DPLocalizedString(@"Configure_back") forState:UIControlStateNormal];
    
    self.back1Btn.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.back2Btn.titleLabel.adjustsFontSizeToFitWidth = YES;
}
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    self = [[[NSBundle mainBundle] loadNibNamed:@"AlertAddFailView" owner:self options:nil] lastObject];
    if (self) {
        self.frame = CGRectMake(0, 0, (GOS_SCREEN_W - 50)>290?290:(GOS_SCREEN_W - 50), (self.backListStr1.length >8?320:280));
    }
    return self;
}
- (NSString *)backListStr1{
    if (!_backListStr1) {
        _backListStr1 = DPLocalizedString(@"Configure_BackToDevListVC");
    }
    return _backListStr1;
}
@end
