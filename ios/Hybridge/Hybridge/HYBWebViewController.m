//
//  HYBWebViewController.m
//  Hybridge
//
//  Copyright (c) 2014 Telefonica I+D. All rights reserved.
//  Licensed under MIT, see LICENSE for more details.
//

#import "HYBWebViewController.h"
#import "HYBBridge.h"
#import "NSHTTPURLResponse+Hybridge.h"
#import "HYBURLSchemeHandler.h"

@interface HYBWebViewController ()

@property (strong, nonatomic, readwrite) WKWebView *webView;
@property (strong, nonatomic) NSURL *URL;

@end

@implementation HYBWebViewController

#pragma mark - Properties

#pragma mark - Lifecycle

- (void)dealloc {
    [self.webView stopLoading];
    self.webView.navigationDelegate = nil;
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

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.URL) {
        HYBURLSchemeHandler *schemeHandler = [HYBURLSchemeHandler new];
        WKWebViewConfiguration *configuration = [WKWebViewConfiguration new];
//        [configuration setURLSchemeHandler:schemeHandler forURLScheme:@"hybridge"];
//        id<WKURLSchemeHandler> test = [configuration urlSchemeHandlerForURLScheme:@"https"];
     
        
        self.webView = [[WKWebView alloc] initWithFrame:self.view.frame configuration:configuration];
        self.webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        //view.scalesPageToFit = YES;
        self.webView.navigationDelegate = self;
        [self.view addSubview:self.webView];
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

#pragma mark - WKNavigationDelegate

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    [self webViewDidStartLoad];
}

- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(null_unspecified WKNavigation *)navigation {
    NSLog(@"didReceiveServerRedirectForProvisionalNavigation %@ webViewURL: %@", navigation, webView.URL);
}

- (void)webView:(WKWebView *)webView didCommitNavigation:(null_unspecified WKNavigation *)navigation {
       NSLog(@"didCommitNavigation %@ webViewURL: %@", navigation, webView.URL);
}


- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    [self.bridge prepareWebView:webView withRequestScheme:self.webView.URL.scheme];
    [self webViewDidFinishLoad];
}

- (void)        webView:(WKWebView *)webView
      didFailNavigation:(null_unspecified WKNavigation *)navigation
              withError:(nonnull NSError *)error
{
    [self webViewDidFailLoadWithError:error];
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    NSLog(@"decidePolicyForNavigationAction host response: %@", navigationAction.request.URL.host.lowercaseString);
        if ([webView.URL.host.lowercaseString isEqualToString:HYBHostName]) {
            decisionHandler(WKNavigationActionPolicyCancel);
            return;
        }
     decisionHandler(WKNavigationActionPolicyAllow);
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler {
    NSLog(@"decidePolicyForNavigationResponse host response: %@", navigationResponse.response.URL.host.lowercaseString);
    decisionHandler(WKNavigationResponsePolicyAllow);
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
