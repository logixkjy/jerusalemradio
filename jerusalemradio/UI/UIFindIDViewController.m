//
//  UIFindIDViewController.m
//  jerusalemradio
//
//  Created by Ja Young Park on 2017. 5. 16..
//  Copyright © 2017년 JooYoung Kim. All rights reserved.
//

#import "UIFindIDViewController.h"
#import "URLAddressManager.h"
#import "UIPopupView.h"

@interface UIFindIDViewController () <UIAlertViewDelegate>
@property (nonatomic, strong) IBOutlet UITextField *tf_nickName;
@property (nonatomic, strong) IBOutlet UITextField *tf_mobile;
@property (nonatomic, strong) IBOutlet UITextView *tv_idList;
    
    @property (nonatomic, strong) IBOutlet UILabel *lbl_title;
    @property (nonatomic, strong) IBOutlet UIButton *btn_close;
    @property (nonatomic, strong) IBOutlet UILabel *lbl_desc01;
    @property (nonatomic, strong) IBOutlet UILabel *lbl_desc02;
    @property (nonatomic, strong) IBOutlet UIButton *btn_submit;

@end

@implementation UIFindIDViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
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
    
    _tf_nickName.inputAccessoryView = _m_keyboardToolBar;
    _tf_mobile.inputAccessoryView = _m_keyboardToolBar;
    
    
    self.headerView.frame = CGRectMake(0, 0, MAIN_SIZE().width, CommonUtil.getSafaAreaTop + 44);
    self.bodyVIew.frame = CGRectMake(0, CommonUtil.getSafaAreaTop + 44, MAIN_SIZE().width, MAIN_SIZE().height - (CommonUtil.getSafaAreaTop + 44));
    
    _lbl_title.text = NSLocalizedString(@"FindID_title", @"이메일 아이디 찾기");
    [_btn_close setTitle:NSLocalizedString(@"close", @"닫기") forState:UIControlStateNormal];
    [_btn_submit setTitle:NSLocalizedString(@"FindID_submit", @"이메일 아이디 찾기") forState:UIControlStateNormal];
    
    _lbl_desc01.text = NSLocalizedString(@"FindID_des01", @"아이디를 잊으셨나요?");
    _lbl_desc02.text = NSLocalizedString(@"FindID_des02", @"닉네임과 전화번호를 입력하세요.\n일치하면 아이디를 알려드리겠습니다.");
    
    _tf_nickName.placeholder = NSLocalizedString(@"FindID_nicname_hint", @"닉네임을 입력하세요.");
    _tf_mobile.placeholder = NSLocalizedString(@"FindID_phone_hint", @"휴대폰 번호를 입력하세요.");
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
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)findID
{
    [UINavigationController globalResignFirstResponder];
    if (_tf_nickName.text.length < 2) {
        [self.view makeToast:NSLocalizedString(@"FindID_nicname_empty", @"닉네임을 입력해주세요.")];
        return;
    }
//    else {
//        if ([self checkNickName:_tf_nickName.text]) {
//            [self.view makeToast:@"영어, 한글만 입력해주세요 입력해주세요"];
//            return;
//        }
//    }
    if (_tf_mobile.text.length == 0) {
        [self.view makeToast:NSLocalizedString(@"FindID_phone_empty", @"휴대폰번호를 입력해주세요.")];
        return;
    }
    [GetURLAddressManager idRequest:[URLAddressManager getURL:[URLAddressManager getLocal] type:FINDID]
                           nickName:_tf_nickName.text
                             mobile:_tf_mobile.text
                  CompletionHandler:^(NSDictionary *data, NSError *error) {
                      dispatch_async(dispatch_get_main_queue(), ^{
                          if (error) {
//                              [self.view makeToast:@"이메일아이디 찾기에 실패했습니다."];
                          } else {
                              if ([data[@"status"] intValue] == 200) {
                                  NSString *str_idList = @"";
                                  for (NSDictionary *dic in data[@"data"]) {
                                      str_idList = [str_idList stringByAppendingFormat:@"\n%@", dic[@"MB_ID"]];
                                  }
                                  str_idList = [NSString stringWithFormat:NSLocalizedString(@"FindID_message", @""), self.tf_nickName.text, str_idList];
                                  [[[UIAlertView alloc] initWithTitle:@"알림" message:[data[@"status_message"] stringByAppendingString:str_idList] delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil] show];
                              } else {
                                  [[[UIAlertView alloc] initWithTitle:@"알림" message:data[@"status_message"] delegate:self cancelButtonTitle:@"확인" otherButtonTitles:nil, nil] show];
                              }
                          }
                      });
                   }];
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

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self close];
}

-(UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

@end
