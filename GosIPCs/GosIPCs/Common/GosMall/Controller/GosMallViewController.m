//
//  GosMallViewController.m
//  Goscom
//
//  Created by shenyuanluo on 2018/11/10.
//  Copyright © 2018 shenyuanluo. All rights reserved.
//

#import "GosMallViewController.h"
#import <JavaScriptCore/JavaScriptCore.h>
#import "GosMallJSModel.h"
#import "GosLoggedInUserInfo.h"

#define ONLINE_SHOP_URL               @"https://t-console.ulifecam.com/dashboard-store/index.html"

#define ONLINE_SHOP_URL_PREFIX          @"https://t-console.ulifecam.com/dashboard-store/"
#define ONLINE_SHOP_ARGUMENT            @"?isApp=1"//区分是否为app访问
#define ONLINE_SHOP_COOKIES_KEY         @"USERTOKEN"//cookies中保存用户登录token的key值
#define ONLINE_SHOP_WECHAT_PAY_URL      @"https://t-console.ulifecam.com/dashboard-store/pay/wechat/beforehand/goscam"
#define ONLINE_SHOP_ALIPAY_PAY_URL      @"https://t-console.ulifecam.com/dashboard-store/pay/alipay/order/sign"
#define ONLINE_SHOP_ALIPAY_CHECK_URL    @"https://t-console.ulifecam.com/dashboard-store/pay/alipay/payment/check"
#define ONLINE_SHOP_WECHAT_CHECK_URL    @"https://t-console.ulifecam.com/dashboard-store/pay/wechat/check/?order_id=%@"
#define ONLINE_SHOP_PAY_ARGUMENT        @"?order_id=%@&token=%@"

@protocol OnlineShopViewJSDelegate <JSExport>
@required
- (void)payWithPayReqJSon:(JSValue *)jsonStr;
@end

/**
 页面类型
 */
typedef NS_ENUM(int, WEBVIEW_TYPE) {
    WEBVIEW_UNKNOWN     = 0,    //未知页
    WEBVIEW_OTHERVIEW   = 1,    //其他页
    WEBVIEW_HOMEPAGE    = 2,    //主页
    WEBVIEW_SEARCHVIEW  = 3,    //搜索页
    WEBVIEW_GOODDETIAL  = 4     //商品详情页
};

@interface GosMallViewController ()<
UIWebViewDelegate,
//                                    UMSocialShareMenuViewDelegate,
OnlineShopViewJSDelegate
>

@property (nonatomic, assign) WEBVIEW_TYPE currentViewType;
@property (nonatomic, assign) WEBVIEW_TYPE lastViewType;
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (nonatomic, readwrite, strong) WEB_ShareInfoModel *shareModel;
@property (nonatomic, readwrite, strong) UIImage *thumImage;
@property (nonatomic, strong) JSContext *jsContext;
@property (nonatomic, strong) NSString *token;
@property (nonatomic, strong) NSString *orderID;
@end

@implementation GosMallViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = DPLocalizedString(@"GosMall");
    self.webView.delegate = self;
    
    [self addLeftBarButtonItem];
    [self addRightBarButtonItem];
    [self configBackBtnHidden:YES];
    
    [self saveCookies];
    [self loadWeb];
}

- (void)dealloc
{
    GosLog(@"---------- GosMallViewController dealloc ----------");
}

#pragma mark -- 初始加载网页
- (void)loadWeb
{
    [SVProgressHUD showWithStatus:DPLocalizedString(@"SVPLoading")];
    //添加app标识
    NSString *newURLStr = [ONLINE_SHOP_URL stringByAppendingString:ONLINE_SHOP_ARGUMENT];
    NSURL *url = [NSURL URLWithString:newURLStr];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    [self.webView loadRequest:request];
}


#pragma mark - UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSURL * url = [request URL];
    
    [self setViewTypeWithURL:url];
    
    return YES;
}

