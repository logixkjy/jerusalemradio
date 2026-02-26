//
//  URLAddressManager.h
//  jerusalemradio
//
//  Created by JooYoung Kim on 2017. 5. 2..
//  Copyright © 2017년 JooYoung Kim. All rights reserved.
//

#import <Foundation/Foundation.h>

#define GetURLAddressManager [URLAddressManager shared]

//#define BASE_URL                    @"http://jerusalemradio.net"
//
//#define LOGIN                       [BASE_URL stringByAppendingPathComponent:@"api/auth/login"]
//#define ADDRESS                     [BASE_URL stringByAppendingPathComponent:@"assets/json/streaming/address.json"]
//#define LIVEINFO                    [BASE_URL stringByAppendingPathComponent:@"assets/json/streaming/liveinfo.json"]
//#define MAINIMAGE               [BASE_URL stringByAppendingFormat:@"/uploads/program/%@.jpg"]
//#define MAINIMAGE2               [BASE_URL stringByAppendingFormat:@"/uploads/program/%@"]
//#define PROGRAMLIST                 [BASE_URL stringByAppendingPathComponent:@"api/program/getList"]
//#define PROGRAMDETAILLIST   [BASE_URL stringByAppendingFormat:@"/api/program/view/PR_ID/%@/page/%@"]
//#define COMMENTSLIST            [BASE_URL stringByAppendingFormat:@"/api/comments/getList/PR_ID/%@"]
//#define COMMENTSWRITE               [BASE_URL stringByAppendingPathComponent:@"api/comments/write"]
//#define COMMENTSDELETE          [BASE_URL stringByAppendingFormat:@"/api/comments/delete/PR_CO_ID/%@"]
//#define PAIRING                     [BASE_URL stringByAppendingPathComponent:@"api/listings"]
//#define JOIN                        [BASE_URL stringByAppendingPathComponent:@"member/join"]
//#define RECOVERY                    [BASE_URL stringByAppendingPathComponent:@"member/recovery"]
//#define PLAYPREV            [BASE_URL stringByAppendingFormat:@"/api/content/getPrev/PR_ID/%@/CT_NO/%@"]
//#define PLAYNEXT            [BASE_URL stringByAppendingFormat:@"/api/content/getNext/PR_ID/%@/CT_NO/%@"]
//#define BOARD                   [BASE_URL stringByAppendingFormat:@"/board/index/PR_ID/%@"]
//#define SIGNUP                      [BASE_URL stringByAppendingPathComponent:@"api/auth/signup"]
//#define ID_REQUEST                  [BASE_URL stringByAppendingPathComponent:@"api/auth/idRequest"]
//#define PWD_REQUEST                 [BASE_URL stringByAppendingPathComponent:@"api/auth/pwdRequest"]
//#define OPEN_BOARD                  [BASE_URL stringByAppendingPathComponent:@"api/auth/openBoardFromApp"]
//#define LOGOUT                      [BASE_URL stringByAppendingPathComponent:@"api/auth/logoutInput"]

#define TOKEN_SEND                      @"https://www.goodnews.or.kr/adm/notification/registerDevice"

#define BASE_URL_KR                     @"https://jerusalemradio.net"
#define BASE_URL_ES                     @"https://es.jerusalemradio.net"
#define BASE_URL_PT                     @"https://br.jerusalemradio.net"

// 한국어
#define LOGIN_KR                        [BASE_URL_KR stringByAppendingPathComponent:@"/api/auth/login"]
#define ADDRESS_KR                      [BASE_URL_KR stringByAppendingPathComponent:@"/assets/json/streaming/address.json"]
#define LIVEINFO_KR                     @"https://jerusalem.airtime.pro/api/live-info-v2?timezone=seoul"
#define MAINIMAGE_KR                    [BASE_URL_KR stringByAppendingPathComponent:@"/uploads/program/%@"]
#define PROGRAMLIST_KR                  [BASE_URL_KR stringByAppendingPathComponent:@"/api/program/getList"]
#define PROGRAMDETAILLIST_KR            [BASE_URL_KR stringByAppendingPathComponent:@"/api/program/view/PR_ID/%@/page/%@"]
#define COMMENTSLIST_KR                 [BASE_URL_KR stringByAppendingPathComponent:@"/api/comments/getList/PR_ID/%@"]
#define COMMENTSWRITE_KR                [BASE_URL_KR stringByAppendingPathComponent:@"/api/comments/write"]
#define COMMENTSDELETE_KR               [BASE_URL_KR stringByAppendingPathComponent:@"/api/comments/delete/PR_CO_ID/%@"]
#define PAIRING_KR                      [BASE_URL_KR stringByAppendingPathComponent:@"/api/listings"]
#define JOIN_KR                         [BASE_URL_KR stringByAppendingPathComponent:@"/api/auth/signup"]
#define FINDID_KR                       [BASE_URL_KR stringByAppendingPathComponent:@"/api/auth/idRequest"]
#define FINDPW_KR                       [BASE_URL_KR stringByAppendingPathComponent:@"/api/auth/pwdRequest"]
#define PLAYPREV_KR                     [BASE_URL_KR stringByAppendingPathComponent:@"/api/content/getPrev/PR_ID/%@/CT_NO/%@"]
#define PLAYNEXT_KR                     [BASE_URL_KR stringByAppendingPathComponent:@"/api/content/getNext/PR_ID/%@/CT_NO/%@"]
#define OPENBOARD_KR                    [BASE_URL_KR stringByAppendingPathComponent:@"/api/auth/openBoardFromApp?MB_ID=%@&MB_TOKEN=%@&PR_ID=%@"]
#define LOGOUT_KR                       [BASE_URL_KR stringByAppendingPathComponent:@"api/auth/logoutInput"]
#define NOTICE_KR                       @"http://jerusalemradio.net/notice_app?isApp=yes"

