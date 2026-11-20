//
//  UIRegistMemberViewController.m
//  jerusalemradio
//
//  Created by Ja Young Park on 2017. 5. 13..
//  Copyright © 2017년 JooYoung Kim. All rights reserved.
//

#import "UIRegistMemberViewController.h"

@interface UIRegistMemberViewController ()
{
    UITextField *activeField;
}
@property (nonatomic, strong) IBOutlet UIView *vi_regist;
@property (nonatomic, strong) IBOutlet UITextField *tf_id;
@property (nonatomic, strong) IBOutlet UITextField *tf_pw;
@property (nonatomic, strong) IBOutlet UITextField *tf_pw_confirm;
@property (nonatomic, strong) IBOutlet UITextField *tf_nickName;
@property (nonatomic, strong) IBOutlet UITextField *tf_mobile;
@property (nonatomic, strong) IBOutlet UIScrollView *scrollView;
    
    @property (nonatomic, strong) IBOutlet UILabel *lbl_title;
    @property (nonatomic, strong) IBOutlet UIButton *btn_close;
    @property (nonatomic, strong) IBOutlet UIButton *btn_submit;
    @property (nonatomic, strong) IBOutlet UILabel *lbl_id;
    @property (nonatomic, strong) IBOutlet UILabel *lbl_pw;
    @property (nonatomic, strong) IBOutlet UILabel *lbl_pw_confirm;
    @property (nonatomic, strong) IBOutlet UILabel *lbl_nickname;
    @property (nonatomic, strong) IBOutlet UILabel *lbl_mobile;

@end

@implementation UIRegistMemberViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.vi_regist.layer.borderWidth = 1;
    self.vi_regist.layer.borderColor = UIColorFromRGB(0xE0E0E0).CGColor;
    
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
    [btn_key_close setTitle:@"완료" forState:UIControlStateNormal];
    [btn_key_close setTitleColor:UIColorFromRGB(0x5F5F5F) forState:UIControlStateNormal];
    [btn_key_close addTarget:self action:@selector(closeKeyboard) forControlEvents:UIControlEventTouchUpInside];
    
    [_m_keyboardToolBar addSubview:btn_key_close];
    
    _tf_pw.inputAccessoryView = _m_keyboardToolBar;
    _tf_id.inputAccessoryView = _m_keyboardToolBar;
    _tf_pw_confirm.inputAccessoryView = _m_keyboardToolBar;
    _tf_mobile.inputAccessoryView = _m_keyboardToolBar;
    _tf_nickName.inputAccessoryView = _m_keyboardToolBar;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    
    self.headerView.frame = CGRectMake(0, 0, MAIN_SIZE().width, CommonUtil.getSafaAreaTop + 44);
    self.bodyVIew.frame = CGRectMake(0, CommonUtil.getSafaAreaTop + 44, MAIN_SIZE().width, MAIN_SIZE().height - (CommonUtil.getSafaAreaTop + 44));
    
    _lbl_title.text = NSLocalizedString(@"Join_title", @"회원가입");
    [_btn_close setTitle:NSLocalizedString(@"close", @"닫기") forState:UIControlStateNormal];
    [_btn_submit setTitle:NSLocalizedString(@"Join_submit", @"회원가입") forState:UIControlStateNormal];
    
    _lbl_id.text = NSLocalizedString(@"Join_id", @"아이디");
    _lbl_pw.text = NSLocalizedString(@"Join_pw01", @"비밀번호");
    _lbl_pw_confirm.text = NSLocalizedString(@"Join_pw02", @"비밀번호 확인");
    _lbl_nickname.text = NSLocalizedString(@"Join_nicname", @"닉네임");
    _lbl_mobile.text = NSLocalizedString(@"Join_phone", @"휴대폰 번호");
    
    _tf_id.placeholder = NSLocalizedString(@"Join_id_hint", @"이메일 주소를 입력하세요.");
    _tf_pw.placeholder = NSLocalizedString(@"Join_pw01", @"비밀번호");
    _tf_pw_confirm.placeholder = NSLocalizedString(@"Join_pw02", @"비밀번호 확인");
    _tf_nickName.placeholder = NSLocalizedString(@"Join_nicname_hint", @"닉네임을 입력하세요.");
    _tf_mobile.placeholder = NSLocalizedString(@"Join_phone_hint", @"휴대폰 번호를 입력하세요.");
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
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

