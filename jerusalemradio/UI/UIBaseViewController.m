//
//  UIBaseViewController.m
//  jerusalemradio
//
//  Created by JooYoung Kim on 2017. 5. 2..
//  Copyright © 2017년 JooYoung Kim. All rights reserved.
//

#import "UIBaseViewController.h"
#import "UIWebViewController.h"
#import "UINoticeViewController.h"
#import "ViewController.h"
#import "UIScheduleViewController.h"
#import "UILoginViewController.h"
#import "SettingViewController.h"
#import "UIAODListViewController.h"
#import <Reachability.h>

#import "DBStorage.h"
#import "STKAudioPlayer.h"

@import AVFoundation;
@import AudioToolbox;

@interface UIBaseViewController () <UITextViewDelegate, UIAlertViewDelegate, UIGestureRecognizerDelegate, STKAudioPlayerDelegate> {
    
    IBOutlet UIView *backView;
    NSDictionary *metadata;
    
    NSTimer *mainTimer;
    
    UIRefreshControl *refreshControl;
    
    BOOL isPlay;
}

@end

@implementation UIBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    // 오른쪽으로
    UISwipeGestureRecognizer *rightRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(rightSwipeHandle:)];
    rightRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    [rightRecognizer setNumberOfTouchesRequired:1];
    [rightRecognizer setDelegate:self];
    [self.view addGestureRecognizer:rightRecognizer];
    
    // 왼쪽으로
    UISwipeGestureRecognizer *leftRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(leftSwipeHandle:)];
    leftRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    [leftRecognizer setNumberOfTouchesRequired:1];
    [leftRecognizer setDelegate:self];
    [self.view addGestureRecognizer:leftRecognizer];
    
    self.mainDelegate = MAIN_APP_DELEGATE();
    
    
    self.sl_progress = [[UISlider alloc] initWithFrame:CGRectMake(-5, 5, MAIN_SIZE().width+10, 10)];
    [self.sl_progress setThumbImage:[UIImage imageNamed:@"player_time_handle"] forState:UIControlStateNormal];
    [self.sl_progress setBackgroundColor:[UIColor clearColor]];
    self.sl_progress.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.0, 6);
    [self.sl_progress setMinimumTrackTintColor:UIColorFromRGB(0xF5AF14)];
    [self.sl_progress setMaximumTrackTintColor:UIColorFromRGB(0x4d4d58)];
    [self.sl_progress setValue:0];
    [self.sl_progress addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    
    [self.vi_progress addSubview:self.sl_progress];
    [self.vi_progress sendSubviewToBack:self.sl_progress];
    self.vi_progress.clipsToBounds = NO;
    
    _lbl_title.font = [UIFont systemFontOfSizeForDpi:12];
    _lbl_time.font = [UIFont systemFontOfSizeForDpi:9];
    
    __weak typeof(self)weakSelf = self;
//    Reachability *reachability = [[Reachability alloc] init];
//    if ([reachability isReachableViaWWAN]) {
//        self.lbl_playback_time.text = @"00:00:00";
//        self.lbl_duration.text = @"00:00:00";
//        [self.vi_progress setBackgroundColor:UIColorFromRGB(0xF5AF14)];
//        [mainTimer invalidate];
//        [self.timer invalidate];
//        [_mainDelegate.audioPlayer stop];
//        _btn_play.selected = NO;
//        _btn_next.enabled = NO;
//        _btn_prev.enabled = NO;
//        _btn_play.enabled = NO;
//        _lbl_title.text = @"";
//        _lbl_time.text = @"";
//        _img_onair.hidden = YES;
//    } else {
//    if ([URLAddressManager getLocal] != PT) {
        [self setLiveInfoCompletionHandler:^(NSDictionary *data, BOOL isSuccess) {
            weakSelf.commentsList = [[NSMutableArray alloc] init];
            [weakSelf getComments];
            [weakSelf initLayout];
            if (self.mainDelegate.avAudioPlayer.state == STKAudioPlayerStateStopped ||
                self.mainDelegate.avAudioPlayer == nil) {
                if (isSuccess) {
                    if ([GetCommonData.liveType isEqualToString:@"track"]) {
                        if (![GetCommonData.metadata[@"track_title"] isKindOfClass:[NSNull class]] &&
                            [GetCommonData.metadata[@"track_title"] length] > 0) {
                            [weakSelf play];
                        }
                    } else if ([GetCommonData.liveType isEqualToString:@"livestream"]) {
                        if (![GetCommonData.showsCurrent[@"name"] isKindOfClass:[NSNull class]] &&
                            [GetCommonData.showsCurrent[@"name"] length] > 0) {
                            [weakSelf play];
                        }
                    }
                }
            }
        }];
//    }
    
    self.tv_comments.placeholder = NSLocalizedString(@"Comment_hint", @"청취 소감을 남겨주세요!(100자 내외)");
    self.tv_comments.placeholderLabel.font = [UIFont systemFontOfSize:10.];
    
    CGSize mainSize = [[UIScreen mainScreen] bounds].size;
    UIView *_m_keyboardToolBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, mainSize.width, 44)];
    [_m_keyboardToolBar setBackgroundColor:UIColorFromRGB(0xF8F8F8)];
    
    UIImageView *img_topLine = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, mainSize.width, 1)];
    [img_topLine setBackgroundColor:UIColorFromRGB(0xB2B2B2)];
    [_m_keyboardToolBar addSubview:img_topLine];
    
    //    UIImageView *img_logo = [[UIImageView alloc] initWithFrame:CGRectMake(8, 15.5, 123, 13)];
    //    [img_logo setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"action_logo" ofType:@"png"]]];
    //    [_m_keyboardToolBar addSubview:img_logo];
    
    UIButton *btn_key_close = [UIButton buttonWithType:UIButtonTypeSystem];
    [btn_key_close setFrame:CGRectMake(mainSize.width - 37, 9, 37, 27)];
    [btn_key_close setTitle:NSLocalizedString(@"common_ok", @"확인") forState:UIControlStateNormal];
    [btn_key_close setTitleColor:UIColorFromRGB(0x5F5F5F) forState:UIControlStateNormal];
    [btn_key_close addTarget:self action:@selector(closeKeyboard) forControlEvents:UIControlEventTouchUpInside];
    
    [_m_keyboardToolBar addSubview:btn_key_close];
    
    self.tv_comments.inputAccessoryView = _m_keyboardToolBar;
    
    if (![mainTimer isValid]) {
        mainTimer = [NSTimer scheduledTimerWithTimeInterval:30 repeats:YES block:^(NSTimer * _Nonnull timer) {
            [self setLiveInfoCompletionHandler:nil];
        }];
    }
    
    _lmg_mainImg.image = [UIImage imageNamed:@"default_image"];
    
//    CGFloat btn_size = 0;
//    if (IS_4_INCH || IS_3_5_INCH) {
//        btn_size = 60;
//    } else {
//        btn_size = 80;
//    }
    
