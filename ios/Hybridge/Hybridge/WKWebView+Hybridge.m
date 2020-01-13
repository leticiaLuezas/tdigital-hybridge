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

- (NSString *)hyb_fireEvent:(NSString *)event data:(NSDictionary *)data {
    NSString *javascript = [NSString hyb_javascriptStringWithEvent:event data:data];
    return [self stringByEvaluatingJavaScriptFromString:javascript];
}

- (NSString *)stringByEvaluatingJavaScriptFromString:(NSString *)script {
    __block NSString *resultString = nil;
    __block BOOL finished = NO;
    
    [self evaluateJavaScript:script completionHandler:^(id result, NSError *error) {
        if (error == nil) {
            if (result != nil) {
                resultString = [NSString stringWithFormat:@"%@", result];
            }
        } else {
            NSLog(@"evaluateJavaScript error : %@", error.localizedDescription);
        }
        finished = YES;
    }];
    
    while (!finished)
    {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
    
    return resultString;
}

@end
