//
//  ViewController.m
//  jerusalemradio
//
//  Created by JooYoung Kim on 2017. 3. 21..
//  Copyright © 2017년 JooYoung Kim. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () <UITableViewDelegate, UITableViewDataSource>
{
    
}

@property (nonatomic) IBOutlet UIView *onAirView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    if (![CommonUtil readBoolFromDefault:@"AUTO_LOGIN"] && ([[CommonUtil readObjectFromDefault:@"USER_ID"] length] > 0)) {
        [GetURLAddressManager sendLogin:[URLAddressManager getURL:[URLAddressManager getLocal] type:LOGIN]
                                    uid:[CommonUtil readObjectFromDefault:@"USER_ID"]
                                    upw:[CommonUtil readObjectFromDefault:@"USER_PW"]
                      CompletionHandler:^(NSDictionary *data, NSError *error) {
                          if ([data[@"status"] intValue] == 200) {
                              GetCommonData.isLogin = YES;
                              GetCommonData.MB_ID = data[@"data"][@"MB_ID"];
                              GetCommonData.MB_NAME = data[@"data"][@"MB_NAME"];
                              GetCommonData.MB_TOKEN = data[@"data"][@"MB_TOKEN"];
                              GetCommonData.MB_TYPE = data[@"data"][@"MB_TYPE"];
                              [self checkSchemes];
                          }
                      }];
    } else {
        [self checkSchemes];
    }
}

- (void)checkSchemes
{
    if (GetCommonData.schemesData != nil) {
        [self onSchemesData:GetCommonData.schemesData];
        GetCommonData.schemesData = nil;
    }
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    if (!IS_3_5_INCH) {
        float w = MAIN_SIZE().width - 106;
        float h = 341 * w / 214;
        
        if ([CommonUtil isiPhoneXScreen]) {
            float y = 44 + 35 + (MAIN_SIZE().height - 79 - 133 - h) / 2;
            self.mainImageView.frame = CGRectMake(CGRectGetMinX(self.mainImageView.frame),
                                                  y,
                                                  w, h);
        } else {
            self.mainImageView.frame = CGRectMake(CGRectGetMinX(self.mainImageView.frame),
                                                  CGRectGetMinY(self.mainImageView.frame),
                                                  w, h);
        }
    }
    
    UIView *vi_menu = [self.view viewWithTag:20001];
    vi_menu.frame = CGRectMake(RESIZE(10), (isiPhoneXScreen() ? 44 : 20) + RESIZE(10), RESIZE(70), RESIZE(70));
    
    UIView *vi_comments = [self.view viewWithTag:20002];
    vi_comments.frame = CGRectMake(MAIN_SIZE().width - RESIZE(80), (isiPhoneXScreen() ? 44 : 20) + RESIZE(10), RESIZE(70), RESIZE(70));
    
    self.bottomView.frame = CGRectMake(0, MAIN_SIZE().height - RESIZE(194) - (isiPhoneXScreen() ? 34 : 0), MAIN_SIZE().width, RESIZE(194) + (isiPhoneXScreen() ? 34 : 0));
    self.vi_progress.frame = CGRectMake(0, 0, MAIN_SIZE().width, RESIZE(40));
//    self.sl_progress.frame = CGRectMake(-3, 0, MAIN_SIZE().width+6, RESIZE(20));
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
            ((CommentsCell*)cell).lbl_notice_name.frame = CGRectMake(RESIZE(33), RESIZE(23), CGRectGetWidth(self.commentsView.frame) - RESIZE(66), RESIZE(38));
    
            ((CommentsCell*)cell).lbl_notice_desc.text = self.commentsList[indexPath.row][@"PR_CO_CONTENT"];
            ((CommentsCell*)cell).lbl_notice_desc.font = [UIFont systemFontOfSize720:28];
            
            CGSize maxSize = CGSizeMake(CGRectGetWidth(self.commentsView.frame) - RESIZE(66), 10000);
            
            CGSize viewSize = CGSizeZero;
            
            NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
            paragraphStyle.lineBreakMode = NSLineBreakByCharWrapping;
            paragraphStyle.alignment = NSTextAlignmentLeft;
            
            NSDictionary *attributes = @{NSFontAttributeName:[UIFont systemFontOfSize720:28], NSParagraphStyleAttributeName: paragraphStyle};
            viewSize = [self.commentsList[indexPath.row][@"PR_CO_CONTENT"] boundingRectWithSize:maxSize options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin
                                                                                     attributes:attributes  context:nil].size;
            
            ((CommentsCell*)cell).lbl_notice_desc.frame = CGRectMake(RESIZE(33), RESIZE(68), CGRectGetWidth(self.commentsView.frame) - RESIZE(66), viewSize.height);
            
            NSDictionary *data = self.commentsList[indexPath.row];
            if ([data[@"MB_ID"] isEqualToString:GetCommonData.MB_ID]) {
                ((CommentsCell*)cell).indexPath = indexPath;
                ((CommentsCell*)cell).btn_delete.hidden = NO;
                ((CommentsCell*)cell).onDeleteAction = ^(NSIndexPath *indexPath) {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"common_noti", @"알림")
                                                                    message:NSLocalizedString(@"Comment_delete_message", @"청취소감을 삭제하시겠습니까?")
                                                                   delegate:self
                                                          cancelButtonTitle:NSLocalizedString(@"common_cancel", @"취소")
                                                          otherButtonTitles:NSLocalizedString(@"common_delete", @"삭제"), nil];
                    alert.tag = indexPath.row;
                    [alert show];
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


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        [GetURLAddressManager deleteComments:[NSString stringWithFormat:[URLAddressManager getURL:[URLAddressManager getLocal] type:COMMENTSDELETE],self.commentsList[alertView.tag][@"PR_CO_ID"]] mbID:GetCommonData.MB_ID CompletionHandler:^(NSDictionary *data, NSError *error) {
            if ([data[@"status"] intValue] == 200) {
                [self getComments];
            }
        }];
    }
}

@end
