//
//  HYBWebViewController.h
//  Hybridge
//
//  Copyright (c) 2014 Telefonica I+D. All rights reserved.
//  Licensed under MIT, see LICENSE for more details.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

#import "HYBBridge.h"

/**
 A view controller that manages a web view and the bridge to communicate with it.
 */
@interface HYBWebViewController : UIViewController <WKNavigationDelegate, HYBBridgeDelegate>

@property (strong, nonatomic, readonly) WKWebView *webView;
@property (strong, nonatomic, readonly) HYBBridge *bridge;

- (id)initWithURL:(NSURL *)url;

- (void)webViewDidStartLoad;

- (void)webViewDidFinishLoad;

- (void)webViewDidFailLoadWithError:(NSError *)error;

@end
