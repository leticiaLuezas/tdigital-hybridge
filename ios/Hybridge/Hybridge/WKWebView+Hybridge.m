//
//  WKWebView+Hybridge.m
//  Hybridge
//
//  Copyright (c) 2014 Telefonica I+D. All rights reserved.
//  Licensed under MIT, see LICENSE for more details.
//

#import "WKWebView+Hybridge.h"
#import "NSString+Hybridge.h"

@implementation WKWebView (Hybridge)

- (void)hyb_fireEvent:(NSString *)event data:(NSDictionary *)data {
    NSString *javascript = [NSString hyb_javascriptStringWithEvent:event data:data];
    [self evaluateJavaScript:javascript completionHandler:nil];
}

@end
