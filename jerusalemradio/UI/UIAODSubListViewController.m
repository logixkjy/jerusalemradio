//
//  UIAODSubListViewController.m
//  jerusalemradio
//
//  Created by Ja Young Park on 2017. 6. 25..
//  Copyright © 2017년 JooYoung Kim. All rights reserved.
//

#import "UIAODSubListViewController.h"

@interface UIAODSubListViewController () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, assign) BOOL practicableLoad;
@property (nonatomic, assign) int page;
@property (nonatomic, strong) IBOutlet UILabel *lbl_mainTitle;
@property (nonatomic, strong) IBOutlet UIButton *btn_programShare;

@end

@implementation UIAODSubListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    __weak typeof(self) weakSelf = self;
    
    self.tb_AODSubList.bounces = NO;
    self.tb_AODSubList.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    self.lmg_subImg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, MAIN_SIZE().width, MAIN_SIZE().width)];
    self.lmg_subImg.image = [UIImage imageNamed:@"default_image.png"];
    
    if ([URLAddressManager getLocal] == KR) {
        self.btn_programShare.hidden = NO;
        self.btn_programShare.frame = CGRectMake(MAIN_SIZE().width - RESIZE(140), CGRectGetHeight(self.lmg_subImg.frame) - RESIZE(70), RESIZE(85), RESIZE(86));
        [self.tb_AODSubList addSubview:self.btn_programShare];
    } else {
        self.btn_programShare.hidden = YES;
    }
    
    self.tb_AODSubList.tableHeaderView = self.lmg_subImg;
    self.tb_AODSubList.sectionHeaderHeight = MAIN_SIZE().width;
    
    self.lbl_programName.text = self.PR_NAME;
    
    _page = 0;
    NSString *page = [NSString stringWithFormat:@"%ld",(long)self.page];
//    [self.mainDelegate startAnimatedLodingView];
    [GetURLAddressManager getProgramList:[NSString stringWithFormat:[URLAddressManager getURL:[URLAddressManager getLocal] type:PROGRAMDETAILLIST],self.PR_ID, page] CompletionHandler:^(id data, NSError *error) {
//        [self.mainDelegate stopAnimatedLodingView];
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.arr_programSubList = data[@"CONTENTS"][@"data"];
            @try {
                NSString *str_thumb = [NSString stringWithFormat:[URLAddressManager getURL:[URLAddressManager getLocal] type:MAINIMAGE], data[@"PR_INFO"][@"data"][@"PR_THUMBS"]];
                [weakSelf.lmg_subImg setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:str_thumb]]
                                           placeholderImage:[UIImage imageNamed:@"default_image"]
                                                    success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, UIImage * _Nonnull image) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        weakSelf.lmg_subImg.image = image;
                    });
                } failure:nil];
            } @catch (NSException *exception) {
                weakSelf.lmg_subImg.image = [UIImage imageNamed:@"default_image"];
            }
            
            
            weakSelf.page++;
            weakSelf.practicableLoad = YES;
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.tb_AODSubList reloadData];
            });
        });
    }];
    
//    self.headerView.frame = CGRectMake(0, 0, MAIN_SIZE().width, RESIZE(80) + (isiPhoneXScreen() ? 44 : 20));
    
    UIButton *vi_menu = [self.view viewWithTag:20001];
    vi_menu.frame = CGRectMake(RESIZE(10), (isiPhoneXScreen() ? 44 : 20) + (isiPhoneXScreen() ? RESIZE(35) : RESIZE(10)), RESIZE(70), RESIZE(70));
    [self.tb_AODSubList addSubview:vi_menu];
    
