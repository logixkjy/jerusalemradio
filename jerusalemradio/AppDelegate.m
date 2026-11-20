//
//  AppDelegate.m
//  jerusalemradio
//
//  Created by JooYoung Kim on 2017. 3. 21..
//  Copyright © 2017년 JooYoung Kim. All rights reserved.
//

#import "AppDelegate.h"
#import "ActivityIndicatorCommonViewController.h"

#import <Firebase/Firebase.h>
//#import "AGPushNoteView.h"
#import <FirebaseMessaging/FIRMessaging.h>

#import "DBStorage.h"
#import <UserNotifications/UserNotifications.h>

@interface AppDelegate () <UNUserNotificationCenterDelegate, FIRMessagingDelegate>

@end

@implementation AppDelegate

NSString *const kGCMMessageIDKey = @"gcm.message_id";

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    return [self handleOpenURL:url];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    return [self handleOpenURL:url];
}

- (BOOL)handleOpenURL:(NSURL *)url {
    NSDictionary *callbackDic = [self URLSchemesCallbackParsing:[url absoluteString]];
    if (!callbackDic) return NO;
    
    NSInteger count = ((UINavigationController*)self.window.rootViewController).viewControllers.count;
    if (count > 1) {
        [[NSNotificationCenter defaultCenter] postNotificationName:CMD_PUSH_MOVE_LINK object:nil userInfo:callbackDic];
    } else {
        GetCommonData.schemesData = callbackDic;
    }
    
    return YES;
}

- (NSDictionary *)URLSchemesCallbackParsing:(NSString *)urlString
{
    NSRange funcPrefixRange = [urlString rangeOfString:@"jerusalemradio://" options:NSCaseInsensitiveSearch|NSBackwardsSearch];
    
    if (funcPrefixRange.location != NSNotFound) {
        @try {
            NSString *func = nil;
            NSMutableDictionary *param = [NSMutableDictionary dictionary];
            
            NSString *webAPI = [urlString substringFromIndex:funcPrefixRange.location+funcPrefixRange.length];
            NSUInteger separatedIndex = [webAPI rangeOfString:@"?"].location;
            if (separatedIndex != NSNotFound) {
                
                func = [webAPI substringToIndex:separatedIndex];
                if ([func length] > 0) {
                    param[@"func"] = func;
                }
                NSArray *paramList = [[webAPI substringFromIndex:separatedIndex+1] componentsSeparatedByString:@"&"];
                for (NSString *paramData in paramList)
                {
                    NSArray *temp = [paramData componentsSeparatedByString:@"="];
                    if ([temp count] == 2) {
                        param[temp[0]] = temp[1];
                    } else if ([temp count] > 2) {
                        separatedIndex = [paramData rangeOfString:@"="].location;
                        param[temp[0]] = [paramData substringFromIndex:separatedIndex+1];
                    }
                }
            } else {
                if ([webAPI length] > 0) {
                    param[@"func"] = webAPI;
                }
            }
            
            if ([param count] > 0) {
                return [NSDictionary dictionaryWithDictionary:param];
            }
        }
        @catch (NSException *exception) {
            
        }
    }
    
    return nil;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [FIRApp configure];
    
    [self resetBadge];
    
    // 캐시삭제
    NSString *LibraryDir = [NSString stringWithString:[NSHomeDirectory() stringByAppendingPathComponent:@"Library"]];
    
    NSString *Library_CachesDir = [NSString stringWithString:[LibraryDir stringByAppendingPathComponent:@"Caches"]];
    
    NSFileManager *fm = [NSFileManager defaultManager];
    
    NSArray *list = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:Library_CachesDir error:nil];
    
    int fileCount = (int)[list count];
    
    if (fileCount!=0)
    {
        for (NSString *path in [fm contentsOfDirectoryAtPath:Library_CachesDir error:nil])
        {
            [fm removeItemAtPath:[Library_CachesDir stringByAppendingPathComponent:path] error:nil];
        }
    }
    
