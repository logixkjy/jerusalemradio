//
//  UIFindPWViewController.m
//  jerusalemradio
//
//  Created by Ja Young Park on 2017. 5. 16..
//  Copyright © 2017년 JooYoung Kim. All rights reserved.
//

#import "UIFindPWViewController.h"
#import "URLAddressManager.h"
#import "UIPopupView.h"

@interface UIFindPWViewController () <UIAlertViewDelegate>
@property (nonatomic, strong) IBOutlet UITextField *tf_id;
    
    @property (nonatomic, strong) IBOutlet UILabel *lbl_title;
    @property (nonatomic, strong) IBOutlet UIButton *btn_close;
    @property (nonatomic, strong) IBOutlet UILabel *lbl_desc01;
    @property (nonatomic, strong) IBOutlet UILabel *lbl_desc02;
    @property (nonatomic, strong) IBOutlet UIButton *btn_submit;

@end

@implementation UIFindPWViewController

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
    
    _tf_id.inputAccessoryView = _m_keyboardToolBar;
    
    
    self.headerView.frame = CGRectMake(0, 0, MAIN_SIZE().width, CommonUtil.getSafaAreaTop + 44);
    self.bodyVIew.frame = CGRectMake(0, CommonUtil.getSafaAreaTop + 44, MAIN_SIZE().width, MAIN_SIZE().height - (CommonUtil.getSafaAreaTop + 44));
    
    _lbl_title.text = NSLocalizedString(@"FindPW_title", @"비밀번호 재설정");
    [_btn_close setTitle:NSLocalizedString(@"close", @"닫기") forState:UIControlStateNormal];
    [_btn_submit setTitle:NSLocalizedString(@"Join_submit", @"회원가입") forState:UIControlStateNormal];
    
    _lbl_desc01.text = NSLocalizedString(@"FindPW_des01", @"비밀번호를 잊으셨나요?");
    _lbl_desc02.text = NSLocalizedString(@"FindPW_des02", @"예루살렘라디오에 가입한 이메일아이디를\n입력하시면 비밀번호 재설정이 가능한\n안내 메일을 보내드리겠습니다.");
    
    _tf_id.placeholder = NSLocalizedString(@"FindPW_id_hint", @"이메일 주소를 입력하세요.");
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


- (IBAction)findPW
{
    [UINavigationController globalResignFirstResponder];
    if (_tf_id.text.length == 0) {
        [self.view makeToast:NSLocalizedString(@"FindPW_id_empty", @"이메일 아이디를 입력해주세요.")];
        return;
    }
//    else {
//        if (![self checkEmail:_tf_id.text]) {
//            [self.view makeToast:@"이메일 형식이 아닙니다."];
//            return;
//        }
//    }
    [GetURLAddressManager pwdRequest:[URLAddressManager getURL:[URLAddressManager getLocal] type:FINDPW]
                            memberID:_tf_id.text
                   CompletionHandler:^(NSDictionary *data, NSError *error) {
                       dispatch_async(dispatch_get_main_queue(), ^{
                           if (error != nil) {
//                               [self.view makeToast:@"비밀번호 재설정에 실패했습니다."];
                           } else {
                               if ([data[@"status"] intValue] == 200) {
                                   [[[UIAlertView alloc] initWithTitle:@"알림" message:data[@"status_message"] delegate:self cancelButtonTitle:@"확인" otherButtonTitles:nil, nil] show];
                               } else {
                                   [[[UIAlertView alloc] initWithTitle:@"알림" message:data[@"status_message"] delegate:self cancelButtonTitle:@"확인" otherButtonTitles:nil, nil] show];
                               }
                               [self.view makeToast:NSLocalizedString(@"FindPW_success", @"안내 메일을 보냈습니다.")];
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

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self close];
}

-(UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

@end
