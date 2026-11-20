//
//  UIAODSubListViewController.m
//  jerusalemradio
//
//  Created by Ja Young Park on 2017. 6. 25..
//  Copyright © 2017년 JooYoung Kim. All rights reserved.
//

#import "UIAODSubListViewController.h"
#import "JRBiblePlayback.h"

@interface JRBibleTestamentTabs : UIControl
@property (nonatomic) NSInteger selectedSegmentIndex;
@property (nonatomic, copy) NSArray<UIButton *> *buttons;
@end

@implementation JRBibleTestamentTabs

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (!self) return nil;

    self.backgroundColor = UIColorFromRGB(0x16294E);
    self.layer.cornerRadius = 11;
    self.layer.borderWidth = 1;
    self.layer.borderColor = UIColorFromRGBA(0xFFFFFF, 0.17).CGColor;

    NSMutableArray<UIButton *> *buttons = [NSMutableArray array];
    for (NSString *title in @[@"구약 39권", @"신약 27권"]) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.tag = buttons.count;
        button.layer.cornerRadius = 8;
        button.titleLabel.font = [UIFont boldSystemFontOfSize:14];
        button.titleLabel.adjustsFontSizeToFitWidth = YES;
        [button setTitle:title forState:UIControlStateNormal];
        [button setTitleColor:UIColorFromRGB(0xDBEAFE) forState:UIControlStateNormal];
        [button setTitleColor:UIColorFromRGB(0x142B54) forState:UIControlStateSelected];
        [button addTarget:self action:@selector(selectTab:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button];
        [buttons addObject:button];
    }
    self.buttons = buttons;
    self.selectedSegmentIndex = 0;
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat inset = 4;
    CGFloat tabWidth = MAX(0, (CGRectGetWidth(self.bounds) - 2 * inset) / 2);
    CGFloat tabHeight = MAX(0, CGRectGetHeight(self.bounds) - 2 * inset);
    for (UIButton *button in self.buttons) {
        button.frame = CGRectMake(inset + button.tag * tabWidth, inset, tabWidth, tabHeight);
    }
}

- (void)setSelectedSegmentIndex:(NSInteger)selectedSegmentIndex {
    _selectedSegmentIndex = selectedSegmentIndex;
    for (UIButton *button in self.buttons) {
        button.selected = button.tag == selectedSegmentIndex;
        button.backgroundColor = button.selected ? UIColor.whiteColor : UIColor.clearColor;
        button.accessibilityTraits = UIAccessibilityTraitButton | (button.selected ? UIAccessibilityTraitSelected : 0);
    }
}

