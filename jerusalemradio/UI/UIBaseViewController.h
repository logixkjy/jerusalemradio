//
//  UIBaseViewController.h
//  jerusalemradio
//
//  Created by JooYoung Kim on 2017. 5. 2..
//  Copyright © 2017년 JooYoung Kim. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UITextView+Placeholder.h"

@interface UIBaseViewController : UIViewController

@property (nonatomic, strong) IBOutlet UIView *headerView;
@property (nonatomic, strong) IBOutlet UIView *bottomView;

@property (nonatomic, strong) IBOutlet UIView *mainImageView;


@property (nonatomic, strong) IBOutlet UILabel *lbl_title;
@property (nonatomic, strong) IBOutlet UILabel *lbl_time;
@property (nonatomic, strong) IBOutlet UIImageView *img_onair;
@property (nonatomic, strong) IBOutlet UIButton *btn_onair;
@property (nonatomic, strong) IBOutlet UIButton *btn_comments;

@property (nonatomic, strong) IBOutlet UIButton *btn_prev;
@property (nonatomic, strong) IBOutlet UIButton *btn_play;
@property (nonatomic, strong) IBOutlet UIButton *btn_next;

@property (nonatomic, strong) IBOutlet UIView *menuView;
@property (nonatomic, strong) IBOutlet UIImageView *img_logo;
@property (nonatomic, strong) IBOutlet UIButton *btn_live;
@property (nonatomic, strong) IBOutlet UIButton *btn_aod;
@property (nonatomic, strong) IBOutlet UIButton *btn_schedule;
@property (nonatomic, strong) IBOutlet UIButton *btn_notice;
@property (nonatomic, strong) IBOutlet UIButton *btn_setting;
@property (nonatomic, strong) IBOutlet UIButton *btn_close;

@property (nonatomic, strong) IBOutlet UIView *commentsView;

@property (nonatomic, strong) IBOutlet UIView *noticeTitleView;
@property (nonatomic, strong) IBOutlet UIImageView *img_comments;
@property (nonatomic, strong) IBOutlet UILabel *lbl_notice_title;
@property (nonatomic, strong) IBOutlet UIButton *btn_board;

@property (nonatomic, strong) IBOutlet UIView *noticeView;
@property (nonatomic, strong) IBOutlet UILabel *lbl_notice_name;
@property (nonatomic, strong) IBOutlet UILabel *lbl_notice_desc;
@property (nonatomic, strong) IBOutlet UIView *commentsInputView;
@property (nonatomic, strong) IBOutlet UIButton *btn_Input;
@property (nonatomic, strong) IBOutlet UITableView *commentsTableView;
@property (nonatomic, strong) IBOutlet UITextView *tv_comments;

@property (nonatomic, strong) IBOutlet UIImageView *lmg_mainImg;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) AppDelegate *mainDelegate;

@property (nonatomic, strong) UISlider *sl_progress;
@property (nonatomic, strong) IBOutlet UIView *vi_progress;
@property (nonatomic, strong) IBOutlet UILabel *lbl_playback_time;
@property (nonatomic, strong) IBOutlet UILabel *lbl_duration;

@property (nonatomic, strong) NSArray *arr_programList;
@property (nonatomic, strong) NSArray *arr_programSubList;
@property (nonatomic, strong) IBOutlet UITableView *tb_AODSubList;
@property (nonatomic, strong) IBOutlet UIImageView *lmg_subImg;
@property (nonatomic, strong) IBOutlet UILabel *lbl_programName;

@property (nonatomic, strong) NSMutableArray *commentsList;
@property (nonatomic, assign) BOOL isPlaying;

- (void)onSchemesData:(NSDictionary*)callbackDic;

- (void)setAodLayout;
- (void)getComments;
- (void)playAOD;
+ (BOOL)usesAODGroupsForProgramID:(NSString *)programID;
- (IBAction)play;
- (IBAction)playOnAir;
- (void)confirmDeleteCommentAtIndexPath:(NSIndexPath *)indexPath;


- (IBAction)nextTrack;
- (IBAction)prevTrack;

@end

@interface CommentsCell : UITableViewCell
@property (nonatomic, strong) IBOutlet UILabel *lbl_notice_name;
@property (nonatomic, strong) IBOutlet UILabel *lbl_notice_desc;
@property (nonatomic, strong) IBOutlet UIButton *btn_delete;
@property (nonatomic, strong) NSIndexPath *indexPath;

@property (nonatomic, copy) void (^onDeleteAction)(NSIndexPath *indexPath);
@end

@interface AODListCell : UITableViewCell
@property (nonatomic, strong) IBOutlet UIImageView *img_thum;
@property (nonatomic, strong) IBOutlet UILabel *lbl_title;
@property (nonatomic, strong) IBOutlet UILabel *lbl_host;
@property (nonatomic, strong) IBOutlet UIButton* btn_select;
@property (nonatomic, strong) NSIndexPath *indexPath;

@property (nonatomic, copy) void (^onSelectAction)(NSIndexPath *indexPath);
@end

@interface AODSubListCell : UITableViewCell
@property (nonatomic, strong) IBOutlet UILabel *lbl_title;
@property (nonatomic, strong) IBOutlet UILabel *lbl_date;
@property (nonatomic, strong) IBOutlet UIButton* btn_select;
@property (nonatomic, strong) NSIndexPath *indexPath;

@property (nonatomic, copy) void (^onSelectAction)(NSIndexPath *indexPath);
@end
