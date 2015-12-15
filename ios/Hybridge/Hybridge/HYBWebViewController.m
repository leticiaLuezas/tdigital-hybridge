//
//  HYBWebViewController.m
//  Hybridge
//
//  Copyright (c) 2014 Telefonica I+D. All rights reserved.
//  Licensed under MIT, see LICENSE for more details.
//

#import "HYBWebViewController.h"
#import "HYBBridge.h"

@interface HYBWebViewController ()

@property (strong, nonatomic) NSURL *URL;

@end

@implementation HYBWebViewController

#pragma mark - Properties

- (UIWebView *)webView {
    return (UIWebView *)self.view;
}

#pragma mark - Lifecycle

- (void)dealloc {
    [self.webView stopLoading];
    self.webView.delegate = nil;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        _bridge = [[HYBBridge alloc] init];
        _bridge.delegate = self;
    }
    
    return self;
}

- (id)initWithURL:(NSURL *)url {
    self = [self initWithNibName:nil bundle:nil];
    
    if (self) {
        _URL = url;
    }
    
    return self;
}

- (void)loadView {
    if ([self nibName]) {
        [super loadView];
        NSAssert([self.view isKindOfClass:[UIWebView class]], @"HYBWebViewController view must be a UIWebView instance.");
    } else {
        UIWebView *view = [[UIWebView alloc] init];
        view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        view.scalesPageToFit = YES;
        view.delegate = self;
        
        self.view = view;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.URL) {
        [self.webView loadRequest:[NSURLRequest requestWithURL:self.URL]];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [HYBBridge setActiveBridge:self.bridge];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if (self.bridge == [HYBBridge activeBridge]) {
        [HYBBridge setActiveBridge:nil];
    }
}

- (void)webViewDidStartLoad {
}

- (void)webViewDidFinishLoad {
}

- (void)webViewDidFailLoadWithError:(NSError *)error {
}

#pragma mark - UIWebViewDelegate

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [self webViewDidStartLoad];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self.bridge prepareWebView:webView withRequestScheme:self.webView.request.URL.scheme];
    [self webViewDidFinishLoad];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [self webViewDidFailLoadWithError:error];
}

#pragma mark - HYBBridgeDelegate

- (NSArray *)bridgeActions:(HYBBridge *)bridge {
    return nil;
}

#pragma mark - HYBBridgeDelegate

- (NSDictionary *)bridgeCustomData:(HYBBridge *)bridge {
    return nil;
}

@end
