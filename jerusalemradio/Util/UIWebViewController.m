//
//  UIWebViewController.m
//  RoadMaster
//
//  Created by KimJooYoung on 2016. 11. 21..
//
//

#import "UIWebViewController.h"
#import <Webkit/WebKit.h>

@interface UIWebViewController ()

@property (nonatomic, strong) WKWebView *webView;

@end

@implementation UIWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.headerView.frame = CGRectMake(0, 0, MAIN_SIZE().width, CommonUtil.getSafaAreaTop + 44);
    
    self.webView = [[WKWebView alloc] init];
    self.webView.frame = CGRectMake(0, CommonUtil.getSafaAreaTop + 44, MAIN_SIZE().width, MAIN_SIZE().height - (CommonUtil.getSafaAreaTop + 44));
    [self.view addSubview:self.webView];
    
    NSString *url = [NSString stringWithFormat:[URLAddressManager getURL:[URLAddressManager getLocal] type:OPENBOARD], [CommonUtil readObjectFromDefault:@"USER_ID"], GetCommonData.MB_TOKEN, GetCommonData.PR_ID];

    NSLog(@"%s %@", __FUNCTION__, url);
//    NSString *url = [NSString stringWithFormat:@"%@?MB_ID=%@&MB_TOKEN=%@&PR_ID=%@",OPEN_BOARD, [CommonUtil readObjectFromDefault:@"USER_ID"], GetCommonData.MB_TOKEN, TEST_PR_ID];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:@"GET"];
    
    [_webView loadRequest:request];
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
