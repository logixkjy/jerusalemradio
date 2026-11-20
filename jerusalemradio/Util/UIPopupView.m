//
//  UIPopupView.m
//  KnpApp
//
//  Created by vito on 2014. 9. 22..
//  Copyright (c) 2014년 BEAGLE CO., Ltd. All rights reserved.
//

#import "UIPopupView.h"

@interface UIPopupItem : NSObject
@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) UIImage *icon;
@property (nonatomic, assign) BOOL isSignificance;
@property (nonatomic, strong) void(^actionBlock)();
@property (nonatomic, strong) void(^actionBlockWithCertifycation)();
@property (nonatomic, strong) void(^__strong actionBlockWithSecess)(BOOL);
@property (nonatomic, strong) void(^__strong actionBlockWithData)(NSDictionary*);
@end

@implementation UIPopupItem
@end

@interface UIPopupView ()

@property (nonatomic, strong) UIView *adContainerView;

@end

@implementation UIPopupView

- (id)init
{
    self = [super init];
    if (self) {
        self.popupType = UIPopupView_TYPE_DEFAULT;
        m_itemList = [[NSMutableArray alloc] init];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillShow:)
                                                     name:UIKeyboardWillShowNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(KeyboardWillHide:)
                                                     name:UIKeyboardWillHideNotification
                                                   object:nil];

    }
    
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
}

- (void)addItem:(NSString *)title actionBlock:(void (^)(void))actionBlock
{
    [self addItem:title icon:nil actionBlock:actionBlock];
}

- (void)addItem:(NSString *)title actionBlockWithData:(void (^)(NSDictionary *))actionBlockWithData
{
    UIPopupItem *item = [[UIPopupItem alloc] init];
    item.title = title;
    item.icon = nil;
    item.isSignificance = NO;
    item.actionBlockWithData = actionBlockWithData;
    [m_itemList addObject:item];
}
- (void)addItem:(NSString *)title actionBlockWithSecess:(void (^)(BOOL))actionBlockWithSecess
{
    [self addItem:title icon:nil actionBlockWithSecess:actionBlockWithSecess];
}

- (void)addItem:(NSString *)title actionBlockWithCertifycation:(void (^)(void))actionBlockWithCertifycation
{
    [self addItem:title icon:nil actionBlockWithCertifycation:actionBlockWithCertifycation];
}

- (void)addItem:(NSString *)title significance:(BOOL)significance actionBlock:(void (^)(void))actionBlock
{
    [self addItem:title icon:nil significance:significance actionBlock:actionBlock];
}

- (void)addItem:(NSString *)title icon:(UIImage *)icon actionBlock:(void (^)(void))actionBlock
{
    [self addItem:title icon:icon significance:NO actionBlock:actionBlock];
}

- (void)addItem:(NSString *)title icon:(UIImage *)icon actionBlockWithSecess:(void (^)(BOOL))actionBlockWithSecess
{
    [self addItem:title icon:icon significance:NO actionBlockWithSecess:(void (^)(BOOL))actionBlockWithSecess];
}

- (void)addItem:(NSString *)title icon:(UIImage *)icon actionBlockWithCertifycation:(void (^)(void))actionBlock
{
    [self addItem:title icon:icon significance:NO actionBlockWithCertifycation:actionBlock];
}

- (void)addItem:(NSString *)title icon:(UIImage *)icon significance:(BOOL)significance actionBlock:(void (^)(void))actionBlock
{
    UIPopupItem *item = [[UIPopupItem alloc] init];
    item.title = title;
    item.icon = icon;
    item.isSignificance = significance;
    item.actionBlock = actionBlock;
    [m_itemList addObject:item];
}

- (void)addItem:(NSString *)title icon:(UIImage *)icon significance:(BOOL)significance actionBlockWithSecess:(void (^)(BOOL))actionBlockWithSecess
{
    UIPopupItem *item = [[UIPopupItem alloc] init];
    item.title = title;
    item.icon = icon;
    item.isSignificance = significance;
    item.actionBlockWithSecess = actionBlockWithSecess;
    [m_itemList addObject:item];
}

