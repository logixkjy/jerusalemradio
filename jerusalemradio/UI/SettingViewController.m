//
//  SettingViewController.m
//  MahanaimBTC
//
//  Created by KimJooYoung on 2016. 2. 14..
//  Copyright © 2016년 mahanaim. All rights reserved.
//

#import "SettingViewController.h"
#import "UILoginViewController.h"
#import "UIIntroViewController.h"

@interface SettingViewController () <UIActionSheetDelegate>
@property (nonatomic, strong) IBOutlet UILabel *lbl_userID;
@property (nonatomic, strong) IBOutlet UISwitch *sw_autoLogin;
@property (nonatomic, strong) IBOutlet UIButton *btn_withDrawal;
@property (nonatomic, strong) IBOutlet UIButton *btn_push;
@property (nonatomic, strong) IBOutlet UILabel *lbl_version;
@property (nonatomic, strong) IBOutlet UIButton *btn_developer;
@property (nonatomic, strong) IBOutlet UIButton *btn_login;
@property (nonatomic, strong) IBOutlet UIButton *btn_liveLevel;
@property (nonatomic, strong) IBOutlet UIButton *btn_langSetting;

@property (nonatomic, strong) IBOutlet UILabel *lbl_mainTitle;
@property (nonatomic, strong) IBOutlet UIButton *btn_mainClose;

@property (nonatomic, strong) IBOutlet UILabel *lbl_loginInfo;
@property (nonatomic, strong) IBOutlet UILabel *lbl_loginID;
@property (nonatomic, strong) IBOutlet UILabel *lbl_withDrawal;
@property (nonatomic, strong) IBOutlet UILabel *lbl_autoLogin;

@property (nonatomic, strong) IBOutlet UILabel *lbl_setting;
@property (nonatomic, strong) IBOutlet UILabel *lbl_push;
@property (nonatomic, strong) IBOutlet UILabel *lbl_quality;
@property (nonatomic, strong) IBOutlet UILabel *lbl_langSetting;

@property (nonatomic, strong) IBOutlet UILabel *lbl_appInfo;
@property (nonatomic, strong) IBOutlet UILabel *lbl_versionInfo;
@property (nonatomic, strong) IBOutlet UILabel *lbl_developer;
@property (nonatomic, strong) IBOutlet UILabel *lbl_copyright;
@property (nonatomic, strong) IBOutlet UILabel *lbl_copyright_desc;
@end

