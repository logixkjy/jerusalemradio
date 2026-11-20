//
//  ModalViewController.m
//  goodnews
//
//  Created by KimJooYoung on 2015. 4. 30..
//  Copyright (c) 2015년 goodnews. All rights reserved.
//

#import "ModalViewController.h"
#import "AppDelegate.h"
#import <WebKit/WebKit.h>
@import AVFoundation;
@import AudioToolbox;

@interface ModalViewController () <WKNavigationDelegate>
{
    float menuViewH;
    WKWebView *_webView;
}
@end

@implementation ModalViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    _webView = [[WKWebView alloc] initWithFrame:self.webContainer.bounds];
    _webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _webView.navigationDelegate = self;
    _webView.scrollView.bounces = NO;
    [self.webContainer addSubview:_webView];
    [self loadMainUrl];
    
    CGFloat y = 0, gap = 0;
    gap = (MAIN_SIZE().width - 30 - (28 * 4)) / 3;
    
    y += 15;
    [_btn_pre setFrame:CGRectMake(y, 8, 28, 28)];
    
    y += 28 + gap;
    
    [_btn_next setFrame:CGRectMake(y, 8, 28, 28)];
    
    y += 28 + gap;
    
    [_btn_more setFrame:CGRectMake(y, 8, 28, 28)];
    
    [_btn_close setFrame:CGRectMake(MAIN_SIZE().width - 15 - 28, 8, 28, 28)];
    
    for (id item in [_webView subviews]) {
        if ([item isKindOfClass:[UIScrollView class]]) {
            [(UIScrollView*)item setBounces:NO];
        }
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    // Remove progress view
    // because UINavigationBar is shared with other ViewControllers
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)loadMainUrl
{
    NSURLRequest *req = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:GetCommonData.PUSH_URL]];
    [_webView loadRequest:req];
}

- (IBAction)goBack {
    if ([_webView canGoBack]) {
        [_webView goBack];
    }
}

- (IBAction)goFoword {
    if ([_webView canGoForward]) {
        [_webView goForward];
    }
}

- (IBAction)close {
    GetCommonData.isShowModalView = NO;
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)more {
    [self.view addSubview:_backView];
}

- (IBAction)cancel {
    [_backView removeFromSuperview];
}


- (BOOL)scriptControl:(NSString*)strUrl {
    NSRange range = [strUrl rangeOfString:MAIN_KEY];
    
    if (![strUrl hasPrefix:MAIN_KEY]) {
        return YES;
    }
    
    if (range.location != NSNotFound) {
        [GetCommonData setPUSH_URL:[strUrl stringByReplacingOccurrencesOfString:MAIN_KEY withString:@"http://"]];
        [GetCommonData setIsShowPUSH_URL:YES];

        [self dismissViewControllerAnimated:YES completion:^{
            ModalViewController *pushUrlView = [self.storyboard instantiateViewControllerWithIdentifier:@"modalView"];
            GetCommonData.isShowModalView = YES;
            
            AppDelegate *delegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
            dispatch_async(dispatch_get_main_queue(), ^{
                [delegate.window.rootViewController presentViewController:pushUrlView animated:YES completion:nil];
            });
        }];
        return NO;
    }
    
    return YES;
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    decisionHandler([self shouldNavigateRequest:navigationAction.request] ? WKNavigationActionPolicyAllow : WKNavigationActionPolicyCancel);
}

- (BOOL)shouldNavigateRequest:(NSURLRequest *)request {
    NSString *strUrl = [[request URL] absoluteString];
    [GetCommonData setCURRENT_URL:strUrl];
    NSLog(@"RequestURL[%@]",strUrl);
    
    if ([self isWebViewCallback:strUrl]) {
//        if ([strUrl containsString:MENU_KEY]) {
//            [self viewMenu];
//            return NO;
//        }
//        
//        if ([strUrl containsString:SHARE_KEY]) {
//            [self.view.window addSubview:_sharePopup];
//            return NO;
//        }
    }
    
    if ([strUrl hasPrefix:MOVE_KEY]) {
        NSURLRequest *req = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:[strUrl stringByReplacingOccurrencesOfString:MOVE_KEY withString:@"http://"]]];
        [_webView loadRequest:req];
        return NO;
    }
    
    if ([strUrl hasPrefix:SAFARI_OPEN]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[strUrl stringByReplacingOccurrencesOfString:SAFARI_OPEN withString:@"http://"]] options:@{} completionHandler:nil];
        return NO;
    }
    
    if (![self scriptControl:strUrl]) {
        return NO;
    }
    
    return YES;
}

- (BOOL)isWebViewCallback:(NSString *)urlString
{
    return ([urlString rangeOfString:@"jscall://" options:NSCaseInsensitiveSearch].location != NSNotFound);
}

#pragma mark -
#pragma mark - UIScrollView Delegate Methods

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale
{
    _webView.scrollView.maximumZoomScale = 20; // set similar to previous.
}

-(UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

@end
