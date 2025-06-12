//
//  UILoginViewController.m
//  jerusalemradio
//
//  Created by Ja Young Park on 2017. 5. 11..
//  Copyright © 2017년 JooYoung Kim. All rights reserved.
//

#import "UILoginViewController.h"
#import "UIRegistMemberViewController.h"
#import "UIFindPWViewController.h"
#import "UIFindIDViewController.h"

@interface UILoginViewController ()
@property (nonatomic, strong) IBOutlet UIView *vi_id_pw;
@property (nonatomic, strong) IBOutlet UITextField *tf_id;
@property (nonatomic, strong) IBOutlet UITextField *tf_pw;
@property (nonatomic, strong) IBOutlet UIImageView *img_autoLogin;

    @property (nonatomic, strong) IBOutlet UILabel *lbl_title;
    @property (nonatomic, strong) IBOutlet UIButton *btn_close;
    @property (nonatomic, strong) IBOutlet UILabel *lbl_autoLogin;
    @property (nonatomic, strong) IBOutlet UIButton *btn_login;
    @property (nonatomic, strong) IBOutlet UIButton *btn_find_pw;
    @property (nonatomic, strong) IBOutlet UIButton *btn_find_id;
    @property (nonatomic, strong) IBOutlet UIButton *btn_regist;

@end

@implementation UILoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _img_autoLogin.highlighted = ![CommonUtil readBoolFromDefault:@"AUTO_LOGIN"];
    
    _vi_id_pw.layer.borderWidth = 1;
    _vi_id_pw.layer.borderColor = UIColorFromRGB(0xD6D6D6).CGColor;
    
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
    [btn_key_close setTitle:NSLocalizedString(@"close", @"닫기") forState:UIControlStateNormal];
    [btn_key_close setTitleColor:UIColorFromRGB(0x5F5F5F) forState:UIControlStateNormal];
    [btn_key_close addTarget:self action:@selector(closeKeyboard) forControlEvents:UIControlEventTouchUpInside];
    
    [_m_keyboardToolBar addSubview:btn_key_close];
    
    _tf_pw.inputAccessoryView = _m_keyboardToolBar;
    _tf_id.inputAccessoryView = _m_keyboardToolBar;
    
    self.headerView.frame = CGRectMake(0, 0, MAIN_SIZE().width, CommonUtil.getSafaAreaTop + 44);
    self.bodyVIew.frame = CGRectMake(0, CommonUtil.getSafaAreaTop + 44, MAIN_SIZE().width, MAIN_SIZE().height - (CommonUtil.getSafaAreaTop + 44));
    
    _lbl_title.text = NSLocalizedString(@"Login_title", @"로그인");
    [_btn_close setTitle:NSLocalizedString(@"close", @"닫기") forState:UIControlStateNormal];
    _tf_id.placeholder = NSLocalizedString(@"Login_id_hint", @"이메일 주소를 입력하세요.");
    _tf_pw.placeholder = NSLocalizedString(@"Login_pw_hint", @"비밀번호를 입력하세요.");
    _lbl_autoLogin.text = NSLocalizedString(@"Login_auto", @"자동 로그인");
    [_btn_login setTitle:NSLocalizedString(@"Login_submit", @"로그인") forState:UIControlStateNormal];
    [_btn_find_pw setTitle:NSLocalizedString(@"Login_pw", @"비밀번호 찾기") forState:UIControlStateNormal];
    _btn_find_pw.titleLabel.numberOfLines = 2;
    _btn_find_pw.titleLabel.textAlignment = NSTextAlignmentCenter;
    [_btn_find_id setTitle:NSLocalizedString(@"Login_id", @"아이디 찾기") forState:UIControlStateNormal];
    [_btn_regist setTitle:NSLocalizedString(@"Login_join", @"회원가입") forState:UIControlStateNormal];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)closeKeyboard
{
    [UINavigationController globalResignFirstResponder];
}

- (IBAction)close
{
    [UINavigationController globalResignFirstResponder];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)login
{
    [UINavigationController globalResignFirstResponder];
    if (_tf_id.text.length == 0) {
        [self.view makeToast:NSLocalizedString(@"Login_id_hint", @"이메일 주소를 입력하세요.")];
        return;
    } else if (_tf_pw.text.length == 0) {
        [self.view makeToast:NSLocalizedString(@"Login_pw_hint", @"비밀번호를 입력하세요.")];
        return;
    }
    [GetURLAddressManager sendLogin:[URLAddressManager getURL:[URLAddressManager getLocal] type:LOGIN]
                                uid:_tf_id.text
                                upw:_tf_pw.text
                  CompletionHandler:^(NSDictionary *data, NSError *error) {
                      dispatch_async(dispatch_get_main_queue(), ^{
                          if ([data[@"status"] intValue] == 200) {
                              GetCommonData.isLogin = YES;
                              GetCommonData.MB_ID = data[@"data"][@"MB_ID"];
                              GetCommonData.MB_NAME = data[@"data"][@"MB_NAME"];
                              GetCommonData.MB_TOKEN = data[@"data"][@"MB_TOKEN"];
                              GetCommonData.MB_TYPE = data[@"data"][@"MB_TYPE"];
                              if (![CommonUtil readBoolFromDefault:@"AUTO_LOGIN"]) {
                                  [CommonUtil writeObjectToDefault:GetCommonData.MB_ID KEY:@"USER_ID"];
                                  [CommonUtil writeObjectToDefault:_tf_pw.text KEY:@"USER_PW"];
                              }
                              [self.navigationController popViewControllerAnimated:YES];
                          } else {
                              [self.view makeToast:NSLocalizedString(@"Login_fail", @"로그인에 실패했습니다.")];
                          }
                      });
                  }];
}

- (IBAction)autoLogin:(UIButton*)sender
{
    [CommonUtil writeBoolToDefault:![CommonUtil readBoolFromDefault:@"AUTO_LOGIN"] KEY:@"AUTO_LOGIN"];
    _img_autoLogin.highlighted = ![CommonUtil readBoolFromDefault:@"AUTO_LOGIN"];
    
}

- (IBAction)findID
{
    UIFindIDViewController *findIdView = [self.storyboard instantiateViewControllerWithIdentifier:@"UIFindIDView"];
    [self.navigationController pushViewController:findIdView animated:YES];
    
}

- (IBAction)findPW
{
    UIFindPWViewController *findPwView = [self.storyboard instantiateViewControllerWithIdentifier:@"UIFindPWView"];
    [self.navigationController pushViewController:findPwView animated:YES];
}

- (IBAction)registMember
{
    UIRegistMemberViewController *registView = [self.storyboard instantiateViewControllerWithIdentifier:@"UIRegistMemberView"];
    [self.navigationController pushViewController:registView animated:YES];
}


-(UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

@end
