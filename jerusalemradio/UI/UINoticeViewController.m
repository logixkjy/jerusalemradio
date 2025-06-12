//
//  UINoticeViewController.m
//  jerusalemradio
//
//  Created by james on 25/08/2019.
//  Copyright © 2019 JooYoung Kim. All rights reserved.
//

#import "UINoticeViewController.h"

@interface UINoticeViewController () <UIWebViewDelegate>

@property (nonatomic, strong) IBOutlet UIWebView *webView;

@end

@implementation UINoticeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *url = [URLAddressManager getURL:[URLAddressManager getLocal] type:NOTICE];
    
    NSLog(@"%s %@", __FUNCTION__, url);
    //    NSString *url = [NSString stringWithFormat:@"%@?MB_ID=%@&MB_TOKEN=%@&PR_ID=%@",OPEN_BOARD, [CommonUtil readObjectFromDefault:@"USER_ID"], GetCommonData.MB_TOKEN, TEST_PR_ID];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:@"GET"];
    
    [_webView loadRequest:request];
    
    self.headerView.frame = CGRectMake(0, 0, MAIN_SIZE().width, CommonUtil.getSafaAreaTop + 44);
    self.webView.frame = CGRectMake(0, CommonUtil.getSafaAreaTop + 44, MAIN_SIZE().width, MAIN_SIZE().height - (CommonUtil.getSafaAreaTop + 44));
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)close
{
    [self.navigationController popViewControllerAnimated:YES];
}


-(UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

@end