- (void)selectTab:(UIButton *)button {
    if (self.selectedSegmentIndex == button.tag) return;
    self.selectedSegmentIndex = button.tag;
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

@end

@interface UIAODSubListViewController () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic) UIView *biblePanel;
@property (nonatomic) CAGradientLayer *biblePanelGradient;
@property (nonatomic) UIView *bibleCover;
@property (nonatomic) UIView *bibleTopBar;
@property (nonatomic) UIButton *bibleBackButton;
@property (nonatomic) JRBibleTestamentTabs *bibleTabs;
@property (nonatomic) UIScrollView *bookGrid;
@property (nonatomic) UILabel *bookBadge;
@property (nonatomic) UIView *bibleComments;
@property (nonatomic) UILabel *resumeLabel;
@property (nonatomic) UIButton *repeatButton;
@property (nonatomic) UIButton *sleepButton;
@property (nonatomic) NSString *selectedBookID;
@property (nonatomic) NSString *loadedBibleBookID;
@property (nonatomic) NSString *displayedPlayingBookID;
@property (nonatomic) NSString *displayedChapterID;
@property (nonatomic) BOOL bibleFallback;
@property (nonatomic) NSUInteger bookRequest;
@property (nonatomic, assign) BOOL practicableLoad;
@property (nonatomic, assign) int page;
@property (nonatomic, strong) IBOutlet UILabel *lbl_mainTitle;
@property (nonatomic, strong) IBOutlet UIButton *btn_programShare;
@property (nonatomic) UIView *groupPanel;
@property (nonatomic) CAGradientLayer *groupPanelGradient;
@property (nonatomic) UIView *groupTopBar;
@property (nonatomic) UIButton *groupBackButton;
@property (nonatomic) UIView *groupComments;
@property (nonatomic) UIView *standardTopBar;
@property (nonatomic) UIButton *standardBackButton;
@property (nonatomic) UIView *standardComments;
@property (nonatomic) UIScrollView *groupGrid;
@property (nonatomic) UILabel *groupHint;
@property (nonatomic) UILabel *groupBadge;
@property (nonatomic, copy) NSArray<NSDictionary *> *programGroups;
@property (nonatomic) NSString *selectedGroupID;
@property (nonatomic) NSUInteger groupRequest;
@property (nonatomic, copy) NSString *programGroupType;

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
        self.btn_programShare.frame = CGRectMake(0, 0, 44, 44);
        UIImage *shareIcon = [[UIImage imageNamed:@"icon_share.png"] imageByPreparingThumbnailOfSize:CGSizeMake(20, 20)];
        [self.btn_programShare setImage:[shareIcon imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        self.btn_programShare.tintColor = UIColor.whiteColor;
        self.btn_programShare.backgroundColor = UIColor.clearColor;
        self.btn_programShare.accessibilityLabel = NSLocalizedString(@"공유하기", nil);
    } else {
        self.btn_programShare.hidden = YES;
    }
    
    self.tb_AODSubList.tableHeaderView = self.lmg_subImg;
    self.tb_AODSubList.sectionHeaderHeight = MAIN_SIZE().width;
    
    self.lbl_programName.text = self.PR_NAME;
    
    _page = 0;
    NSString *page = [NSString stringWithFormat:@"%ld",(long)self.page];
//    [self.mainDelegate startAnimatedLodingView];
    if ([self.PR_ID isEqualToString:@"002005"]) {
        [self setupBible];
    } else if ([self usesProgramGroups]) {
        [self setupProgramGroups];
    } else {
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
    }
    
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
    if (self.biblePanel) {
        CGFloat edge = MAIN_SIZE().width - 48;
        self.repeatButton.frame = CGRectMake(edge, CGRectGetMinY(self.btn_next.frame), 40, 40);
        CGRect titleFrame = self.lbl_title.frame; titleFrame.size.width = MAX(0, edge - titleFrame.origin.x - 8); self.lbl_title.frame = titleFrame;
        CGRect timeFrame = self.lbl_time.frame; timeFrame.size.width = titleFrame.size.width; self.lbl_time.frame = timeFrame;
        self.lbl_title.adjustsFontSizeToFitWidth = YES;
        self.bibleTopBar = [UIView new]; self.bibleTopBar.backgroundColor = UIColorFromRGB(0x1B3668); [self.view addSubview:self.bibleTopBar];
        self.bibleBackButton = vi_menu; [self.view addSubview:vi_menu];
        if (!self.lbl_mainTitle) self.lbl_mainTitle = [UILabel new];
        self.lbl_mainTitle.text = self.PR_NAME ?: @"성경낭독"; self.lbl_mainTitle.textColor = UIColor.whiteColor;
        self.lbl_mainTitle.font = [UIFont boldSystemFontOfSize:17]; self.lbl_mainTitle.hidden = NO;
        [self.view addSubview:self.lbl_mainTitle];
        self.bibleComments = [self.view viewWithTag:20002];
        if (self.bibleComments) [self.view addSubview:self.bibleComments];
        [self.view addSubview:self.btn_programShare];
        self.repeatButton.layer.cornerRadius = 20; self.repeatButton.layer.borderWidth = 1;
        self.repeatButton.layer.borderColor = UIColorFromRGB(0xDCA743).CGColor;
        self.repeatButton.backgroundColor = UIColorFromRGBA(0xFFD460, 0.15);
        [self.view bringSubviewToFront:self.sleepButton];
    }
    if (self.groupPanel) {
        self.groupTopBar = [UIView new];
        self.groupTopBar.backgroundColor = UIColorFromRGB(0x1B3668);
        [self.view addSubview:self.groupTopBar];
        self.groupBackButton = vi_menu;
        [self.view addSubview:vi_menu];
        if (!self.lbl_mainTitle) self.lbl_mainTitle = [UILabel new];
        self.lbl_mainTitle.text = self.PR_NAME ?: @"다시듣기";
        self.lbl_mainTitle.textColor = UIColor.whiteColor;
        self.lbl_mainTitle.font = [UIFont boldSystemFontOfSize:17];
        self.lbl_mainTitle.hidden = NO;
        [self.view addSubview:self.lbl_mainTitle];
        self.groupComments = [self.view viewWithTag:20002];
        if (self.groupComments) self.groupComments.hidden = YES;
        [self.view addSubview:self.btn_programShare];
        [self.view bringSubviewToFront:self.groupBackButton];
        [self.view bringSubviewToFront:self.lbl_mainTitle];
        [self.view bringSubviewToFront:self.btn_programShare];
    }
    if (!self.biblePanel && !self.groupPanel) {
        self.standardTopBar = [UIView new];
        self.standardTopBar.backgroundColor = UIColorFromRGB(0x1B3668);
        [self.view addSubview:self.standardTopBar];
        self.standardBackButton = vi_menu;
        [self.view addSubview:vi_menu];
        if (!self.lbl_mainTitle) self.lbl_mainTitle = [UILabel new];
        NSString *programName = [self.PR_NAME isKindOfClass:NSString.class] ? [self.PR_NAME stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet] : nil;
        self.lbl_mainTitle.text = programName.length ? programName : NSLocalizedString(@"Listen_title", @"다시듣기");
        self.lbl_mainTitle.textColor = UIColor.whiteColor;
        self.lbl_mainTitle.font = [UIFont boldSystemFontOfSize:17];
        self.lbl_mainTitle.hidden = NO;
        [self.view addSubview:self.lbl_mainTitle];
        self.standardComments = [self.view viewWithTag:20002];
        if (self.standardComments) self.standardComments.hidden = YES;
        [self.view addSubview:self.btn_programShare];
        [self.view bringSubviewToFront:self.standardBackButton];
        [self.view bringSubviewToFront:self.lbl_mainTitle];
        [self.view bringSubviewToFront:self.btn_programShare];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (self.isPlay && ![self.PR_ID isEqualToString:@"002005"]) {
        [self playAOD];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)requestNextList
{
    if ([self.PR_ID isEqualToString:@"002005"] && !self.bibleFallback) return;
    if ([self usesProgramGroups]) return;
    self.practicableLoad = NO;
    __weak typeof(self) weakSelf = self;
    NSString *page = [NSString stringWithFormat:@"%ld",(long)self.page];
    [GetURLAddressManager getProgramList:[NSString stringWithFormat:[URLAddressManager getURL:[URLAddressManager getLocal] type:PROGRAMDETAILLIST], self.PR_ID, page] CompletionHandler:^(id data, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSArray *items = [data isKindOfClass:NSDictionary.class] && [data[@"CONTENTS"] isKindOfClass:NSDictionary.class] ? data[@"CONTENTS"][@"data"] : nil;
            if (!error && [items isKindOfClass:NSArray.class] && items.count) {
                weakSelf.arr_programSubList = [(weakSelf.arr_programSubList ?: @[]) arrayByAddingObjectsFromArray:items];
                weakSelf.page++;
                NSDictionary *pagination = data[@"PAGENATION"];
                weakSelf.practicableLoad = [pagination isKindOfClass:NSDictionary.class] && weakSelf.page <= [pagination[@"total"] integerValue];
                [weakSelf.tb_AODSubList reloadData];
            } else weakSelf.practicableLoad = NO;
        });
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
    if ([JRBiblePlayback shared].active) { [super nextTrack]; return; }
    [super nextTrack];
    NSInteger row = [self getRow];
    [self.tb_AODSubList reloadData];
    if (row >= 0) [self.tb_AODSubList selectRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0] animated:YES scrollPosition:UITableViewScrollPositionMiddle];
}

- (IBAction)prevTrack
{
    if ([JRBiblePlayback shared].active) { [super prevTrack]; return; }
    [super prevTrack];
    NSInteger row = [self getRow];
    [self.tb_AODSubList reloadData];
    if (row >= 0) [self.tb_AODSubList selectRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0] animated:YES scrollPosition:UITableViewScrollPositionMiddle];
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
    if (tableView != self.tb_AODSubList) return;
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if ([self.PR_ID isEqualToString:@"002005"] && !self.bibleFallback) {
        GetCommonData.thum = self.lmg_subImg.image;
        [[JRBiblePlayback shared] playItem:self.arr_programSubList[indexPath.row] bookID:self.selectedBookID items:self.arr_programSubList position:0];
        return;
    }
    GetCommonData.PR_ID = self.arr_programSubList[indexPath.row][@"PR_ID"];
    GetCommonData.aodData = self.arr_programSubList[indexPath.row];
    GetCommonData.playingAODGroupItems = [self usesProgramGroups] ? self.arr_programSubList : nil;
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
                    [self confirmDeleteCommentAtIndexPath:indexPath];
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
            // Configured buttons keep a bitmap's intrinsic size even with content insets.
            // Fit the artwork explicitly while preserving the 40pt touch target.
            UIImage *shareImage = [[UIImage imageNamed:@"icon_share.png"] imageByPreparingThumbnailOfSize:CGSizeMake(20, 20)];
            [btn_share setImage:shareImage forState:UIControlStateNormal];
            [btn_share applyContentInsets:UIEdgeInsetsMake(10, 10, 10, 10) imagePadding:0];
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
        return self.arr_programSubList.count;
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

- (BOOL)usesProgramGroups {
    return [UIBaseViewController usesAODGroupsForProgramID:self.PR_ID];
}

- (NSString *)programGroupsURL {
    NSString *baseURL = [URLAddressManager getLocal] == ES ? BASE_URL_ES : ([URLAddressManager getLocal] == PT ? BASE_URL_PT : BASE_URL_KR);
    return [NSString stringWithFormat:@"%@/api/program/getBibleBooks/PR_ID/%@", baseURL, self.PR_ID];
}

- (NSString *)programGroupHint {
    return [self.programGroupType isEqualToString:@"season"] ? @"시즌을 선택하시면 순서대로 들을 수 있어요" : @"권을 선택하시면 첫 강의부터 들을 수 있어요";
}

- (CGFloat)programGroupContentHeight {
    NSUInteger rows = (self.programGroups.count + 1) / 2;
    return rows > 0 ? rows * 60 - 10 : 0;
}

- (CGFloat)programGroupGridHeight {
    return MIN([self programGroupContentHeight], 3 * 60 + 14);
}

- (void)setupProgramGroups {
    self.tb_AODSubList.showsVerticalScrollIndicator = NO;
    self.tb_AODSubList.sectionHeaderTopPadding = 0;
    self.tb_AODSubList.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    if (@available(iOS 26.0, *)) {
        self.tb_AODSubList.topEdgeEffect.hidden = YES;
        self.tb_AODSubList.bottomEdgeEffect.hidden = YES;
    }

    CGFloat width = self.view.bounds.size.width;
    self.groupPanel = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, 0)];
    self.groupPanel.backgroundColor = UIColorFromRGB(0x1B3668);
    CAGradientLayer *gradient = [CAGradientLayer layer];
    self.groupPanelGradient = gradient;
    gradient.colors = @[(id)UIColorFromRGB(0x1B3668).CGColor, (id)UIColorFromRGB(0x285094).CGColor, (id)UIColorFromRGB(0x162B54).CGColor];
    gradient.startPoint = CGPointMake(0, 0); gradient.endPoint = CGPointMake(0.25, 1);
    gradient.frame = self.groupPanel.bounds;
    [self.groupPanel.layer insertSublayer:gradient atIndex:0];

    self.groupHint = [UILabel new];
    self.groupHint.text = @"목록을 불러오는 중입니다";
    self.groupHint.font = [UIFont boldSystemFontOfSize:13];
    self.groupHint.textColor = UIColorFromRGB(0xDBEAFE);
    [self.groupPanel addSubview:self.groupHint];
    self.groupBadge = [UILabel new];
    self.groupBadge.textAlignment = NSTextAlignmentRight;
    self.groupBadge.font = [UIFont boldSystemFontOfSize:12];
    self.groupBadge.textColor = UIColorFromRGB(0xFFE082);
    self.groupBadge.textAlignment = NSTextAlignmentCenter;
    self.groupBadge.backgroundColor = UIColorFromRGBA(0xFFE082, 0.14);
    self.groupBadge.layer.cornerRadius = 12;
    self.groupBadge.layer.borderWidth = 1;
    self.groupBadge.layer.borderColor = UIColorFromRGB(0xD5AC42).CGColor;
    self.groupBadge.clipsToBounds = YES;
    [self.groupPanel addSubview:self.groupBadge];
    self.groupGrid = [UIScrollView new];
    self.groupGrid.showsVerticalScrollIndicator = NO;
    self.groupGrid.bounces = NO;
    self.groupGrid.scrollEnabled = NO;
    self.groupGrid.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    self.groupGrid.clipsToBounds = YES;
    self.groupGrid.directionalLockEnabled = YES;
    if (@available(iOS 26.0, *)) {
        self.groupGrid.topEdgeEffect.hidden = YES;
        self.groupGrid.bottomEdgeEffect.hidden = YES;
    }
    [self.groupPanel addSubview:self.groupGrid];
    [self loadProgramGroups];
}

