//
//  HYBURLSchemeHandler.m
//  Hybridge
//
//  Created by llv245 on 17/01/2020.
//  Copyright © 2020 Telefonica I+D. All rights reserved.
//

#import "HYBURLSchemeHandler.h"
#import "NSHTTPURLResponse+Hybridge.h"

@implementation HYBURLSchemeHandler


- (void)webView:(WKWebView *)webView startURLSchemeTask:(id<WKURLSchemeTask>)urlSchemeTask {
    NSURL *url = urlSchemeTask.request.URL;
    NSLog(@"startURLSchemeTask : %@", url.absoluteString);
    if ([url.host isEqualToString:HYBHostName]) {
        NSLog(@"Hybridge!!!!");
    }
}

- (void)webView:(WKWebView *)webView stopURLSchemeTask:(id<WKURLSchemeTask>)urlSchemeTask {
    
}

@end