//    self.menuView.frame = CGRectMake(-btn_size, (CommonUtil.isiPhoneXScreen ? 44 : 20), btn_size, CGRectGetHeight([UIScreen mainScreen].bounds) - (CommonUtil.isiPhoneXScreen ? 44 : 20));
//    self.img_logo.frame = CGRectMake(0, 0, btn_size, btn_size);
////    if ([URLAddressManager getLocal] == PT) {
////        self.btn_live.hidden = YES;
////        self.btn_live.frame = CGRectZero;
////        GetCommonData.audio_mode = @"AOD";
////        self.btn_aod.frame = CGRectMake(0, CGRectGetMaxY(self.img_logo.frame)+1, btn_size, btn_size);
////
////    } else {
//        self.btn_live.frame = CGRectMake(0, CGRectGetMaxY(self.img_logo.frame)+1, btn_size, btn_size);
//        self.btn_aod.frame = CGRectMake(0, CGRectGetMaxY(self.btn_live.frame)+1, btn_size, btn_size);
////    }
//    self.btn_schedule.frame = CGRectMake(0, CGRectGetMaxY(self.btn_aod.frame)+1, btn_size, btn_size);
//    if ([URLAddressManager getLocal] != KR) {
//        self.btn_notice.frame = CGRectZero;
//        self.btn_notice.hidden = YES;
//        self.btn_setting.frame = CGRectMake(0, CGRectGetMaxY(self.btn_schedule.frame)+1, btn_size, btn_size);
//    } else {
//        self.btn_notice.frame = CGRectMake(0, CGRectGetMaxY(self.btn_schedule.frame)+1, btn_size, btn_size);
//        self.btn_setting.frame = CGRectMake(0, CGRectGetMaxY(self.btn_notice.frame)+1, btn_size, btn_size);
//    }
//    self.btn_close.frame = CGRectMake((btn_size - 46) / 2, CGRectGetMinY(self.btn_close.frame), 46, 46);
 
    CGFloat maxY = 0;
    self.menuView.frame = CGRectMake(-RESIZE(332), 0, RESIZE(332), MAIN_SIZE().height);
    UIView *statusView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, RESIZE(332), CommonUtil.getSafaAreaTop - 20)];
    statusView.backgroundColor = UIColorFromRGB(0xF6B719);
    [self.menuView addSubview:statusView];
    maxY = CGRectGetMaxY(statusView.frame);
    self.img_logo.frame = CGRectMake(0, maxY, RESIZE(332), RESIZE(160));
    self.img_logo.backgroundColor = UIColorFromRGB(0xF6B719);
    UIImageView *img_line = [[UIImageView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.img_logo.frame) - RESIZE(2), RESIZE(332), RESIZE(2))];
    img_line.backgroundColor = UIColorFromRGB(0x888888);
    [self.menuView addSubview:img_line];
    
    maxY = CGRectGetMaxY(self.img_logo.frame);
    self.btn_live.frame = CGRectMake(0, maxY, RESIZE(332), RESIZE(160));
    [self.btn_live setImage:[UIImage imageNamed:@"menu_icon_mic01"] forState:UIControlStateNormal];
    [self.btn_live setTitle:NSLocalizedString(@"Menu_live", @"Live") forState:UIControlStateNormal];
    [self.btn_live setTitleColor:UIColorFromRGB(0x292B35) forState:UIControlStateNormal];
    [self.btn_live.titleLabel setFont:[UIFont boldSystemFontOfSize720:28]];
    [self.btn_live setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [self.btn_live setContentEdgeInsets:UIEdgeInsetsMake(0, RESIZE(55), 0, 0)];
    [self.btn_live setTitleEdgeInsets:UIEdgeInsetsMake(0, RESIZE(22), 0, 0)];
    img_line = [[UIImageView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.btn_live.frame) - RESIZE(2), RESIZE(332), RESIZE(2))];
    img_line.backgroundColor = UIColorFromRGB(0x888888);
    [self.menuView addSubview:img_line];
    
    maxY = CGRectGetMaxY(self.btn_live.frame);
    self.btn_aod.frame = CGRectMake(0, maxY, RESIZE(332), RESIZE(160));
    [self.btn_aod setImage:[UIImage imageNamed:@"menu_icon_headphones01"] forState:UIControlStateNormal];
    [self.btn_aod setTitle:NSLocalizedString(@"Menu_again", @"다시 듣기") forState:UIControlStateNormal];
    [self.btn_aod setTitleColor:UIColorFromRGB(0x292B35) forState:UIControlStateNormal];
    [self.btn_aod.titleLabel setFont:[UIFont boldSystemFontOfSize720:28]];
    [self.btn_aod setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [self.btn_aod setContentEdgeInsets:UIEdgeInsetsMake(0, RESIZE(55), 0, 0)];
    [self.btn_aod setTitleEdgeInsets:UIEdgeInsetsMake(0, RESIZE(22), 0, 0)];
    img_line = [[UIImageView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.btn_aod.frame) - RESIZE(2), RESIZE(332), RESIZE(2))];
    img_line.backgroundColor = UIColorFromRGB(0x888888);
    [self.menuView addSubview:img_line];
    
    maxY = CGRectGetMaxY(self.btn_aod.frame);
    self.btn_schedule.frame = CGRectMake(0, maxY, RESIZE(332), RESIZE(160));
    [self.btn_schedule setImage:[UIImage imageNamed:@"menu_icon_schedule01"] forState:UIControlStateNormal];
    [self.btn_schedule setTitle:NSLocalizedString(@"Menu_pairing", @"편성표") forState:UIControlStateNormal];
    [self.btn_schedule setTitleColor:UIColorFromRGB(0x292B35) forState:UIControlStateNormal];
    [self.btn_schedule.titleLabel setFont:[UIFont boldSystemFontOfSize720:28]];
    [self.btn_schedule setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [self.btn_schedule setContentEdgeInsets:UIEdgeInsetsMake(0, RESIZE(55), 0, 0)];
    [self.btn_schedule setTitleEdgeInsets:UIEdgeInsetsMake(0, RESIZE(22), 0, 0)];
    img_line = [[UIImageView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.btn_schedule.frame) - RESIZE(2), RESIZE(332), RESIZE(2))];
    img_line.backgroundColor = UIColorFromRGB(0x888888);
    [self.menuView addSubview:img_line];
    
    maxY = CGRectGetMaxY(self.btn_schedule.frame);
    if ([URLAddressManager getLocal] != KR) {
        self.btn_notice.frame = CGRectZero;
        self.btn_notice.hidden = YES;
    } else {
        self.btn_notice.hidden = NO;
        self.btn_notice.frame = CGRectMake(0, maxY, RESIZE(332), RESIZE(160));
        [self.btn_notice setImage:[UIImage imageNamed:@"menu_icon_notice01"] forState:UIControlStateNormal];
        [self.btn_notice setTitle:@"공지사항" forState:UIControlStateNormal];
        [self.btn_notice setTitleColor:UIColorFromRGB(0x292B35) forState:UIControlStateNormal];
        [self.btn_notice.titleLabel setFont:[UIFont boldSystemFontOfSize720:28]];
        [self.btn_notice setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        [self.btn_notice setContentEdgeInsets:UIEdgeInsetsMake(0, RESIZE(55), 0, 0)];
        [self.btn_notice setTitleEdgeInsets:UIEdgeInsetsMake(0, RESIZE(22), 0, 0)];
        img_line = [[UIImageView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.btn_notice.frame) - RESIZE(2), RESIZE(332), RESIZE(2))];
        img_line.backgroundColor = UIColorFromRGB(0x888888);
        [self.menuView addSubview:img_line];
        maxY = CGRectGetMaxY(self.btn_notice.frame);
    }
    
    self.btn_setting.frame = CGRectMake(0, maxY, RESIZE(332), RESIZE(160));
    [self.btn_setting setImage:[UIImage imageNamed:@"menu_icon_setting01"] forState:UIControlStateNormal];
    [self.btn_setting setTitle:NSLocalizedString(@"Menu_setting", @"설정") forState:UIControlStateNormal];
    [self.btn_setting setTitleColor:UIColorFromRGB(0x292B35) forState:UIControlStateNormal];
    [self.btn_setting.titleLabel setFont:[UIFont boldSystemFontOfSize720:28]];
    [self.btn_setting setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [self.btn_setting setContentEdgeInsets:UIEdgeInsetsMake(0, RESIZE(55), 0, 0)];
    [self.btn_setting setTitleEdgeInsets:UIEdgeInsetsMake(0, RESIZE(22), 0, 0)];
    img_line = [[UIImageView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.btn_setting.frame) - RESIZE(2), RESIZE(332), RESIZE(2))];
    img_line.backgroundColor = UIColorFromRGB(0x888888);
    [self.menuView addSubview:img_line];
    
    self.commentsView.frame = CGRectMake(MAIN_SIZE().width, isiPhoneXScreen() ? 44 : 20, MAIN_SIZE().width - RESIZE(96), MAIN_SIZE().height - (isiPhoneXScreen() ? 44 : 20));
    
    _noticeTitleView.frame = CGRectMake(0, 0, MAIN_SIZE().width - RESIZE(96), RESIZE(86));
    
    _img_comments.frame = CGRectMake(RESIZE(18), (RESIZE(86) - RESIZE(40)) / 2, RESIZE(40), RESIZE(40));
    
    self.lbl_notice_title.frame = CGRectMake(RESIZE(90), 0, RESIZE(440), RESIZE(86));
    self.lbl_notice_title.font = [UIFont systemFontOfSize720:32];
    
    _btn_board.frame = CGRectMake(CGRectGetWidth(self.commentsView.frame) - RESIZE(86), 0, RESIZE(86), RESIZE(86));
    
    self.lbl_notice_name.font = [UIFont systemFontOfSize720:30];
    self.lbl_notice_desc.font = [UIFont systemFontOfSize720:28];
    
    self.commentsInputView.frame = CGRectMake(0, CGRectGetHeight(self.commentsView.frame) - RESIZE(145) - (isiPhoneXScreen() ? 34 : 0), MAIN_SIZE().width - RESIZE(96), RESIZE(145) + (isiPhoneXScreen() ? 34 : 0));
    self.tv_comments.frame = CGRectMake(RESIZE(33), 0, RESIZE(475), RESIZE(145));
    self.tv_comments.font = [UIFont systemFontOfSize720:30];
    self.btn_Input.frame = CGRectMake(MAIN_SIZE().width - RESIZE(108) - RESIZE(96), (RESIZE(145) - RESIZE(90)) / 2, RESIZE(90), RESIZE(90));
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //이걸 지우면 전화걸때... 꺼짐
    [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayback error: nil];
    
    //백그라운드에서 재생
    AVAudioSession*session =[AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayback error:nil];
    [session setActive:YES error:nil];
    
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    [self becomeFirstResponder];
    
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(moviePlayerLoadStateChanged:)
//                                                 name:MPMoviePlayerLoadStateDidChangeNotification
//                                               object:nil];
//
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(moviePlayBackDidFinish:)
//                                                 name:MPMoviePlayerPlaybackDidFinishNotification
//                                               object:self.mainDelegate.audioPlayer];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(ActionPlaybackStateInterrupted)
                                                 name:_CMD_PLAYBACK_STATE_INTERRUPTED
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillResignActive)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:NULL];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidBecomeActive)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:NULL];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(pushMoveLinkNotification:)
                                                 name:CMD_PUSH_MOVE_LINK object:nil];
    
    if (self.mainDelegate.avAudioPlayer.state == STKAudioPlayerStatePlaying) {
        self.btn_play.selected = YES;
        if (![self.timer isValid]) {
            self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updatePlaybackProgressFromTimer:) userInfo:nil repeats:YES];
        }
    }
    else  {
        if (![GetCommonData.audio_mode isEqualToString:@"AOD"]) {
            self.lbl_playback_time.text = [self convertIntToTime:GetCommonData.liveTimeInterval];
            self.lbl_duration.text = @"00:00:00";
            [self.vi_progress setBackgroundColor:UIColorFromRGB(0xF5AF14)];
        } else {
            [self.vi_progress setBackgroundColor:UIColorFromRGB(0x4D4D58)];
        }
        
        self.btn_play.selected = NO;
    }
    
    if (_commentsList.count > 0) {
        [_commentsTableView reloadData];
    }
    
    if (![GetCommonData.audio_mode isEqualToString:@"AOD"]) {
        [self.sl_progress setHidden:YES];
        if (GetCommonData.thum == nil) {
            GetCommonData.thum = [UIImage imageNamed:@"default_image"];
        }
        self.lmg_mainImg.image = GetCommonData.thum;
    } else {
        [self.sl_progress setHidden:NO];
        if (GetCommonData.aodMetaData != nil) {
//            @try {
//                __weak typeof(self)weakSelf = self;
//                NSString *str_thum = [NSString stringWithFormat:[URLAddressManager getURL:[URLAddressManager getLocal] type:MAINIMAGE], GetCommonData.aodMetaData[@"PR_THUMBS"]];
//                [self.lmg_mainImg setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:str_thum]]
//                                        placeholderImage:[UIImage imageNamed:@"default_image"]
//                                                 success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, UIImage * _Nonnull image) {
//                                                     weakSelf.lmg_mainImg.image = image;
//                                                     GetCommonData.thum = image;
//                                                 } failure:nil];
//            } @catch (NSException *exception) {
//                self.lmg_mainImg.image = [UIImage imageNamed:@"default_image"];
//            }
            @try {
                if (![GetCommonData.aodMetaData[@"PR_NAME"] isEqualToString:self.lbl_notice_title.text]) {
                    [self getComments];
                }
                self.lbl_notice_title.text = GetCommonData.aodMetaData[@"PR_NAME"];
            } @catch (NSException *exception) {
                self.lbl_notice_title.text = @"NO NAME";
            }
            @try {
                self.lbl_title.text = GetCommonData.aodData[@"CT_NAME"];
            } @catch (NSException *exception) {
                self.lbl_title.text = @"NO NAME";
            }
            @try {
                NSString *str_host = @"";
                if (![GetCommonData.aodData[@"CT_HOST"] isKindOfClass:[NSNull class]] && [GetCommonData.aodData[@"CT_HOST"] length] > 0)
                str_host = [str_host stringByAppendingFormat:NSLocalizedString(@"ListenDetail_item_contents4", @"진행:%@"),GetCommonData.aodData[@"CT_HOST"]];
                
                if (![GetCommonData.aodData[@"CT_PANEL"] isKindOfClass:[NSNull class]] && [GetCommonData.aodData[@"CT_PANEL"] length] > 0)
                str_host = [str_host stringByAppendingFormat:NSLocalizedString(@"ListenDetail_item_contents1", @"%@패널:%@"),str_host.length > 0 ? @", " : @"",GetCommonData.aodData[@"CT_PANEL"]];
                
                if (![GetCommonData.aodData[@"CT_GUEST"] isKindOfClass:[NSNull class]] && [GetCommonData.aodData[@"CT_GUEST"] length] > 0)
                str_host = [str_host stringByAppendingFormat:NSLocalizedString(@"ListenDetail_item_contents5", @"%@게스트:%@"),str_host.length > 0 ? @", " : @"",GetCommonData.aodData[@"CT_GUEST"]];
                
                if (![GetCommonData.aodData[@"CT_SPEAKER"] isKindOfClass:[NSNull class]] && [GetCommonData.aodData[@"CT_SPEAKER"] length] > 0)
                str_host = [str_host stringByAppendingFormat:@"%@",GetCommonData.aodData[@"CT_SPEAKER"]];
                
                
                self.lbl_time.text = str_host;
            } @catch (NSException *exception) {
                self.lbl_time.text = @"No information";
            }
                
            [self.lbl_time sizeToFit];
            
            
        } else {
            self.lbl_notice_title.text = @"NO NAME";
            self.lbl_title.text = @"NO NAME";
            self.lbl_time.text = @"No information";
        }
        self.img_onair.hidden = YES;
        
        self.btn_prev.enabled = YES;
        self.btn_next.enabled = YES;
        self.btn_play.enabled = YES;
        self.btn_onair.enabled = YES;
        self.btn_comments.enabled = YES;
        
        [self.tb_AODSubList reloadData];
        
    }
    self.commentsView.frame = CGRectMake(MAIN_SIZE().width, 20 + (CommonUtil.isiPhoneXScreen ? 24 : 0), 248, CGRectGetHeight([UIScreen mainScreen].bounds) - 20 - (CommonUtil.isiPhoneXScreen ? 24 : 0));
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:CMD_PUSH_MOVE_LINK
                                                  object:nil];
    
    [self resignFirstResponder];
    [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerLoadStateDidChangeNotification object:nil];
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:self.mainDelegate.audioPlayer];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:_CMD_MOVE_SETTING_VIEW object:nil];
    [self.timer invalidate];
}

