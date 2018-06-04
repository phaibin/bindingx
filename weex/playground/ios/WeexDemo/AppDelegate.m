/**
 * Created by Weex.
 * Copyright (c) 2016, Alibaba, Inc. All rights reserved.
 *
 * This source code is licensed under the Apache Licence 2.0.
 * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
 */

#import "AppDelegate.h"
#import "WXDemoViewController.h"
#import "UIViewController+WXDemoNaviBar.h"
#import "WXEventModule.h"
#import "WXImgLoaderDefaultImpl.h"
#import "DemoDefine.h"
#import "WXScannerVC.h"
#import "WXSyncTestModule.h"
#import "UIView+UIThreadCheck.h"
#import <WeexSDK/WeexSDK.h>
#import <AVFoundation/AVFoundation.h>
#import <ATSDK/ATManager.h>
#import "WXNavigationImpl.h"
#import <BindingX/EBHandlerFactory.h>
#import "CustomEBHandler.h"

@interface AppDelegate ()
@end

@implementation AppDelegate

#pragma mark
#pragma mark application

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor];
    
    [self initWeexSDK];
    
    self.window.rootViewController = [[WXRootViewController alloc] initWithRootViewController:[self demoController]];
    [self.window makeKeyAndVisible];
    
#if DEBUG
    // check if there are any UI changes on main thread.
    [UIView wx_checkUIThread];
#endif
    
    [EBHandlerFactory addHandler:[CustomEBHandler new]];
    
    return YES;
}

-(void)application:(UIApplication *)application performActionForShortcutItem:(UIApplicationShortcutItem *)shortcutItem completionHandler:(void (^)(BOOL))completionHandler
{
    if ([shortcutItem.type isEqualToString:QRSCAN]) {
        WXScannerVC * scanViewController = [[WXScannerVC alloc] init];
        [(WXRootViewController*)self.window.rootViewController pushViewController:scanViewController animated:YES];
    }
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    
#ifdef UITEST
#if !TARGET_IPHONE_SIMULATOR
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    setenv("GCOV_PREFIX", [documentsDirectory cStringUsingEncoding:NSUTF8StringEncoding], 1);
    setenv("GCOV_PREFIX_STRIP", "6", 1);
#endif
    extern void __gcov_flush(void);
    __gcov_flush();
#endif
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    NSString *newUrlStr = url.absoluteString;
    if([url.scheme isEqualToString:@"wxpage"]) {
        newUrlStr = [newUrlStr stringByReplacingOccurrencesOfString:@"wxpage://" withString:@"http://"];
    }
    UIViewController * viewController = [self demoController];
    ((WXDemoViewController*)viewController).url = [NSURL URLWithString:newUrlStr];
    [(WXRootViewController*)self.window.rootViewController pushViewController:viewController animated:YES];
    return YES;
}

#pragma mark weex
- (void)initWeexSDK
{
    [WXAppConfiguration setAppGroup:@"AliApp"];
    [WXAppConfiguration setAppName:@"WeexDemo"];
    [WXAppConfiguration setExternalUserAgent:@"ExternalUA"];
    
    [WXSDKEngine initSDKEnvironment];
    
    [WXSDKEngine registerHandler:[WXImgLoaderDefaultImpl new] withProtocol:@protocol(WXImgLoaderProtocol)];
    [WXSDKEngine registerHandler:[WXEventModule new] withProtocol:@protocol(WXEventModuleProtocol)];
    [WXSDKEngine registerHandler:[WXNavigationImpl new] withProtocol:@protocol(WXNavigationProtocol)];
    
    [WXSDKEngine registerComponent:@"select" withClass:NSClassFromString(@"WXSelectComponent")];
    [WXSDKEngine registerModule:@"event" withClass:[WXEventModule class]];
    [WXSDKEngine registerModule:@"syncTest" withClass:[WXSyncTestModule class]];
    
#if !(TARGET_IPHONE_SIMULATOR)
    
#endif
    
#ifdef DEBUG
//    [self atAddPlugin];
//    [WXDebugTool setDebug:YES];
//    [WXLog setLogLevel:WXLogLevelLog];
    
    #ifndef UITEST
//        [[ATManager shareInstance] show];
    #endif
#else
//    [WXDebugTool setDebug:NO];
//   [WXLog setLogLevel:WXLogLevelError];
#endif
}

- (UIViewController *)demoController
{
    UIViewController *demo = [[WXDemoViewController alloc] init];
    
#if DEBUG
    //If you are debugging in device , please change the host to current IP of your computer.
    ((WXDemoViewController *)demo).url = [NSURL URLWithString:@"https://jsplayground.taobao.org/bundle/69c73b5e-cc82-4c69-8098-c668f9fe1310/raxbundle.js?wh_weex=true&wh_ttid=native&_wx_tpl=https://jsplayground.taobao.org/bundle/69c73b5e-cc82-4c69-8098-c668f9fe1310/raxbundle.js"];
#else
    ((WXDemoViewController *)demo).url = [NSURL URLWithString:BUNDLE_URL];
#endif
    
#ifdef UITEST
    ((WXDemoViewController *)demo).url = [NSURL URLWithString:UITEST_HOME_URL];
#endif
    
    return demo;
}

#pragma mark

- (void)atAddPlugin {
    
    [[ATManager shareInstance] addPluginWithId:@"weex" andName:@"weex" andIconName:@"../weex" andEntry:@"" andArgs:@[@""]];
    [[ATManager shareInstance] addSubPluginWithParentId:@"weex" andSubId:@"logger" andName:@"logger" andIconName:@"log" andEntry:@"WXATLoggerPlugin" andArgs:@[@""]];
//    [[ATManager shareInstance] addSubPluginWithParentId:@"weex" andSubId:@"viewHierarchy" andName:@"hierarchy" andIconName:@"log" andEntry:@"WXATViewHierarchyPlugin" andArgs:@[@""]];
    [[ATManager shareInstance] addSubPluginWithParentId:@"weex" andSubId:@"test2" andName:@"test" andIconName:@"at_arr_refresh" andEntry:@"" andArgs:@[]];
    [[ATManager shareInstance] addSubPluginWithParentId:@"weex" andSubId:@"test3" andName:@"test" andIconName:@"at_arr_refresh" andEntry:@"" andArgs:@[]];
}

@end