@implementation SettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.mainDelegate = MAIN_APP_DELEGATE();
    
    self.headerView.frame = CGRectMake(0, 0, MAIN_SIZE().width, CommonUtil.getSafaAreaTop + 44);
    self.bottomView.frame = CGRectMake(0, CommonUtil.getSafaAreaTop + 44, MAIN_SIZE().width, MAIN_SIZE().height - (CommonUtil.getSafaAreaTop + 44));
    
    _lbl_mainTitle.text = NSLocalizedString(@"setting_title", @"설정");
    [_btn_mainClose setTitle:NSLocalizedString(@"close", @"닫기") forState:UIControlStateNormal];
    
    _lbl_loginInfo.text = NSLocalizedString(@"setting_subtitle1", @"로그인 정보");
    _lbl_loginID.text = NSLocalizedString(@"setting_login_id", @"로그인 아이디");
    _lbl_autoLogin.text = NSLocalizedString(@"setting_auto", @"자동 로그인");
    _lbl_withDrawal.text = NSLocalizedString(@"setting_withdrawal", @"회원 탈퇴");
    
    [_btn_withDrawal setTitle:NSLocalizedString(@"setting_to_withdraw", @"탈퇴하기") forState:UIControlStateNormal];

    _lbl_setting.text = NSLocalizedString(@"setting_subtitle2", @"설정");
    _lbl_push.text = NSLocalizedString(@"setting_push", @"푸시알림");
    _lbl_quality.text = NSLocalizedString(@"setting_quality", @"음질");
    _lbl_langSetting.text = NSLocalizedString(@"setting_local", @"언어설정");
    
    _lbl_appInfo.text = NSLocalizedString(@"setting_subtitle3", @"어플리케이션 정보");
    _lbl_versionInfo.text = NSLocalizedString(@"setting_version", @"버전");
    _lbl_developer.text = NSLocalizedString(@"setting_info", @"개발자 정보");
    _lbl_copyright.text = NSLocalizedString(@"setting_copyright", @"Copyright");
    _lbl_copyright_desc.text = NSLocalizedString(@"setting_copyright_name", @"Jerusalem Radio");
    [_btn_developer setTitle:NSLocalizedString(@"common_view", @"보기") forState:UIControlStateNormal];
    [_btn_push setTitle:NSLocalizedString(@"setting_subtitle2", @"설정") forState:UIControlStateNormal];
    
    [_btn_mainClose sizeToFit];
    _btn_mainClose.frame = CGRectMake(MAIN_SIZE().width - CGRectGetWidth(_btn_mainClose.frame) - 20, CGRectGetMinY(_btn_mainClose.frame), CGRectGetWidth(_btn_mainClose.frame) + 20, 44);
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (GetCommonData.isLogin) {
        [_btn_login setTitle:NSLocalizedString(@"setting_logout", @"로그아웃") forState:UIControlStateNormal];
        _lbl_userID.text = [CommonUtil readObjectFromDefault:@"USER_ID"];
//        _btn_withDrawal.enabled = YES;
    } else {
        [_btn_login setTitle:NSLocalizedString(@"setting_login", @"로그인") forState:UIControlStateNormal];
        _lbl_userID.text = @"";
//        _btn_withDrawal.enabled = NO;
    }
    _sw_autoLogin.on = ![CommonUtil readBoolFromDefault:@"IS_AUTOLOGIN"];
    
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    _lbl_version.text = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    
    if (![[CommonUtil readObjectFromDefault:@"LIVE_LEVEL"] isEqualToString:@"LOW"]) {
        [_btn_liveLevel setTitle:NSLocalizedString(@"setting_quality_high", @"일반 (96kbps)") forState:UIControlStateNormal];
    } else {
        [_btn_liveLevel setTitle:NSLocalizedString(@"setting_quality_low", @"저속 (32kbps)") forState:UIControlStateNormal];
    }
    
    if ([[CommonUtil readObjectFromDefault:@"LANG_CODE"] isEqualToString:@"PT"]) {
        [_btn_langSetting setTitle:NSLocalizedString(@"local_pt", @"포르투갈어") forState:UIControlStateNormal];
    } else if ([[CommonUtil readObjectFromDefault:@"LANG_CODE"] isEqualToString:@"ES"]) {
        [_btn_langSetting setTitle:NSLocalizedString(@"local_es", @"스페인어") forState:UIControlStateNormal];
    } else {
        [_btn_langSetting setTitle:NSLocalizedString(@"local_kr", @"한국어") forState:UIControlStateNormal];
    }
        
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)back
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)setLogOut
{
    if (GetCommonData.isLogin) {
        [GetURLAddressManager sendLogout:[URLAddressManager getURL:[URLAddressManager getLocal] type:LOGOUT] uid:GetCommonData.MB_ID CompletionHandler:^(NSDictionary *data, NSError *error) {
            GetCommonData.isLogin = NO;
            GetCommonData.MB_ID = @"";
            GetCommonData.MB_NAME = @"";
            GetCommonData.MB_TOKEN = @"";
            GetCommonData.MB_TYPE = @"";
            [CommonUtil writeObjectToDefault:@"" KEY:@"USER_ID"];
            [CommonUtil writeObjectToDefault:@"" KEY:@"USER_PW"];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                _lbl_userID.text = @"";
                [_btn_login setTitle:NSLocalizedString(@"setting_login", @"로그인") forState:UIControlStateNormal];
            });
        }];
    } else {
        UILoginViewController *loginView = [self.storyboard instantiateViewControllerWithIdentifier:@"UILoginView"];
        [self.navigationController pushViewController:loginView animated:YES];
    }
}

