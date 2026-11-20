//
//  CommonData.h
//  jerusalemradio
//
//  Created by JooYoung Kim on 2017. 5. 4..
//  Copyright © 2017년 JooYoung Kim. All rights reserved.
//

#import <Foundation/Foundation.h>
#define GetCommonData [CommonData shared]

@interface CommonData : NSObject
@property (nonatomic, strong) NSDictionary *metadata;
@property (nonatomic, strong) NSDictionary *current;
@property (nonatomic, strong) NSDictionary *showsCurrent;
@property (nonatomic, strong) NSString *liveType;
@property (nonatomic, strong) NSString *audio_mode;
@property (nonatomic, assign) BOOL isLogin;

@property (nonatomic, strong) NSString *MB_ID;
@property (nonatomic, strong) NSString *MB_NAME;
@property (nonatomic, strong) NSString *MB_TOKEN;
@property (nonatomic, strong) NSString *MB_TYPE;

@property (nonatomic, strong) UIImage *thum;

@property (nonatomic, assign) int liveTimeInterval;
@property (nonatomic, assign) int pauseTimeInterval;
@property (nonatomic, assign) int backgroudPauseTimeInterval;


@property (nonatomic)         BOOL isShowPUSH_URL;
@property (nonatomic)         BOOL isShowModalView;

@property (nonatomic, strong) NSString *PUSH_URL;
@property (nonatomic, strong) NSString *MAIN_URLstring;
@property (nonatomic, strong) NSString *str_MAIN_URL;
@property (nonatomic, strong) NSString *CURRENT_URL;
@property (nonatomic, strong) NSString *MODAL_URL;

@property (nonatomic, strong) NSString *CT_NO;
@property (nonatomic, strong) NSString *PR_ID;
@property (nonatomic, strong) NSDictionary *aodData;
@property (nonatomic, copy) NSArray<NSDictionary *> *playingAODGroupItems;
@property (nonatomic, strong) NSDictionary *aodMetaData;

@property (nonatomic, strong) NSDictionary *schemesData;

+ (CommonData*)shared;
+ (void)terminate;

@end
