//
//  UIScheduleViewController.m
//  jerusalemradio
//
//  Created by Ja Young Park on 2017. 5. 22..
//  Copyright © 2017년 JooYoung Kim. All rights reserved.
//

#import "UIScheduleViewController.h"
#import <WebKit/WebKit.h>

@interface UIScheduleViewController ()
@property (nonatomic, strong) IBOutlet UIView *webContainer;
@property (nonatomic, strong) WKWebView *webView;
    @property (nonatomic, strong) IBOutlet UILabel *lbl_mainTitle;
@end

@implementation UIScheduleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.webView = [[WKWebView alloc] initWithFrame:self.webContainer.bounds];
    self.webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.webContainer addSubview:self.webView];
    // Do any additional setup after loading the view.NSString *post = [NSString stringWithFormat:@"MB_ID=%@&PR_ID=%@",[CommonUtil readObjectFromDefault:@"USER_ID"],GetCommonData.metadata[@"genre"]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[URLAddressManager getURL:[URLAddressManager getLocal] type:PAIRING]]];
    
    [_webView loadRequest:request];
    
    self.headerView.frame = CGRectMake(0, 0, MAIN_SIZE().width, CommonUtil.getSafaAreaTop + RESIZE(80));
    
    UIView *vi_menu = [self.view viewWithTag:20001];
    vi_menu.frame = CGRectMake(RESIZE(10), (isiPhoneXScreen() ? 44 : 20) + RESIZE(10), RESIZE(70), RESIZE(70));
    
    UIView *vi_comments = [self.view viewWithTag:20002];
    vi_comments.frame = CGRectMake(MAIN_SIZE().width - RESIZE(80), (isiPhoneXScreen() ? 44 : 20) + RESIZE(10), RESIZE(70), RESIZE(70));
    
    self.lbl_mainTitle.frame = CGRectMake(CGRectGetMaxX(vi_menu.frame), (isiPhoneXScreen() ? 44 : 20), MAIN_SIZE().width - RESIZE(20 + 140), RESIZE(80));
    self.lbl_mainTitle.font = [UIFont systemFontOfSize720:30];
    
    self.bottomView.frame = CGRectMake(0, MAIN_SIZE().height - RESIZE(194) - (CommonUtil.getSafaAreaBottom), MAIN_SIZE().width, RESIZE(194) + (CommonUtil.getSafaAreaBottom));
    
    
    self.webContainer.frame = CGRectMake(0, CGRectGetMaxY(self.headerView.frame), MAIN_SIZE().width, MAIN_SIZE().height - CGRectGetHeight(self.headerView.frame) - CGRectGetHeight(self.bottomView.frame));
    
    _lbl_mainTitle.text = NSLocalizedString(@"Pairing_title", @"편성표");
    
    
    self.vi_progress.frame = CGRectMake(0, 0, MAIN_SIZE().width, RESIZE(40));
