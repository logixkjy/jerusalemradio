//
//  UIIntroViewController.m
//  jerusalemradio
//
//  Created by Ja Young Park on 2017. 6. 2..
//  Copyright © 2017년 JooYoung Kim. All rights reserved.
//

#import "UIIntroViewController.h"
#import "ViewController.h"
#import "UIAODListViewController.h"
@interface UIIntroViewController ()

@end

@implementation UIIntroViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    // 포루투갈어권에선 더이상 생방송을 지원하지 않아 AOD 리스트로 바로 이동 시킨다.
//    if ([URLAddressManager getLocal] != PT) {
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    ViewController *VC = nil;
    if (IS_3_5_INCH) {
        _img_BG.image = [UIImage imageNamed:@"launch_image"];
        VC = [self.storyboard instantiateViewControllerWithIdentifier:@"LiveRadioView_480"];
    } else {
        _img_BG.image = [UIImage imageNamed:@"launch_image_568h@2x.png"];
        VC = [self.storyboard instantiateViewControllerWithIdentifier:@"LiveRadioView"];
    }
    [NSThread sleepForTimeInterval:1];
    
    [self.navigationController pushViewController:VC animated:NO];
//    } else {
//        UIAODListViewController *VC = [self.storyboard instantiateViewControllerWithIdentifier:@"UIAODListView"];
//        if (IS_3_5_INCH) {
//            _img_BG.image = [UIImage imageNamed:@"launch_image"];
//        } else {
//            _img_BG.image = [UIImage imageNamed:@"launch_image_568h@2x.png"];
//        }
//        [NSThread sleepForTimeInterval:1];
//
//        [self.navigationController pushViewController:VC animated:NO];
//    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
