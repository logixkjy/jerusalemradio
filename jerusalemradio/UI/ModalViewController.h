//
//  ModalViewController.h
//  goodnews
//
//  Created by KimJooYoung on 2015. 4. 30..
//  Copyright (c) 2015년 goodnews. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ModalViewController.h"
@import MessageUI;

@interface ModalViewController : UIViewController <UIScrollViewDelegate, UIWebViewDelegate> {
    
    UIView *_backView;
    UIView *_menuView;
    
    BOOL isLoadingView;
}
@property (nonatomic, strong) IBOutlet UIWebView *webView;
@property (nonatomic, strong) IBOutlet UIButton *btn_pre;
@property (nonatomic, strong) IBOutlet UIButton *btn_next;
@property (nonatomic, strong) IBOutlet UIButton *btn_more;
@property (nonatomic, strong) IBOutlet UIButton *btn_close;
@property (strong, nonatomic) ModalViewController *modalView;

@property (nonatomic, strong) IBOutlet UIView *headerView;
@property (nonatomic, strong) IBOutlet UIView *bottomView;

@end
