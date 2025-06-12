//
//  GPCommonUtil.h
//  GoodNewsPodcast
//
//  Created by 김주영 on 2014. 7. 14..
//  Copyright (c) 2014년 GoodNews. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CommonUtil : NSObject

+ (CGFloat)getSafaAreaTop;
+ (CGFloat)getSafaAreaBottom;

+ (float)resizeFor720:(float)size;
+ (BOOL)isiPhoneXScreen;
+ (NSString*)changeString:(NSString*)str;
+ (NSInteger)CheckNetworkEnable;
+ (NSString *)md5StringForString:(NSString *)string;
+ (NSString *)cacheFolder;
+ (id)connetcionNetworkWithURL:(NSURL*)url;
+ (id)jsonParser:(NSString*)str;
+ (id)jsonParserWithData:(NSData*)data;
+ (NSString*)jsonStringFromDictionary:(NSDictionary*)data;
+ (NSString*)getChangeDateFormat:(NSString *)pDate tdateFormat:(NSString*)format changeDateFormat:(NSString*)cFormat;
+ (NSString*)getPassedTime:(NSString*)time;

+ (void) writeIntToDefault:(int) nValue KEY:(NSString *)strKey;
+ (int) readIntFromDefault:(NSString *)strKey;
+ (void) writeObjectToDefault:(id)idValue KEY:(NSString *)strKey;
+ (id) readObjectFromDefault:(NSString *)strKey;
+ (void) writeBoolToDefault:(BOOL)bValue KEY:(NSString *)strKey;
+ (BOOL) readBoolFromDefault:(NSString *)strKey;
+ (void) writeFloatToDefault:(float) fValue KEY:(NSString *)strKey;
+ (float) readFloatFromDefault:(NSString *)strKey;

@end

@interface UIViewController (NavigationBar)

+ (void)globalResignFirstResponderView:(UIView*) view;
+ (void)globalResignFirstResponder;
@end

@interface UIFont (DPI)
+ (UIFont *)systemFontOfSizeForDpi:(CGFloat)fontSize;

+ (UIFont *_Nullable)systemFontOfSize720:(CGFloat)size;
+ (UIFont *_Nullable)systemFontOfSize720:(CGFloat)size weight:(UIFontWeight)weight;
+ (UIFont *_Nullable)boldSystemFontOfSize720:(CGFloat)size;
@end

#import <objc/runtime.h>

typedef void (^ActionBlock)(id sender);

@interface UIButton (TranggleExtend)

@property (readonly) NSMutableDictionary *event;
- (void) handleControlEvent:(UIControlEvents)controlEvent withBlock:(ActionBlock)action;
- (void)centerVerticallyWithPadding:(float)padding;
- (void)centerVertically;

@end

@interface NSString (utility)

- (int) indexOf:(NSString *)text;
- (NSString *)URLDecode;
- (NSString *)URLEncode;
- (NSString *)urlEncodeUsingEncoding:(NSStringEncoding)encoding;

@end

