    //
//  GPCommonUtil.m
//  GoodNewsPodcast
//
//  Created by 김주영 on 2014. 7. 14..
//  Copyright (c) 2014년 GoodNews. All rights reserved.
//

#import "CommonUtil.h"
#import <Reachability.h>
#import <CommonCrypto/CommonDigest.h>
#import <SBJson4.h>

@implementation CommonUtil

+ (CGFloat)getSafaAreaTop
{
    if (@available(iOS 11.0, *)) {
        UIWindow *window = UIApplication.sharedApplication.windows.firstObject;
        CGFloat top = window.safeAreaInsets.top;
        return top;
    }
    return 20.f;
}

+ (CGFloat)getSafaAreaBottom
{
    if (@available(iOS 11.0, *)) {
        UIWindow *window = UIApplication.sharedApplication.windows.firstObject;
        CGFloat bottom = window.safeAreaInsets.bottom;
        return bottom;
    }
    return 0.f;
}

+ (float)resizeFor720:(float)size
{
    float resize = (MAIN_SIZE().width * size) / 720;
    return resize;
}

+ (BOOL)isiPhoneXScreen {
    if (@available(iOS 11.0, *)) {
        UIEdgeInsets edgeInsets = [UIApplication sharedApplication].windows[0].safeAreaInsets;
        if (edgeInsets.top != 0 && edgeInsets.bottom != 0) {
            return YES;
        }
    } else {
        return NO;
    }
    return NO;
}

+ (NSString*)changeString:(NSString*)str {
    str = [str stringByReplacingOccurrencesOfString:@"[" withString:@""];
    str = [str stringByReplacingOccurrencesOfString:@"]" withString:@""];
    str = [str stringByReplacingOccurrencesOfString:@"/" withString:@"-"];
    str = [str stringByReplacingOccurrencesOfString:@" " withString:@""];
    str = [str stringByReplacingOccurrencesOfString:@"&" withString:@"and"];
    
    return str;
}

+ (NSInteger)CheckNetworkEnable {
    Reachability *isConnect = [Reachability reachabilityForInternetConnection];
    return [isConnect currentReachabilityStatus];
}

+ (NSString *)cacheFolder {
    NSFileManager *filemgr = [NSFileManager new];
    static NSString *cacheFolder;
    
    if (!cacheFolder) {
        NSString *cacheDir = NSTemporaryDirectory();
        cacheFolder = [cacheDir stringByAppendingPathComponent:kAFNetworkingIncompleteDownloadFolderName];
    }
    
    // ensure all cache directories are there
    NSError *error = nil;
    if(![filemgr createDirectoryAtPath:cacheFolder withIntermediateDirectories:YES attributes:nil error:&error]) {
        NSLog(@"Failed to create cache directory at %@", cacheFolder);
        cacheFolder = nil;
    }
    return cacheFolder;
}

// calculates the MD5 hash of a key
+ (NSString *)md5StringForString:(NSString *)string {
    const char *str = [string UTF8String];
    unsigned char r[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, (uint32_t)strlen(str), r);
    return [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            r[0], r[1], r[2], r[3], r[4], r[5], r[6], r[7], r[8], r[9], r[10], r[11], r[12], r[13], r[14], r[15]];
}

+ (id)connetcionNetworkWithURL:(NSURL*)url {
    NSError             *error  = nil;
    NSMutableURLRequest *request = [NSMutableURLRequest
                                    requestWithURL:url
                                    cachePolicy:NSURLRequestReloadIgnoringCacheData
                                    timeoutInterval:60.0f];
    
    NSData *dataBuffer = [NSURLConnection sendSynchronousRequest:request returningResponse: nil error: &error];
    
    if (error) {
        return error;
    }else {
        return [CommonUtil jsonParserWithData:dataBuffer];
    }
    
    return nil;
}

// json데이터 파싱
+(id)jsonParser:(NSString*)str {
    __block id object = nil;
    SBJson4ValueBlock block = ^(id obj, BOOL *stop) {
        object = obj;
    };
    
    SBJson4ErrorBlock eh = ^(NSError* err){
        NSLog(@"Oops: %@",err);
    };
    
    id parser = [SBJson4Parser multiRootParserWithBlock:block
                                           errorHandler:eh];
    
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    SBJson4ParserStatus status = [parser parse:data];
    
    NSLog(@"Status: %u",status);
    
    return object;
}

