//
//  AppDelegate.h
//  jerusalemradio
//
//  Created by JooYoung Kim on 2017. 3. 21..
//  Copyright © 2017년 JooYoung Kim. All rights reserved.
//

#import <UIKit/UIKit.h>
@import MediaPlayer;
@class ActivityIndicatorCommonViewController;
#import "ModalViewController.h"
#import "STKAudioPlayer.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate> {
    
    ActivityIndicatorCommonViewController *processingController;
    NSString            *str_url;
    NSString            *str_alert;
    NSString            *str_view;
}

@property (strong, nonatomic) UIWindow *window;
//@property (strong, nonatomic) MPMoviePlayerController        *audioPlayer;
@property (strong, nonatomic) STKAudioPlayer *avAudioPlayer;
@property (strong, nonatomic) ModalViewController *modalView;


- (BOOL)handleOpenURL:(NSURL *)url;
- (void)handleRemoteNotification:(NSDictionary *)userInfo;
- (void)startAnimatedLodingView;
- (void)stopAnimatedLodingView;

@end