- (void)applicationWillResignActive
{
    GetCommonData.backgroudPauseTimeInterval = [NSDate timeIntervalSinceReferenceDate];
}

- (void)applicationDidBecomeActive
{
//    if (![[AFNetworkReachabilityManager sharedManager] isReachable]) {
//        self.lbl_playback_time.text = @"00:00:00";
//        self.lbl_duration.text = @"00:00:00";
//        [self.vi_progress setBackgroundColor:UIColorFromRGB(0xF5AF14)];
//        [mainTimer invalidate];
//        [self.timer invalidate];
//        [_mainDelegate.audioPlayer stop];
//        _btn_play.selected = NO;
//    } else {
        if (_mainDelegate.avAudioPlayer.state == STKAudioPlayerStatePlaying) {
            _btn_play.selected = YES;
        } else {
            GetCommonData.pauseTimeInterval = [NSDate timeIntervalSinceReferenceDate] - GetCommonData.backgroudPauseTimeInterval;
            _btn_play.selected = NO;
            if ([GetCommonData.audio_mode isEqualToString:@"AOD"]) {
                if (GetCommonData.CT_NO != nil && GetCommonData.CT_NO.length > 0) {
                    [CommonUtil writeIntToDefault:self.mainDelegate.avAudioPlayer.progress KEY:GetCommonData.CT_NO];
                }
            }
        }
        if (![mainTimer isValid]) {
            mainTimer = [NSTimer scheduledTimerWithTimeInterval:30 repeats:YES block:^(NSTimer * _Nonnull timer) {
                [self setLiveInfoCompletionHandler:nil];
            }];
        }
        if (![self.timer isValid]) {
            self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updatePlaybackProgressFromTimer:) userInfo:nil repeats:YES];
        }
//    }
}

-(void)remoteControlReceivedWithEvent:(UIEvent *)event
{
    if ( event.type == UIEventTypeRemoteControl ) {
        switch (event.subtype) {
            case UIEventSubtypeRemoteControlTogglePlayPause:
                if (_mainDelegate.avAudioPlayer.state == STKAudioPlayerStatePlaying) {
                    [_mainDelegate.avAudioPlayer pause];
                } else if (_mainDelegate.avAudioPlayer.state == STKAudioPlayerStatePaused) {
                    [_mainDelegate.avAudioPlayer resume];
                }
                NSLog(@"UIEventSubtypeRemoteControlTogglePlayPause");
                break;
            case UIEventSubtypeRemoteControlPlay:
                NSLog(@"UIEventSubtypeRemoteControlPlay");
                [_mainDelegate.avAudioPlayer resume];
                break;
            case UIEventSubtypeRemoteControlPause:
                NSLog(@"UIEventSubtypeRemoteControlPause");
                [_mainDelegate.avAudioPlayer pause];
                if ([GetCommonData.audio_mode isEqualToString:@"AOD"]) {
                    [CommonUtil writeIntToDefault:self.mainDelegate.avAudioPlayer.progress KEY:GetCommonData.CT_NO];
                }
                break;
            case UIEventSubtypeRemoteControlStop:
                NSLog(@"UIEventSubtypeRemoteControlStop");
                [_mainDelegate.avAudioPlayer stop];
                if ([GetCommonData.audio_mode isEqualToString:@"AOD"]) {
                    [CommonUtil writeIntToDefault:self.mainDelegate.avAudioPlayer.progress KEY:GetCommonData.CT_NO];
                }
                break;
            case UIEventSubtypeRemoteControlNextTrack:
                NSLog(@"UIEventSubtypeRemoteControlNextTrack");
//                [_mainDelegate.audioPlayer stop];
//                [self moveTrackWithEventSubType:UIEventSubtypeRemoteControlNextTrack];
                break;
            case UIEventSubtypeRemoteControlPreviousTrack:
                NSLog(@"UIEventSubtypeRemoteControlPreviousTrack");
//                [_mainDelegate.audioPlayer stop];
//                [self moveTrackWithEventSubType:UIEventSubtypeRemoteControlPreviousTrack];
                break;
            case UIEventSubtypeRemoteControlBeginSeekingBackward:
                NSLog(@"UIEventSubtypeRemoteControlBeginSeekingBackward");
                break;
            case UIEventSubtypeRemoteControlEndSeekingBackward:
                NSLog(@"UIEventSubtypeRemoteControlEndSeekingBackward");
                break;
            case UIEventSubtypeRemoteControlBeginSeekingForward:
                NSLog(@"UIEventSubtypeRemoteControlBeginSeekingForward");
                break;
            case UIEventSubtypeRemoteControlEndSeekingForward:
                NSLog(@"UIEventSubtypeRemoteControlEndSeekingForward");
                break;
                
            default:
                break;
        }
    }
}

- (void)closeKeyboard
{
    [UINavigationController globalResignFirstResponder];
}

- (void)pushMoveLinkNotification:(NSNotification*)noti
{
    [self onSchemesData:noti.userInfo];
}
- (void)onSchemesData:(NSDictionary*)callbackDic
{
    if ([callbackDic[@"func"] isEqualToString:@"program"]) {
        UIAODListViewController *view = [self.storyboard instantiateViewControllerWithIdentifier:@"UIAODListView"];
        view.PR_ID = callbackDic[@"PR_ID"];
        view.PR_NAME = [callbackDic[@"PR_NAME"] URLDecode];
        [self.navigationController pushViewController:view animated:NO];
    } else if ([callbackDic[@"func"] isEqualToString:@"content"]) {
        [self getContentsInfo:callbackDic[@"CT_NO"]];
    } else if ([callbackDic[@"func"] isEqualToString:@"main"]) {
        [self onMoveLive];
    } else if ([callbackDic[@"func"] isEqualToString:@"intro"]) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

- (void)getContentsInfo:(NSString*)CT_NO
{
    NSString *url = [CONTENT_GET_INFO_KR stringByAppendingString:CT_NO];
    [[URLAddressManager shared] getComments:url CompletionHandler:^(NSDictionary *data, NSError *error) {
        @try {
            NSDictionary *aodData = data[@"CONTENTS"][@"data"][0];
            GetCommonData.PR_ID = aodData[@"PR_ID"];
            GetCommonData.aodData = aodData;
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAODListViewController *view = [self.storyboard instantiateViewControllerWithIdentifier:@"UIAODListView"];
                view.PR_ID = aodData[@"PR_ID"];
                view.PR_NAME = [aodData[@"PR_NAME"] URLDecode];
                view.isPlay = YES;
                [self.navigationController pushViewController:view animated:NO];
            });
        } @catch (NSException *exception) {
            NSLog(@"%@",exception);
        }
        
        
    }];
}

/// Raised when an item has started playing
-(void) audioPlayer:(STKAudioPlayer*)audioPlayer didStartPlayingQueueItemId:(NSObject*)queueItemId
{
    
}
/// Raised when an item has finished buffering (may or may not be the currently playing item)
/// This event may be raised multiple times for the same item if seek is invoked on the player
-(void) audioPlayer:(STKAudioPlayer*)audioPlayer didFinishBufferingSourceWithQueueItemId:(NSObject*)queueItemId
{
    
}
/// Raised when the state of the player has changed
-(void) audioPlayer:(STKAudioPlayer*)audioPlayer stateChanged:(STKAudioPlayerState)state previousState:(STKAudioPlayerState)previousState
{
//    if (self.mainDelegate.avAudioPlayer.state != STKAudioPlayerStatePlaying) {
//        [self.mainDelegate.avAudioPlayer resume];
//    } else
    if (self.mainDelegate.avAudioPlayer.state == STKAudioPlayerStatePlaying) {
        [self.mainDelegate stopAnimatedLodingView];

        if ([GetCommonData.audio_mode isEqualToString:@"AOD"]) {
            if ([CommonUtil readIntFromDefault:GetCommonData.CT_NO] > 0) {
                NSLog(@"interval %@", @([CommonUtil readIntFromDefault:GetCommonData.CT_NO]));
                NSLog(@"self.mainDelegate.avAudioPlayer.duration [%@]",@(self.mainDelegate.avAudioPlayer.duration));
                if (!isPlay) {
                    isPlay = YES;
                    if (self.mainDelegate.avAudioPlayer.duration - [CommonUtil readIntFromDefault:GetCommonData.CT_NO] > 10) {
                        //                    [self.mainDelegate.avAudioPlayer pause];
                        [self.mainDelegate.avAudioPlayer seekToTime:[CommonUtil readIntFromDefault:GetCommonData.CT_NO]];
                        //                    [self.mainDelegate.avAudioPlayer resume];
                    }
                }
            }
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:_CMD_PLAY_START object:nil userInfo:nil];
        if (![_timer isValid]) {
            _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updatePlaybackProgressFromTimer:) userInfo:nil repeats:YES];
        }
    }
}
/// Raised when an item has finished playing
-(void) audioPlayer:(STKAudioPlayer*)audioPlayer didFinishPlayingQueueItemId:(NSObject*)queueItemId withReason:(STKAudioPlayerStopReason)stopReason andProgress:(double)progress andDuration:(double)duration
{
    
}
/// Raised when an unexpected and possibly unrecoverable error has occured (usually best to recreate the STKAudioPlauyer)
-(void) audioPlayer:(STKAudioPlayer*)audioPlayer unexpectedError:(STKAudioPlayerErrorCode)errorCode
{
    
}
//@optional
/// Optionally implemented to get logging information from the STKAudioPlayer (used internally for debugging)
-(void) audioPlayer:(STKAudioPlayer*)audioPlayer logInfo:(NSString*)line
{
    
}
/// Raised when items queued items are cleared (usually because of a call to play, setDataSource or stop)
-(void) audioPlayer:(STKAudioPlayer*)audioPlayer didCancelQueuedItems:(NSArray*)queuedItems
{
    
}



