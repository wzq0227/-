//
//  GosMallJSModel.m
//  Goscom
//
//  Created by 罗乐 on 2018/12/27.
//  Copyright © 2018 goscam. All rights reserved.
//

#import "GosMallJSModel.h"
#import "YYModel.h"

static NSString *const WEB_GO_BACK              = @"naBridgeGoBack";
static NSString *const WEB_GET_VIEWINFO         = @"naBridgeGetInfo";
static NSString *const WEB_GET_SHAREINFO        = @"shareInfo";
static NSString *const WEB_OPEN_SEARCH          = @"naBridgeOpenSearch";
static NSString *const WEB_CLOSE_SEARCH         = @"naBridgeOutSearch";
static NSString *const WEB_GET_TOKEN_CALLBACK   = @"getTokenCallBack";
static NSString *const WEB_SAVE_NATIVE_INFO     = @"saveNativeInfo";
static NSString *const WEB_PAY_CALLBACK         = @"appPayCallBack";
static NSString *const WEB_GO_USER_CENTER       = @"naBridgeGoUser";

@interface GosMallJSModel ()

@property (nonatomic, strong, readonly) NSString *methodName;

@property (nonatomic, strong, readonly) NSArray  *arguments;

@end

@implementation GosMallJSModel
- (BOOL)callJSMethodWithJSContext:(JSContext *)jsContext{
    if (self.methodName == nil || jsContext == nil) {
        return NO;
    }
    JSValue *jsFun = jsContext[self.methodName];
    JSValue *jsStr = [jsFun callWithArguments:self.arguments];
    if (jsStr.isString) {
        return [self yy_modelSetWithJSON:[jsStr toString]];
    } else if (jsStr.isUndefined || jsStr.isNull) {
        return NO;
    }
    return YES;
}

- (BOOL)asyncCallJSMethodWithJSContext:(JSContext *)jsContext {
    if (self.methodName == nil || jsContext == nil) {
        return NO;
    }
    JSValue *jsFun = jsContext[self.methodName];
    
    //MARK:不知道为什么有的方法需要setTimeout间接调用才能成功
    JSValue *jsStr = [jsFun.context[@"setTimeout"] callWithArguments:@[jsFun, @0, self.arguments]];
    if (jsStr.isString) {
        return [self yy_modelSetWithJSON:[jsStr toString]];
    } else if (jsStr.isUndefined || jsStr.isNull) {
        return NO;
    }
    return YES;
}

- (NSString *)methodName {
    return nil;
}

- (NSArray *)arguments {
    return [[NSArray alloc] init];
}
@end

@implementation WEB_GoBack
- (NSString *)methodName {
    return WEB_GO_BACK;
}
@end

@implementation WEB_WebViewInfoModel
- (NSString *)methodName {
    return WEB_GET_VIEWINFO;
}
@end

@implementation WEB_ShareInfoModel
- (NSString *)methodName {
    return WEB_GET_SHAREINFO;
}

@end

@implementation WEB_OpenSearch
- (BOOL)callJSMethodWithJSContext:(JSContext *)jsContext {
    return [self asyncCallJSMethodWithJSContext:jsContext];
}

- (NSString *)methodName {
    return WEB_OPEN_SEARCH;
}
@end

@implementation WEB_CloseSearch
- (BOOL)callJSMethodWithJSContext:(JSContext *)jsContext {
    return [self asyncCallJSMethodWithJSContext:jsContext];
}

- (NSString *)methodName {
    return WEB_CLOSE_SEARCH;
}
@end

@implementation WEB_ReturnPayResult
- (NSArray *)arguments{
    NSDictionary *dic = @{
                          @"payment":@(self.arg_peyment),
                          @"result":@(self.arg_result)
                          };
    NSString *jsonStr = [dic yy_modelToJSONString];
    return @[jsonStr];
}

- (NSString *)methodName {
    return WEB_PAY_CALLBACK;
}
@end

@implementation WEB_GoUserCenter
- (NSString *)methodName {
    return WEB_GO_USER_CENTER;
}
@end
