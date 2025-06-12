//
//  main.m
//  jerusalemradio
//
//  Created by JooYoung Kim on 2017. 3. 21..
//  Copyright © 2017년 JooYoung Kim. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

int main(int argc, char * argv[]) {
    @autoreleasepool {
//        if ([CommonUtil readObjectFromDefault:@"LANG_CODE"] == nil) {
            NSString *languageCode2 = @"";
            if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8) {
                NSLocale *currentLocale = [NSLocale currentLocale];
                languageCode2 = [currentLocale objectForKey:NSLocaleLanguageCode];
            } else {
                languageCode2 = [[NSLocale preferredLanguages] objectAtIndex:0];
            }
            if ([languageCode2 hasPrefix:@"pt"]) {
                [CommonUtil writeObjectToDefault:@"PT" KEY:@"LANG_CODE"];
            }
            else if ([languageCode2 hasPrefix:@"es"]) {
                [CommonUtil writeObjectToDefault:@"ES" KEY:@"LANG_CODE"];
            } else {
                [CommonUtil writeObjectToDefault:@"KR" KEY:@"LANG_CODE"];
            }
//        }

        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }
}

