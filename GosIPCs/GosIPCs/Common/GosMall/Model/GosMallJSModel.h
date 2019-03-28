//
//  GosMallJSModel.h
//  Goscom
//
//  Created by 罗乐 on 2018/12/27.
//  Copyright © 2018 goscam. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>

NS_ASSUME_NONNULL_BEGIN

/**
 js交互类父类
 */
@interface GosMallJSModel : NSObject

/**
 设置参数调用js方法，根据方法返回的json设置model
 
 @param jsContext 当前页面的jsContext对象
 @return 返回成功或者失败
 */
- (BOOL)callJSMethodWithJSContext:(JSContext *)jsContext;

@end

/**
控制页面返回上一页
*/
@interface WEB_GoBack : GosMallJSModel

@end

/**
 获取页面信息
 GetShareInfo方法只有在商品详情页面可以被调用，GetWebViewInfo方法所有页面均可调用
 */
@interface WEB_WebViewInfoModel : GosMallJSModel

/**
 Title: 顶部导航栏标题内容
 URL: 当前页的地址
 */
@property (nonatomic, strong) NSString *Title;
@property (nonatomic, strong) NSString *URL;
@property (nonatomic, assign) BOOL HasSearch;

@end

/**
 获取分享商品信息
 GetShareInfo方法只有在商品详情页面可以被调用，GetWebViewInfo方法所有页面均可调用
 */
@interface WEB_ShareInfoModel : GosMallJSModel
/**
 Title: 用于分享的标题内容
 URL: 用于分享的页面地址
 Picture: 用于分享的商品的图片地址
 Content: 用于分享的商品文字描述
 */
@property (nonatomic, readwrite, copy) NSString *URL;
@property (nonatomic, readwrite, copy) NSString *Picture;
@property (nonatomic, readwrite, copy) NSString *Title;
@property (nonatomic, readwrite, copy) NSString *Content;
@end


/**
 展开搜索框，主要用于首页、搜索页、分类页点击搜索框后拉起显示搜索框，此时不存在页面跳转只是显示视图
 */
@interface WEB_OpenSearch : GosMallJSModel
@end

/**
 描述：挂起搜索框，主要用于已展开搜索框后的返回按钮，点击返回按钮调用此方法挂起搜索框，此时也不存在页面跳转。
 
 注：搜索页为独立的页面，搜索框只是在首页、分类页、搜索页显示和隐藏的UI。
 */
@interface WEB_CloseSearch : GosMallJSModel
@end

/**
 支付方式
 
 - WEB_PAYMENT_ALIPAY: 支付宝
 - WEB_PAYMENT_WECHAT: 微信
 */
typedef NS_ENUM(int, WEB_PAYMENT) {
    WEB_PAYMENT_ALIPAY = 1,
    WEB_PAYMENT_WECHAT = 2
};

/**
 支付结果
 
 - WEB_PAY_RESULT_SUCCESS: 成功
 - WEB_PAY_RESULT_CANCEL: 取消
 - WEB_PAY_RESULT_FAILED: 失败
 */
typedef NS_ENUM(int, WEB_PAY_RESULT) {
    WEB_PAY_RESULT_SUCCESS  = 0,
    WEB_PAY_RESULT_CANCEL   = -1,
    WEB_PAY_RESULT_FAILED   = -2
};

/**
 返回支付结果给网页
 */
@interface WEB_ReturnPayResult : GosMallJSModel

@property (nonatomic, assign) WEB_PAY_RESULT arg_result; // 0-成功 -1 - 用户取消支付  -2 - 失败

@property (nonatomic, assign) WEB_PAYMENT    arg_peyment; // 1-支付宝 2-微信

@end

@interface WEB_GoUserCenter : GosMallJSModel

@end

NS_ASSUME_NONNULL_END