//    [[DBStorage shared] initDB];
    GetCommonData.MAIN_URLstring = @"";
    if (application.applicationState != UIApplicationStateBackground) {
        // Track an app open here if we launch with a push, unless
        // "content_available" was used to trigger a background push (introduced in iOS 7).
        // In that case, we skip tracking here to avoid double counting the app-open.
        BOOL preBackgroundPush = ![application respondsToSelector:@selector(backgroundRefreshStatus)];
        BOOL oldPushHandlerOnly = ![self respondsToSelector:@selector(application:didReceiveRemoteNotification:fetchCompletionHandler:)];
        BOOL noPushPayload = ![launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
        if (preBackgroundPush || oldPushHandlerOnly || noPushPayload) {
            //            [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
            if (launchOptions != nil) {
                str_url = nil;
                str_view = nil;
                if ([[[launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey] allKeys] containsObject:@"gcm.notification.url"]) {
                    str_url = [[launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey] objectForKey:@"gcm.notification.url"];
                }
                if ([[[launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey] allKeys] containsObject:@"gcm.notification.view"]) {
                    str_view = [[launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey] objectForKey:@"gcm.notification.view"];
                }
                
                if (str_url != nil) {
                    [GetCommonData setPUSH_URL:str_url]; // http://kr.mahanaim.org/intro/prvideo.php
                    [GetCommonData setIsShowPUSH_URL:YES];
                    if (str_view != nil) {
                        if ([str_view isEqualToString:@"modal"]) {
                            [self showModalView:self.window.rootViewController];
                        } else {
                            GetCommonData.MAIN_URLstring = str_url;
                        }
                    }
                }
            }
        }
    }
    
    UNUserNotificationCenter *notificationCenter = UNUserNotificationCenter.currentNotificationCenter;
    notificationCenter.delegate = self;
    [FIRMessaging messaging].delegate = self;
    [notificationCenter requestAuthorizationWithOptions:UNAuthorizationOptionAlert | UNAuthorizationOptionBadge | UNAuthorizationOptionSound completionHandler:^(BOOL granted, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{ [application registerForRemoteNotifications]; });
    }];
    // [END register_for_notifications]
    // [START configure_firebase]
    //    [FIRApp configure];
    // [END configure_firebase]
    
    [FIRAnalytics logEventWithName:kFIREventSelectContent
                        parameters:@{
                                     kFIRParameterItemID:@"id-JerusalemRadio",
                                     kFIRParameterItemName:@"JerusalemRadio_AppDelegate",
                                     }];
    
    return YES;
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)(void))completionHandler {
    [self handleRemoteNotification:response.notification.request.content.userInfo];
    completionHandler();
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler {
    [self handleRemoteNotification:notification.request.content.userInfo];
    completionHandler(UNNotificationPresentationOptionNone);
}

#pragma mark - APNS.

// [START receive_message]
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [self handleRemoteNotification:userInfo];
}

- (void)handleRemoteNotification:(NSDictionary *)userInfo {
    UIApplication *application = UIApplication.sharedApplication;
    // If you are receiving a notification message while your app is in the background,
    // this callback will not be fired till the user taps on the notification launching the application.
    // TODO: Handle data of notification
    
    // Print message ID.
    if (userInfo[kGCMMessageIDKey]) {
        NSLog(@"Message ID: %@", userInfo[kGCMMessageIDKey]);
    }
    
    // Print full message.
    NSLog(@"%@", userInfo);
    
    [self resetBadge];
    str_url = nil;
    str_view = nil;
    str_alert = nil;
    if ([userInfo.allKeys containsObject:@"gcm.notification.url"]) {
        str_url = [userInfo objectForKey:@"gcm.notification.url"];
    }
    if ([[userInfo[@"aps"] allKeys] containsObject:@"alert"]) {
        if ([[userInfo[@"aps"] objectForKey:@"alert"] isKindOfClass:[NSDictionary class]] &&
            [[[userInfo[@"aps"] objectForKey:@"alert"] allKeys] containsObject:@"body"]) {
            str_alert = [userInfo[@"aps"] objectForKey:@"alert"][@"body"];
        } else {
            str_alert = [userInfo[@"aps"] objectForKey:@"alert"];
        }
    }
    if ([userInfo.allKeys containsObject:@"gcm.notification.view"]) {
        str_view = [userInfo objectForKey:@"gcm.notification.view"];
    }
    
    if (str_url != nil) {
        [GetCommonData setPUSH_URL:str_url]; // http://kr.mahanaim.org/intro/prvideo.php
        [GetCommonData setIsShowPUSH_URL:YES];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (application.applicationState == UIApplicationStateInactive) {
            if (str_url != nil) {
                if (str_view != nil) {
                    if ([str_view isEqualToString:@"modal"]) {
                        [self showModalView:self.window.rootViewController];
                    } else {
                        [self moveUrl];
                    }
                }
            }
        } else if (application.applicationState == UIApplicationStateActive) {
            if (str_alert != nil) {
                [MNMToast showWithText:str_alert completionHandler:nil tapHandler:^(MNMToastValue *toast) {
                    if (str_view != nil) {
                        if ([str_view isEqualToString:@"modal"]) {
                            [self showModalView:self.window.rootViewController];
                        } else {
                            [self moveUrl];
                        }
                    }
                }];
            }
        }
    });
}