#define PROGRAM_SHARE_KR                @"https://jerusalemradio.net/share/program/p/"

#define CONTENT_SHARE_KR                @"https://jerusalemradio.net/share/content/c/"
#define CONTENT_GET_INFO_KR             @"https://jerusalemradio.net/api/content/getInfo/CT_NO/"

// 스페인어
#define LOGIN_ES                        [BASE_URL_ES stringByAppendingPathComponent:@"/api/auth/login"]
#define ADDRESS_ES                      [BASE_URL_ES stringByAppendingPathComponent:@"/assets_es/json/streaming/addressEs.json"]
#define LIVEINFO_ES                     @"https://jerusalemfmradio.airtime.pro/api/live-info-v2"
#define MAINIMAGE_ES                    [BASE_URL_ES stringByAppendingPathComponent:@"/uploads_es/program/%@"]
#define PROGRAMLIST_ES                  [BASE_URL_ES stringByAppendingPathComponent:@"/api/program/getList"]
#define PROGRAMDETAILLIST_ES            [BASE_URL_ES stringByAppendingPathComponent:@"/api/program/view/PR_ID/%@/page/%@"]
#define COMMENTSLIST_ES                 [BASE_URL_ES stringByAppendingPathComponent:@"/api/comments/getList/PR_ID/%@"]
#define COMMENTSWRITE_ES                [BASE_URL_ES stringByAppendingPathComponent:@"/api/comments/write"]
#define COMMENTSDELETE_ES               [BASE_URL_ES stringByAppendingPathComponent:@"/api/comments/delete/PR_CO_ID/%@"]
#define PAIRING_ES                      [BASE_URL_ES stringByAppendingPathComponent:@"/api/listings"]
#define JOIN_ES                         [BASE_URL_ES stringByAppendingPathComponent:@"/api/auth/signup"]
#define FINDID_ES                       [BASE_URL_ES stringByAppendingPathComponent:@"/api/auth/idRequest"]
#define FINDPW_ES                       [BASE_URL_ES stringByAppendingPathComponent:@"/api/auth/pwdRequest"]
#define PLAYPREV_ES                     [BASE_URL_ES stringByAppendingPathComponent:@"/api/content/getPrev/PR_ID/%@/CT_NO/%@"]
#define PLAYNEXT_ES                     [BASE_URL_ES stringByAppendingPathComponent:@"/api/content/getNext/PR_ID/%@/CT_NO/%@"]
#define OPENBOARD_ES                    [BASE_URL_ES stringByAppendingPathComponent:@"/api/auth/openBoardFromApp?MB_ID=%@&MB_TOKEN=%@&PR_ID=%@"]
#define LOGOUT_ES                       [BASE_URL_ES stringByAppendingPathComponent:@"api/auth/logoutInput"]

