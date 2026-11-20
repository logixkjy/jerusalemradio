//
//  URLAddressManager.m
//  jerusalemradio
//
//  Created by JooYoung Kim on 2017. 5. 2..
//  Copyright © 2017년 JooYoung Kim. All rights reserved.
//

#import "URLAddressManager.h"
#import <AFNetworking.h>
#import <SBJson4.h>

static URLAddressManager* g_URLAddressManagerInstance = nil;
@implementation URLAddressManager

+ (URLAddressManager*)shared
{
    if( g_URLAddressManagerInstance == nil )
    {
        @synchronized(self)
        {
            if(g_URLAddressManagerInstance == nil)
            {
                g_URLAddressManagerInstance = [[self alloc] init];
            }
        }
    }
    
    return g_URLAddressManagerInstance;
}

+ (void)terminate
{
    if( g_URLAddressManagerInstance == nil ) return;
}

- (id) init {
    self = [super init];
    if (self != nil) {
        
    }
    return self;
}
+ (int)getLocal
{
    int local = 0;
    if ([[CommonUtil readObjectFromDefault:@"LANG_CODE"] isEqualToString:@"KR"]) {
        local = KR;
    } else if ([[CommonUtil readObjectFromDefault:@"LANG_CODE"] isEqualToString:@"ES"]) {
        local = ES;
    } else if ([[CommonUtil readObjectFromDefault:@"LANG_CODE"] isEqualToString:@"PT"]) {
        local = PT;
    }
    return local;
}

+ (NSString*)getURL:(int)local type:(int)type
{
    NSString *URL = @"";
    switch (local) {
        case KR:
            URL = [self getKR:type];
            break;
        case ES:
            URL = [self getES:type];
            break;
        case PT:
            URL = [self getPT:type];
            break;
    }
    return URL;
}

+ (NSString*)getKR:(int)type
{
    NSString *URL = @"";
    switch (type) {
        case LOGIN:
            URL = LOGIN_KR;
            break;
        case ADDRESS:
            URL = ADDRESS_KR;
            break;
        case LIVEINFO:
            URL = LIVEINFO_KR;
            break;
        case MAINIMAGE:
            URL = MAINIMAGE_KR;
            break;
        case PROGRAMLIST:
            URL = PROGRAMLIST_KR;
            break;
        case PROGRAMDETAILLIST:
            URL = PROGRAMDETAILLIST_KR;
            break;
        case COMMENTSLIST:
            URL = COMMENTSLIST_KR;
            break;
        case COMMENTSWRITE:
            URL = COMMENTSWRITE_KR;
            break;
        case COMMENTSDELETE:
            URL = COMMENTSDELETE_KR;
            break;
        case PAIRING:
            URL = PAIRING_KR;
            break;
        case JOIN:
            URL = JOIN_KR;
            break;
        case FINDID:
            URL = FINDID_KR;
            break;
        case FINDPW:
            URL = FINDPW_KR;
            break;
        case PLAYPREV:
            URL = PLAYPREV_KR;
            break;
        case PLAYNEXT:
            URL = PLAYNEXT_KR;
            break;
        case OPENBOARD:
            URL = OPENBOARD_KR;
            break;
        case LOGOUT:
            URL = LOGOUT_KR;
            break;
        case NOTICE:
            URL = NOTICE_KR;
            break;
        case WITHDRAWAL:
            URL = WITHDRAWAL_KR;
            break;
    }
    return URL;
}