//    UIView *vi_comments = [self.view viewWithTag:20002];
//    vi_comments.frame = CGRectMake(MAIN_SIZE().width - RESIZE(80), (isiPhoneXScreen() ? 44 : 20) + RESIZE(10), RESIZE(70), RESIZE(70));
    
    self.lbl_mainTitle.frame = CGRectMake(CGRectGetMaxX(vi_menu.frame), (isiPhoneXScreen() ? 44 : 20), MAIN_SIZE().width - RESIZE(20 + 140), RESIZE(80));
    self.lbl_mainTitle.font = [UIFont systemFontOfSize720:30];
    
    self.bottomView.frame = CGRectMake(0, MAIN_SIZE().height - RESIZE(194) - (isiPhoneXScreen() ? 34 : 0), MAIN_SIZE().width, RESIZE(194) + (isiPhoneXScreen() ? 34 : 0));
    
    self.tb_AODSubList.frame = CGRectMake(0, 0, MAIN_SIZE().width, MAIN_SIZE().height - CGRectGetHeight(self.bottomView.frame));
    
    _lbl_mainTitle.text = NSLocalizedString(@"Listen_title", @"다시듣기");
    
    
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

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (self.isPlay) {
        [self playAOD];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)requestNextList
{
    __weak typeof(self) weakSelf = self;
    NSString *page = [NSString stringWithFormat:@"%ld",(long)self.page];
    [GetURLAddressManager getProgramList:[NSString stringWithFormat:[URLAddressManager getURL:[URLAddressManager getLocal] type:PROGRAMDETAILLIST], self.PR_ID, page] CompletionHandler:^(id data, NSError *error) {
        if (![(data[@"CONTENTS"][@"data"]) isKindOfClass:[NSNull class]]) {
            weakSelf.arr_programSubList = [weakSelf.arr_programSubList arrayByAddingObjectsFromArray:data[@"CONTENTS"][@"data"]];
            weakSelf.page++;
            weakSelf.practicableLoad = YES;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.tb_AODSubList reloadData];
            });
        } else {
            weakSelf.practicableLoad = NO;
        }
    }];
}

- (IBAction)back
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)shareProgram
{
    NSString *url = [PROGRAM_SHARE_KR stringByAppendingString:self.PR_ID];
    
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:@[[NSURL URLWithString:url]] applicationActivities:nil];
    
    [self.navigationController presentViewController:activityVC animated:YES completion:NULL];
}

- (void)shareContet:(NSString*)CT_NO
{
    NSString *url = [CONTENT_SHARE_KR stringByAppendingString:CT_NO];
    
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:@[[NSURL URLWithString:url]] applicationActivities:nil];
    
    [self.navigationController presentViewController:activityVC animated:YES completion:NULL];
}

- (IBAction)nextTrack
{
    [super nextTrack];
    NSInteger row = [self getRow];
    [self.tb_AODSubList reloadData];
    [self.tb_AODSubList selectRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0] animated:YES scrollPosition:UITableViewScrollPositionMiddle];
}

- (IBAction)prevTrack
{
    [super prevTrack];
    NSInteger row = [self getRow];
    [self.tb_AODSubList reloadData];
    [self.tb_AODSubList selectRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0] animated:YES scrollPosition:UITableViewScrollPositionMiddle];
}

- (NSInteger)getRow{
    NSInteger row = - 1;
    for (int ii = 0; ii < self.arr_programSubList.count; ii++) {
        if ([self.arr_programSubList[ii][@"CT_NO"] isEqualToString:GetCommonData.CT_NO]) {
            row = ii;
        }
    }
    return row;
}