- (IBAction)setAutoLogin:(UISwitch*)sender
{
    [CommonUtil writeBoolToDefault:!sender.on KEY:@"AUTO_LOGIN"];
}

- (IBAction)moveSettingPage
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
}

- (IBAction)viewDeveloperInfo
{
    [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"setting_developer_title", @"개발자 정보")
                                message:NSLocalizedString(@"setting_developer_message", @"Team GIV\nhttp://volunteers.gnn.or.kr") delegate:nil cancelButtonTitle:NSLocalizedString(@"common_ok", @"확인") otherButtonTitles:nil, nil] show];
}

- (IBAction)setLiveLevel
{
    [self setActionSheet];
}

- (IBAction)onWithDrawal
{
//    if (GetCommonData.isLogin) {
        UIAlertController *alertController = [UIAlertController
                                              alertControllerWithTitle:NSLocalizedString(@"setting_withdrawal", @"회원 탈퇴")
                                              message:NSLocalizedString(@"setting_withdrawal_desc", @"예루살렘 라디오 탈퇴하시겠습니까?\n탈퇴하시면 모든 회원정보는 삭제됩니다.")
                                              preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"common_ok", @"확인")
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * _Nonnull action) {
            [self sendWithDrawal];
        }];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"common_cancel", @"취소")
                                                               style:UIAlertActionStyleCancel
                                                             handler:nil];
        
        [alertController addAction:okAction];
        [alertController addAction:cancelAction];
        
        [self presentViewController:alertController animated:YES completion:nil];
//    }
}

- (void)sendWithDrawal
{
    
    [GetURLAddressManager sendWithdrawal:GetCommonData.MB_ID
                       CompletionHandler:^(NSDictionary *data, NSError *error) {
        GetCommonData.isLogin = NO;
        GetCommonData.MB_ID = @"";
        GetCommonData.MB_NAME = @"";
        GetCommonData.MB_TOKEN = @"";
        GetCommonData.MB_TYPE = @"";
        [CommonUtil writeObjectToDefault:@"" KEY:@"USER_ID"];
        [CommonUtil writeObjectToDefault:@"" KEY:@"USER_PW"];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            _lbl_userID.text = @"";
            [_btn_login setTitle:NSLocalizedString(@"setting_login", @"로그인") forState:UIControlStateNormal];
        });
    }];
}