- (void)loadProgramGroups {
    __weak typeof(self) weakSelf = self;
    [GetURLAddressManager getProgramList:[self programGroupsURL] CompletionHandler:^(id data, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSArray *groups = [data isKindOfClass:NSDictionary.class] ? data[@"data"] : nil;
            NSString *type = [data isKindOfClass:NSDictionary.class] ? data[@"type"] : nil;
            if (error || ![groups isKindOfClass:NSArray.class] || !groups.count || ![type isKindOfClass:NSString.class]) {
                weakSelf.groupHint.text = @"권/시즌 목록을 불러오지 못했습니다";
                weakSelf.tb_AODSubList.backgroundView = [weakSelf groupedEmptyView:@"목록을 다시 열어 주세요."];
                return;
            }
            weakSelf.programGroupType = type;
            weakSelf.programGroups = groups;
            weakSelf.groupHint.text = [weakSelf programGroupHint];
            [weakSelf renderProgramGroups];
            [weakSelf.view setNeedsLayout];
            [weakSelf.view layoutIfNeeded];
            NSDictionary *first = [groups filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(NSDictionary *group, NSDictionary *bindings) {
                return [group[@"count"] integerValue] > 0;
            }]].firstObject ?: groups.firstObject;
            [weakSelf selectProgramGroup:first[@"BB_ID"]];
        });
    }];
}