#pragma mark- UITableViewDelegate & DataSource
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    GetCommonData.PR_ID = self.arr_programSubList[indexPath.row][@"PR_ID"];
    GetCommonData.aodData = self.arr_programSubList[indexPath.row];
    GetCommonData.thum = self.lmg_subImg.image;
    [self playAOD];
    [self.tb_AODSubList reloadData];
} 
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
    } else if (tableView == self.tb_AODSubList) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        cell.contentView.backgroundColor = UIColorFromRGBA(0x262631, .95);
        UIView *bgColorView = [[UIView alloc] init];
        bgColorView.backgroundColor = UIColorFromRGB(0x3d3e48);
        [cell setSelectedBackgroundView:bgColorView];
       
        NSString *str_info = @"";
        @try {
            str_info = self.arr_programSubList[indexPath.row][@"CT_NAME"];
        } @catch (NSException *exception) {
            
        }
        NSString *str_host = @"";
        @try {
            if (![self.arr_programSubList[indexPath.row][@"CT_HOST"] isKindOfClass:[NSNull class]] && [self.arr_programSubList[indexPath.row][@"CT_HOST"] length] > 0)
            str_host = [str_host stringByAppendingFormat:NSLocalizedString(@"ListenDetail_item_contents4", @"진행:%@"),self.arr_programSubList[indexPath.row][@"CT_HOST"]];
            
            if (![self.arr_programSubList[indexPath.row][@"CT_PANEL"] isKindOfClass:[NSNull class]] && [self.arr_programSubList[indexPath.row][@"CT_PANEL"] length] > 0)
            str_host = [str_host stringByAppendingFormat:NSLocalizedString(@"ListenDetail_item_contents1", @"%@패널:%@"),str_host.length > 0 ? @", " : @"",self.arr_programSubList[indexPath.row][@"CT_PANEL"]];
            
            if (![self.arr_programSubList[indexPath.row][@"CT_GUEST"] isKindOfClass:[NSNull class]] && [self.arr_programSubList[indexPath.row][@"CT_GUEST"] length] > 0)
            str_host = [str_host stringByAppendingFormat:NSLocalizedString(@"ListenDetail_item_contents5", @"%@게스트:%@"),str_host.length > 0 ? @", " : @"",self.arr_programSubList[indexPath.row][@"CT_GUEST"]];
            
            if (![self.arr_programSubList[indexPath.row][@"CT_SPEAKER"] isKindOfClass:[NSNull class]] && [self.arr_programSubList[indexPath.row][@"CT_SPEAKER"] length] > 0)
            str_host = [str_host stringByAppendingFormat:@"%@",self.arr_programSubList[indexPath.row][@"CT_SPEAKER"]];
        } @catch (NSException *exception) {
            
        }
        
        
        if (str_host.length > 0) {
            str_info = [str_info stringByAppendingFormat:@"(%@)",str_host];
        }
        @try {
            if (![self.arr_programSubList[indexPath.row][@"CT_TOPIC"] isKindOfClass:[NSNull class]] &&[self.arr_programSubList[indexPath.row][@"CT_TOPIC"] length] > 0)
            str_info = [str_info stringByAppendingFormat:NSLocalizedString(@"ListenDetail_item_contents2", @" 주제:%@"),self.arr_programSubList[indexPath.row][@"CT_TOPIC"]];
        } @catch (NSException *exception) {
            
        }
        UILabel *lbl_title = [[UILabel alloc] initWithFrame:CGRectMake(RESIZE(24), RESIZE(30), RESIZE(613), RESIZE(83))];
        lbl_title.text = str_info;
        @try {
            lbl_title.textColor = [self.arr_programSubList[indexPath.row][@"CT_NO"] isEqualToString:GetCommonData.CT_NO] ? UIColorFromRGBA(0xF5AF14, 1) : UIColorFromRGBA(0xFFFFFF, .6);
        } @catch (NSException *exception) {
            
        }
        lbl_title.font = [UIFont systemFontOfSize720:30];
        lbl_title.numberOfLines = 2;
        [cell.contentView addSubview:lbl_title];
        
        
        UILabel *lbl_date = [[UILabel alloc] initWithFrame:CGRectMake(RESIZE(24), RESIZE(115), RESIZE(613), RESIZE(28))];
        @try {
            lbl_date.text = self.arr_programSubList[indexPath.row][@"CT_EVENT_DATE"];
        } @catch (NSException *exception) {
            
        }
        lbl_date.textColor = UIColorFromRGBA(0xFFFFFF, .3);
        lbl_date.font = [UIFont systemFontOfSize720:24];
        [cell.contentView addSubview:lbl_date];
        if ([URLAddressManager getLocal] == KR) {
            UIButton *btn_share = [UIButton buttonWithType:UIButtonTypeCustom];
            btn_share.frame = CGRectMake(MAIN_SIZE().width - 50, (RESIZE(175) - 40) / 2, 40, 40);
            [btn_share setImage:[UIImage imageNamed:@"icon_share.png"] forState:UIControlStateNormal];
            [btn_share setImageEdgeInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
            [btn_share handleControlEvent:UIControlEventTouchUpInside withBlock:^(id sender) {
                [self shareContet:self.arr_programSubList[indexPath.row][@"CT_NO"]];
            }];
            [cell.contentView addSubview:btn_share];
        }
        
        UIImageView *img_line = [[UIImageView alloc] initWithFrame:CGRectMake(0, RESIZE(174), MAIN_SIZE().width, RESIZE(1))];
        img_line.backgroundColor = UIColorFromRGB(0x42424A);
        [cell.contentView addSubview:img_line];
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
    } else if (tableView == self.tb_AODSubList) {
        height = RESIZE(175);
    }
    return height;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.commentsTableView) {
        return [self.commentsList count];
    } else if (tableView == self.tb_AODSubList) {
        return [self.arr_programSubList count];
    }
    return 0;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.tb_AODSubList) {
        if (indexPath.row == [self.arr_programSubList count] - 1 && self.practicableLoad) {
            [self requestNextList];
        }
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        [GetURLAddressManager deleteComments:[NSString stringWithFormat:[URLAddressManager getURL:[URLAddressManager getLocal] type:COMMENTSDELETE],self.commentsList[alertView.tag][@"PR_CO_ID"]]
                                        mbID:GetCommonData.MB_ID CompletionHandler:^(NSDictionary *data, NSError *error) {
            if ([data[@"status"] intValue] == 200) {
                [self getComments];
            }
        }];
    }
}

@end