- (void)setActionSheet
{
    if ([UIAlertController class]) {
        __weak typeof(self) weakSelf = self;
        UIAlertController * view=   [UIAlertController
                                     alertControllerWithTitle:NSLocalizedString(@"setting_live_quality", @"라이브 음질 설정")
                                     message:NSLocalizedString(@"setting_live_quality_desc", @"원하는 음질을 선택하세요.")
                                     preferredStyle:UIAlertControllerStyleActionSheet];
        
        UIAlertAction *item1 = [UIAlertAction
                                actionWithTitle:NSLocalizedString(@"setting_quality_high", @"일반 (96kbps)")
                                style:[[CommonUtil readObjectFromDefault:@"LIVE_LEVEL"] isEqualToString:@"NOMAL"] ? UIAlertActionStyleDestructive : UIAlertActionStyleDefault
                                handler:^(UIAlertAction * action)
                                {
                                    [view dismissViewControllerAnimated:YES completion:nil];
                                    [weakSelf alertAction:action clickedButtonAtIndex:0];
                                }];
    
        [view addAction:item1];
        
        UIAlertAction *item2 = [UIAlertAction
                                actionWithTitle:NSLocalizedString(@"setting_quality_low", @"저속 (32kbps)")
                                style:[[CommonUtil readObjectFromDefault:@"LIVE_LEVEL"] isEqualToString:@"LOW"] ? UIAlertActionStyleDestructive : UIAlertActionStyleDefault
                                handler:^(UIAlertAction * action)
                                {
                                    [view dismissViewControllerAnimated:YES completion:nil];
                                    [weakSelf alertAction:action clickedButtonAtIndex:1];
                                }];
        
        [view addAction:item2];
        
        UIAlertAction *itemCancel = [UIAlertAction
                                     actionWithTitle:NSLocalizedString(@"close", @"닫기")
                                     style:UIAlertActionStyleCancel
                                     handler:^(UIAlertAction * action)
                                     {
                                         [view dismissViewControllerAnimated:YES completion:nil];
                                     }];
        
        [view addAction:itemCancel];
        
        [self presentViewController:view animated:YES completion:nil];
    }
    else {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"닫기" destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"setting_quality_high", @"일반 (96kbps)"),NSLocalizedString(@"setting_quality_low", @"저속 (32kbps)"),nil];
        actionSheet.tag = 1001;
        UIView *keyView = [[[[UIApplication sharedApplication] keyWindow] subviews] objectAtIndex:0];
        [actionSheet showInView:keyView];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == 1001) {
        if (buttonIndex == 0) {
            [CommonUtil writeObjectToDefault:@"NOMAL" KEY:@"LIVE_LEVEL"];
            [_btn_liveLevel setTitle:NSLocalizedString(@"setting_quality_high", @"일반 (96kbps)") forState:UIControlStateNormal];
        } else {
            [CommonUtil writeObjectToDefault:@"LOW" KEY:@"LIVE_LEVEL"];
            [_btn_liveLevel setTitle:NSLocalizedString(@"setting_quality_low", @"저속 (32kbps)") forState:UIControlStateNormal];
        }
        [self.mainDelegate.avAudioPlayer stop];
        GetCommonData.audio_mode = @"";
        [self playOnAir];
    } else {
        if (buttonIndex == 0) {
            [CommonUtil writeObjectToDefault:@"KR" KEY:@"LANG_CODE"];
            [_btn_langSetting setTitle:NSLocalizedString(@"local_kr", @"한국어") forState:UIControlStateNormal];
        } else if (buttonIndex == 1) {
            [CommonUtil writeObjectToDefault:@"ES" KEY:@"LANG_CODE"];
            [_btn_langSetting setTitle:NSLocalizedString(@"local_es", @"스페인어") forState:UIControlStateNormal];
        } else {
            [CommonUtil writeObjectToDefault:@"PT" KEY:@"LANG_CODE"];
            [_btn_langSetting setTitle:NSLocalizedString(@"local_pt", @"포르투갈어") forState:UIControlStateNormal];
        }
    }
}

- (void)alertAction:(UIAlertAction *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        [CommonUtil writeObjectToDefault:@"NOMAL" KEY:@"LIVE_LEVEL"];
        [_btn_liveLevel setTitle:NSLocalizedString(@"setting_quality_high", @"일반 (96kbps)") forState:UIControlStateNormal];
    } else {
        [CommonUtil writeObjectToDefault:@"LOW" KEY:@"LIVE_LEVEL"];
        [_btn_liveLevel setTitle:NSLocalizedString(@"setting_quality_low", @"저속 (32kbps)") forState:UIControlStateNormal];
    }
    [self.mainDelegate.avAudioPlayer stop];
    GetCommonData.audio_mode = @"";
    [self playOnAir];
}