- (UILabel *)groupedEmptyView:(NSString *)message {
    UILabel *label = [UILabel new];
    label.text = message; label.textColor = UIColor.whiteColor; label.textAlignment = NSTextAlignmentCenter;
    label.numberOfLines = 2; return label;
}

- (void)renderProgramGroups {
    for (UIView *view in self.groupGrid.subviews) [view removeFromSuperview];
    CGFloat width = floor((self.view.bounds.size.width - 34) / 2);
    NSInteger index = 0;
    for (NSDictionary *group in self.programGroups) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake((index % 2) * (width + 10), (index / 2) * 60, width, 50);
        button.accessibilityIdentifier = group[@"BB_ID"];
        NSString *range = [group[@"range"] isKindOfClass:NSString.class] ? group[@"range"] : @"";
        [button setTitle:[NSString stringWithFormat:@"%@%@%@", group[@"name"] ?: @"", range.length ? @"\n" : @"", range] forState:UIControlStateNormal];
        button.titleLabel.numberOfLines = 2; button.titleLabel.textAlignment = NSTextAlignmentCenter;
        button.titleLabel.font = [UIFont boldSystemFontOfSize:14];
        button.titleLabel.adjustsFontSizeToFitWidth = YES; button.titleLabel.minimumScaleFactor = 0.75;
        button.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        BOOL selected = [group[@"BB_ID"] isEqual:self.selectedGroupID];
        [button setTitleColor:selected ? UIColorFromRGB(0x101827) : UIColor.whiteColor forState:UIControlStateNormal];
        button.backgroundColor = selected ? UIColorFromRGB(0xFFC43D) : UIColorFromRGBA(0xDCEAFF, 0.24);
        button.layer.cornerRadius = 12; button.layer.borderWidth = 1;
        button.layer.borderColor = (selected ? UIColorFromRGB(0xFFE79E) : UIColorFromRGBA(0xBBD2F4, 0.48)).CGColor;
        button.alpha = [group[@"count"] integerValue] == 0 ? 0.4 : 1;
        button.accessibilityTraits = UIAccessibilityTraitButton | (selected ? UIAccessibilityTraitSelected : 0);
        [button addTarget:self action:@selector(selectProgramGroupButton:) forControlEvents:UIControlEventTouchUpInside];
        [self.groupGrid addSubview:button]; index++;
    }
    self.groupGrid.contentSize = CGSizeMake(0, [self programGroupContentHeight]);
}

- (void)selectProgramGroupButton:(UIButton *)button {
    [self selectProgramGroup:button.accessibilityIdentifier];
}

- (void)selectProgramGroup:(NSString *)groupID {
    NSDictionary *group = [self.programGroups filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(NSDictionary *candidate, NSDictionary *bindings) {
        return [candidate[@"BB_ID"] isEqual:groupID];
    }]].firstObject;
    if (!groupID.length || !group || [group[@"count"] integerValue] == 0) {
        [self.view makeToast:@"준비 중입니다"]; return;
    }
    self.selectedGroupID = groupID;
    self.groupBadge.text = [NSString stringWithFormat:@"%@ · %@", group[@"name"] ?: @"", group[@"range"] ?: @""];
    [self renderProgramGroups];
    self.groupRequest++;
    NSUInteger request = self.groupRequest;
    self.practicableLoad = NO;
    self.arr_programSubList = @[];
    [self.tb_AODSubList reloadData];
    self.tb_AODSubList.backgroundView = [self groupedEmptyView:[NSString stringWithFormat:@"%@ 불러오는 중…", group[@"name"] ?: @""]];
    NSString *baseURL = [URLAddressManager getLocal] == ES ? BASE_URL_ES : ([URLAddressManager getLocal] == PT ? BASE_URL_PT : BASE_URL_KR);
    NSString *url = [NSString stringWithFormat:@"%@/api/program/view/PR_ID/%@/BB_ID/%@/oType/asc/limit/200", baseURL, self.PR_ID, groupID];
    __weak typeof(self) weakSelf = self;
    [GetURLAddressManager getProgramList:url CompletionHandler:^(id data, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (request != weakSelf.groupRequest) return;
            NSArray *items = [data isKindOfClass:NSDictionary.class] && [data[@"CONTENTS"] isKindOfClass:NSDictionary.class] ? data[@"CONTENTS"][@"data"] : nil;
            if (error || ![items isKindOfClass:NSArray.class]) {
                weakSelf.tb_AODSubList.backgroundView = [weakSelf groupedEmptyView:@"회차 목록을 불러오지 못했습니다."];
                return;
            }
            weakSelf.arr_programSubList = items;
            NSDictionary *info = [data[@"PR_INFO"] isKindOfClass:NSDictionary.class] ? data[@"PR_INFO"][@"data"] : nil;
            NSString *thumbnail = info[@"PR_THUMBS"];
            if ([thumbnail isKindOfClass:NSString.class]) {
                NSURL *imageURL = [NSURL URLWithString:[NSString stringWithFormat:[URLAddressManager getURL:[URLAddressManager getLocal] type:MAINIMAGE], thumbnail]];
                [weakSelf.lmg_subImg setImageWithURL:imageURL placeholderImage:[UIImage imageNamed:@"default_image"]];
            }
            weakSelf.tb_AODSubList.backgroundView = items.count ? nil : [weakSelf groupedEmptyView:[NSString stringWithFormat:@"이 %@에 지정된 회차가 없습니다.", [weakSelf.programGroupType isEqualToString:@"season"] ? @"시즌" : @"권"]];
            [weakSelf.tb_AODSubList reloadData];
            [weakSelf.tb_AODSubList setContentOffset:CGPointMake(0, MIN(MAX(0, weakSelf.tb_AODSubList.contentOffset.y), weakSelf.lmg_subImg.bounds.size.height)) animated:NO];
        });
    }];
}