// 포루투갈어
#define LOGIN_PT                        [BASE_URL_PT stringByAppendingPathComponent:@"/api/auth/login"]
#define ADDRESS_PT                      [BASE_URL_PT stringByAppendingPathComponent:@"/assets_br/json/streaming/addressBr.json"]
#define LIVEINFO_PT                     @"https://radiojerusalem.airtime.pro/api/live-info-v2"
#define MAINIMAGE_PT                    [BASE_URL_PT stringByAppendingPathComponent:@"/uploads_br/program/%@"]
#define PROGRAMLIST_PT                  [BASE_URL_PT stringByAppendingPathComponent:@"/api/program/getList"]
#define PROGRAMDETAILLIST_PT            [BASE_URL_PT stringByAppendingPathComponent:@"/api/program/view/PR_ID/%@/page/%@"]
#define COMMENTSLIST_PT                 [BASE_URL_PT stringByAppendingPathComponent:@"/api/comments/getList/PR_ID/%@"]
#define COMMENTSWRITE_PT                [BASE_URL_PT stringByAppendingPathComponent:@"/api/comments/write"]
#define COMMENTSDELETE_PT               [BASE_URL_PT stringByAppendingPathComponent:@"/api/comments/delete/PR_CO_ID/%@"]
#define PAIRING_PT                      [BASE_URL_PT stringByAppendingPathComponent:@"/api/listings"]
#define JOIN_PT                         [BASE_URL_PT stringByAppendingPathComponent:@"/api/auth/signup"]
#define FINDID_PT                       [BASE_URL_PT stringByAppendingPathComponent:@"/api/auth/idRequest"]
#define FINDPW_PT                       [BASE_URL_PT stringByAppendingPathComponent:@"/api/auth/pwdRequest"]
#define PLAYPREV_PT                     [BASE_URL_PT stringByAppendingPathComponent:@"/api/content/getPrev/PR_ID/%@/CT_NO/%@"]
#define PLAYNEXT_PT                     [BASE_URL_PT stringByAppendingPathComponent:@"/api/content/getNext/PR_ID/%@/CT_NO/%@"]
#define OPENBOARD_PT                    [BASE_URL_PT stringByAppendingPathComponent:@"/api/auth/openBoardFromApp?MB_ID=%@&MB_TOKEN=%@&PR_ID=%@"]
#define LOGOUT_PT                       [BASE_URL_PT stringByAppendingPathComponent:@"api/auth/logoutInput"]


#define WITHDRAWAL_KR                   [BASE_URL_KR stringByAppendingPathComponent:@"api/auth/withdrawal"]
#define WITHDRAWAL_ES                   [BASE_URL_ES stringByAppendingPathComponent:@"api/auth/withdrawal"]
#define WITHDRAWAL_PT                   [BASE_URL_PT stringByAppendingPathComponent:@"api/auth/withdrawal"]

#define TEST_PR_ID @"002002"

#define KR                  1 // 한국어
#define CN                  2 // 중국어
#define ES                  3 // 스페인어
#define PT                  4 // 포루투갈어

#define LOGIN               1
#define ADDRESS             2
#define LIVEINFO            3
#define MAINIMAGE           4
#define PROGRAMLIST         5
#define PROGRAMDETAILLIST   6
#define COMMENTSLIST        7
#define COMMENTSWRITE       8
#define COMMENTSDELETE      9
#define PAIRING             10
#define JOIN                11
#define FINDID              12
#define FINDPW              13
#define PLAYPREV            14
#define PLAYNEXT            15
#define OPENBOARD           16
#define LOGOUT              17
#define NOTICE              18
#define WITHDRAWAL          19

@interface URLAddressManager : NSObject

+ (URLAddressManager*)shared;
+ (void)terminate;

+ (int)getLocal;
+ (NSString*)getURL:(int)local type:(int)type;
- (void)getAddressListCompletionHandler:(void (^)(NSDictionary *data, NSError *error))completionHandler;
- (void)getLiveInfoCompletionHandler:(void (^)(NSDictionary *data, NSError *error))completionHandler;
- (void)getProgramInfo:(NSString*)url CompletionHandler:(void (^)(id data, NSError *error))completionHandler;
- (void)getComments:(NSString*)url CompletionHandler:(void (^)(NSDictionary *data, NSError *error))completionHandler;
- (void)sendRegistMembar:(NSString*)url memberID:(NSString*)memberID pw:(NSString*)pw pwConfirm:(NSString*)pwConfirm nickName:(NSString*)nickName mobile:(NSString*)mobile CompletionHandler:(void (^)(NSDictionary *data, NSError *error))completionHandler;
- (void)idRequest:(NSString*)url nickName:(NSString*)nickName mobile:(NSString*)mobile CompletionHandler:(void (^)(NSDictionary *data, NSError *error))completionHandler;
- (void)pwdRequest:(NSString*)url memberID:(NSString*)memberID CompletionHandler:(void (^)(NSDictionary *data, NSError *error))completionHandler;
- (void)sendLogin:(NSString*)url uid:(NSString*)uid upw:(NSString*)upw CompletionHandler:(void (^)(NSDictionary *data, NSError *error))completionHandler;
- (void)sendLogout:(NSString*)url uid:(NSString*)uid CompletionHandler:(void (^)(NSDictionary *data, NSError *error))completionHandler;
- (void)writeComments:(NSString*)url prID:(NSString*)prID mbID:(NSString*)mbID prContent:(NSString*)prContent CompletionHandler:(void (^)(NSDictionary *data, NSError *error))completionHandler;
- (void)deleteComments:(NSString*)url mbID:(NSString*)mbID CompletionHandler:(void (^)(NSDictionary *data, NSError *error))completionHandler;
- (void)getProgramList:(NSString*)url CompletionHandler:(void (^)(id data, NSError *error))completionHandler;

- (void)sendWithdrawal:(NSString*)userID CompletionHandler:(void (^)(NSDictionary *data, NSError *error))completionHandler;

@end
