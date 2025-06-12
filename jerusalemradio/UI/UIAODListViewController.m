//
//  UIAODListViewController.m
//  jerusalemradio
//
//  Created by Ja Young Park on 2017. 6. 3..
//  Copyright © 2017년 JooYoung Kim. All rights reserved.
//

#import "UIAODListViewController.h"
#import "UIAODSubListViewController.h"

@interface UIAODListViewController () <UICollectionViewDelegate, UICollectionViewDataSource>
@property (nonatomic, strong) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) IBOutlet UILabel *lbl_mainTitle;
@end

@implementation UIAODListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    __weak typeof(self) weakSelf = self;
    self.collectionView.bounces = NO;
    [GetURLAddressManager getProgramInfo:[URLAddressManager getURL:[URLAddressManager getLocal] type:PROGRAMLIST] CompletionHandler:^(NSArray *data, NSError *error) {
        weakSelf.arr_programList = data;
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.collectionView reloadData];
        });
    }];
    
    self.headerView.frame = CGRectMake(0, 0, MAIN_SIZE().width, CommonUtil.getSafaAreaTop + RESIZE(80));
    
    UIView *vi_menu = [self.view viewWithTag:20001];
    vi_menu.frame = CGRectMake(RESIZE(10), (isiPhoneXScreen() ? 44 : 20) + RESIZE(10), RESIZE(70), RESIZE(70));
    
    UIView *vi_comments = [self.view viewWithTag:20002];
    vi_comments.frame = CGRectMake(MAIN_SIZE().width - RESIZE(80), (isiPhoneXScreen() ? 44 : 20) + RESIZE(10), RESIZE(70), RESIZE(70));
    
    self.lbl_mainTitle.frame = CGRectMake(CGRectGetMaxX(vi_menu.frame), (isiPhoneXScreen() ? 44 : 20), MAIN_SIZE().width - RESIZE(20 + 140), RESIZE(80));
    self.lbl_mainTitle.font = [UIFont systemFontOfSize720:30];
    
    self.bottomView.frame = CGRectMake(0, MAIN_SIZE().height - RESIZE(194) - (CommonUtil.getSafaAreaBottom), MAIN_SIZE().width, RESIZE(194) + (CommonUtil.getSafaAreaBottom));
    
    UIAODListCollectionViewFlowLayout *collectionViewLayout = [[UIAODListCollectionViewFlowLayout alloc] init];
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(RESIZE(44), CGRectGetMaxY(self.headerView.frame) + RESIZE(25), MAIN_SIZE().width - RESIZE(88), MAIN_SIZE().height - CGRectGetHeight(self.headerView.frame) - CGRectGetHeight(self.bottomView.frame) - RESIZE(50)) collectionViewLayout:collectionViewLayout];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    
    [self.collectionView setBackgroundColor:[UIColor clearColor]];
    [self.collectionView setPagingEnabled:YES];
    [self.collectionView registerClass:[UIAODListCollectionViewCell class]
              forCellWithReuseIdentifier:UIAODListCollectionViewCellIdentifier];
    
    [self.view addSubview:self.collectionView];
    
    [self.view bringSubviewToFront:self.menuView];
    [self.view bringSubviewToFront:self.commentsView];
    
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
    
    if (self.PR_ID.length > 0 && self.PR_NAME.length > 0) {
        [self onSelectAOD:self.PR_ID PR_NAME:self.PR_NAME];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)onSelectAOD:(NSString*)PR_ID PR_NAME:(NSString*)PR_NAME
{
    UIAODSubListViewController *subListVC = [self.storyboard instantiateViewControllerWithIdentifier:@"UIAODSubListView"];
    subListVC.PR_ID = PR_ID;
    subListVC.PR_NAME = PR_NAME;
    subListVC.isPlay = self.isPlay;
    [self.navigationController pushViewController:subListVC animated:YES];
}