//- (void)webViewDidStartLoad:(UIWebView *)webView {
//
//}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [SVProgressHUD dismiss];
    
    self.jsContext = [self.webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    GOS_WEAK_SELF;
    self.jsContext.exceptionHandler = ^(JSContext *context,
                                        JSValue *exceptionValue)
    {
        GOS_STRONG_SELF;
        strongSelf.currentViewType = WEBVIEW_UNKNOWN;
        strongSelf.jsContext = nil;
        context.exception = exceptionValue;
        GosLog(@"在线商城加载异常：%@", exceptionValue);
    };
    
    self.jsContext[@"iosApp"] = self;//将自身作为参数传给js,用于js调用方法
    
    NSString *currentURL = [webView stringByEvaluatingJavaScriptFromString:@"document.location.href"];
    GosLog(@"currentURL = %@", currentURL);
    
    [self getWebViewInfo];
    
}


- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [SVProgressHUD dismiss];
}


#pragma mark - js交互
#pragma mark -- 获取商品信息
- (void)getGoodsInfo
{
    WEB_ShareInfoModel *shareModel = [[WEB_ShareInfoModel alloc] init];
    if ([shareModel callJSMethodWithJSContext:self.jsContext])
    {
        self.shareModel = shareModel;
    } else {
        self.shareModel = nil;
    }
}

#pragma mark -- 获取页面信息
- (void)getWebViewInfo
{
    WEB_WebViewInfoModel *infoModel = [[WEB_WebViewInfoModel alloc] init];
    if ([infoModel callJSMethodWithJSContext:self.jsContext])
    {
        self.navigationItem.title = infoModel.Title;
        if (infoModel.HasSearch) {
            [self configsearchAndShareBtnHidden:NO];
            [self configRishtBtnSearchType];
        }
    }
}

#pragma mark - 将用户token保存在cookie
- (void)saveCookies {
    // 获取cookieStorage
    NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    
    NSURL *url = [NSURL URLWithString:ONLINE_SHOP_URL_PREFIX];
    [[NSURLCache sharedURLCache] removeCachedResponseForRequest:[NSURLRequest requestWithURL:url]];
    
    NSArray * cookArray = [cookieStorage cookiesForURL:[NSURL URLWithString:ONLINE_SHOP_URL_PREFIX]];
    for (NSHTTPCookie *cookie in cookArray) {
        if([cookie.name isEqualToString:ONLINE_SHOP_COOKIES_KEY]) {
            [cookieStorage deleteCookie:cookie];
        }
    }
    // 创建一个可变字典存放cookie
    // cookieh中存放token用于自动登录
    NSMutableDictionary *cookieProperties = [NSMutableDictionary dictionary];
    [cookieProperties setObject:ONLINE_SHOP_COOKIES_KEY forKey:NSHTTPCookieName];
    [cookieProperties setObject:self.token forKey:NSHTTPCookieValue];
    [cookieProperties setObject:[url host] forKey:NSHTTPCookieDomain];
    [cookieProperties setObject:ONLINE_SHOP_URL_PREFIX forKey:NSHTTPCookieOriginURL];
    [cookieProperties setObject:@"/" forKey:NSHTTPCookiePath];
    [cookieProperties setObject:@"0" forKey:NSHTTPCookieVersion];
    
    // 将可变字典转化为cookie
    NSHTTPCookie *cookie = [NSHTTPCookie cookieWithProperties:cookieProperties];
    
    // 存储cookie
    [cookieStorage setCookie:cookie];
}