- (void)setupBible {
    self.tb_AODSubList.showsVerticalScrollIndicator = NO;
    self.tb_AODSubList.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    self.tb_AODSubList.sectionHeaderTopPadding = 0;
    // The panel and player already have opaque backgrounds. System edge blur
    // must not extend across the chapter rows when the section header pins.
    if (@available(iOS 26.0, *)) {
        self.tb_AODSubList.topEdgeEffect.hidden = YES;
        self.tb_AODSubList.bottomEdgeEffect.hidden = YES;
    }
    self.selectedBookID = [JRBiblePlayback shared].active ? [JRBiblePlayback shared].playingBookID : ([JRBiblePlayback shared].resumeRecord[@"BB_ID"] ?: @"01");
    CGFloat width = self.view.bounds.size.width;
    self.bibleCover = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, width)];
    self.tb_AODSubList.tableHeaderView = nil;
    self.lmg_subImg.frame = self.bibleCover.bounds;
    self.lmg_subImg.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.lmg_subImg.contentMode = UIViewContentModeScaleAspectFill;
    self.lmg_subImg.clipsToBounds = YES;
    [self.bibleCover addSubview:self.lmg_subImg];
    self.tb_AODSubList.tableHeaderView = self.bibleCover;
    self.biblePanel = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, 240)];
    self.biblePanel.backgroundColor = UIColorFromRGB(0x1B3668);
    CAGradientLayer *gradient = [CAGradientLayer layer];
    self.biblePanelGradient = gradient;
    gradient.colors = @[(id)UIColorFromRGB(0x1B3668).CGColor, (id)UIColorFromRGB(0x285094).CGColor, (id)UIColorFromRGB(0x162B54).CGColor];
    gradient.startPoint = CGPointMake(0, 0); gradient.endPoint = CGPointMake(0.25, 1);
    [self.biblePanel.layer insertSublayer:gradient atIndex:0];
    self.bibleTabs = [[JRBibleTestamentTabs alloc] initWithFrame:CGRectZero];
    self.bibleTabs.selectedSegmentIndex = self.selectedBookID.integerValue < 40 ? 0 : 1;
    [self.bibleTabs addTarget:self action:@selector(changeBibleTestament) forControlEvents:UIControlEventValueChanged];
    [self.biblePanel addSubview:self.bibleTabs];
    self.bookBadge = [UILabel new]; self.bookBadge.textColor = UIColorFromRGB(0xFFE082);
    self.bookBadge.font = [UIFont boldSystemFontOfSize:12]; self.bookBadge.textAlignment = NSTextAlignmentCenter;
    self.bookBadge.backgroundColor = UIColorFromRGBA(0xFFE082, 0.16);
    self.bookBadge.layer.cornerRadius = 9;
    self.bookBadge.layer.borderWidth = 1;
    self.bookBadge.layer.borderColor = UIColorFromRGB(0xD5AC42).CGColor;
    self.bookBadge.clipsToBounds = YES;
    self.bookBadge.adjustsFontSizeToFitWidth = YES; [self.biblePanel addSubview:self.bookBadge];
    self.bookGrid = [UIScrollView new]; self.bookGrid.showsVerticalScrollIndicator = NO;
    self.bookGrid.bounces = NO; self.bookGrid.directionalLockEnabled = YES;
    if (@available(iOS 26.0, *)) {
        self.bookGrid.topEdgeEffect.hidden = YES;
        self.bookGrid.bottomEdgeEffect.hidden = YES;
    }
    [self.biblePanel addSubview:self.bookGrid];
    self.resumeLabel = [UILabel new]; self.resumeLabel.textColor = UIColorFromRGB(0x86601A);
    self.resumeLabel.font = [UIFont systemFontOfSize:11]; self.resumeLabel.adjustsFontSizeToFitWidth = YES;
    [self.bottomView addSubview:self.resumeLabel];
    self.repeatButton = [UIButton buttonWithType:UIButtonTypeSystem]; self.repeatButton.tintColor = UIColorFromRGB(0xFFD460);
    [self.repeatButton addTarget:self action:@selector(cycleRepeat) forControlEvents:UIControlEventTouchUpInside]; [self.bottomView addSubview:self.repeatButton];
    self.sleepButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.sleepButton.tintColor = UIColor.whiteColor; self.sleepButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentTrailing;
    UIButtonConfiguration *timerConfiguration = UIButtonConfiguration.plainButtonConfiguration;
    timerConfiguration.image = [UIImage systemImageNamed:@"clock"]; timerConfiguration.imagePadding = 6;
    timerConfiguration.contentInsets = NSDirectionalEdgeInsetsZero; timerConfiguration.baseForegroundColor = UIColor.whiteColor;
    timerConfiguration.titleTextAttributesTransformer = ^NSDictionary<NSAttributedStringKey,id> *(NSDictionary<NSAttributedStringKey,id> *incoming) {
        NSMutableDictionary *attributes = incoming.mutableCopy; attributes[NSFontAttributeName] = [UIFont systemFontOfSize:12]; return attributes;
    };
    self.sleepButton.configuration = timerConfiguration;
    [self.sleepButton addTarget:self action:@selector(cycleSleep) forControlEvents:UIControlEventTouchUpInside]; [self.view addSubview:self.sleepButton];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(biblePlaybackChanged) name:JRBiblePlaybackChanged object:nil];
    [self updateBibleControls];
    __weak typeof(self) weakSelf = self;
    [[JRBiblePlayback shared] loadBooks:^(BOOL success) {
        if (!success) { [weakSelf loadBibleFallback]; return; }
        [weakSelf showSelectedBibleBook];
        [weakSelf selectBibleBook:weakSelf.selectedBookID];
    }];
}
- (void)showSelectedBibleBook {
    for (NSDictionary *book in [JRBiblePlayback shared].books) {
        if ([book[@"BB_ID"] isEqual:self.selectedBookID]) {
            self.bibleTabs.selectedSegmentIndex = [book[@"testament"] isEqual:@"NT"] ? 1 : 0;
            break;
        }
    }
    [self renderBooks];
    [self.view layoutIfNeeded];
    for (UIView *button in self.bookGrid.subviews) {
        if ([button.accessibilityIdentifier isEqual:self.selectedBookID]) {
            [self.bookGrid scrollRectToVisible:button.frame animated:NO];
            break;
        }
    }
}
- (void)renderBooks {
    for (UIView *view in self.bookGrid.subviews) [view removeFromSuperview];
    NSString *testament = self.bibleTabs.selectedSegmentIndex == 0 ? @"OT" : @"NT";
    CGFloat width = floor((self.view.bounds.size.width - 44) / 3);
    NSInteger index = 0;
    for (NSDictionary *book in [JRBiblePlayback shared].books) {
        if ([book[@"BB_ID"] isEqual:self.selectedBookID]) self.bookBadge.text = [NSString stringWithFormat:@"%@ · %@%@", book[@"name"], book[@"chapters"], book[@"unit"] ?: @"장"];
        if (![book[@"testament"] isEqual:testament]) continue;
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake((index % 3) * (width + 10), (index / 3) * 54, width, 43);
        button.accessibilityIdentifier = book[@"BB_ID"];
        [button setTitle:book[@"name"] forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont boldSystemFontOfSize:[book[@"name"] length] >= 6 ? 12.5 : 14.5];
        button.titleLabel.adjustsFontSizeToFitWidth = YES;
        BOOL selected = [book[@"BB_ID"] isEqual:self.selectedBookID];
        [button setTitleColor:selected ? UIColorFromRGB(0x141923) : UIColor.whiteColor forState:UIControlStateNormal];
        button.backgroundColor = UIColorFromRGBA(0xFFFFFF, 0.16);
        button.layer.cornerRadius = 12; button.clipsToBounds = YES; button.layer.borderWidth = 1;
        button.layer.borderColor = (selected ? UIColorFromRGB(0xFFE79E) : UIColorFromRGBA(0xFFFFFF, 0.28)).CGColor;
        if (selected) {
            CAGradientLayer *gold = [CAGradientLayer layer]; gold.frame = button.bounds;
            gold.colors = @[(id)UIColorFromRGB(0xFFD460).CGColor, (id)UIColorFromRGB(0xF5A618).CGColor];
            [button.layer insertSublayer:gold atIndex:0]; button.accessibilityTraits |= UIAccessibilityTraitSelected;
        }
        button.alpha = [book[@"count"] integerValue] == 0 ? 0.4 : 1;
        [button addTarget:self action:@selector(selectBibleBookButton:) forControlEvents:UIControlEventTouchUpInside];
        [self.bookGrid addSubview:button]; index++;
    }
    self.bookGrid.contentSize = CGSizeMake(0, ((index + 2) / 3) * 54);
}
- (void)changeBibleTestament {
    [self renderBooks]; [self.bookGrid setContentOffset:CGPointZero animated:NO];
}
- (void)selectBibleBookButton:(UIButton *)button {
    for (NSDictionary *book in [JRBiblePlayback shared].books) {
        if ([book[@"BB_ID"] isEqual:button.accessibilityIdentifier] && [book[@"count"] integerValue] == 0) {
            [self.view makeToast:@"준비 중입니다"]; return;
        }
    }
    [self selectBibleBook:button.accessibilityIdentifier];
}
- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    if (!self.biblePanel && !self.groupPanel && self.standardTopBar) {
        CGFloat width = self.view.bounds.size.width;
        CGFloat safeTop = MAX(self.view.safeAreaInsets.top, CommonUtil.getSafaAreaTop);
        CGFloat top = safeTop + 44;
        self.standardTopBar.frame = CGRectMake(0, 0, width, top);
        self.standardBackButton.frame = CGRectMake(8, safeTop, 44, 44);
        self.btn_programShare.frame = CGRectMake(width - 56, safeTop, 44, 44);
        self.lbl_mainTitle.frame = CGRectMake(60, safeTop, MAX(0, width - 128), 44);
        self.tb_AODSubList.frame = CGRectMake(0, top, width, MAX(0, CGRectGetMinY(self.bottomView.frame) - top));
        [self.view bringSubviewToFront:self.standardTopBar];
        [self.view bringSubviewToFront:self.standardBackButton];
        [self.view bringSubviewToFront:self.lbl_mainTitle];
        [self.view bringSubviewToFront:self.btn_programShare];
        return;
    }
    if (self.groupPanel) {
        CGFloat width = self.view.bounds.size.width;
        CGFloat safeTop = MAX(self.view.safeAreaInsets.top, CommonUtil.getSafaAreaTop);
        CGFloat top = safeTop + 44;
        self.groupTopBar.frame = CGRectMake(0, 0, width, top);
        self.groupBackButton.frame = CGRectMake(8, safeTop, 44, 44);
        self.btn_programShare.frame = CGRectMake(width - 56, safeTop, 44, 44);
        self.lbl_mainTitle.frame = CGRectMake(60, safeTop, MAX(0, width - 128), 44);
        self.tb_AODSubList.frame = CGRectMake(0, top, width, MAX(0, CGRectGetMinY(self.bottomView.frame) - top));
        CGFloat gridHeight = [self programGroupGridHeight];
        CGFloat panelHeight = 52 + gridHeight + 8;
        CGRect groupFrame = self.groupPanel.frame;
        groupFrame.size = CGSizeMake(width, panelHeight);
        self.groupPanel.frame = groupFrame;
        self.groupPanelGradient.frame = self.groupPanel.bounds;
        self.groupHint.frame = CGRectMake(14, 10, width - 168, 42);
        self.groupBadge.frame = CGRectMake(width - 150, 8, 136, 38);
        self.groupGrid.frame = CGRectMake(12, 52, width - 24, gridHeight);
        self.groupGrid.scrollEnabled = self.groupGrid.contentSize.height > CGRectGetHeight(self.groupGrid.bounds);
        if (!self.groupGrid.scrollEnabled && self.groupGrid.contentOffset.y != 0) {
            self.groupGrid.contentOffset = CGPointZero;
        }
        [self.view bringSubviewToFront:self.groupTopBar];
        [self.view bringSubviewToFront:self.groupBackButton];
        [self.view bringSubviewToFront:self.lbl_mainTitle];
        [self.view bringSubviewToFront:self.btn_programShare];
        return;
    }
    if (!self.biblePanel) return;
    CGFloat width = self.view.bounds.size.width;
    CGFloat safeTop = MAX(self.view.safeAreaInsets.top, CommonUtil.getSafaAreaTop);
    CGFloat top = safeTop + 44;
    CGFloat timerWidth = [JRBiblePlayback shared].sleepMode ? 110 : 44;
    self.bibleTopBar.frame = CGRectMake(0, 0, width, top);
    self.bibleBackButton.frame = CGRectMake(8, safeTop, 44, 44);
    self.btn_programShare.frame = CGRectMake(width - 56, safeTop, 44, 44);
    CGFloat timerRight = self.btn_programShare.hidden ? width - 12 : CGRectGetMinX(self.btn_programShare.frame) - 8;
    self.sleepButton.frame = CGRectMake(timerRight - timerWidth, safeTop, timerWidth, 44);
    self.lbl_mainTitle.frame = CGRectMake(60, safeTop, MAX(0, CGRectGetMinX(self.sleepButton.frame) - 68), 44);
    [self.view bringSubviewToFront:self.btn_programShare];
    [self.view bringSubviewToFront:self.sleepButton];
    self.tb_AODSubList.frame = CGRectMake(0, top, width, MAX(0, CGRectGetMinY(self.bottomView.frame) - top));
    if (self.bibleCover.bounds.size.width != width) {
        self.bibleCover.frame = CGRectMake(0, 0, width, width);
        self.tb_AODSubList.tableHeaderView = self.bibleCover;
    }
    // UITableView owns the pinned header's origin as contentOffset changes.
    CGRect panelFrame = self.biblePanel.frame;
    panelFrame.size = CGSizeMake(width, 240);
    self.biblePanel.frame = panelFrame;
    self.biblePanelGradient.frame = self.biblePanel.bounds;
    CGFloat badgeWidth = MAX(104, floor(width * 0.27));
    self.bibleTabs.frame = CGRectMake(12, 10, MAX(0, width - badgeWidth - 34), 40);
    self.bookBadge.frame = CGRectMake(width - badgeWidth - 12, 14, badgeWidth, 32);
    self.bookGrid.frame = CGRectMake(12, 56, width - 24, 174);
    self.resumeLabel.frame = CGRectMake(12, 25, width - 24, 16);
    // Reflow the three columns when the available width changes.
    if (self.bookGrid.subviews.count && fabs(self.bookGrid.subviews.firstObject.bounds.size.width - floor((width - 44) / 3)) > 0.1) [self renderBooks];
}
- (void)selectBibleBook:(NSString *)bookID {
    JRBiblePlayback *playback = [JRBiblePlayback shared];
    if (playback.active && [bookID isEqual:playback.playingBookID] && [self displayPlayingBibleBook]) {
        [self.tb_AODSubList setContentOffset:CGPointMake(0, MIN(MAX(0, self.tb_AODSubList.contentOffset.y), self.bibleCover.bounds.size.height)) animated:NO];
        return;
    }
    CGFloat retainedOffset = MIN(MAX(0, self.tb_AODSubList.contentOffset.y), self.bibleCover.bounds.size.height);
    self.selectedBookID = bookID; self.bibleFallback = NO; self.practicableLoad = NO;
    self.bookRequest++; NSUInteger request = self.bookRequest;
    [self renderBooks]; self.loadedBibleBookID = nil; self.arr_programSubList = @[]; [self.tb_AODSubList reloadData];
    __weak typeof(self) weakSelf = self;
    [[JRBiblePlayback shared] loadBook:bookID completion:^(NSArray *items, NSDictionary *info, NSError *error) {
        if (request != weakSelf.bookRequest) return;
        if (error) { [weakSelf loadBibleFallback]; return; }
        weakSelf.arr_programSubList = items;
        weakSelf.loadedBibleBookID = bookID;
        if (info) {
            GetCommonData.aodMetaData = info;
            NSString *thumb = info[@"PR_THUMBS"];
            [[JRBiblePlayback shared] updateProgramInfo:info artwork:nil];
            if ([thumb isKindOfClass:NSString.class]) {
                NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:[URLAddressManager getURL:[URLAddressManager getLocal] type:MAINIMAGE], thumb]];
                [weakSelf.lmg_subImg setImageWithURLRequest:[NSURLRequest requestWithURL:url] placeholderImage:[UIImage imageNamed:@"default_image"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                    weakSelf.lmg_subImg.image = image;
                    [[JRBiblePlayback shared] updateProgramInfo:info artwork:image];
                } failure:nil];
            }
        }
        UILabel *empty = [UILabel new]; empty.text = @"준비 중입니다"; empty.textAlignment = NSTextAlignmentCenter; empty.textColor = UIColor.whiteColor;
        weakSelf.tb_AODSubList.backgroundView = items.count ? nil : empty;
        [weakSelf.tb_AODSubList reloadData];
        [weakSelf.tb_AODSubList setContentOffset:CGPointMake(0, retainedOffset) animated:NO];
        [weakSelf updateBibleControls];
        [weakSelf scrollToPlayingChapter];
    }];
}
- (void)loadBibleFallback {
    self.bibleFallback = YES; self.page = 0; self.arr_programSubList = @[];
    [self.view makeToast:@"성경 목록을 불러오지 못해 기존 목록을 표시합니다."];
    [self requestNextList];
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (tableView != self.tb_AODSubList) return nil;
    return self.biblePanel ?: self.groupPanel;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (tableView != self.tb_AODSubList) return 0;
    if (self.biblePanel) return 240;
    if (self.groupPanel) {
        return 52 + [self programGroupGridHeight] + 8;
    }
    return 0;
}