- (void)moviePlayerLoadStateChanged:(NSNotification*)notification
{
//    if (self.mainDelegate.avAudioPlayer.state != STKAudioPlayerStatePlaying) {
//        [self.mainDelegate.avAudioPlayer resume];
//    } else if (self.mainDelegate.avAudioPlayer.state == STKAudioPlayerStatePlaying) {
//        [self.mainDelegate stopAnimatedLodingView];
//
//        if ([GetCommonData.audio_mode isEqualToString:@"AOD"]) {
//            if ([CommonUtil readIntFromDefault:GetCommonData.CT_NO] > 0) {
//                if (self.mainDelegate.avAudioPlayer.duration - [CommonUtil readIntFromDefault:GetCommonData.CT_NO] > 10) {
//                    [self.mainDelegate.avAudioPlayer pause];
//                    [self.mainDelegate.avAudioPlayer seekToTime:[CommonUtil readIntFromDefault:GetCommonData.CT_NO]];
//                    [self.mainDelegate.avAudioPlayer resume];
//                }
//            }
//        }
//        [[NSNotificationCenter defaultCenter] postNotificationName:_CMD_PLAY_START object:nil userInfo:nil];
//        if (![_timer isValid]) {
//            _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updatePlaybackProgressFromTimer:) userInfo:nil repeats:YES];
//        }
//    }
}

- (void) moviePlayBackDidFinish:(NSNotification*)notification
{
//    if ([GetCommonData.audio_mode isEqualToString:@"AOD"]) {
////        if (self.mainDelegate.audioPlayer.duration - self.mainDelegate.audioPlayer.currentPlaybackTime < 10) {
////            [CommonUtil writeIntToDefault:0 KEY:GetCommonData.CT_NO];
////        } else {
//            [CommonUtil writeIntToDefault:self.mainDelegate.audioPlayer.currentPlaybackTime KEY:GetCommonData.CT_NO];
////        }
//    }
}

- (void)ActionPlaybackStateInterrupted {
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)sliderValueChanged:(UISlider*)sender {
    if (_btn_play.selected) {
        [self.mainDelegate.avAudioPlayer pause];
    }
    
    CGFloat interval = self.mainDelegate.avAudioPlayer.duration * sender.value;
    NSLog(@"interval [%@]  maximumValue [%@]", @(interval), @(self.sl_progress.maximumValue));
    [self.mainDelegate.avAudioPlayer seekToTime:sender.value];

    self.lbl_playback_time.text = [NSString stringWithFormat:@"%@",[self convertIntToTime:(int)self.mainDelegate.avAudioPlayer.progress]];

    self.lbl_duration.text = [NSString stringWithFormat:@"-%@",[self convertIntToTime:abs((int)(self.mainDelegate.avAudioPlayer.progress-self.mainDelegate.avAudioPlayer.duration))]];

    if (_btn_play.selected) {
        [self.mainDelegate.avAudioPlayer resume];
    }
    if ([GetCommonData.audio_mode isEqualToString:@"AOD"]) {
        [CommonUtil writeIntToDefault:self.mainDelegate.avAudioPlayer.progress KEY:GetCommonData.CT_NO];
    }
}

- (void)rightSwipeHandle:(UISwipeGestureRecognizer*)gestureRecognizer {
    //Do moving
//    NSLog(@"right swipe!!");
//    if (CGRectGetMinX(self.menuView.frame) < 0 && CGRectGetMinX(self.commentsView.frame) > 319) {
//        [self viewMenu];
//    } else {
//        [self closeComments];
//    }
}

- (void)leftSwipeHandle:(UISwipeGestureRecognizer*)gestureRecognizer {
    // do moving
//    NSLog(@"left swipe!!");
//    if (CGRectGetMaxX(self.menuView.frame) > 0 && CGRectGetMinX(self.commentsView.frame) < 321) {
//        [self closeMenu];
//    } else {
//        [self viewComments];
//    }
}


-(UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (IBAction)viewMenu
{
    backView.hidden = NO;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5];
    self.menuView.frame = CGRectMake(0, 0, RESIZE(332), MAIN_SIZE().height);
    [UIView commitAnimations];
}

- (IBAction)closeMenu
{
    [UIViewController globalResignFirstResponder];
    
    backView.hidden = YES;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5];
    self.menuView.frame = CGRectMake(-RESIZE(332), 0, RESIZE(332), MAIN_SIZE().height);
    [UIView commitAnimations];
}

- (IBAction)viewComments
{
    if ([GetCommonData.PR_ID length] == 0) {
        [self.view makeToast:NSLocalizedString(@"Player_commnet_null", @"청취소감이 열려있지 않습니다.")];
        return;
    }
    backView.hidden = NO;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5];
    self.commentsView.frame = CGRectMake(RESIZE(96), isiPhoneXScreen() ? 44 : 20, MAIN_SIZE().width - RESIZE(96), MAIN_SIZE().height - (isiPhoneXScreen() ? 44 : 20));
    [UIView commitAnimations];
}

- (IBAction)closeComments
{
    [UIViewController globalResignFirstResponder];
    backView.hidden = YES;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5];
    self.commentsView.frame = CGRectMake(MAIN_SIZE().width, isiPhoneXScreen() ? 44 : 20, MAIN_SIZE().width - RESIZE(96), MAIN_SIZE().height - (isiPhoneXScreen() ? 44 : 20));
    [UIView commitAnimations];
    
}

- (IBAction)closeMenuView
{
    [self closeMenu];
    [self closeComments];
}

- (IBAction)onMoveLive
{
    [self closeMenu];
    ViewController *VC = nil;
    if (IS_3_5_INCH) {
        VC = [self.storyboard instantiateViewControllerWithIdentifier:@"LiveRadioView_480"];
    } else {
        VC = [self.storyboard instantiateViewControllerWithIdentifier:@"LiveRadioView"];
    }
    [self.navigationController pushViewController:VC animated:NO];
}

- (IBAction)onMoveAOD
{
    [self closeMenu];
    UIAODListViewController *view = [self.storyboard instantiateViewControllerWithIdentifier:@"UIAODListView"];
    [self.navigationController pushViewController:view animated:NO];
}

- (IBAction)onMoveSchedule
{
    [self closeMenu];
    UIScheduleViewController *view = [self.storyboard instantiateViewControllerWithIdentifier:@"UIScheduleView"];
    [self.navigationController pushViewController:view animated:NO];
}

- (IBAction)onMoveSetting
{
    [self closeMenu];
    SettingViewController *view = [self.storyboard instantiateViewControllerWithIdentifier:IS_3_5_INCH ? @"SettingView_480" : @"SettingView"];
    [self.navigationController pushViewController:view animated:NO];
}

- (IBAction)onMoveComments
{
    if (GetCommonData.isLogin) {
        if (GetCommonData.PR_ID != nil) {
            UIWebViewController *webView = [self.storyboard instantiateViewControllerWithIdentifier:@"UIWebView"];
            [self.navigationController pushViewController:webView animated:YES];
        } else {
            [self.view makeToast:NSLocalizedString(@"Player_finish", @"현재 방송을 하고 있지 않습니다")];
        }
    } else {
        UILoginViewController *loginView = [self.storyboard instantiateViewControllerWithIdentifier:@"UILoginView"];
        [self.navigationController pushViewController:loginView animated:YES];
    }
}

- (IBAction)onMoveNotice
{
    [self closeMenu];
    UINoticeViewController *noticeView = [self.storyboard instantiateViewControllerWithIdentifier:@"UINoticeView"];
    [self.navigationController pushViewController:noticeView animated:YES];
}

- (IBAction)nextTrack
{
    NSString *URL = [NSString stringWithFormat:[URLAddressManager getURL:[URLAddressManager getLocal] type:PLAYNEXT] ,GetCommonData.aodData[@"PR_ID"], GetCommonData.CT_NO];
    NSLog(@"%s %@", __FUNCTION__, URL);
    NSURLResponse *response = nil;
    NSError *error = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:[[NSURLRequest alloc] initWithURL:[NSURL URLWithString:URL]] returningResponse:&response error:&error];
    
    if ([((NSDictionary*)[CommonUtil jsonParserWithData:data])[@"CONTENTS"][@"status_message"] isEqualToString:@"No Data"] ||
        [((NSDictionary*)[CommonUtil jsonParserWithData:data])[@"CONTENTS"][@"status"] intValue] == 400) {
        [self.view makeToast:NSLocalizedString(@"Player_next_empty", @"다음곡이 없습니다.")];
        return;
    }
    NSDictionary *dic_data = ((NSDictionary*)[CommonUtil jsonParserWithData:data])[@"CONTENTS"][@"data"][0];
    GetCommonData.PR_ID = dic_data[@"PR_ID"];
    GetCommonData.aodData = dic_data;
    self.isPlaying = NO;
    [self.mainDelegate.avAudioPlayer stop];
    [self.timer invalidate];
    [self playAOD];
}

- (IBAction)prevTrack
{
    NSString *URL = [NSString stringWithFormat:[URLAddressManager getURL:[URLAddressManager getLocal] type:PLAYPREV] ,GetCommonData.aodData[@"PR_ID"], GetCommonData.CT_NO];
    NSLog(@"%s %@", __FUNCTION__, URL);
    NSURLResponse *response = nil;
    NSError *error = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:[[NSURLRequest alloc] initWithURL:[NSURL URLWithString:URL]] returningResponse:&response error:&error];
    
    if ([((NSDictionary*)[CommonUtil jsonParserWithData:data])[@"CONTENTS"][@"status_message"] isEqualToString:@"No Data"] ||
        [((NSDictionary*)[CommonUtil jsonParserWithData:data])[@"CONTENTS"][@"status"] intValue] == 400) {
        [self.view makeToast:NSLocalizedString(@"Player_prev_empty", @"이전곡이 없습니다.")];
        return;
    }
    NSDictionary *dic_data = ((NSDictionary*)[CommonUtil jsonParserWithData:data])[@"CONTENTS"][@"data"][0];
    GetCommonData.PR_ID = dic_data[@"PR_ID"];
    GetCommonData.aodData = dic_data;
    self.isPlaying = NO;
    [self.mainDelegate.avAudioPlayer stop];
    [self.timer invalidate];
    [self playAOD];
}

