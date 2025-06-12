//
//  UIPopupView.h
//  KnpApp
//
//  Created by vito on 2014. 9. 22..
//  Copyright (c) 2014년 BEAGLE CO., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MessageListItem;
enum {
    UIPopupView_TYPE_DEFAULT = 0,
    UIPopupView_TYPE_ACTIVITY_INDICATOR,
    UIPopupView_TYPE_TEXTFIELD,
    UIPopupView_TYPE_NOMORE,
    UIPopupView_TYPE_TEXTFIELD_UP,
};

@interface UIPopupView : UIView <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UITextViewDelegate>
{
@private
    NSMutableArray *m_itemList;
}

@property (nonatomic, assign) int popupType;
@property (nonatomic, strong) MessageListItem *messageItem;
@property (nonatomic, strong) NSArray *userIDs;
@property (nonatomic, copy) NSString *title;      // 제목
@property (nonatomic, copy) NSString *keyword;      // placeholder
@property (nonatomic, strong) UIView *contentView;  // 표시할 컨트롤
@property (nonatomic, strong) UITextField *textField; // 텍스트 입력창
@property (nonatomic, strong) UIImageView *img_check;
@property (nonatomic, copy) NSString *message;    // 메시지
@property (nonatomic, copy) NSDictionary *dicTrackInfo;
@property (nonatomic, copy) NSAttributedString *attributedMessage;
@property (nonatomic, strong) NSString *mfilePath;
@property (nonatomic, strong) NSString *mlinkUrl;

@property (nonatomic, strong) NSString *mFileLink;
@property (nonatomic, strong) NSString *mFileName;
@property (nonatomic, strong) NSString *mFileNo;

@property (nonatomic, strong, readonly) UIView *backgroundView;
@property (nonatomic, assign) id target;
@property (nonatomic, copy) void (^nomoreAction)(BOOL isSelected);
@property (nonatomic, copy) void (^certPrivateAction)(BOOL isSelected);
@property (nonatomic, copy) void (^certAgeAction)(BOOL isSelected);
@property (nonatomic, copy) void (^deleteTrackAction)(NSString *msg);
@property (nonatomic, copy) void (^moveTrackAction)(NSString *file_link, NSString *file_name);

- (void)addItem:(NSString *)title actionBlock:(void (^)(void))actionBlock;
- (void)addItem:(NSString *)title actionBlockWithData:(void (^)(NSDictionary *writeData))actionBlockWithData;
- (void)addItem:(NSString *)title actionBlockWithSecess:(void (^)(BOOL sucess))actionBlockWithSecess;
- (void)addItem:(NSString *)title actionBlockWithCertifycation:(void (^)(void))actionBlockWithCertifycation;

- (void)addItem:(NSString *)title significance:(BOOL)significance actionBlock:(void (^)(void))actionBlock;

- (void)addItem:(NSString *)title icon:(UIImage *)icon actionBlock:(void (^)(void))actionBlock;
- (void)addItem:(NSString *)title icon:(UIImage *)icon actionBlockWithSecess:(void (^)(BOOL))actionBlockWithSecess;
- (void)addItem:(NSString *)title icon:(UIImage *)icon actionBlockWithCertifycation:(void (^)(void))actionBlockWithCertifycation;

- (void)addItem:(NSString *)title icon:(UIImage *)icon significance:(BOOL)significance actionBlock:(void (^)(void))actionBlock;
- (void)addItem:(NSString *)title icon:(UIImage *)icon significance:(BOOL)significance actionBlockWithSecess:(void (^)(BOOL))actionBlockWithSecess;
- (void)addItem:(NSString *)title icon:(UIImage *)icon significance:(BOOL)significance actionBlockWithCertifycation:(void (^)(void))actionBlockWithCertifycation;

- (NSUInteger)itemCount;
- (void)show;
- (void)close;

+ (UIPopupView *)showPopupView:(NSString *)message;
+ (UIPopupView *)showPopupView:(NSString *)message actionBlock:(void (^)(void))actionBlock;
+ (UIPopupView *)showPopupView:(NSString *)message buttonName:(NSString *)buttonName;
+ (UIPopupView *)showPopupView:(NSString *)message buttonName:(NSString *)buttonName actionBlock:(void (^)(void))actionBlock;
@end

@interface MessageListItem : NSObject
@property (nonatomic, copy) NSString *UserID;
@property (nonatomic, copy) NSString *NickName;
@property (nonatomic, copy) NSString *strDate;
@property (nonatomic, copy) NSString *strMsg;
@property (nonatomic, copy) NSString *MemberPicture;

@property (nonatomic, copy) NSString *file_no;
@property (nonatomic, copy) NSString *file_link;
@property (nonatomic, copy) NSString *file_name;

@property (nonatomic, assign) int IDX;
@property (nonatomic, assign) BOOL bCheck;
@property (nonatomic, assign) BOOL read;
@property (nonatomic, assign) BOOL have_file;
@end