- (void)cycleRepeat {
    JRBiblePlayback *playback = [JRBiblePlayback shared]; playback.repeatMode = (playback.repeatMode + 1) % 3;
    [self.view makeToast:@[@"순차재생",@"전체반복",@"한장반복"][playback.repeatMode] duration:1.5 position:CSToastPositionCenter];
    [self updateBibleControls];
}
- (void)cycleSleep {
    [[JRBiblePlayback shared] cycleSleep]; [self updateBibleControls];
    [self.view makeToast:[NSString stringWithFormat:@"취침 타이머: %@", [JRBiblePlayback shared].sleepLabel]];
}
- (UIImage *)sequentialPlaybackImage {
    UIGraphicsImageRenderer *renderer = [[UIGraphicsImageRenderer alloc] initWithSize:CGSizeMake(24, 24)];
    UIImage *image = [renderer imageWithActions:^(UIGraphicsImageRendererContext *context) {
        UIBezierPath *path = [UIBezierPath bezierPath]; path.lineWidth = 1.8; path.lineCapStyle = kCGLineCapRound; path.lineJoinStyle = kCGLineJoinRound;
        for (NSInteger row = 0; row < 3; row++) { [path moveToPoint:CGPointMake(3, 6 + row * 6)]; [path addLineToPoint:CGPointMake(13, 6 + row * 6)]; }
        [path moveToPoint:CGPointMake(19, 5)]; [path addLineToPoint:CGPointMake(19, 19)];
        [path moveToPoint:CGPointMake(16, 16)]; [path addLineToPoint:CGPointMake(19, 19)]; [path addLineToPoint:CGPointMake(22, 16)];
        [UIColor.blackColor setStroke]; [path stroke];
    }];
    return [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
}
- (void)updateBibleControls {
    JRBiblePlayback *playback = [JRBiblePlayback shared];
    UIImage *modeImage = playback.repeatMode == 0 ? [self sequentialPlaybackImage] : [UIImage systemImageNamed:playback.repeatMode == 1 ? @"repeat" : @"repeat.1"];
    [self.repeatButton setImage:modeImage ?: [UIImage systemImageNamed:@"list.bullet"] forState:UIControlStateNormal];
    self.btn_play.enabled = playback.active || self.arr_programSubList.count > 0;
    self.repeatButton.accessibilityLabel = @[@"순차재생",@"전체반복",@"한장반복"][playback.repeatMode];
    [self.sleepButton setTitle:playback.sleepMode ? playback.sleepLabel : @"" forState:UIControlStateNormal];
    self.sleepButton.accessibilityLabel = [@"취침 타이머 " stringByAppendingString:playback.sleepLabel];
    [self.view setNeedsLayout];
    NSDictionary *resume = playback.resumeRecord;
    NSInteger seconds = [resume[@"position"] integerValue];
    self.resumeLabel.text = !playback.active && resume ? [NSString stringWithFormat:@"이어듣기: %@ %ld:%02ld부터 · 재생 버튼으로 시작",resume[@"title"],(long)seconds/60,(long)seconds%60] : @"";
    if (playback.active) {
        self.lbl_title.text = GetCommonData.aodData[@"CT_NAME"];
        self.lbl_time.text = GetCommonData.aodData[@"CT_SPEAKER"];
        self.btn_play.enabled = YES; self.btn_next.enabled = YES; self.btn_prev.enabled = YES;
        self.sl_progress.hidden = NO;
        double progress = self.mainDelegate.avAudioPlayer.progress, duration = self.mainDelegate.avAudioPlayer.duration;
        if (!self.sl_progress.tracking) {
            self.sl_progress.maximumValue = duration;
            self.sl_progress.value = progress;
            self.lbl_playback_time.text = [NSString stringWithFormat:@"%02ld:%02ld", (long)progress/60, (long)progress%60];
            NSInteger remaining = MAX(0, (NSInteger)(duration-progress));
            self.lbl_duration.text = [NSString stringWithFormat:@"-%02ld:%02ld", (long)remaining/60, (long)remaining%60];
        }
        self.btn_play.selected = self.mainDelegate.avAudioPlayer.state == STKAudioPlayerStatePlaying;
    }
}
- (void)biblePlaybackChanged {
    if (!NSThread.isMainThread) {
        dispatch_async(dispatch_get_main_queue(), ^{ [self biblePlaybackChanged]; });
        return;
    }
    if (!self.isViewLoaded) return;
    [self updateBibleControls];
    JRBiblePlayback *playback = [JRBiblePlayback shared];
    if (!playback.active) return;
    BOOL chapterChanged = ![self.displayedChapterID isEqual:GetCommonData.CT_NO];
    BOOL viewingPlayingBook = [self.selectedBookID isEqual:playback.playingBookID];
    BOOL needsRepair = viewingPlayingBook && (!self.arr_programSubList.count || ![self.loadedBibleBookID isEqual:playback.playingBookID]);
    // Heartbeats must not pull someone away from another book they are browsing.
    if (!chapterChanged && !needsRepair) return;
    if ([self displayPlayingBibleBook]) [self scrollToPlayingChapter];
}
- (BOOL)displayPlayingBibleBook {
    JRBiblePlayback *playback = [JRBiblePlayback shared];
    NSArray<NSDictionary *> *chapters = playback.playingItems;
    NSUInteger chapter = [chapters indexOfObjectPassingTest:^BOOL(NSDictionary *item, NSUInteger index, BOOL *stop) {
        return [item[@"CT_NO"] isEqual:GetCommonData.CT_NO];
    }];
    if (!chapters.count || chapter == NSNotFound) return NO;

    // The player loads a complete book before changing tracks. Use that snapshot
    // atomically instead of clearing the list and requesting the same book again.
    self.bookRequest++;
    self.selectedBookID = playback.playingBookID;
    self.loadedBibleBookID = playback.playingBookID;
    self.bibleFallback = NO; self.practicableLoad = NO;
    self.arr_programSubList = chapters;
    self.tb_AODSubList.backgroundView = nil;
    self.displayedChapterID = GetCommonData.CT_NO;
    self.displayedPlayingBookID = playback.playingBookID;
    [self showSelectedBibleBook];
    [self.tb_AODSubList reloadData];
    return YES;
}
- (void)scrollToPlayingChapter {
    if (![JRBiblePlayback shared].active) return;
    NSInteger row = [self getRow];
    [self.tb_AODSubList layoutIfNeeded];
    if (row >= 0 && row < [self.tb_AODSubList numberOfRowsInSection:0]) {
        [self.tb_AODSubList scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    }
}
- (IBAction)play {
    if (![self.PR_ID isEqualToString:@"002005"] || self.bibleFallback) { [super play]; return; }
    JRBiblePlayback *playback = [JRBiblePlayback shared];
    if (playback.active && [self.selectedBookID isEqual:playback.playingBookID]) { [playback togglePlayback]; return; }
    NSDictionary *resume = playback.resumeRecord;
    NSDictionary *item = self.arr_programSubList.firstObject;
    double position = 0;
    if (!playback.active && [resume[@"BB_ID"] isEqual:self.selectedBookID]) {
        for (NSDictionary *candidate in self.arr_programSubList) if ([candidate[@"CT_NO"] isEqual:resume[@"CT_NO"]]) { item = candidate; position = [resume[@"position"] doubleValue]; break; }
    }
    if (item) { GetCommonData.thum = self.lmg_subImg.image; [playback playItem:item bookID:self.selectedBookID items:self.arr_programSubList position:position]; }
}
- (void)dealloc { [[NSNotificationCenter defaultCenter] removeObserver:self name:JRBiblePlaybackChanged object:nil]; }

@end
