//
//  CommonData.m
//  jerusalemradio
//
//  Created by JooYoung Kim on 2017. 5. 4..
//  Copyright © 2017년 JooYoung Kim. All rights reserved.
//

#import "CommonData.h"

static CommonData* g_CommonDataInstance = nil;
@implementation CommonData

+ (CommonData*)shared
{
    if( g_CommonDataInstance == nil )
    {
        @synchronized(self)
        {
            if(g_CommonDataInstance == nil)
            {
                g_CommonDataInstance = [[self alloc] init];
            }
        }
    }
    
    return g_CommonDataInstance;
}

+ (void)terminate
{
    if( g_CommonDataInstance == nil ) return;
}

- (id) init {
    self = [super init];
    if (self != nil) {
        self.metadata = [NSDictionary dictionary];
        self.isLogin = NO;
        self.liveTimeInterval = 0;
        self.isShowPUSH_URL         = NO;
        self.isShowModalView        = NO;
        self.PUSH_URL               = @"";
        self.CURRENT_URL            = @"";
        self.MODAL_URL              = @"";
        self.MAIN_URLstring         = @"";
        self.str_MAIN_URL           = @"";
    }
    return self;
}
@end