- (IBAction)registMember
{
    [UINavigationController globalResignFirstResponder];
    if (_tf_id.text.length == 0) {
        [self.view makeToast:NSLocalizedString(@"Join_id_empty", @"이메일 아이디를 입력해주세요.")];
        return;
    }
//    else {
//        if (![self checkEmail:_tf_id.text]) {
//            [self.view makeToast:@"이메일 형식이 아닙니다."];
//            return;
//        }
//    }
    if (_tf_pw.text.length < 4) {
        [self.view makeToast:NSLocalizedString(@"Join_pw_empty", @"비밀번호를 입력해주세요.")];
        return;
    }
    if (![_tf_pw.text isEqualToString:_tf_pw_confirm.text]) {
        [self.view makeToast:NSLocalizedString(@"Join_pw_error", @"입력하신 비밀번호가 다릅니다.\n다시 입력해주세요.")];
        return;
    }
    if (_tf_nickName.text.length < 2) {
        [self.view makeToast:NSLocalizedString(@"Join_nicname_empty", @"닉네임을 입력해주세요.")];
        return;
    }
//    else {
//        if ([self checkNickName:_tf_nickName.text]) {
//            [self.view makeToast:@"영어, 한글만 입력해주세요 입력해주세요"];
//            return;
//        }
//    }
//    if (_tf_mobile.text.length == 0) {
//        [self.view makeToast:NSLocalizedString(@"Join_phone_empty", @"휴대폰번호를 입력해주세요.")];
//        return;
//    }
    
    [GetURLAddressManager sendRegistMembar:[URLAddressManager getURL:[URLAddressManager getLocal] type:JOIN]
                                  memberID:_tf_id.text
                                        pw:_tf_pw.text
                                 pwConfirm:_tf_pw_confirm.text
                                  nickName:_tf_nickName.text
                                    mobile:_tf_mobile.text
                         CompletionHandler:^(NSDictionary *data, NSError *error) {
                             dispatch_async(dispatch_get_main_queue(), ^{
                                 if (error != nil) {
                                     [self.view makeToast:NSLocalizedString(@"Join_fail", @"회원가입에 실패했습니다.")];
                                 } else {
                                     if ([data[@"status"] intValue] == 200) {
                                         [CommonUtil showMessage:data[@"status_message"] title:@"알림" from:self completion:^{ [self close]; }];
                                         
                                         [self.view makeToast:NSLocalizedString(@"Join_success", @"회원가입을 완료했습니다.")];
                                     } else {
                                         [CommonUtil showMessage:data[@"status_message"] title:@"알림" from:self completion:nil];
                                     }
                                     
                                 }
                             });
                         }];
}

- (BOOL)checkEmail:(NSString *)email
{
    const char *tmp = [email cStringUsingEncoding:NSUTF8StringEncoding];
    if (email.length != strlen(tmp))
    {
        return NO;
    }
    
    NSString *check = @"([0-9a-zA-Z_-]+)@([0-9a-zA-Z_-]+)(\\.[0-9a-zA-Z_-]+){1,2}";
    NSRange match = [email rangeOfString:check options:NSRegularExpressionSearch];
    if (NSNotFound == match.location)
    {
        return NO;
    }
    return YES;
}

- (BOOL)checkNickName:(NSString *)nickName
{
    const char *tmp = [nickName cStringUsingEncoding:NSUTF8StringEncoding];
    if (nickName.length != strlen(tmp))
    {
        return NO;
    }
    
    NSString *check = @"/^[가-힣a-zA-Z]+$/";
    NSRange match = [nickName rangeOfString:check options:NSRegularExpressionSearch];
    if (NSNotFound == match.location)
    {
        return NO;
    }
    return YES;
}



-(UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

#pragma mark - Notification

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    activeField = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    activeField = nil;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField == _tf_nickName) {
        if ([textField.text length] > 20) {
            if ([string length] == 0) { // 제한 length만큼 입력된후에 text를 삭제하려 할시 삭제가 되지않기에 삭제키입력(null)일 경우 입력가능케 한다.
                return YES;
            }
            return NO;
        }
    }
    return YES;
}

-(void)moveViewUp:(UITextField*)textField {
    CGPoint origin = [textField.superview convertPoint:textField.frame.origin toView:self.view];
    CGSize tfSize = textField.frame.size;
    CGSize size = MAIN_SIZE();
    NSLog(@"tf_y ===> [%lf][%lf][%lf]",origin.y + tfSize.height ,(size.height-260),-((origin.y + tfSize.height + 50) - (size.height-260)));
    if (origin.y + tfSize.height + 60 > (size.height-260)) {
        [UIView animateWithDuration:0.3 animations:^{
        
        [self.view setFrame:CGRectMake(0, -(( origin.y + tfSize.height + 60 ) - (size.height-260)), 320, size.height)];
        
        }];
    }
    
}

-(void)moveViewDown {
    CGSize size = MAIN_SIZE();
    [UIView animateWithDuration:0.1 animations:^{
    
    [self.view setFrame:CGRectMake(0, 0, 320, size.height)];
    
    }];
}


//// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWasShown:(NSNotification *)aNotification
{
    [self moveViewUp:activeField];
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

@end