- (void)addItem:(NSString *)title icon:(UIImage *)icon significance:(BOOL)significance actionBlockWithCertifycation:(void (^)(void))actionBlockWithCertifycation
{
    UIPopupItem *item = [[UIPopupItem alloc] init];
    item.title = title;
    item.icon = icon;
    item.isSignificance = significance;
    item.actionBlockWithCertifycation = actionBlockWithCertifycation;
    [m_itemList addObject:item];
}

- (NSUInteger)itemCount
{
    return [m_itemList count];
}

- (void)selectedNomore:(UIButton*)sender
{
    sender.selected = !sender.selected;
    _img_check.highlighted = sender.selected;
    if (self.nomoreAction) {
        self.nomoreAction(sender.selected);
    }
}

- (void)show
{
    UIWindow *window = [CommonUtil activeWindow];
    if (!window) return;
    
    self.frame = window.bounds;
    self.backgroundColor = [UIColor colorWithWhite:0. alpha:.8];
    [window addSubview:self];
    
    UIEdgeInsets backgroundEdgeInsets = UIEdgeInsetsMake(20., 20., 20., 20.);
    CGRect backgroundViewFrame = self.bounds;
    backgroundViewFrame = UIEdgeInsetsInsetRect(backgroundViewFrame, backgroundEdgeInsets);
    
    UIView *backgroundView = [[UIView alloc] initWithFrame:backgroundViewFrame];
    backgroundView.backgroundColor = [UIColor whiteColor];
//    backgroundView.layer.borderColor = [UIColor colorWithRed:52/255. green:52/255. blue:52/255. alpha:1.].CGColor;
//    backgroundView.layer.borderWidth = .5;
    [self addSubview:backgroundView];
    
    CGSize mainSize = [[UIScreen mainScreen] bounds].size;
    UIView *_m_keyboardToolBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, mainSize.width, 44)];
    [_m_keyboardToolBar setBackgroundColor:UIColorFromRGB(0xF8F8F8)];
    
    UIImageView *img_topLine = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, mainSize.width, 1)];
    [img_topLine setBackgroundColor:UIColorFromRGB(0xB2B2B2)];
    [_m_keyboardToolBar addSubview:img_topLine];
    
//    UIImageView *img_logo = [[UIImageView alloc] initWithFrame:CGRectMake(8, 15.5, 123, 13)];
//    [img_logo setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"action_logo" ofType:@"png"]]];
//    [_m_keyboardToolBar addSubview:img_logo];
    
    UIButton *btn_key_close = [UIButton buttonWithType:UIButtonTypeSystem];
    [btn_key_close setFrame:CGRectMake(mainSize.width - 37, 9, 37, 27)];
    [btn_key_close setTitle:@"완료" forState:UIControlStateNormal];
    [btn_key_close setTitleColor:UIColorFromRGB(0x5F5F5F) forState:UIControlStateNormal];
    [btn_key_close addTarget:self action:@selector(closeKeyboard) forControlEvents:UIControlEventTouchUpInside];
    
    [_m_keyboardToolBar addSubview:btn_key_close];
    
    CGFloat maxY = 0.f;
    
    if ([self.title length] > 0) {
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(backgroundView.bounds) + 15.,
                                                                        18.,
                                                                        CGRectGetWidth(backgroundView.bounds)-30.,
                                                                        22.)];
        titleLabel.font = [UIFont boldSystemFontOfSize:18.];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.adjustsFontSizeToFitWidth = YES;
        titleLabel.text = self.title;