#pragma mark - navigationBar button 添加
#pragma mark -- 添加 左侧item
- (void)addLeftBarButtonItem
{
    UIImage *image = [UIImage imageNamed:@"GosMall_back"];
    EnlargeClickButton *button = [EnlargeClickButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 70, 40);
    button.imageEdgeInsets = UIEdgeInsetsMake(10, 0, 10, 50);
    [button setImage:image forState:UIControlStateNormal];
    [button addTarget:self
               action:@selector(backBtnAction:)
     forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    leftBarButtonItem.style = UIBarButtonItemStylePlain;
    self.navigationItem.leftBarButtonItem = leftBarButtonItem;
}

#pragma mark -- 添加 右侧item
- (void)addRightBarButtonItem
{
    EnlargeClickButton *shareBtn = [EnlargeClickButton buttonWithType:UIButtonTypeCustom];
    shareBtn.frame     = CGRectMake(0, 0, 40, 40);
    [shareBtn addTarget:self
                 action:@selector(rightBtnAction:)
       forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *RightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:shareBtn];
    
    EnlargeClickButton *userCenterBtn = [EnlargeClickButton buttonWithType:UIButtonTypeCustom];
    [userCenterBtn setImage:[UIImage imageNamed:@"GosMall_user"] forState:UIControlStateNormal];
    [userCenterBtn setTitle:@"" forState:UIControlStateNormal];
    userCenterBtn.frame     = CGRectMake(0, 0, 40, 40);
    [userCenterBtn addTarget:self
                      action:@selector(userCenterBtnAction:)
            forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *RightBarButtonItem1 = [[UIBarButtonItem alloc] initWithCustomView:userCenterBtn];
    
    self.navigationItem.rightBarButtonItems = @[RightBarButtonItem1, RightBarButtonItem];
}

#pragma mark - navigationBar button 显示设置
#pragma mark -- 根据页面类型控制navigationBar button显示
- (void)configNavBarButtonWithViewType:(WEBVIEW_TYPE)viewType {
    BOOL backBtnHidden = NO;
    BOOL usercentBtnHidden = NO;
    BOOL searchAndShareBtnHidden = NO; //除了商品详情页和搜索页，其它页面是否有该按钮需要根据网页返回的参数判断
    switch (viewType) {
        case WEBVIEW_GOODDETIAL:
            [self configRishtBtnShareType];
            break;
        case WEBVIEW_OTHERVIEW:
            searchAndShareBtnHidden = YES;
            break;
        case WEBVIEW_HOMEPAGE:
            //隐藏返回按钮
            backBtnHidden = YES;
            searchAndShareBtnHidden = YES;
            break;
        case WEBVIEW_SEARCHVIEW:
            //已经在搜索页，隐藏搜索按钮
            searchAndShareBtnHidden = YES;
            break;
        case WEBVIEW_UNKNOWN:
            searchAndShareBtnHidden = YES;
            usercentBtnHidden = YES;
            break;
        default:
            break;
    }
    
    [self configBackBtnHidden:backBtnHidden];
    [self configUserCenterBtnHidden:usercentBtnHidden];
    [self configsearchAndShareBtnHidden:searchAndShareBtnHidden];
    
}

#pragma mark -- 设置返回按钮
- (void)configBackBtnHidden:(BOOL)hidden {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIButton *btn = (UIButton *)self.navigationItem.leftBarButtonItem.customView;
        btn.hidden = hidden;
    });
}

#pragma mark -- 设置个人中心按钮
- (void)configUserCenterBtnHidden:(BOOL)hidden {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIButton *btn = (UIButton *)self.navigationItem.rightBarButtonItems[0].customView;
        btn.hidden = hidden;
    });
}

#pragma mark -- 设置右侧按钮按钮
- (void)configsearchAndShareBtnHidden:(BOOL)isHidden
{
    dispatch_async(dispatch_get_main_queue(), ^{
        UIButton *btn = (UIButton *)self.navigationItem.rightBarButtonItems[1].customView;
        btn.hidden = isHidden;
    });
}

- (void)configRishtBtnSearchType {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIButton *btn = (UIButton *)self.navigationItem.rightBarButtonItems[1].customView;
        [btn setImage:[UIImage imageNamed:@"GosMall_search"] forState:UIControlStateNormal];
        [btn setTitle:@"" forState:UIControlStateNormal];
    });
}

- (void)configRishtBtnShareType {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIButton *btn = (UIButton *)self.navigationItem.rightBarButtonItems[1].customView;
        [btn setImage:nil forState:UIControlStateNormal];
        [btn setTitle:DPLocalizedString(@"Mall_Share") forState:UIControlStateNormal];
    });
}

#pragma mark - navigationBar button action
#pragma mark -- 分享按钮action
- (void)shareGoods:(UIButton *)button
{
    //    [self showBottomNormalView];
}