// json데이터 파싱
+(id)jsonParserWithData:(NSData*)data {
    __block id object = nil;
    SBJson4ValueBlock block = ^(id obj, BOOL *stop) {
        object = obj;
    };
    
    SBJson4ErrorBlock eh = ^(NSError* err){
        NSLog(@"Oops: %@",err);
    };
    
    id parser = [SBJson4Parser multiRootParserWithBlock:block
                                           errorHandler:eh];
    
    SBJson4ParserStatus status = [parser parse:data];
    
    NSLog(@"Status: %u",status);
    
    return object;
}

// json데이터
+(NSString*)jsonStringFromDictionary:(NSDictionary*)data {
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:data
                                                       options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
                                                         error:&error];
    
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

+ (NSString*)getPassedTime:(NSString*)time
{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"Asia/Seoul"];
    [dateFormat setTimeZone:timeZone];
    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];

    NSString *str_time = @"";
    int now = (int)[NSDate timeIntervalSinceReferenceDate];
    int passTime = (int)[[dateFormat dateFromString:time] timeIntervalSinceReferenceDate];
    int bTime = now - passTime;
    if (bTime >= 59) {
        bTime = bTime/60;
        if (bTime >= 59) {
            bTime = bTime/60;
            if (bTime <= 24) {
                str_time = [NSString stringWithFormat:@"%ld시간 전",(long)bTime];
            } else {
                str_time = [self getChangeDateFormat:time tdateFormat:@"yyyy-MM-dd HH:mm:ss" changeDateFormat:@"yyyy-MM-dd"];
            }
        } else {
            str_time = [NSString stringWithFormat:@"%ld분 전",(long)bTime];
        }
    } else {
        str_time = [NSString stringWithFormat:@"%ld초 전",(long)bTime];
    }
    
    return str_time;
}

+ (NSString*)getChangeDateFormat:(NSString *)pDate tdateFormat:(NSString*)format changeDateFormat:(NSString*)cFormat
{
    pDate = [pDate stringByReplacingOccurrencesOfString:@"T" withString:@" "];
    pDate = [pDate stringByReplacingOccurrencesOfString:@"Z" withString:@""];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"Asia/Seoul"];
    [dateFormat setTimeZone:timeZone];
    
    if ([format length] > 0) {
        [dateFormat setDateFormat:format];
    }else {
        [dateFormat setDateFormat:@"yyyyMMdd"];
    }
    
    NSDate *date = [dateFormat dateFromString:pDate];
    if ([cFormat length] > 0) {
        [dateFormat setDateFormat:cFormat];
    }else {
        [dateFormat setDateFormat:@"yyyyMMdd"];
    }
    
    return [dateFormat stringFromDate:date];
}

#pragma mark -------------------------------------------------------------------
#pragma mark < NSUserDefaults Methods >

+ (void) writeIntToDefault:(int) nValue KEY:(NSString *)strKey
{
	NSUserDefaults *defaults;
	defaults = NUD;
    
	[defaults setInteger:nValue forKey:strKey];
	[defaults synchronize];
}

+ (int) readIntFromDefault:(NSString *)strKey
{
	NSUserDefaults *defaults;
	defaults = NUD;
    
	return [defaults integerForKey:strKey];
}

+ (void) writeObjectToDefault:(id)idValue KEY:(NSString *)strKey
{
	NSUserDefaults *defaults;
	defaults = NUD;
	
	[defaults setObject:idValue forKey:strKey];
	[defaults synchronize];
}

+ (id) readObjectFromDefault:(NSString *)strKey
{
	NSUserDefaults *defaults;
	defaults = NUD;
    
	return [defaults objectForKey:strKey];
}

+ (void) writeBoolToDefault:(BOOL)bValue KEY:(NSString *)strKey
{
	NSUserDefaults *defaults;
	defaults = NUD;
	
	[defaults setBool:bValue forKey:strKey];
	[defaults synchronize];
}

+(BOOL) readBoolFromDefault:(NSString *)strKey
{
	NSUserDefaults *defaults;
	defaults = NUD;
    
	return [defaults boolForKey:strKey];
}

+ (void) writeFloatToDefault:(float) fValue KEY:(NSString *)strKey
{
	NSUserDefaults *defaults;
	defaults = NUD;
	
	[defaults setFloat:fValue forKey:strKey];
	[defaults synchronize];
}