- (IBAction)play
{
    _btn_play.selected = !_btn_play.selected;
    if (!_btn_play.selected) {
        if ([GetCommonData.audio_mode isEqualToString:@"AOD"]) {
            [CommonUtil writeIntToDefault:self.mainDelegate.avAudioPlayer.progress KEY:GetCommonData.CT_NO];
        }
        [self.mainDelegate.avAudioPlayer pause];
    } else {
        if (self.mainDelegate.avAudioPlayer.state == STKAudioPlayerStatePaused) {
            if (![_timer isValid]) {
                _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updatePlaybackProgressFromTimer:) userInfo:nil repeats:YES];
            }
            NSLog(@"%@",[NSString stringWithFormat:@"%ld",(long)GetCommonData.pauseTimeInterval]);
            if (GetCommonData.pauseTimeInterval > 60) {
                [self.mainDelegate.avAudioPlayer stop];
                GetCommonData.audio_mode = @"";
                if (![GetCommonData.audio_mode isEqualToString:@"AOD"]) {
                    [self playOnAir];
                } else {
                    [self playAOD];
                }
            } else {
                GetCommonData.pauseTimeInterval = 0;
                [self.mainDelegate.avAudioPlayer resume];
            }
        } else {
            if (![GetCommonData.audio_mode isEqualToString:@"AOD"]) {
                [self playOnAir];
            } else {
                [self playAOD];
            }
        }
    }
}

- (void)playAOD
{
    [self.mainDelegate startAnimatedLodingView];
    if ([GetCommonData.audio_mode isEqualToString:@"AOD"]&&
        [GetCommonData.CT_NO isEqualToString:GetCommonData.aodData[@"CT_NO"]]) {
        [self.mainDelegate stopAnimatedLodingView];
        return;
    } else {
        self.isPlaying = NO;
        [self.mainDelegate.avAudioPlayer stop];
    }
    
//    if (self.mainDelegate.audioPlayer.playbackState != MPMoviePlaybackStateStopped) {
//        [self.mainDelegate.audioPlayer stop];
//    }
//    
    [self.sl_progress setHidden:NO];
    GetCommonData.audio_mode = @"AOD";
    self.btn_play.selected = YES;
    
    NSLog(@"%@", GetCommonData.aodData);
    GetCommonData.CT_NO = GetCommonData.aodData[@"CT_NO"];
    NSURL *url_path = [NSURL URLWithString:GetCommonData.aodData[@"CT_SOURCE_STREAM"]];
    self.mainDelegate.avAudioPlayer =  [[STKAudioPlayer alloc] init];
    [self.mainDelegate.avAudioPlayer playURL:url_path];
    self.mainDelegate.avAudioPlayer.delegate = self;
//    self.mainDelegate.audioPlayer.shouldAutoplay = YES;
//    [self.mainDelegate.audioPlayer play];
    
    isPlay = NO;
    if (![_timer isValid]) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updatePlaybackProgressFromTimer:) userInfo:nil repeats:YES];
    }
//    self.mainDelegate.audioPlayer.controlStyle = MPMovieControlStyleNone;
//
//    self.mainDelegate.audioPlayer.view.hidden = YES;
    GetCommonData.liveTimeInterval = 0;
    GetCommonData.pauseTimeInterval = 0;
    
    [self setAodInfo];
}

- (void)setAodInfo
{
    NSString *url = [NSString stringWithFormat:[URLAddressManager getURL:[URLAddressManager getLocal] type:PROGRAMDETAILLIST], GetCommonData.aodData[@"PR_ID"], @"0"];
    [GetURLAddressManager getProgramInfo:url CompletionHandler:^(NSDictionary *data, NSError *error) {
        GetCommonData.aodMetaData = data[@"PR_INFO"][@"data"];
        [self setAodLayout];
    }];
}

- (void)setAodLayout
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.sl_progress setHidden:NO];
        __weak typeof(self)weakSelf = self;
//        @try {
//            NSString *str_thum = [NSString stringWithFormat:[URLAddressManager getURL:[URLAddressManager getLocal] type:MAINIMAGE] ,  GetCommonData.aodMetaData[@"PR_THUMBS"]];
//            [self.lmg_mainImg setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:str_thum]]
//                                    placeholderImage:[UIImage imageNamed:@"default_image"]
//                                             success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, UIImage * _Nonnull image) {
//                                                 weakSelf.lmg_mainImg.image = image;
//                                                 GetCommonData.thum = image;
//                                             } failure:nil];
//        } @catch (NSException *e) {
//            self.lmg_mainImg.image = [UIImage imageNamed:@"default_image"];
//        }
        
        @try {
            if (![GetCommonData.aodMetaData[@"PR_NAME"] isEqualToString:self.lbl_notice_title.text]) {
                [self getComments];
            }
        } @catch (NSException *e) {
            
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            @try {
                weakSelf.lbl_notice_title.text = GetCommonData.aodMetaData[@"PR_NAME"];
            } @catch (NSException *e) {
                weakSelf.lbl_notice_title.text = @"NO NAME";
            }
            @try {
                weakSelf.lbl_title.text = GetCommonData.aodData[@"CT_NAME"];
            } @catch (NSException *e) {
                weakSelf.lbl_title.text = @"NO NAME";
            }
            @try {
                NSString *str_host = @"";
                if (![GetCommonData.aodData[@"CT_HOST"] isKindOfClass:[NSNull class]] && [GetCommonData.aodData[@"CT_HOST"] length] > 0)
                    str_host = [str_host stringByAppendingFormat:NSLocalizedString(@"ListenDetail_item_contents4", @"진행:%@"),GetCommonData.aodData[@"CT_HOST"]];
                
                if (![GetCommonData.aodData[@"CT_PANEL"] isKindOfClass:[NSNull class]] && [GetCommonData.aodData[@"CT_PANEL"] length] > 0)
                    str_host = [str_host stringByAppendingFormat:NSLocalizedString(@"ListenDetail_item_contents1", @"%@패널:%@"),str_host.length > 0 ? @", " : @"",GetCommonData.aodData[@"CT_PANEL"]];
                
                if (![GetCommonData.aodData[@"CT_GUEST"] isKindOfClass:[NSNull class]] && [GetCommonData.aodData[@"CT_GUEST"] length] > 0)
                    str_host = [str_host stringByAppendingFormat:NSLocalizedString(@"ListenDetail_item_contents5", @"%@게스트:%@"),str_host.length > 0 ? @", " : @"",GetCommonData.aodData[@"CT_GUEST"]];
                
                if (![GetCommonData.aodData[@"CT_SPEAKER"] isKindOfClass:[NSNull class]] && [GetCommonData.aodData[@"CT_SPEAKER"] length] > 0)
                    str_host = [str_host stringByAppendingFormat:@"%@",GetCommonData.aodData[@"CT_SPEAKER"]];
                
                weakSelf.lbl_time.text = str_host;
            } @catch (NSException *e) {
                weakSelf.lbl_time.text = @"No information";
            }
            
            [weakSelf.lbl_time sizeToFit];
            
            weakSelf.img_onair.hidden = YES;
            
            weakSelf.btn_prev.enabled = YES;
            weakSelf.btn_next.enabled = YES;
            weakSelf.btn_play.enabled = YES;
            weakSelf.btn_onair.enabled = YES;
            weakSelf.btn_comments.enabled = YES;
            
            [weakSelf.tb_AODSubList reloadData];
        });
    });
    
}

- (IBAction)playOnAir
{
    [self.mainDelegate startAnimatedLodingView];
    if ([GetCommonData.audio_mode isEqualToString:@"LIVE"]) {
        [self.mainDelegate stopAnimatedLodingView];
        return;
    } else {
        self.isPlaying = NO;
        [self.mainDelegate.avAudioPlayer stop];
    }
    
    [self.sl_progress setHidden:YES];
    GetCommonData.audio_mode = @"LIVE";
    self.btn_play.selected = YES;
    
    NSURL *url_path = nil;
    if ([[CommonUtil readObjectFromDefault:@"LIVE_LEVEL"] isEqualToString:@"LOW"]) {
        url_path = [NSURL URLWithString:[CommonUtil readObjectFromDefault:Low_Quality]];
    } else {
        url_path = [NSURL URLWithString:[CommonUtil readObjectFromDefault:High_Quality]];
    }
    
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    sessionConfiguration.timeoutIntervalForRequest = 30;
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfiguration delegate:nil delegateQueue:nil];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:[NSURLRequest requestWithURL:url_path] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
        NSLog(@"httpResponse status %@", @(httpResponse.statusCode));
        if (httpResponse.statusCode != 200) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.mainDelegate.avAudioPlayer stop];
                [MAIN_APP_DELEGATE() stopAnimatedLodingView];
                [MNMToast showWithText:NSLocalizedString(@"could_not_stream", @"라이브 스트림을 재생할 수 없습니다.") completionHandler:nil tapHandler:nil];
                [self onMoveAOD];
            });
        }
    }];
    
    [task resume];
    
    self.mainDelegate.avAudioPlayer =  [[STKAudioPlayer alloc] init];
    [self.mainDelegate.avAudioPlayer playURL:url_path];
    self.mainDelegate.avAudioPlayer.delegate = self;
//    self.mainDelegate.audioPlayer.shouldAutoplay = YES;
//    [self.mainDelegate.audioPlayer play];
    
    if (![_timer isValid]) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updatePlaybackProgressFromTimer:) userInfo:nil repeats:YES];
    }
//    self.mainDelegate.audioPlayer.controlStyle = MPMovieControlStyleNone;
//
//    self.mainDelegate.audioPlayer.view.hidden = YES;
    GetCommonData.liveTimeInterval = 0;
    GetCommonData.pauseTimeInterval = 0;
    
    [self setLiveInfoCompletionHandler:nil];
}