//        [titleLabel sizeToFit];
//        titleLabel.frame = CGRectMake((CGRectGetWidth(backgroundView.bounds) - CGRectGetWidth(titleLabel.frame))/2.,
//                                      CGRectGetMinY(titleLabel.frame),
//                                      CGRectGetWidth(titleLabel.frame),
//                                      CGRectGetHeight(titleLabel.frame));
        [backgroundView addSubview:titleLabel];
        
        if ([self.message length] > 0 ||
            [self.attributedMessage length] > 0) {
            UIView *titleUnderLineView = [[UIView alloc] initWithFrame:CGRectMake(0.,
                                                                                  CGRectGetMaxY(titleLabel.frame) + 16.,
                                                                                  CGRectGetWidth(backgroundView.bounds),
                                                                                  3.)];
            titleUnderLineView.backgroundColor = UIColorFromRGB(0x808081);
            [backgroundView addSubview:titleUnderLineView];
            
            maxY = CGRectGetMaxY(titleUnderLineView.frame);
        } else {
            maxY = CGRectGetMaxY(titleLabel.frame)+18.;
        }
    }
    
    if (self.popupType == UIPopupView_TYPE_ACTIVITY_INDICATOR) {
        UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleLarge];
        activityIndicatorView.color = UIColorFromRGB(0x808081);
        activityIndicatorView.frame = CGRectMake((CGRectGetWidth(backgroundView.frame)-CGRectGetWidth(activityIndicatorView.frame))/2.,
                                                 maxY + 25.,
                                                 CGRectGetWidth(activityIndicatorView.frame),
                                                 CGRectGetHeight(activityIndicatorView.frame));
        [activityIndicatorView startAnimating];
        [backgroundView addSubview:activityIndicatorView];
        
        maxY = CGRectGetMaxY(activityIndicatorView.frame);
    }
    
    if (self.contentView != nil) {
        self.contentView.frame = CGRectMake((CGRectGetWidth(backgroundView.frame)-CGRectGetWidth(self.contentView.frame))/2.,
                                            maxY + 15.,
                                            CGRectGetWidth(self.contentView.frame),
                                            CGRectGetHeight(self.contentView.frame));
        [backgroundView addSubview:self.contentView];
        
        maxY = CGRectGetMaxY(self.contentView.frame);
    }
    
    
    if ([self.message length] > 0 || [self.attributedMessage length] > 0) {
        if (self.popupType == UIPopupView_TYPE_TEXTFIELD_UP) {
            _textField = [[UITextField alloc] initWithFrame:CGRectMake(10, maxY + 10, backgroundView.frame.size.width - 20, 25)];
            _textField.placeholder = _keyword;
            _textField.font = [UIFont systemFontOfSize:14.];
            _textField.borderStyle = UITextBorderStyleRoundedRect;
            _textField.delegate = self;
            _textField.inputAccessoryView = _m_keyboardToolBar;
            _textField.autocorrectionType = UITextAutocorrectionTypeNo;
            [backgroundView addSubview:_textField];
            
            maxY = CGRectGetMaxY(_textField.frame);
        }
        
        UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(backgroundView.bounds)+15.,
                                                                          maxY+25.,
                                                                          CGRectGetWidth(backgroundView.bounds)-30.,
                                                                          5.)];
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = self.popupType == UIPopupView_TYPE_TEXTFIELD_UP ? NSTextAlignmentLeft : NSTextAlignmentCenter;
        messageLabel.font = self.popupType == UIPopupView_TYPE_TEXTFIELD_UP ? [UIFont systemFontOfSize:14.] :[UIFont systemFontOfSize:14.];
        if ([self.attributedMessage length] > 0) {
            if ([messageLabel respondsToSelector:@selector(setAttributedText:)])
                messageLabel.attributedText = self.attributedMessage;
            else
                messageLabel.text = [messageLabel.attributedText string];
        }
        else {
            messageLabel.text = self.message;
        }
        [messageLabel sizeToFit];
        messageLabel.frame = CGRectMake((CGRectGetWidth(backgroundView.frame)-CGRectGetWidth(messageLabel.frame))/2.,
                                        CGRectGetMinY(messageLabel.frame),
                                        CGRectGetWidth(messageLabel.frame),
                                        CGRectGetHeight(messageLabel.frame));
        [backgroundView addSubview:messageLabel];
        
        maxY = CGRectGetMaxY(messageLabel.frame);
        
        if (self.popupType == UIPopupView_TYPE_TEXTFIELD) {
            _textField = [[UITextField alloc] initWithFrame:CGRectMake(10, maxY + 10, backgroundView.frame.size.width - 20, 25)];
            _textField.placeholder = _keyword;
            _textField.font = [UIFont systemFontOfSize:14.];
            _textField.borderStyle = UITextBorderStyleRoundedRect;
            _textField.delegate = self;
            _textField.inputAccessoryView = _m_keyboardToolBar;
            _textField.autocorrectionType = UITextAutocorrectionTypeNo;
            [backgroundView addSubview:_textField];
            
            maxY = CGRectGetMaxY(_textField.frame);
        }
        else if (self.popupType == UIPopupView_TYPE_NOMORE) {
            UIView *underLineView = [[UIView alloc] initWithFrame:CGRectMake(0.,
                                                                             maxY + 15.,
                                                                             CGRectGetWidth(backgroundView.bounds),
                                                                             2.)];
            underLineView.backgroundColor = [UIColor lightGrayColor];
            [backgroundView addSubview:underLineView];
            
            maxY += 17;
            
            _img_check = [[UIImageView alloc] initWithFrame:CGRectMake(10, maxY + 7, 20, 20)];
            [_img_check setImage:[UIImage imageNamed:@"check_off.png"]];
            [_img_check setHighlightedImage:[UIImage imageNamed:@"check_on.png"]];
            [backgroundView addSubview:_img_check];
            
            UILabel *lblCheck = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_img_check.frame) + 3, maxY + 5, MAIN_SIZE().width - 45, 24)];
            lblCheck.text = NSLocalizedString(@"nomore", @"다시 보지 않기");
            lblCheck.textColor = [UIColor darkGrayColor];
            lblCheck.font = [UIFont systemFontOfSize:15.];
            [backgroundView addSubview:lblCheck];
            
            UIButton *checkBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            [checkBtn setFrame:CGRectMake(10, maxY + 5, MAIN_SIZE().width - 20, 24)];
            [checkBtn addTarget:self action:@selector(selectedNomore:) forControlEvents:UIControlEventTouchUpInside];
            [backgroundView addSubview:checkBtn];
            
            maxY = CGRectGetMaxY(checkBtn.frame);
        }
        
    }
    
    CGFloat buttonInSideGap = 1.;
    CGFloat buttonOutSideGap = 0.;
    CGFloat buttonWidth = (CGRectGetWidth(backgroundView.bounds)-(buttonOutSideGap*2+([m_itemList count]-1)*buttonInSideGap))/(CGFloat)[m_itemList count];
    
    CGFloat xx = buttonOutSideGap;
    CGFloat yy = maxY+(self.popupType == UIPopupView_TYPE_NOMORE ? 7. :15.);
    
    for (int ii=0; ii<[m_itemList count]; ii++)
    {
        UIPopupItem *item = m_itemList[ii];
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.backgroundColor = [UIColor lightGrayColor];
        button.frame = CGRectMake(xx, yy, buttonWidth, 46.);
        button.titleLabel.font = [UIFont boldSystemFontOfSize:16.];
        button.tag = ii;
        [button setTitle:item.title forState:UIControlStateNormal];
        button.titleLabel.numberOfLines = 2;
        button.titleLabel.textAlignment = NSTextAlignmentCenter;
        [button addTarget:self action:@selector(onButton:) forControlEvents:UIControlEventTouchUpInside];
        [backgroundView addSubview:button];
        
        xx = CGRectGetMaxX(button.frame) + buttonInSideGap;
        
        maxY = CGRectGetMaxY(button.frame);
    }
    
    if ([m_itemList count] == 0) {
        maxY += 20.;
    }
    
    backgroundView.frame = CGRectMake(CGRectGetMinX(backgroundView.frame),
                                      CGRectGetMinY(backgroundView.frame),
                                      CGRectGetWidth(backgroundView.frame),
                                      maxY);
    
    backgroundView.center = self.center;
    _backgroundView = backgroundView;
}

