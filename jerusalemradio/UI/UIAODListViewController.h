//
//  UIAODListViewController.h
//  jerusalemradio
//
//  Created by Ja Young Park on 2017. 6. 3..
//  Copyright © 2017년 JooYoung Kim. All rights reserved.
//

#import "UIBaseViewController.h"

@interface UIAODListViewController : UIBaseViewController

@property (nonatomic, strong) NSString *PR_ID;
@property (nonatomic, strong) NSString *PR_NAME;
@property (nonatomic, assign) BOOL isPlay;

@end

@interface UIAODListCollectionViewFlowLayout : UICollectionViewFlowLayout

@end

extern NSString * const  UIAODListCollectionViewCellIdentifier;

@interface UIAODListCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) IBOutlet UIImageView *image;
@property (nonatomic, strong) IBOutlet UILabel *title;
@property (nonatomic, strong) IBOutlet UILabel *subTitle;

- (void) setLayOut;

@end