- (void) updatePlaybackProgressFromTimer:(NSTimer *)timer {
    
    if (!_isPlaying) {
        if ([self.mainDelegate.avAudioPlayer duration] > 0) {
            _isPlaying = YES;
            Class playingInfoCenter = NSClassFromString(@"MPNowPlayingInfoCenter");
            MPMediaItemArtwork *albumArt = nil;
            if (playingInfoCenter) {
                if ([GetCommonData.audio_mode isEqualToString:@"AOD"]) {
                    @try {
                        NSMutableDictionary *songInfo = [[NSMutableDictionary alloc] init];
                        albumArt = [[MPMediaItemArtwork alloc] initWithImage:GetCommonData.thum];
                        [songInfo setObject:GetCommonData.aodData[@"CT_NAME"] forKey:MPMediaItemPropertyArtist];
                        [songInfo setObject:[GetCommonData.aodData[@"CT_HOST"] length] > 0 ? GetCommonData.aodData[@"CT_HOST"] : GetCommonData.aodData[@"CT_SPEAKER"] forKey:MPMediaItemPropertyTitle];
                        [songInfo setObject:GetCommonData.aodData[@"CT_TOPIC"] forKey:MPMediaItemPropertyAlbumTitle];
                        if (![GetCommonData.audio_mode isEqualToString:@"AOD"])
                        [songInfo setObject:[NSString stringWithFormat:@"%f",[self.mainDelegate.avAudioPlayer duration]] forKey:MPMediaItemPropertyPlaybackDuration];
                        
                        if (albumArt != nil) {
                            [songInfo setObject:albumArt forKey:MPMediaItemPropertyArtwork];
                        }
                        [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:songInfo];
                    } @catch (NSException *exception) {
                        NSMutableDictionary *songInfo = [[NSMutableDictionary alloc] init];
                        albumArt = [[MPMediaItemArtwork alloc] initWithImage:[UIImage imageNamed:@"default_image"]];
                        [songInfo setObject:@"NO DATA" forKey:MPMediaItemPropertyArtist];
                        [songInfo setObject:@"NO DATA" forKey:MPMediaItemPropertyTitle];
                        [songInfo setObject:@"NO DATA" forKey:MPMediaItemPropertyAlbumTitle];
                        
                        if (albumArt != nil) {
                            [songInfo setObject:albumArt forKey:MPMediaItemPropertyArtwork];
                        }
                        [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:songInfo];
                    }
                }
                
            }
        }
    }
    
    if ([GetCommonData.audio_mode isEqualToString:@"LIVE"]) {
        Class playingInfoCenter = NSClassFromString(@"MPNowPlayingInfoCenter");
        MPMediaItemArtwork *albumArt = nil;
        if (playingInfoCenter) {
            @try {
                NSMutableDictionary *songInfo = [[NSMutableDictionary alloc] init];
                albumArt = [[MPMediaItemArtwork alloc] initWithImage:GetCommonData.thum];
                if ([GetCommonData.liveType isEqualToString:@"track"]) {
                    [songInfo setObject:GetCommonData.metadata[@"artist_name"] forKey:MPMediaItemPropertyArtist];
                    [songInfo setObject:GetCommonData.metadata[@"track_title"] forKey:MPMediaItemPropertyTitle];
                    [songInfo setObject:GetCommonData.metadata[@"album_title"] forKey:MPMediaItemPropertyAlbumTitle];
                } else if ([GetCommonData.liveType isEqualToString:@"livestream"]) {
                    NSString *title = @"";
                    @try {
                        if ([GetCommonData.showsCurrent[@"name"] length] == 0) {
                            title = @"On Air";
                        } else {
                            title = GetCommonData.showsCurrent[@"name"];
                        }
                    } @catch (NSException *e) {
                        title = @"NO TITLE";
                    }
                    [songInfo setObject:@"Jerusalrem Radio" forKey:MPMediaItemPropertyArtist];
                    [songInfo setObject:title forKey:MPMediaItemPropertyTitle];
                    [songInfo setObject:title forKey:MPMediaItemPropertyAlbumTitle];
                }
                
                if (albumArt != nil) {
                    [songInfo setObject:albumArt forKey:MPMediaItemPropertyArtwork];
                }
                [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:songInfo];
            } @catch (NSException *exception) {
                NSMutableDictionary *songInfo = [[NSMutableDictionary alloc] init];
                albumArt = [[MPMediaItemArtwork alloc] initWithImage:[UIImage imageNamed:@"default_image"]];
                [songInfo setObject:@"NO DATA" forKey:MPMediaItemPropertyArtist];
                [songInfo setObject:@"NO DATA" forKey:MPMediaItemPropertyTitle];
                [songInfo setObject:@"NO DATA" forKey:MPMediaItemPropertyAlbumTitle];
                
                if (albumArt != nil) {
                    [songInfo setObject:albumArt forKey:MPMediaItemPropertyArtwork];
                }
                [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:songInfo];
            }
        }
        
    }
    if (([UIApplication sharedApplication].applicationState == UIApplicationStateActive) &&
        (self.mainDelegate.avAudioPlayer.state ==STKAudioPlayerStatePlaying)) {
        if ([GetCommonData.audio_mode isEqualToString:@"AOD"]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                float progress = self.mainDelegate.avAudioPlayer.progress/self.mainDelegate.avAudioPlayer.duration;
                NSLog(@"progress [%@]", @(progress));
                
                [self.sl_progress setValue:self.mainDelegate.avAudioPlayer.progress];
                [self.sl_progress setMaximumValue:self.mainDelegate.avAudioPlayer.duration];
                //            NSLog(@"interval [%@]  maximumValue [%@]", @(self.sl_progress.value), @(self.sl_progress.maximumValue));
                
                self.lbl_playback_time.text = [NSString stringWithFormat:@"%@",[self convertIntToTime:(int)self.mainDelegate.avAudioPlayer.progress]];
                self.lbl_duration.text = [NSString stringWithFormat:@"-%@",[self convertIntToTime:abs((int)(self.mainDelegate.avAudioPlayer.progress-self.mainDelegate.avAudioPlayer.duration))]];
                [self.vi_progress setBackgroundColor:UIColorFromRGB(0x4D4D58)];
                
                if ([GetCommonData.audio_mode isEqualToString:@"AOD"]) {
                    [CommonUtil writeIntToDefault:self.mainDelegate.avAudioPlayer.progress KEY:GetCommonData.CT_NO];
                }
            });
        } else {
            GetCommonData.liveTimeInterval++;
            self.lbl_playback_time.text = [self convertIntToTime:GetCommonData.liveTimeInterval];;
            self.lbl_duration.text = @"00:00:00";
            [self.vi_progress setBackgroundColor:UIColorFromRGB(0xF5AF14)];
        }
    } else {
        if (self.mainDelegate.avAudioPlayer.state == STKAudioPlayerStatePaused) {
            GetCommonData.pauseTimeInterval++;
        }
    }
}

- (NSString*)convertIntToTime:(int)time
{
    int hou = time / 3600;
    int min = (time % 3600) / 60;
    int sec = (time % 3600) % 60;
    
    return [NSString stringWithFormat:@"%d:%02d:%02d",hou,min,sec];
}