- (void)onSelectAOD:(NSIndexPath *)indexPath
{
    NSString *PR_ID = self.arr_programList[indexPath.item][@"PR_ID"];
    UIAODSubListViewController *subListVC = [self.storyboard instantiateViewControllerWithIdentifier:@"UIAODSubListView"];
    subListVC.PR_ID = PR_ID;
    subListVC.PR_NAME = self.arr_programList[indexPath.item][@"PR_NAME"];
    [self.navigationController pushViewController:subListVC animated:YES];
}

- (void)reloadCollectionView {
    [self.collectionView reloadData];
}

#pragma mark - UICollectionView Delegate / DataSourse
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (collectionView == self.collectionView) {
        return [self.arr_programList count];
    }
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UIAODListCollectionViewCell *cell = (UIAODListCollectionViewCell*)[collectionView dequeueReusableCellWithReuseIdentifier:UIAODListCollectionViewCellIdentifier forIndexPath:indexPath];
    
    if (cell.image == nil) {
        [cell setLayOut];
    }
    @try {
        [cell.image setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:[URLAddressManager getURL:[URLAddressManager getLocal] type:MAINIMAGE], self.arr_programList[indexPath.item][@"PR_THUMBS"]]] placeholderImage:[UIImage imageNamed:@"default_image"]];
    } @catch (NSException *exception) {
        cell.image.image = [UIImage imageNamed:@"default_image"];
    }
    
    @try {
        cell.title.text = self.arr_programList[indexPath.item][@"PR_NAME"];
    } @catch (NSException *exception) {
        cell.title.text = @"NO DATA";
    }
    
    NSString *str_host = @"";
    @try {
        if ([self.arr_programList[indexPath.item][@"PR_HOST"] length] > 0) {
            str_host = [NSString stringWithFormat:NSLocalizedString(@"Listen_adapter_host", @"진행 : %@"),self.arr_programList[indexPath.row][@"PR_HOST"]];
        } else if ([self.arr_programList[indexPath.item][@"PR_SPEAKER"] length] > 0) {
            str_host = [NSString stringWithFormat:NSLocalizedString(@"Listen_adapter_host", @"진행 : %@"),self.arr_programList[indexPath.row][@"PR_SPEAKER"]];
        }
    } @catch (NSException *exception) {
        
    }
    
    cell.subTitle.text = str_host;
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    return CGSizeMake(RESIZE(316), RESIZE(440));
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    if (collectionView == self.collectionView) {
        [self onSelectAOD:indexPath];
    }
}
#pragma mark- UITableViewDelegate & DataSource
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
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
    }