//    self.sl_progress.frame = CGRectMake(-3, 0, MAIN_SIZE().width+6, RESIZE(10));
    self.lbl_playback_time.frame = CGRectMake(RESIZE(13), 0, RESIZE(300), RESIZE(40));
    self.lbl_playback_time.textColor = UIColor.blackColor;
    self.lbl_playback_time.font = [UIFont systemFontOfSize720:20];
    self.lbl_playback_time.textAlignment = NSTextAlignmentLeft;
    
    self.lbl_duration.frame = CGRectMake(MAIN_SIZE().width - RESIZE(313), 0, RESIZE(300), RESIZE(40));
    self.lbl_duration.textColor = UIColor.blackColor;
    self.lbl_duration.font = [UIFont systemFontOfSize720:20];
    self.lbl_duration.textAlignment = NSTextAlignmentRight;
    
    self.btn_prev.frame = CGRectMake(RESIZE(30), RESIZE(85), RESIZE(64), RESIZE(64));
    self.btn_play.frame = CGRectMake(RESIZE(114), RESIZE(71), RESIZE(94), RESIZE(94));
    self.btn_next.frame = CGRectMake(RESIZE(226), RESIZE(85), RESIZE(64), RESIZE(64));
    
    self.lbl_title.frame = CGRectMake(RESIZE(320), RESIZE(80), RESIZE(390), RESIZE(40));
    self.lbl_title.font = [UIFont systemFontOfSize720:30];
    
    self.lbl_time.frame = CGRectMake(RESIZE(320), RESIZE(126), RESIZE(390), RESIZE(33));
    self.lbl_time.font = [UIFont systemFontOfSize720:23];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark- UITableViewDelegate & DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    if (tableView == self.commentsTableView) {
        static NSString *commmentsCellIdentifier = @"CommentsCell";
        cell = (CommentsCell*)[tableView dequeueReusableCellWithIdentifier:commmentsCellIdentifier];
        if (cell == nil) {
            cell = [[CommentsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:commmentsCellIdentifier];
        }
        @try {
            NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] init];
            [attributedString appendAttributedString:[[NSAttributedString alloc] initWithString:self.commentsList[indexPath.row][@"MB_NAME"]
                                                                                     attributes:@{NSFontAttributeName: [UIFont systemFontOfSize720:30],
                                                                                                  NSForegroundColorAttributeName:UIColorFromRGB(0xB60018)}]];
            [attributedString appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@" %@",[CommonUtil getPassedTime:self.commentsList[indexPath.row][@"PR_CO_REG_DATE"]]]
                                                                                     attributes:@{NSFontAttributeName: [UIFont systemFontOfSize720:20],
                                                                                                  NSForegroundColorAttributeName:UIColorFromRGB(0x939393)}]];
            
            ((CommentsCell*)cell).lbl_notice_name.attributedText = attributedString;
            ((CommentsCell*)cell).lbl_notice_desc.text = self.commentsList[indexPath.row][@"PR_CO_CONTENT"];
            ((CommentsCell*)cell).lbl_notice_desc.font = [UIFont systemFontOfSizeForDpi:10];
            
            CGSize maxSize = CGSizeMake(223, 10000);
            
            CGSize viewSize = CGSizeZero;
            
            NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
            paragraphStyle.lineBreakMode = NSLineBreakByCharWrapping;
            paragraphStyle.alignment = NSTextAlignmentLeft;
            
            NSDictionary *attributes = @{NSFontAttributeName:[UIFont systemFontOfSizeForDpi:10], NSParagraphStyleAttributeName: paragraphStyle};
            viewSize = [self.commentsList[indexPath.row][@"PR_CO_CONTENT"] boundingRectWithSize:maxSize options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin
                                                                                     attributes:attributes  context:nil].size;
            
            ((CommentsCell*)cell).lbl_notice_desc.frame = CGRectMake(CGRectGetMinX(((CommentsCell*)cell).lbl_notice_desc.frame), CGRectGetMinY(((CommentsCell*)cell).lbl_notice_desc.frame), viewSize.width, viewSize.height);
            
            NSDictionary *data = self.commentsList[indexPath.row];
            if ([data[@"MB_ID"] isEqualToString:GetCommonData.MB_ID]) {
                ((CommentsCell*)cell).indexPath = indexPath;
                ((CommentsCell*)cell).btn_delete.hidden = NO;
                ((CommentsCell*)cell).onDeleteAction = ^(NSIndexPath *indexPath) {
                    [self confirmDeleteCommentAtIndexPath:indexPath];
                };
            } else {
                ((CommentsCell*)cell).btn_delete.hidden = YES;
            }
        } @catch (NSException *exception) {
            
        }
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat height = 0.0;
    if (tableView == self.commentsTableView) {
        CGSize maxSize = CGSizeMake(CGRectGetWidth(self.commentsView.frame) - RESIZE(66), 10000);
        
        CGSize viewSize = CGSizeZero;
        
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
        paragraphStyle.lineBreakMode = NSLineBreakByCharWrapping;
        paragraphStyle.alignment = NSTextAlignmentLeft;
        NSDictionary *attributes = @{NSFontAttributeName:[UIFont systemFontOfSize720:28], NSParagraphStyleAttributeName: paragraphStyle};
        viewSize = [self.commentsList[indexPath.row][@"PR_CO_CONTENT"] boundingRectWithSize:maxSize options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin
                                                                                 attributes:attributes  context:nil].size;
        
        height = RESIZE(68) + viewSize.height + RESIZE(20);
    }
    return height;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.commentsTableView) {
        return [self.commentsList count];
    }
    return 0;
}




@end