+ (NSString*)getES:(int)type
{
    NSString *URL = @"";
    switch (type) {
        case LOGIN:
            URL = LOGIN_ES;
            break;
        case ADDRESS:
            URL = ADDRESS_ES;
            break;
        case LIVEINFO:
            URL = LIVEINFO_ES;
            break;
        case MAINIMAGE:
            URL = MAINIMAGE_ES;
            break;
        case PROGRAMLIST:
            URL = PROGRAMLIST_ES;
            break;
        case PROGRAMDETAILLIST:
            URL = PROGRAMDETAILLIST_ES;
            break;
        case COMMENTSLIST:
            URL = COMMENTSLIST_ES;
            break;
        case COMMENTSWRITE:
            URL = COMMENTSWRITE_ES;
            break;
        case COMMENTSDELETE:
            URL = COMMENTSDELETE_ES;
            break;
        case PAIRING:
            URL = PAIRING_ES;
            break;
        case JOIN:
            URL = JOIN_ES;
            break;
        case FINDID:
            URL = FINDID_ES;
            break;
        case FINDPW:
            URL = FINDPW_ES;
            break;
        case PLAYPREV:
            URL = PLAYPREV_ES;
            break;
        case PLAYNEXT:
            URL = PLAYNEXT_ES;
            break;
        case OPENBOARD:
            URL = OPENBOARD_ES;
            break;
        case LOGOUT:
            URL = LOGOUT_ES;
            break;
        case NOTICE:
            URL = NOTICE_KR;
            break;
        case WITHDRAWAL:
            URL = WITHDRAWAL_ES;
            break;
    }
    return URL;
}

+ (NSString*)getPT:(int)type
{
    NSString *URL = @"";
    switch (type) {
        case LOGIN:
            URL = LOGIN_PT;
            break;
        case ADDRESS:
            URL = ADDRESS_PT;
            break;
        case LIVEINFO:
            URL = LIVEINFO_PT;
            break;
        case MAINIMAGE:
            URL = MAINIMAGE_PT;
            break;
        case PROGRAMLIST:
            URL = PROGRAMLIST_PT;
            break;
        case PROGRAMDETAILLIST:
            URL = PROGRAMDETAILLIST_PT;
            break;
        case COMMENTSLIST:
            URL = COMMENTSLIST_PT;
            break;
        case COMMENTSWRITE:
            URL = COMMENTSWRITE_PT;
            break;
        case COMMENTSDELETE:
            URL = COMMENTSDELETE_PT;
            break;
        case PAIRING:
            URL = PAIRING_PT;
            break;
        case JOIN:
            URL = JOIN_PT;
            break;
        case FINDID:
            URL = FINDID_PT;
            break;
        case FINDPW:
            URL = FINDPW_PT;
            break;
        case PLAYPREV:
            URL = PLAYPREV_PT;
            break;
        case PLAYNEXT:
            URL = PLAYNEXT_PT;
            break;
        case OPENBOARD:
            URL = OPENBOARD_PT;
            break;
        case LOGOUT:
            URL = LOGOUT_PT;
            break;
        case NOTICE:
            URL = NOTICE_KR;
            break;
        case WITHDRAWAL:
            URL = WITHDRAWAL_PT;
            break;
    }
    return URL;
}

- (void)getLiveInfoCompletionHandler:(void (^)(NSDictionary *data, NSError *error))completionHandler
{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[URLAddressManager getURL:[URLAddressManager getLocal] type:LIVEINFO]]];
    
    [[NSURLSession.sharedSession dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *connectionError) {
        if (connectionError != nil) {
            completionHandler(nil, connectionError);
        } else {
            completionHandler([CommonUtil jsonParserWithData:data], connectionError);
        }
    }] resume];
}

- (void)getAddressListCompletionHandler:(void (^)(NSDictionary *data, NSError *error))completionHandler
{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[URLAddressManager getURL:[URLAddressManager getLocal] type:ADDRESS]]];
    
    [[NSURLSession.sharedSession dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *connectionError) {
        if (connectionError != nil) {
            completionHandler(nil, connectionError);
        } else {
            completionHandler([CommonUtil jsonParserWithData:data], connectionError);
        }
    }] resume];
}

- (void)getProgramInfo:(NSString*)url CompletionHandler:(void (^)(id data, NSError *error))completionHandler
{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
    
    [[NSURLSession.sharedSession dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *connectionError) {
        if (connectionError != nil) {
            completionHandler(nil, connectionError);
        } else {
            completionHandler([CommonUtil jsonParserWithData:data], connectionError);
        }
    }] resume];
}

