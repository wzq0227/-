//  MineWebViewController.m
//  Goscom
//
//  Create by daniel.hu on 2018/11/22.
//  Copyright © 2018年 goscam. All rights reserved.

#import "MineWebViewController.h"
#import <WebKit/WKWebView.h>
#import <WebKit/WKNavigationDelegate.h>
#import "MineWebViewModel.h"
#import "GosHUD.h"
#import "UIColor+GosColor.h"
#import "Masonry.h"

@interface MineWebViewController () <WKNavigationDelegate>
/// 网页控件
@property (nonatomic, strong) WKWebView *wkWebView;
/// 处理webviewcontroller业务逻辑
@property (nonatomic, strong) MineWebViewModel *mineWebViewModel;
/// 目标地址
@property (nonatomic, strong) NSURL *destinationURL;
/// 网页目标标记
@property (nonatomic, readwrite, assign) MineWebDestination mineWebDestination;
@end

@implementation MineWebViewController
#pragma mark - initialization
- (instancetype)init {
    return [self initWithMineWebDestination:MineWebDestinationUnknown];
}
- (instancetype)initWithMineWebDestination:(MineWebDestination)destination {
    if (self = [super init]) {
        self.mineWebDestination = destination;
    }
    return self;
}

#pragma mark - life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // 配置显示数据
    [self configDisplayData];
    // 配置网页控件
    [self configWebView];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    // 离开页面就清除Loading
    [GosHUD dismiss];
}

#pragma mark - config method
/// 配置网页控件
- (void)configWebView {
    [self.view addSubview:self.wkWebView];
    
    [self.wkWebView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view.mas_left);
        make.right.mas_equalTo(self.view.mas_right);
        make.top.mas_equalTo(self.view.mas_topMargin);
        make.bottom.mas_equalTo(self.view.mas_bottomMargin);
    }];
}
/// 配置显示数据
- (void)configDisplayData {
    self.view.backgroundColor = [UIColor gosGrayColor];
    
    NSString *title = nil;
    NSURL *destinationURL = nil;
    
    // 通过目标网页类型，获取网页应该显示的标题以及地址
    [self.mineWebViewModel loadMineWebDestination:self.mineWebDestination title:&title url:&destinationURL];
    
    self.title = title;
    self.destinationURL = destinationURL;
}

#pragma mark - WKNavigationDelegate
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    GosLog(@"%s", __PRETTY_FUNCTION__);
    [GosHUD dismiss];
}
- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    GosLog(@"%s", __PRETTY_FUNCTION__);
    [GosHUD dismiss];
}
- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation {
    GosLog(@"%s", __PRETTY_FUNCTION__);
}
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    GosLog(@"%s", __PRETTY_FUNCTION__);
}


#pragma mark - getters
- (WKWebView *)wkWebView {
    if (!_wkWebView) {
        _wkWebView = [[WKWebView alloc] init];
        _wkWebView.navigationDelegate = self;
    }
    return _wkWebView;
}
- (MineWebViewModel *)mineWebViewModel {
    if (!_mineWebViewModel) {
        _mineWebViewModel = [[MineWebViewModel alloc] init];
    }
    return _mineWebViewModel;
}
- (void)setDestinationURL:(NSURL *)destinationURL {
    _destinationURL = destinationURL;
    
    if (destinationURL) {
        [GosHUD showProcessHUDWithStatus:DPLocalizedString(@"Mine_Loading")];
        // 加载网页
        NSURLRequest *request = [[NSURLRequest alloc] initWithURL:destinationURL];
        
        [self.wkWebView loadRequest:request];
    } else {
        // 空白网页
    }
}
@end