- (UIViewController*)viewController
{
    for (UIView* next = [self superview]; next; next = next.superview)
    {
        UIResponder* nextResponder = [next nextResponder];
        
        if ([nextResponder isKindOfClass:[UIViewController class]])
        {
            return (UIViewController*)nextResponder;
        }
    }
    
    return nil;
}

- (CGSize)sizeToString:(UILabel*)view
{
    CGSize maxSize = CGSizeMake(CGRectGetWidth(view.bounds), 10000);
    CGSize viewSize = CGSizeZero;
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
    paragraphStyle.lineBreakMode = NSLineBreakByCharWrapping;
    paragraphStyle.alignment = NSTextAlignmentLeft;
    NSDictionary *attributes = @{NSFontAttributeName:view.font, NSParagraphStyleAttributeName: paragraphStyle};
    viewSize = [view.text boundingRectWithSize:maxSize options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin
                                            attributes:attributes  context:nil].size;
    
    return viewSize;
}

- (void)closeKeyboard
{
    [_textField resignFirstResponder];
}

- (void)close
{
    [self removeFromSuperview];
}

+ (UIPopupView *)showPopupView:(NSString *)message
{
    return [self showPopupView:message buttonName:NSLocalizedString(@"ok", @"확인")];
}

+ (UIPopupView *)showPopupView:(NSString *)message buttonName:(NSString *)buttonName
{
    UIPopupView *popupView = [[UIPopupView alloc] init];
    popupView.title = NSLocalizedString(@"alert", @"");
    popupView.message = message;
    [popupView addItem:buttonName actionBlock:nil];
    [popupView show];
    
    return popupView;
}