- (IBAction)setLangSetting
{
    if ([UIAlertController class]) {
        __weak typeof(self) weakSelf = self;
        UIAlertController * view=   [UIAlertController
                                     alertControllerWithTitle:NSLocalizedString(@"setting_local", @"언어설정")
                                     message:NSLocalizedString(@"setting_lang_setting_desc", @"원하시는 언어를 선택하세요.")
                                     preferredStyle:UIAlertControllerStyleActionSheet];
        
        UIAlertAction *item1 = [UIAlertAction
                                actionWithTitle:NSLocalizedString(@"local_kr", @"한국어")
                                style:[[CommonUtil readObjectFromDefault:@"LANG_CODE"] isEqualToString:@"KR"] ? UIAlertActionStyleDestructive : UIAlertActionStyleDefault
                                handler:^(UIAlertAction * action)
                                {
            [view dismissViewControllerAnimated:YES completion:nil];
            [weakSelf alertAction2:action clickedButtonAtIndex:0];
        }];
        
        [view addAction:item1];
        
        UIAlertAction *item2 = [UIAlertAction
                                actionWithTitle:NSLocalizedString(@"local_es", @"스페인어")
                                style:[[CommonUtil readObjectFromDefault:@"LANG_CODE"] isEqualToString:@"ES"] ? UIAlertActionStyleDestructive : UIAlertActionStyleDefault
                                handler:^(UIAlertAction * action)
                                {
            [view dismissViewControllerAnimated:YES completion:nil];
            [weakSelf alertAction2:action clickedButtonAtIndex:1];
        }];
        
        [view addAction:item2];
        
        UIAlertAction *item3 = [UIAlertAction
                                actionWithTitle:NSLocalizedString(@"local_pt", @"포르투갈어")
                                style:[[CommonUtil readObjectFromDefault:@"LANG_CODE"] isEqualToString:@"PT"] ? UIAlertActionStyleDestructive : UIAlertActionStyleDefault
                                handler:^(UIAlertAction * action)
                                {
            [view dismissViewControllerAnimated:YES completion:nil];
            [weakSelf alertAction2:action clickedButtonAtIndex:2];
        }];
        
        [view addAction:item3];
        
        UIAlertAction *itemCancel = [UIAlertAction
                                     actionWithTitle:NSLocalizedString(@"close", @"닫기")
                                     style:UIAlertActionStyleCancel
                                     handler:^(UIAlertAction * action)
                                     {
            [view dismissViewControllerAnimated:YES completion:nil];
        }];
        
        [view addAction:itemCancel];
        
        [self presentViewController:view animated:YES completion:nil];
    }
    else {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"close", @"닫기") destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"local_kr", @"한국어"),
                                      NSLocalizedString(@"local_es", @"스페인어"),
                                      NSLocalizedString(@"local_pt", @"포르투갈어"),
                                      nil];
        actionSheet.tag = 1002;
        UIView *keyView = [[[[UIApplication sharedApplication] keyWindow] subviews] objectAtIndex:0];
        [actionSheet showInView:keyView];
    }
}

- (void)alertAction2:(UIAlertAction *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self.mainDelegate.avAudioPlayer stop];
    if (GetCommonData.isLogin) {
        [GetURLAddressManager sendLogout:[URLAddressManager getURL:[URLAddressManager getLocal] type:LOGOUT] uid:GetCommonData.MB_ID CompletionHandler:^(NSDictionary *data, NSError *error) {
            GetCommonData.isLogin = NO;
            GetCommonData.MB_ID = @"";
            GetCommonData.MB_NAME = @"";
            GetCommonData.MB_TOKEN = @"";
            GetCommonData.MB_TYPE = @"";
            [CommonUtil writeObjectToDefault:@"" KEY:@"USER_ID"];
            [CommonUtil writeObjectToDefault:@"" KEY:@"USER_PW"];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                _lbl_userID.text = @"";
                [_btn_login setTitle:NSLocalizedString(@"setting_login", @"로그인") forState:UIControlStateNormal];
            });
        }];
    }
    GetCommonData.audio_mode = @"";
    if (buttonIndex == 0) {
        [CommonUtil writeObjectToDefault:@"KR" KEY:@"LANG_CODE"];
        [_btn_langSetting setTitle:NSLocalizedString(@"local_kr", @"한국어") forState:UIControlStateNormal];
    } else if (buttonIndex == 1) {
        [CommonUtil writeObjectToDefault:@"ES" KEY:@"LANG_CODE"];
        [_btn_langSetting setTitle:NSLocalizedString(@"local_es", @"스페인어") forState:UIControlStateNormal];
    } else {
        [CommonUtil writeObjectToDefault:@"PT" KEY:@"LANG_CODE"];
        [_btn_langSetting setTitle:NSLocalizedString(@"local_pt", @"포르투갈어") forState:UIControlStateNormal];
    }
    [self changeLang];
}

- (void)changeLang
{
    UIIntroViewController *view = [self.storyboard instantiateViewControllerWithIdentifier:@"IntroView"];
    [self.navigationController pushViewController:view animated:NO];
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}

-(UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}
@end