- (void)setLiveInfoCompletionHandler:(void (^)(NSDictionary *data, BOOL isSuccess))completionHandler
{
    __weak typeof(self)weakSelf = self;
    [GetURLAddressManager getAddressListCompletionHandler:^(NSDictionary *data, NSError *error) {
        [CommonUtil writeObjectToDefault:data[High_Quality] KEY:High_Quality];
        [CommonUtil writeObjectToDefault:data[Low_Quality] KEY:Low_Quality];
        [CommonUtil writeObjectToDefault:data[Listings] KEY:Listings];
        [GetURLAddressManager getLiveInfoCompletionHandler:^(NSDictionary *data, NSError *error) {
//            if (![GetCommonData.audio_mode isEqualToString:@"AOD"]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (![data[@"tracks"][@"current"] isKindOfClass:[NSNull class]]) {
                        NSDictionary *current = data[@"tracks"][@"current"];
                        NSString *type = current[@"type"];
                        GetCommonData.liveType = type;
                        if ([type isEqualToString:@"track"]) {
                            GetCommonData.current = current;
                            GetCommonData.metadata = metadata = current[@"metadata"];
                            if (![metadata[@"genre"] isKindOfClass:[NSNull class]] && ![metadata[@"genre"] isEqualToString:GetCommonData.PR_ID]) {
                                GetCommonData.PR_ID = metadata[@"genre"];
                                _isPlaying = NO;
                            }
                            @try {
                                if ([metadata[@"genre"] length] > 0) {
                                    GetCommonData.PR_ID = metadata[@"genre"];
                                    NSString *url = [NSString stringWithFormat:[URLAddressManager getURL:[URLAddressManager getLocal] type:PROGRAMDETAILLIST] , GetCommonData.PR_ID, @"0"];
                                    [GetURLAddressManager getProgramInfo:url CompletionHandler:^(NSDictionary *data, NSError *error) {
                                        NSDictionary *dic_data = data[@"PR_INFO"][@"data"];
                                        NSString *str_thum = [NSString stringWithFormat:[URLAddressManager getURL:[URLAddressManager getLocal] type:MAINIMAGE], dic_data[@"PR_THUMBS"]];
                                        dispatch_async(dispatch_get_main_queue(), ^{
                                            [weakSelf.lmg_mainImg setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:str_thum]]
                                                                        placeholderImage:[UIImage imageNamed:@"default_image"]
                                                                                 success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, UIImage * _Nonnull image) {
                                                weakSelf.lmg_mainImg.image = image;
                                                GetCommonData.thum = image;
                                            } failure:nil];
                                        });
                                    }];
                                } else {
                                    weakSelf.lmg_mainImg.image = [UIImage imageNamed:@"default_image"];
                                }
                            } @catch (NSException *e) {
                                weakSelf.lmg_mainImg.image = [UIImage imageNamed:@"default_image"];
                            }
                            if (![GetCommonData.audio_mode isEqualToString:@"AOD"]) {
                                @try {
                                    if (![metadata[@"album_title"] isEqualToString:weakSelf.lbl_notice_title.text]) {
                                        [weakSelf getComments];
                                    }
                                } @catch (NSException *e) {
                                    
                                }
                                
                                @try {
                                    weakSelf.lbl_title.text = metadata[@"track_title"];
                                } @catch (NSException *e) {
                                    weakSelf.lbl_title.text = @"NO TITLE";
                                }
                                
                                @try {
                                    weakSelf.lbl_notice_title.text = metadata[@"album_title"];
                                } @catch (NSException *e) {
                                    weakSelf.lbl_notice_title.text = @"NO TITLE";
                                }
                                
                                @try {
                                    weakSelf.lbl_time.text = [NSString stringWithFormat:@"%@ ~ %@",
                                                              [CommonUtil getChangeDateFormat:current[@"starts"]
                                                                                  tdateFormat:@"yyyy-MM-dd HH:mm:ss"
                                                                             changeDateFormat:@"HH:mm:ss"] ,
                                                              [CommonUtil getChangeDateFormat:current[@"ends"]
                                                                                  tdateFormat:@"yyyy-MM-dd HH:mm:ss"
                                                                             changeDateFormat:@"HH:mm:ss"]];
                                } @catch (NSException *e) {
                                    weakSelf.lbl_time.text = @"No information";
                                }
                            }
                        } else if ([type isEqualToString:@"livestream"]) {
                            NSDictionary *shows = data[@"shows"];
                            NSDictionary *showsCurrent = shows[@"current"];
                            GetCommonData.showsCurrent = showsCurrent;
                            if (![GetCommonData.audio_mode isEqualToString:@"AOD"]) {
                                @try {
                                    if ([showsCurrent[@"name"] length] == 0) {
                                        weakSelf.lbl_title.text = @"On Air";
                                    } else {
                                        weakSelf.lbl_title.text = showsCurrent[@"name"];
                                    }
                                } @catch (NSException *e) {
                                    weakSelf.lbl_title.text = @"NO TITLE";
                                }
                            }
                            @try {
                                if ([showsCurrent[@"genre"] length] > 0) {
                                    GetCommonData.PR_ID = showsCurrent[@"genre"];
                                    NSString *url = [NSString stringWithFormat:[URLAddressManager getURL:[URLAddressManager getLocal] type:PROGRAMDETAILLIST] , GetCommonData.PR_ID, @"0"];
                                    [GetURLAddressManager getProgramInfo:url CompletionHandler:^(NSDictionary *data, NSError *error) {
                                        NSDictionary *dic_data = data[@"PR_INFO"][@"data"];
                                        NSString *str_thum = [NSString stringWithFormat:[URLAddressManager getURL:[URLAddressManager getLocal] type:MAINIMAGE], dic_data[@"PR_THUMBS"]];
                                        dispatch_async(dispatch_get_main_queue(), ^{
                                            [weakSelf.lmg_mainImg setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:str_thum]]
                                                                        placeholderImage:[UIImage imageNamed:@"default_image"]
                                                                                 success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, UIImage * _Nonnull image) {
                                                weakSelf.lmg_mainImg.image = image;
                                                GetCommonData.thum = image;
                                            } failure:nil];
                                        });
                                    }];
                                } else {
                                    weakSelf.lmg_mainImg.image = [UIImage imageNamed:@"default_image"];
                                }
                            } @catch (NSException *e) {
                                weakSelf.lmg_mainImg.image = [UIImage imageNamed:@"default_image"];
                            }
                            if (![GetCommonData.audio_mode isEqualToString:@"AOD"]) {
                                @try {
                                    weakSelf.lbl_time.text = [NSString stringWithFormat:@"%@ ~ %@",
                                                              [CommonUtil getChangeDateFormat:showsCurrent[@"starts"]
                                                                                  tdateFormat:@"yyyy-MM-dd HH:mm:ss"
                                                                             changeDateFormat:@"HH:mm:ss"] ,
                                                              [CommonUtil getChangeDateFormat:showsCurrent[@"ends"]
                                                                                  tdateFormat:@"yyyy-MM-dd HH:mm:ss"
                                                                             changeDateFormat:@"HH:mm:ss"]];
                                } @catch (NSException *e) {
                                    weakSelf.lbl_time.text = @"No information";
                                }
                            }
                        }
                        if (![GetCommonData.audio_mode isEqualToString:@"AOD"]) {
                            [weakSelf.lbl_time sizeToFit];
                            [weakSelf.lbl_time setFrame:CGRectMake(CGRectGetMinX(weakSelf.lbl_time.frame),
                                                                   CGRectGetMinY(weakSelf.lbl_time.frame),
                                                                   CGRectGetWidth(weakSelf.lbl_time.frame),
                                                                   12)];
                            
                            [weakSelf.img_onair setFrame:CGRectMake(CGRectGetMaxX(weakSelf.lbl_time.frame) + 5,
                                                                    CGRectGetMidY(weakSelf.lbl_time.frame) - (CGRectGetHeight(weakSelf.img_onair.frame) / 2),
                                                                    CGRectGetWidth(weakSelf.img_onair.frame),
                                                                    CGRectGetHeight(weakSelf.img_onair.frame))];
                            
                            weakSelf.img_onair.hidden = NO;
                            
                            weakSelf.btn_prev.enabled = NO;
                            weakSelf.btn_next.enabled = NO;
                            weakSelf.btn_play.enabled = YES;
                            weakSelf.btn_onair.enabled = YES;
                            weakSelf.btn_comments.enabled = YES;
                            //                    [self.vi_progress setBackgroundColor:UIColorFromRGB(0x4D4D58)];
                            if (completionHandler != nil)
                            {
                                completionHandler(metadata, YES);
                            }
                        }
                    } else if (![data[@"shows"][@"current"] isKindOfClass:[NSNull class]]) {
                        NSDictionary *shows = data[@"shows"];
                        NSDictionary *showsCurrent = shows[@"current"];
                        GetCommonData.showsCurrent = showsCurrent;
                        if (![GetCommonData.audio_mode isEqualToString:@"AOD"]) {
                            @try {
                                if ([showsCurrent[@"name"] length] == 0) {
                                    weakSelf.lbl_title.text = @"On Air";
                                } else {
                                    weakSelf.lbl_title.text = showsCurrent[@"name"];
                                }
                            } @catch (NSException *e) {
                                weakSelf.lbl_title.text = @"NO TITLE";
                            }
                        }
                        @try {
                            if ([showsCurrent[@"genre"] length] > 0) {
                                GetCommonData.PR_ID = showsCurrent[@"genre"];
                                NSString *url = [NSString stringWithFormat:[URLAddressManager getURL:[URLAddressManager getLocal] type:PROGRAMDETAILLIST] , GetCommonData.PR_ID, @"0"];
                                [GetURLAddressManager getProgramInfo:url CompletionHandler:^(NSDictionary *data, NSError *error) {
                                    NSDictionary *dic_data = data[@"PR_INFO"][@"data"];
                                    NSString *str_thum = [NSString stringWithFormat:[URLAddressManager getURL:[URLAddressManager getLocal] type:MAINIMAGE], dic_data[@"PR_THUMBS"]];
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        [weakSelf.lmg_mainImg setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:str_thum]]
                                                                    placeholderImage:[UIImage imageNamed:@"default_image"]
                                                                             success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, UIImage * _Nonnull image) {
                                            weakSelf.lmg_mainImg.image = image;
                                            GetCommonData.thum = image;
                                        } failure:nil];
                                    });
                                }];
                            } else {
                                weakSelf.lmg_mainImg.image = [UIImage imageNamed:@"default_image"];
                            }
                        } @catch (NSException *e) {
                            weakSelf.lmg_mainImg.image = [UIImage imageNamed:@"default_image"];
                        }
                        if (![GetCommonData.audio_mode isEqualToString:@"AOD"]) {
                            @try {
                                weakSelf.lbl_time.text = [NSString stringWithFormat:@"%@ ~ %@",
                                                          [CommonUtil getChangeDateFormat:showsCurrent[@"starts"]
                                                                              tdateFormat:@"yyyy-MM-dd HH:mm:ss"
                                                                         changeDateFormat:@"HH:mm:ss"] ,
                                                          [CommonUtil getChangeDateFormat:showsCurrent[@"ends"]
                                                                              tdateFormat:@"yyyy-MM-dd HH:mm:ss"
                                                                         changeDateFormat:@"HH:mm:ss"]];
                            } @catch (NSException *e) {
                                weakSelf.lbl_time.text = @"No information";
                            }
                            
                            [weakSelf.lbl_time sizeToFit];
                            [weakSelf.lbl_time setFrame:CGRectMake(CGRectGetMinX(weakSelf.lbl_time.frame),
                                                                   CGRectGetMinY(weakSelf.lbl_time.frame),
                                                                   CGRectGetWidth(weakSelf.lbl_time.frame),
                                                                   12)];
                            
                            [weakSelf.img_onair setFrame:CGRectMake(CGRectGetMaxX(weakSelf.lbl_time.frame) + 5,
                                                                    CGRectGetMinY(weakSelf.img_onair.frame),
                                                                    CGRectGetWidth(weakSelf.img_onair.frame),
                                                                    CGRectGetHeight(weakSelf.img_onair.frame))];
                            
                            weakSelf.img_onair.hidden = NO;
                            
                            weakSelf.btn_prev.enabled = NO;
                            weakSelf.btn_next.enabled = NO;
                            weakSelf.btn_play.enabled = YES;
                            weakSelf.btn_onair.enabled = YES;
                            weakSelf.btn_comments.enabled = YES;
                            //                    [self.vi_progress setBackgroundColor:UIColorFromRGB(0x4D4D58)];
                            if (completionHandler != nil)
                            {
                                completionHandler(metadata, YES);
                            }
                        }
                    } else {
                        if (![GetCommonData.audio_mode isEqualToString:@"AOD"]) {
                            [_mainDelegate.avAudioPlayer stop];
                            weakSelf.lbl_notice_title.text = NSLocalizedString(@"Borad_title", @"청취자 게시판");
                            [weakSelf.lmg_mainImg setImage:[UIImage imageNamed:@"default_image"]];
                            weakSelf.lbl_title.text = NSLocalizedString(@"Player_finish", @"현재 방송을 하고 있지 않습니다.");
                            weakSelf.lbl_time.text = @"23:00:00 ~ 07:00:00";
                            
                            
                            [weakSelf.lbl_time sizeToFit];
                            [weakSelf.lbl_time setFrame:CGRectMake(CGRectGetMinX(weakSelf.lbl_time.frame),
                                                                   CGRectGetMinY(weakSelf.lbl_time.frame),
                                                                   CGRectGetWidth(weakSelf.lbl_time.frame),
                                                                   12)];
                            
                            [weakSelf.img_onair setFrame:CGRectMake(CGRectGetMaxX(weakSelf.lbl_time.frame) + 5,
                                                                    CGRectGetMinY(weakSelf.img_onair.frame),
                                                                    CGRectGetWidth(weakSelf.img_onair.frame),
                                                                    CGRectGetHeight(weakSelf.img_onair.frame))];
                            
                            weakSelf.img_onair.hidden = YES;
                            
                            
                            weakSelf.btn_prev.enabled = NO;
                            weakSelf.btn_next.enabled = NO;
                            weakSelf.btn_play.enabled = NO;
                            weakSelf.btn_onair.enabled = NO;
                            weakSelf.btn_comments.enabled = NO;
                            [self.vi_progress setBackgroundColor:UIColorFromRGB(0x4D4D58)];
                            if (completionHandler != nil)
                            {
                                completionHandler(metadata, NO);
                            }
                        }
                    }
                });
//            }
        }];
    }];
}

- (IBAction)writeCommments
{
    [UINavigationController globalResignFirstResponder];
    if (self.tv_comments.text.length < 4) {
        [self.view makeToast:NSLocalizedString(@"Comment_empty", @"청취 소감 입력해주세요.")];
        return;
    }
    [GetURLAddressManager writeComments:[URLAddressManager getURL:[URLAddressManager getLocal] type:COMMENTSWRITE]
                                   prID:GetCommonData.PR_ID
                                   mbID:GetCommonData.MB_ID
                              prContent:self.tv_comments.text
                      CompletionHandler:^(NSDictionary *data, NSError *error) {
                          if ([data[@"status"] intValue] == 200) {
                              [self getComments];
                              dispatch_async(dispatch_get_main_queue(), ^{
                                  self.tv_comments.text = @"";
                              });
                          }
                      }];
}