+ (UIPopupView *)showPopupView:(NSString *)message actionBlock:(void (^)(void))actionBlock
{
    return [self showPopupView:message buttonName:NSLocalizedString(@"ok", @"확인") actionBlock:actionBlock];
}

+ (UIPopupView *)showPopupView:(NSString *)message buttonName:(NSString *)buttonName actionBlock:(void (^)(void))actionBlock
{
    UIPopupView *popupView = [[UIPopupView alloc] init];
    popupView.title = @"확인";
    popupView.message = message;
    [popupView addItem:buttonName actionBlock:actionBlock];
    [popupView show];
    
    return popupView;
}

- (void)onMoveTrackView
{
    if (self.moveTrackAction) {
        self.moveTrackAction(_mFileNo, _mFileName);
    }
    [self close];
}

- (void)onButton:(id)sender
{
    @try {
        UIPopupItem *item = m_itemList[((UIButton *)sender).tag];
        if (item.actionBlock != nil) {
            item.actionBlock();
        }
        if (item.actionBlockWithData) {
            if (_popupType == UIPopupView_TYPE_TEXTFIELD_UP ||
                _popupType == UIPopupView_TYPE_TEXTFIELD) {
                item.actionBlockWithData(@{@"TEXT":_textField.text});
            } else {
                if (self.mlinkUrl.length > 0) {
                    item.actionBlockWithData(@{@"LINKURL":_mlinkUrl});
                }
            }
            
        }
        if (item.actionBlockWithCertifycation) {
            item.actionBlockWithCertifycation();
        }
    }
    @catch (NSException *exception) {

    }
}


#pragma mark - Notification
- (void)keyboardWillShow:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    CGRect keyboardFrame = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    self.frame = CGRectMake(0., -CGRectGetHeight(keyboardFrame)/2, self.frame.size.width, self.frame.size.height);
}

- (void)KeyboardWillHide:(NSNotification *)notification
{
    self.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [_textField resignFirstResponder];
    return YES;
}
@end

