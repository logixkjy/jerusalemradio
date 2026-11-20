#import "SceneDelegate.h"
#import "AppDelegate.h"
#import "JRBiblePlayback.h"
#import <UserNotifications/UserNotifications.h>

@implementation SceneDelegate

- (void)scene:(UIScene *)scene willConnectToSession:(UISceneSession *)session options:(UISceneConnectionOptions *)connectionOptions {
    if (![scene isKindOfClass:UIWindowScene.class]) return;

    // UIKit creates this window and its root controller from the scene storyboard.
    // Keep the existing app-wide window reference used by the player and overlays.
    AppDelegate *appDelegate = (AppDelegate *)UIApplication.sharedApplication.delegate;
    appDelegate.window = self.window;

    for (UIOpenURLContext *context in connectionOptions.URLContexts) {
        [appDelegate handleOpenURL:context.URL];
    }
    if (connectionOptions.notificationResponse) {
        [appDelegate handleRemoteNotification:connectionOptions.notificationResponse.notification.request.content.userInfo];
    }
    [self.window makeKeyAndVisible];
}

- (void)scene:(UIScene *)scene openURLContexts:(NSSet<UIOpenURLContext *> *)URLContexts {
    AppDelegate *appDelegate = (AppDelegate *)UIApplication.sharedApplication.delegate;
    for (UIOpenURLContext *context in URLContexts) {
        [appDelegate handleOpenURL:context.URL];
    }
}

- (void)sceneWillResignActive:(UIScene *)scene {
    [[JRBiblePlayback shared] savePosition];
}

- (void)sceneDidEnterBackground:(UIScene *)scene {
    [[JRBiblePlayback shared] savePosition];
}

@end