+(float) readFloatFromDefault:(NSString *)strKey
{
	NSUserDefaults *defaults;
	defaults = NUD;
	
	return [defaults floatForKey:strKey];
}
@end

@implementation UIViewController (NavigationBar)

+ (void)globalResignFirstResponderView:(UIView*) view {
    
    if ([view respondsToSelector:@selector(resignFirstResponder)]){
        if ([view isFirstResponder]) {
            [view resignFirstResponder];
        }
    }
    
    for (UIView * subview in [view subviews]){
        [self globalResignFirstResponderView:subview];
    }
}

+ (void)globalResignFirstResponder {
    UIWindow * window = [[UIApplication sharedApplication] keyWindow];
    for (UIView * view in [window subviews]){
        [self globalResignFirstResponderView:view];
    }
}
@end

@implementation UIFont (DPI)

+ (UIFont *)systemFontOfSizeForDpi:(CGFloat)fontSize
{
    float retFont = 0;
    retFont = fontSize * (MAIN_SIZE().width == 320 ? 0 : (MAIN_SIZE().width == 375 ? 0.1 : 0.2));
    return [UIFont systemFontOfSize:fontSize+retFont];
}

+ (UIFont *)systemFontOfSize720:(CGFloat)size
{
    CGFloat retFont = 0;
    retFont = size * MAIN_SIZE().width / 720;
    return [self systemFontOfSize:retFont];
}

+ (UIFont *)systemFontOfSize720:(CGFloat)size weight:(UIFontWeight)weight
{
    CGFloat retFont = 0;
    retFont = size * MAIN_SIZE().width / 720;
    return [self systemFontOfSize:retFont weight:weight];
}

+ (UIFont *)boldSystemFontOfSize720:(CGFloat)size
{
    CGFloat retFont = 0;
    retFont = size * MAIN_SIZE().width / 720;
    return [self boldSystemFontOfSize:retFont];
}
@end


@implementation UIButton (TranggleExtend)
static char overviewKey;
@dynamic event;
- (void)handleControlEvent:(UIControlEvents)event withBlock:(ActionBlock)block {
    objc_setAssociatedObject(self, &overviewKey, block, OBJC_ASSOCIATION_COPY_NONATOMIC);
    [self addTarget:self action:@selector(callActionBlock:) forControlEvents:event];
}

- (void)callActionBlock:(id)sender {
    ActionBlock block = (ActionBlock)objc_getAssociatedObject(self, &overviewKey);
    if (block) {
        block(sender);
    }
}

- (void)centerVerticallyWithPadding:(float)padding
{
    CGSize imageSize = self.imageView.frame.size;
    CGSize titleSize = [self.titleLabel.text sizeWithAttributes: @{NSFontAttributeName:self.titleLabel.font}];
    
    CGFloat totalHeight = (imageSize.height + titleSize.height + padding);
    
    self.imageEdgeInsets = UIEdgeInsetsMake(- (totalHeight - imageSize.height),
                                            0.0f,
                                            0.0f,
                                            -titleSize.width);
    
    self.titleEdgeInsets = UIEdgeInsetsMake(0.0f,
                                            - imageSize.width,
                                            - (totalHeight - titleSize.height),
                                            0.0f);
    
}


- (void)centerVertically
{
    const CGFloat kDefaultPadding = 6.0f;
    
    [self centerVerticallyWithPadding:kDefaultPadding];
}

@end

@implementation NSString (utility)

- (int) indexOf:(NSString *)text {
    NSRange range = [self rangeOfString:text];
    if ( range.length > 0 ) {
        return (int)range.location;
    } else {
        return -1;
    }
}

- (NSString *)URLDecode
{
    return [self stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

- (NSString *)URLEncode
{
    return [self urlEncodeUsingEncoding:NSUTF8StringEncoding];
}

- (NSString *)urlEncodeUsingEncoding:(NSStringEncoding)encoding
{
    return (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
                                                                                 NULL,
                                                                                 (__bridge CFStringRef)self,
                                                                                 NULL,
                                                                                 (CFStringRef)@"!*'\"();:@&=+$,/?%#[]% ",
                                                                                 CFStringConvertNSStringEncodingToEncoding(encoding)));
}

@end