#pragma mark -- 搜索按钮action
- (void)searchBtnAction:(UIButton *)button {
    if (self.currentViewType != WEBVIEW_SEARCHVIEW) {
        self.lastViewType = self.currentViewType;
        self.currentViewType = WEBVIEW_SEARCHVIEW;
        WEB_OpenSearch *open = [[WEB_OpenSearch alloc] init];
        [open callJSMethodWithJSContext:self.jsContext];
    }
}

#pragma mark -- 返回按钮action
- (void)backBtnAction:(UIButton *)button {
    switch (self.currentViewType) {
        case WEBVIEW_GOODDETIAL:
        case WEBVIEW_OTHERVIEW:{
            //调用JS接口返回上一页
            WEB_GoBack *backModel = [[WEB_GoBack alloc] init];
            [backModel callJSMethodWithJSContext:self.jsContext];
        }
            break;
        case WEBVIEW_HOMEPAGE:{
        }
            break;
        case WEBVIEW_SEARCHVIEW: {
            //关闭搜索页
            WEB_CloseSearch *close = [[WEB_CloseSearch alloc] init];
            [close callJSMethodWithJSContext:self.jsContext];
            self.currentViewType = self.lastViewType;
        }
            break;
        case WEBVIEW_UNKNOWN:{
            //进入非网上商城页面，点击返回回到商城首页
            NSString *newURLStr = [NSString stringWithFormat:@"%@?%@",ONLINE_SHOP_URL,ONLINE_SHOP_ARGUMENT];
            NSURL *url = [NSURL URLWithString:newURLStr];
            NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.webView loadRequest:request];
            });
        }
            break;
        default:
            break;
    }
}

#pragma mark -- 右侧按钮action
// 包括分享和搜索按钮
- (void)rightBtnAction:(UIButton *)button {
    if (self.currentViewType == WEBVIEW_GOODDETIAL) {
        [self shareGoods:button];
    } else {//if (self.currentViewType == WEBVIEW_SEARCHVIEW) {
        [self searchBtnAction:button];
    }
}

#pragma mark -- 用户中心action
- (void)userCenterBtnAction:(UIButton *)button {
    WEB_GoUserCenter *go = [[WEB_GoUserCenter alloc] init];
    [go callJSMethodWithJSContext:self.jsContext];
}

#pragma mark - 页面类型判断
- (void)setViewTypeWithURL:(NSURL *)url {
    NSString *urlStr = [url absoluteString];
    if ([urlStr hasPrefix:ONLINE_SHOP_URL]) { //主页
        self.currentViewType = WEBVIEW_HOMEPAGE;
    } else if ([urlStr hasPrefix:ONLINE_SHOP_URL_PREFIX]) {
        if ([urlStr containsString:@"goods"]) {
            self.currentViewType = WEBVIEW_GOODDETIAL;
        }
        else {
            self.currentViewType = WEBVIEW_OTHERVIEW;
        }
    } else {
        self.currentViewType = WEBVIEW_UNKNOWN;
    }
}

#pragma mark - setter & getter
- (NSString *)token {
    if (_token == nil) {
        _token = [[GosLoggedInUserInfo userToken] copy];
        if (_token == nil || _token.length == 0) {
            GosLog(@"token 为空");
        }else {
            GosLog(@"token ll:%@",_token);
        }
    }
    return _token;
}

- (void)setCurrentViewType:(WEBVIEW_TYPE)currentViewType {
    if (_currentViewType != currentViewType) {
        _currentViewType = currentViewType;
        [self configNavBarButtonWithViewType:currentViewType];
    }
}

#pragma mark - 支付其他
#pragma mark -- 网页通过OnlineShopViewJSDelegate调用支付
- (void)payWithPayReqJSon:(JSValue *)jsonStr {
    NSData *jsonData = [[jsonStr toString] dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    NSNumber *payment = dic[@"PayMent"];
    if (payment.intValue == 1) {
        //        [self goToAliPayWithOrderID:dic[@"OrderId"]];
    } else if (payment.intValue == 2) {
        //        [self goToWeChatPayWithOrderID:dic[@"OrderId"]];
    }
}
@end