//    else if (tableView == self.tableView) {
//        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
//        cell.contentView.backgroundColor = UIColorFromRGBA(0x262631, .95);
//        UIView *bgColorView = [[UIView alloc] init];
//        bgColorView.backgroundColor = UIColorFromRGB(0x3d3e48);
//        [cell setSelectedBackgroundView:bgColorView];
//
////        NSLog(@"%@",MAINIMAGE(self.arr_programList[indexPath.row][@"PR_ID"]));
//
//        UIImageView *img_thum = [[UIImageView alloc] initWithFrame:CGRectMake(12, 13, 49, 49)];
//        @try {
//            [img_thum setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:[URLAddressManager getURL:[URLAddressManager getLocal] type:MAINIMAGE], self.arr_programList[indexPath.row][@"PR_THUMBS"]]] placeholderImage:[UIImage imageNamed:@"default_image"]];
//        } @catch (NSException *exception) {
//            img_thum.image = [UIImage imageNamed:@"default_image"];
//        }
//        [cell.contentView addSubview:img_thum];
//
//        UILabel *lbl_title = [[UILabel alloc] initWithFrame:CGRectMake(73, 20, MAIN_SIZE().width - 116, 15)];
//        @try {
//            lbl_title.text = self.arr_programList[indexPath.row][@"PR_NAME"];
//        } @catch (NSException *exception) {
//            lbl_title.text = @"NO DATA";
//        }
//        lbl_title.textColor = UIColorFromRGBA(0xFFFFFF, .6);
//        lbl_title.font = [UIFont systemFontOfSizeForDpi:13.];
//        [cell.contentView addSubview:lbl_title];
//
//        NSString *str_host = @"";
//        @try {
//            if ([self.arr_programList[indexPath.row][@"PR_HOST"] length] > 0) {
//                str_host = [NSString stringWithFormat:NSLocalizedString(@"Listen_adapter_host", @"진행 : %@"),self.arr_programList[indexPath.row][@"PR_HOST"]];
//            } else if ([self.arr_programList[indexPath.row][@"PR_SPEAKER"] length] > 0) {
//                str_host = [NSString stringWithFormat:NSLocalizedString(@"Listen_adapter_host", @"진행 : %@"),self.arr_programList[indexPath.row][@"PR_SPEAKER"]];
//            }
//        } @catch (NSException *exception) {
//
//        }
//
//        UILabel *lbl_host = [[UILabel alloc] initWithFrame:CGRectMake(73, 40, MAIN_SIZE().width - 116, 13)];
//        lbl_host.text = str_host;
//        lbl_host.textColor = UIColorFromRGBA(0xFFFFFF, .3);
//        lbl_host.font = [UIFont systemFontOfSizeForDpi:10.];
//        [cell.contentView addSubview:lbl_host];
//
//        UIImageView *img_arrow = [[UIImageView alloc] initWithFrame:CGRectMake(MAIN_SIZE().width - 26, 24, 24, 24)];
//        [img_arrow setImage:[UIImage imageNamed:@"icon_arrow.png"]];
//        [cell.contentView addSubview:img_arrow];
//
//        UIImageView *img_line = [[UIImageView alloc] initWithFrame:CGRectMake(0, 75, MAIN_SIZE().width, 1)];
//        img_line.backgroundColor = UIColorFromRGB(0x42424A);
//        [cell.contentView addSubview:img_line];
//    }
    
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
//    else if (tableView == self.tableView) {
//        height = 76;
//    }
    return height;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.commentsTableView) {
        return [self.commentsList count];
    }
//    else if (tableView == self.tableView) {
//        return [self.arr_programList count];
//    }
    return 0;
}

@end



@implementation UIAODListCollectionViewFlowLayout

- (id)init {
    self = [super init];
    if (self) {
        self.scrollDirection         = UICollectionViewScrollDirectionVertical;
        self.minimumInteritemSpacing = 0;
        self.minimumLineSpacing      = 0;
    }
    return self;
}

@end

NSString * const  UIAODListCollectionViewCellIdentifier = @"UIAODListCollectionViewCell";
@interface UIAODListCollectionViewCell()

@end

@implementation UIAODListCollectionViewCell

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    
    if (self) {
        [self setLayOut];
    }
    
    return self;
}

- (void) setLayOut
{
    self.image = [[UIImageView alloc] initWithFrame:CGRectMake(RESIZE(11), RESIZE(31), RESIZE(294), RESIZE(294))];
    [self addSubview:self.image];
    
    self.title = [[UILabel alloc] initWithFrame:CGRectMake(RESIZE(11), CGRectGetMaxY(self.image.frame) + RESIZE(12), RESIZE(294), RESIZE(42))];
    self.title.textColor = UIColor.whiteColor;
    self.title.font = [UIFont systemFontOfSize720:32];
    [self addSubview:self.title];
    
    self.subTitle = [[UILabel alloc] initWithFrame:CGRectMake(RESIZE(11), CGRectGetMaxY(self.image.frame) + RESIZE(55), RESIZE(294), RESIZE(37))];
    self.subTitle.textColor = UIColorFromRGB(0xB5B5B9);
    self.subTitle.font = [UIFont systemFontOfSize720:27];
    [self addSubview:self.subTitle];
}

@end