// [END ios_10_data_message_handling]
// [START refresh_token]
- (void)messaging:(FIRMessaging *)messaging didReceiveRegistrationToken:(NSString *)fcmToken {
    NSLog(@"FCM registration token: %@", fcmToken);
    // Notify about received token.
    
    // TODO: If necessary send token to application server.
    // Note: This callback is fired at each app startup and whenever a new token is generated.
    
    [[FIRMessaging messaging] subscribeToTopic:@"ios"];
    
    if (![CommonUtil readBoolFromDefault:@"isRegisterDevice"]) {
        [self sendRegisterDevice:fcmToken];
    }
}
// [END refresh_token]

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"Unable to register for remote notifications: %@", error);
}

// This function is added here only for debugging purposes, and can be removed if swizzling is enabled.
// If swizzling is disabled then this function must be implemented so that the APNs device token can be paired to
// the FCM registration token.
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSLog(@"APNs device token retrieved: %@", deviceToken);
    
    // With swizzling disabled you must set the APNs device token here.
    [FIRMessaging messaging].APNSToken = deviceToken;
}

- (void)sendRegisterDevice:(NSString*)fcmToken
{
    NSDictionary *param = @{@"deviceToken":fcmToken,
                            @"deviceType":@"ios",
                            @"appIdentifier":@"com.goodnews.jerusalemradio2",
                            @"appName":@"예루살렘라디오",
                            @"appVersion":[[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"],
                            @"phone":@"",
                            @"timezone":[[NSTimeZone localTimeZone] name]};
    
    NSMutableString *body = [NSMutableString string];
    for (NSString *key in param.allKeys) {
        [body appendString:body.length == 0 ?@"":@"&"];
        [body appendString:key];
        [body appendString:@"="];
        [body appendString:param[key]];
    }
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://www.goodnews.or.kr/adm/notification/registerDevice"]];
    [request setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
    [request setHTTPMethod:@"POST"];
    
    [[NSURLSession.sharedSession dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (!error && [(NSHTTPURLResponse *)response statusCode] >= 200 && [(NSHTTPURLResponse *)response statusCode] < 300) {
            [CommonUtil writeBoolToDefault:YES KEY:@"isRegisterDevice"];
        }
    }] resume];

    //    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    //
    //    [manager POST:@"http://neo.goodnews.or.kr/adm/notification/registerDevice" parameters:param progress:nil
    //          success:^(NSURLSessionDataTask * _Nonnull task, id responseObject) {
    //              NSLog(@"Response: %@", responseObject);
    //          } failure:^(NSURLSessionDataTask * _Nullable task, NSError *error) {
    //              NSLog(@"Error: %@", error);
    //          }];
}

-(void)resetBadge {
    //Badge 개수 초기화
    [UNUserNotificationCenter.currentNotificationCenter setBadgeCount:0 withCompletionHandler:nil];
}

- (void) showModalView:(id)target{
    
    if (!GetCommonData.isShowModalView) {
        self.modalView = nil;
        ModalViewController *pushUrlView = [self.window.rootViewController.storyboard instantiateViewControllerWithIdentifier:@"modalView"];
        self.modalView = pushUrlView;
        
        GetCommonData.isShowModalView = YES;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [target presentViewController:self.modalView animated:YES completion:nil];
        });
    }
    
    return;
}

- (void)moveUrl {
    dispatch_async(dispatch_get_main_queue(), ^{
        GetCommonData.MAIN_URLstring = str_url;
//        [((MainViewController*)self.window.rootViewController) loadMainUrl];
    });
}

#pragma mark -
#pragma mark Animation View part

- (void)startAnimatedLodingView
{
    if (processingController == nil) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
        processingController = [storyboard instantiateViewControllerWithIdentifier:@"processingController"];
        [self.window addSubview:processingController.view];
    }
    [self.window bringSubviewToFront:processingController.view];
    NSLog(@"startAnimatedLodingView");
}
 
- (void)stopAnimatedLodingView
{
    if (processingController) {
        [processingController removeFromSuperViewFadeout];
        processingController = nil;
    }
    NSLog(@"stopAnimatedLodingView");
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