- (void)getComments:(NSString*)url CompletionHandler:(void (^)(NSDictionary *data, NSError *error))completionHandler
{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
    
    [[NSURLSession.sharedSession dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *connectionError) {
        if (connectionError != nil) {
            completionHandler(nil, connectionError);
        } else {
            completionHandler([CommonUtil jsonParserWithData:data], connectionError);
        }
    }] resume];
}

- (void)sendRegistMembar:(NSString*)url memberID:(NSString*)memberID pw:(NSString*)pw pwConfirm:(NSString*)pwConfirm nickName:(NSString*)nickName mobile:(NSString*)mobile CompletionHandler:(void (^)(NSDictionary *data, NSError *error))completionHandler
{
    NSString *post = [NSString stringWithFormat:@"MB_ID=%@&MB_PW=%@&MB_PW_CONFIRM=%@&MB_NAME=%@&MB_PHONE=%@",memberID,pw,pwConfirm,nickName,mobile];
    NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%d", (int)[postData length]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"Mozilla/4.0 (compatible;)" forHTTPHeaderField:@"User-Agent"];
    [request setValue:@"jerusalem" forHTTPHeaderField:@"app_name"];
    [request setHTTPBody:postData];
    
    
    
    [[NSURLSession.sharedSession dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *connectionError) {
        if (connectionError != nil) {
            completionHandler(nil, connectionError);
        } else {
            NSLog(@"%s %@",__FUNCTION__,[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
            completionHandler([CommonUtil jsonParserWithData:data], connectionError);
        }
    }] resume];
}

- (void)sendLogin:(NSString*)url uid:(NSString*)uid upw:(NSString*)upw CompletionHandler:(void (^)(NSDictionary *data, NSError *error))completionHandler
{
    NSString *post = [NSString stringWithFormat:@"uid=%@&upw=%@",uid,upw];
    NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%d", (int)[postData length]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"Mozilla/4.0 (compatible;)" forHTTPHeaderField:@"User-Agent"];
    [request setValue:@"jerusalem" forHTTPHeaderField:@"app_name"];
    [request setHTTPBody:postData];
    
    
    
    [[NSURLSession.sharedSession dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *connectionError) {
        if (connectionError != nil) {
            completionHandler(nil, connectionError);
        } else {
            completionHandler([CommonUtil jsonParserWithData:data], connectionError);
        }
    }] resume];
}

- (void)sendLogout:(NSString*)url uid:(NSString*)uid CompletionHandler:(void (^)(NSDictionary *data, NSError *error))completionHandler
{
    NSString *post = [NSString stringWithFormat:@"MB_ID=%@",uid];
    NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%d", (int)[postData length]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"Mozilla/4.0 (compatible;)" forHTTPHeaderField:@"User-Agent"];
    [request setValue:GetCommonData.MB_TOKEN forHTTPHeaderField:@"MB_TOKEN"];
    [request setHTTPBody:postData];
    
    
    
    [[NSURLSession.sharedSession dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *connectionError) {
        if (connectionError != nil) {
            completionHandler(nil, connectionError);
        } else {
            completionHandler([CommonUtil jsonParserWithData:data], connectionError);
        }
    }] resume];
}

- (void)idRequest:(NSString*)url nickName:(NSString*)nickName mobile:(NSString*)mobile CompletionHandler:(void (^)(NSDictionary *data, NSError *error))completionHandler
{
    NSString *post = [NSString stringWithFormat:@"MB_NAME=%@&MB_PHONE=%@",nickName,mobile];
    NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%d", (int)[postData length]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"Mozilla/4.0 (compatible;)" forHTTPHeaderField:@"User-Agent"];
    [request setValue:@"jerusalem" forHTTPHeaderField:@"app_name"];
    [request setHTTPBody:postData];
    
    
    
    [[NSURLSession.sharedSession dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *connectionError) {
        if (connectionError != nil) {
            completionHandler(nil, connectionError);
        } else {
            completionHandler([CommonUtil jsonParserWithData:data], connectionError);
        }
    }] resume];
}

