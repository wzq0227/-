//
//  LocalizableStrings.m
//  Goscom
//
//  Created by shenyuanluo on 2018/11/12.
//  Copyright © 2018 shenyuanluo. All rights reserved.
//

#import "LocalizableStrings.h"

@implementation LocalizableStrings

+ (NSString *)LocalizedString:(NSString *)translation_key {
    
    NSString * s = NSLocalizedString(translation_key, nil);
    
    return s;
}

@end