- (void)getComments
{
    if ([GetCommonData.PR_ID length] == 0) {
//        [self.view makeToast:@"해당 메뉴를 이용할 수 없는 컨텐츠입니다."];
        return;
    }
    __weak typeof(self)weakSelf = self;
    NSString *url = [NSString stringWithFormat:[URLAddressManager getURL:[URLAddressManager getLocal] type:COMMENTSLIST], GetCommonData.PR_ID];
//    NSString *url = COMMENTSLIST(TEST_PR_ID);
    [GetURLAddressManager getComments:url CompletionHandler:^(NSDictionary *data, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            @try {
                if ([data[@"NOTICES"][@"status_message"] isEqualToString:@"Success"] && [data[@"NOTICES"][@"status"] intValue] == 200) {
                    weakSelf.lbl_notice_name.text = data[@"NOTICES"][@"data"][0][@"MB_NAME"];
                    weakSelf.lbl_notice_desc.text = data[@"NOTICES"][@"data"][0][@"B_TITLE"];
                    [weakSelf.lbl_notice_desc sizeToFit];
                    
                    weakSelf.lbl_notice_name.frame = CGRectMake(RESIZE(33), RESIZE(23), CGRectGetWidth(self.commentsView.frame) - RESIZE(66), RESIZE(38));
                    weakSelf.lbl_notice_desc.frame = CGRectMake(RESIZE(33), RESIZE(68), CGRectGetWidth(self.commentsView.frame) - RESIZE(66), CGRectGetHeight(weakSelf.lbl_notice_desc.frame));
                    
                    weakSelf.noticeView.hidden = NO;
                    
                    weakSelf.noticeView.frame = CGRectMake(0, CGRectGetMaxY(weakSelf.noticeTitleView.frame), CGRectGetWidth(self.commentsView.frame), CGRectGetMaxY(weakSelf.lbl_notice_desc.frame) + RESIZE(20));
                    
                    weakSelf.commentsTableView.frame = CGRectMake(0, CGRectGetMaxY(weakSelf.noticeView.frame), MAIN_SIZE().width - RESIZE(96), CGRectGetHeight(weakSelf.commentsView.frame) - CGRectGetMaxY(weakSelf.noticeView.frame) - RESIZE(145) - (isiPhoneXScreen() ? 34 : 0));
                } else {
                    weakSelf.noticeView.frame = CGRectZero;
                    weakSelf.noticeView.hidden = YES;
                    weakSelf.commentsTableView.frame = CGRectMake(0, CGRectGetHeight(weakSelf.noticeTitleView.frame), MAIN_SIZE().width - RESIZE(96), CGRectGetHeight(weakSelf.commentsView.frame) - CGRectGetHeight(weakSelf.noticeTitleView.frame) - RESIZE(145) - (isiPhoneXScreen() ? 34 : 0));
                }
                if ([data[@"COMMENTS"][@"status_message"] isEqualToString:@"Success"] && [data[@"COMMENTS"][@"status"] intValue] == 200) {
                    _commentsList = [NSMutableArray arrayWithArray:data[@"COMMENTS"][@"data"]];
                } else {
                    _commentsList = [[NSMutableArray alloc] init];
                }
                
                [weakSelf.commentsTableView reloadData];
            } @catch (NSException *exception) {
                
            }
            
        });
    }];
}

/**
 * 레이아웃 초기화
 */
- (void)initLayout {
    [self initRefreshControl];
    [self.commentsTableView addSubview:refreshControl];
}

/**
 * RefreshControl 초기화
 */
- (void)initRefreshControl {
    refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(handleRefresh:) forControlEvents:UIControlEventValueChanged];
    
    refreshControl.attributedTitle = [[NSAttributedString alloc]initWithString:@"Pull To Refresh"];
}

/**
 * Refresh 이벤트
 */
- (void)handleRefresh:(UIRefreshControl *)sender {
    NSLog(@">>> handleRefresh");
    [refreshControl endRefreshing];
    
    // refresh
    [self getComments];
}


//#pragma mark- UITableViewDelegate & DataSource
//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    if (tableView == self.tableView) {
//        
//    }
//}
//
//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//{
//    return 1;
//}
//
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    UITableViewCell *cell = nil;
//    if (tableView == self.commentsTableView) {
//        static NSString *commmentsCellIdentifier = @"CommentsCell";
//        cell = (CommentsCell*)[tableView dequeueReusableCellWithIdentifier:commmentsCellIdentifier];
//        if (cell == nil) {
//            cell = [[CommentsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:commmentsCellIdentifier];
//        }
//        
//        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] init];
//        [attributedString appendAttributedString:[[NSAttributedString alloc] initWithString:_commentsList[indexPath.row][@"MB_NAME"]
//                                                                                     attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:11.],
//                                                                                                  NSForegroundColorAttributeName:UIColorFromRGB(0xB60018)}]];
//        [attributedString appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@" %@",[CommonUtil getPassedTime:_commentsList[indexPath.row][@"PR_CO_REG_DATE"]]]
//                                                                                     attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:10.],
//                                                                                                  NSForegroundColorAttributeName:UIColorFromRGB(0x939393)}]];
//        
//        ((CommentsCell*)cell).lbl_notice_name.attributedText = attributedString;
//        ((CommentsCell*)cell).lbl_notice_desc.text = _commentsList[indexPath.row][@"PR_CO_CONTENT"];
//        
//        CGSize maxSize = CGSizeMake(223, 10000);
//        
//        CGSize viewSize = CGSizeZero;
//        
//        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
//        paragraphStyle.lineBreakMode = NSLineBreakByCharWrapping;
//        paragraphStyle.alignment = NSTextAlignmentLeft;
//        
//        NSDictionary *attributes = @{NSFontAttributeName:[UIFont systemFontOfSize:10], NSParagraphStyleAttributeName: paragraphStyle};
//        viewSize = [_commentsList[indexPath.row][@"PR_CO_CONTENT"] boundingRectWithSize:maxSize options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin
//                                                                            attributes:attributes  context:nil].size;
//        
//        ((CommentsCell*)cell).lbl_notice_desc.frame = CGRectMake(CGRectGetMinX(((CommentsCell*)cell).lbl_notice_desc.frame), CGRectGetMinY(((CommentsCell*)cell).lbl_notice_desc.frame), viewSize.width, viewSize.height);
//        
//        NSDictionary *data = _commentsList[indexPath.row];
//        if ([data[@"MB_ID"] isEqualToString:GetCommonData.MB_ID]) {
//            ((CommentsCell*)cell).indexPath = indexPath;
//            ((CommentsCell*)cell).btn_delete.hidden = NO;
//            ((CommentsCell*)cell).onDeleteAction = ^(NSIndexPath *indexPath) {
//                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"알림" message:@"췅취소감을 삭제하시겠습니까?" delegate:self cancelButtonTitle:@"취소" otherButtonTitles:@"삭제", nil];
//                alert.tag = indexPath.row;
//                [alert show];
//            };
//        } else {
//            ((CommentsCell*)cell).btn_delete.hidden = YES;
//        }
//    } else if (tableView == self.tableView) {
//        static NSString *CellIdentifier = @"AODListCell";
//        cell = (AODListCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//        if (cell == nil) {
//            cell = [[AODListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
//        }
//        
//        [((AODListCell*)cell).img_thum setImageWithURL:[NSURL URLWithString:MAINIMAGE(_arr_programList[indexPath.row][@"PR_ID"])] placeholderImage:[UIImage imageNamed:@"default_image"]];
//        
//        ((AODListCell*)cell).lbl_title.text = _arr_programList[indexPath.row][@"PR_NAME"];
//        NSString *str_host = @"";
//        if ([_arr_programList[indexPath.row][@"PR_HOST"] length] > 0) {
//            str_host = [NSString stringWithFormat:@"진행 : %@",_arr_programList[indexPath.row][@"PR_HOST"]];
//        } else if ([_arr_programList[indexPath.row][@"PR_SPEAKER"] length] > 0) {
//            str_host = [NSString stringWithFormat:@"강사 : %@",_arr_programList[indexPath.row][@"PR_SPEAKER"]];
//        }
//        ((AODListCell*)cell).lbl_host.text = str_host;
//        ((AODListCell*)cell).btn_select.tag = indexPath.row;
////        ((AODListCell*)cell).indexPath = indexPath;
////        
////        ((AODListCell*)cell).onSelectAction = ^(NSIndexPath *indexPath) {
////            [self onSelectAOD:indexPath];
////        };
//        
//        [((AODListCell*)cell).btn_select addTarget:self action:@selector(onSelectAOD:) forControlEvents:UIControlEventTouchUpInside];
//    }
//    
//    return cell;
//}
//
//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
//    CGFloat height = 0.0;
//    if (tableView == self.commentsTableView) {
//        CGSize maxSize = CGSizeMake(223, 10000);
//        
//        CGSize viewSize = CGSizeZero;
//        
//        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
//        paragraphStyle.lineBreakMode = NSLineBreakByCharWrapping;
//        paragraphStyle.alignment = NSTextAlignmentLeft;
//        NSDictionary *attributes = @{NSFontAttributeName:[UIFont systemFontOfSize:10], NSParagraphStyleAttributeName: paragraphStyle};
//        viewSize = [self.commentsList[indexPath.row][@"PR_CO_CONTENT"] boundingRectWithSize:maxSize options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin
//                                                    attributes:attributes  context:nil].size;
//        
//        height = 32 + viewSize.height + 8;
//    } else if (tableView == self.tableView) {
//        height = 76;
//    }
//    return height;
//}
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//{
//    if (tableView == self.commentsTableView) {
//        return [self.commentsList count];
//    } else if (tableView == self.tableView) {
//        return [self.arr_programList count];
//    }
//    return 0;
//}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    if (!GetCommonData.isLogin) {
        UILoginViewController *loginView = [self.storyboard instantiateViewControllerWithIdentifier:@"UILoginView"];
        [self.navigationController pushViewController:loginView animated:YES];
        return NO;
    }
    return YES;
}

#pragma mark - Notification

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if (textView == self.tv_comments) {
        if ([textView.text length] > 100) {
            if ([text length] == 0) { // 제한 length만큼 입력된후에 text를 삭제하려 할시 삭제가 되지않기에 삭제키입력(null)일 경우 입력가능케 한다.
                return YES;
            }
            return NO;
        }
    }
    return YES;
}

-(void)moveViewUp:(UITextView*)textView {
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3];
    self.commentsInputView.frame = CGRectMake(0, CGRectGetHeight(self.commentsView.frame) - 260 - CGRectGetHeight(self.commentsInputView.frame), CGRectGetWidth(self.commentsInputView.frame), CGRectGetHeight(self.commentsInputView.frame));
    [UIView commitAnimations];
}

-(void)moveViewDown {
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3];
    self.commentsInputView.frame = CGRectMake(0, CGRectGetMaxY(self.commentsTableView.frame), CGRectGetWidth(self.commentsInputView.frame), CGRectGetHeight(self.commentsInputView.frame));
    [UIView commitAnimations];
}


//// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWasShown:(NSNotification *)aNotification
{
    [self moveViewUp:self.tv_comments];
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    [self moveViewDown];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [UIViewController globalResignFirstResponder];
    return YES;
}
//
//- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
//{
//    if (buttonIndex == 1) {
//        [GetURLAddressManager deleteComments:COMMENTSDELETE(self.commentsList[alertView.tag][@"PR_CO_ID"]) mbID:GetCommonData.MB_ID CompletionHandler:^(NSDictionary *data, NSError *error) {
//            if ([data[@"status"] intValue] == 200) {
//                [self getComments];
//            }
//        }];
//    }
//}
@end

@implementation CommentsCell

- (IBAction)onDelete
{
    if (self.onDeleteAction) {
        self.onDeleteAction(self.indexPath);
    }
}

@end

@implementation AODListCell

- (IBAction)onSelect
{
    if (self.onSelectAction) {
        self.onSelectAction(self.indexPath);
    }
}

@end

@implementation AODSubListCell

- (IBAction)onSelect
{
    if (self.onSelectAction) {
        self.onSelectAction(self.indexPath);
    }
}

@end