- (void)pwdRequest:(NSString*)url memberID:(NSString*)memberID CompletionHandler:(void (^)(NSDictionary *data, NSError *error))completionHandler
{
    NSString *post = [NSString stringWithFormat:@"MB_ID=%@",memberID];
    NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%d", (int)[postData length]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"Mozilla/4.0 (compatible;)" forHTTPHeaderField:@"User-Agent"];
    [request setValue:@"jerusalem" forHTTPHeaderField:@"app_name"];
    [request setHTTPBody:postData];
    
    
    
    [[NSURLSession.sharedSession dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *connectionError) {
        if (connectionError != nil) {
            completionHandler(nil, connectionError);
        } else {
            completionHandler([CommonUtil jsonParserWithData:data], connectionError);
        }
    }] resume];
}

- (void)writeComments:(NSString*)url prID:(NSString*)prID mbID:(NSString*)mbID prContent:(NSString*)prContent CompletionHandler:(void (^)(NSDictionary *data, NSError *error))completionHandler
{
    NSString *post = [NSString stringWithFormat:@"PR_ID=%@&MB_ID=%@&PR_CO_CONTENT=%@",prID, mbID, prContent];
    NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%d", (int)[postData length]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"Mozilla/4.0 (compatible;)" forHTTPHeaderField:@"User-Agent"];
    [request setValue:GetCommonData.MB_TOKEN forHTTPHeaderField:@"MB_TOKEN"];
    [request setHTTPBody:postData];
    
    
    
    [[NSURLSession.sharedSession dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *connectionError) {
        if (connectionError != nil) {
            completionHandler(nil, connectionError);
        } else {
            completionHandler([CommonUtil jsonParserWithData:data], connectionError);
        }
    }] resume];
}

- (void)deleteComments:(NSString*)url mbID:(NSString*)mbID CompletionHandler:(void (^)(NSDictionary *data, NSError *error))completionHandler
{
    NSString *post = [NSString stringWithFormat:@"MB_ID=%@",mbID];
    NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%d", (int)[postData length]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:GetCommonData.MB_TOKEN forHTTPHeaderField:@"MB_TOKEN"];
    [request setHTTPBody:postData];
    
    
    [[NSURLSession.sharedSession dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *connectionError) {
        if (connectionError != nil) {
            completionHandler(nil, connectionError);
        } else {
            completionHandler([CommonUtil jsonParserWithData:data], connectionError);
        }
    }] resume];
}

- (void)getProgramList:(NSString*)url CompletionHandler:(void (^)(id data, NSError *error))completionHandler
{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
    
    [[NSURLSession.sharedSession dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *connectionError) {
        if (connectionError != nil) {
            completionHandler(nil, connectionError);
        } else {
            completionHandler([CommonUtil jsonParserWithData:data], connectionError);
        }
    }] resume];
}

- (void)sendWithdrawal:(NSString*)userID CompletionHandler:(void (^)(NSDictionary *data, NSError *error))completionHandler
{
    NSString *post = [NSString stringWithFormat:@"MB_ID=%@",userID];
    NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%d", (int)[postData length]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[URLAddressManager getURL:[URLAddressManager getLocal] type:WITHDRAWAL]]];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"Mozilla/4.0 (compatible;)" forHTTPHeaderField:@"User-Agent"];
    [request setValue:GetCommonData.MB_TOKEN forHTTPHeaderField:@"MB_TOKEN"];
    [request setHTTPBody:postData];
    
    
    
    [[NSURLSession.sharedSession dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *connectionError) {
        if (connectionError != nil) {
            completionHandler(nil, connectionError);
        } else {
            completionHandler([CommonUtil jsonParserWithData:data], connectionError);
        }
    }] resume];
}

@end
