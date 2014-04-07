//
//  HYBBridge.m
//  Hybridge
//
//  Copyright (c) 2014 Telefonica I+D. All rights reserved.
//  Licensed under the Affero GNU GPL v3, see LICENSE for more details.
//

#import "HYBBridge.h"
#import "HYBURLProtocol.h"
#import "HYBEvent.h"

#import "NSString+Hybridge.h"
#import "NSHTTPURLResponse+Hybridge.h"

static SEL HYBSelectorWithAction(NSString *action) {
    static dispatch_once_t onceToken;
    static NSMutableDictionary *selectorNames;
    
    dispatch_once(&onceToken, ^{
        selectorNames = [NSMutableDictionary dictionary];
    });
    
    NSString *selectorName = selectorNames[action];
    
    if (!selectorName) {
        // Convert the action name to CamelCase
        NSArray *components = [action componentsSeparatedByString:@"_"];
        NSMutableArray *mutableComponents = [NSMutableArray arrayWithCapacity:[components count]];
        [components enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [mutableComponents addObject:[obj capitalizedString]];
        }];
        action = [mutableComponents componentsJoinedByString:@""];
        
        // Cache the selector name
        selectorName = [NSString stringWithFormat:@"handle%@WithData:", action];
        selectorNames[action] = selectorName;
    }
    
    return NSSelectorFromString(selectorName);
}

static NSHTTPURLResponse *HYBSendAction(NSString *action, NSDictionary *data, NSObject<HYBBridgeDelegate> *delegate) {
    SEL selector = HYBSelectorWithAction(action);
    
    if ([delegate respondsToSelector:selector]) {
        NSMethodSignature *methodSignature = [delegate methodSignatureForSelector:selector];
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSignature];
        invocation.target = delegate;
        invocation.selector = selector;
        [invocation setArgument:&data atIndex:2];
        
		[invocation invoke];
        
		return [NSHTTPURLResponse hyb_responseWithAction:action statusCode:200];
    } else if ([delegate respondsToSelector:@selector(bridgeDidReceiveAction:data:)]) {
        NSHTTPURLResponse *response = [delegate bridgeDidReceiveAction:action data:data];
        return response ? : [NSHTTPURLResponse hyb_responseWithAction:action statusCode:200];
    }
    
    return [NSHTTPURLResponse hyb_responseWithAction:action statusCode:404];
}

@interface HYBBridge ()

@property (strong, nonatomic) dispatch_queue_t queue;

@end

@implementation HYBBridge

+ (void)initialize {
    if (self == [HYBBridge class]) {
        [NSURLProtocol registerClass:[HYBURLProtocol class]];
    }
}

+ (NSInteger)version {
    return 1;
}

static HYBBridge *activeBridge;

+ (void)setActiveBridge:(HYBBridge *)bridge {
    @synchronized(self) {
        activeBridge = bridge;
    }
}

+ (instancetype)activeBridge {
    @synchronized(self) {
        return activeBridge;
    }
}

- (id)init {
    return [self initWithQueue:nil];
}

- (id)initWithQueue:(dispatch_queue_t)queue {
    self = [super init];
    
    if (self) {
        self.queue = queue ? : dispatch_get_main_queue();
    }
    
    return self;
}

- (NSString *)prepareWebView:(UIWebView *)webView {
    NSParameterAssert(webView);
    
    static NSString * const kFormat = @"window.HybridgeGlobal || setTimeout(function() {"
                                      @"	window.HybridgeGlobal = {"
                                      @"		isReady:true,"
                                      @"		version:%@,"
                                      @"		actions:%@,"
                                      @"		events:%@"
                                      @"	};"
                                      @"	window.$ && $('#hybridgeTrigger').toggleClass('switch');"
                                      @"}, 0)";
    
    NSArray *actions = [self.delegate bridgeActions:self];
    NSString *actionsString = [NSString hyb_JSONStringWithObject:actions ? : @[]];
    
    NSArray *events = @[HYBEventPause, HYBEventResume, HYBEventMessage, HYBEventReady];
    NSString *eventsString = [NSString hyb_JSONStringWithObject:events];
    
    NSString *javascript = [NSString stringWithFormat:kFormat, @([[self class] version]), actionsString, eventsString];
    return [webView stringByEvaluatingJavaScriptFromString:javascript];
}

- (void)dispatchAction:(NSString *)action data:(NSDictionary *)data completion:(void (^)(NSHTTPURLResponse *))completion {
    NSParameterAssert(action);
    NSParameterAssert(completion);
    
    NSObject<HYBBridgeDelegate> *delegate = self.delegate;
    dispatch_async(self.queue, ^{
        NSHTTPURLResponse *response = HYBSendAction(action, data, delegate);
        completion(response);
    });
}

@end
