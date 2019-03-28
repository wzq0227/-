//
//  AlertInputWiFiView.m
//  Goscom
//
//  Created by 匡匡 on 2018/11/29.
//  Copyright © 2018 goscam. All rights reserved.
//

#import "AlertInputWiFiView.h"
#import "KKAlertView.h"
@interface AlertInputWiFiView()
@property (weak, nonatomic) IBOutlet UILabel *wifiSetLab;
@property (weak, nonatomic) IBOutlet UIButton *cancelBtn;
@property (weak, nonatomic) IBOutlet UIButton *setBtn;


@property (weak, nonatomic) IBOutlet UITextField *wifiNameTF;
@property (weak, nonatomic) IBOutlet UITextField *wifiPasswordTF;

@end
@implementation AlertInputWiFiView

+ (instancetype)initWithFrame:(CGRect)frame
                     SSidName:(NSString *)wifiName
                     delegate:(id<AlertInputWiFiViewDelegate>)delegate{
    AlertInputWiFiView * view = [[AlertInputWiFiView alloc] init];
    view.wifiNameTF.text = wifiName;
    view.delegate = delegate;
    return view;
}

- (IBAction)actionCancelClick:(UIButton *)sender {
    KKAlertView * alert = (KKAlertView *)self.superview;
    [alert hide];
}
- (IBAction)actionSureClick:(UIButton *)sender {
    if (self.wifiPasswordTF.text.length < 1) {
        return;
    }
    KKAlertView * alert = (KKAlertView *)self.superview;
    [alert hide];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(alertInputViewCallBack:password:)]) {
        [self.delegate alertInputViewCallBack:self.wifiNameTF.text password:self.wifiPasswordTF.text];
    }
}
- (void)awakeFromNib{
    [super awakeFromNib];
    self.layer.cornerRadius = 5;
    self.clipsToBounds = YES;
    self.wifiNameTF.enabled = NO;
}
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    self = [[[NSBundle mainBundle] loadNibNamed:@"AlertInputWiFiView" owner:self options:nil] lastObject];
    if (self) {
        self.frame = CGRectMake(0, 0, 240, 220);
    }
    return self;
}
@end
