#import "UIIntroViewController.h"
#import "ViewController.h"

@interface UIIntroViewController ()
@property (nonatomic) BOOL scheduledMainScreen;
@end

@implementation UIIntroViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.img_BG.image = [UIImage imageNamed:@"LaunchArtwork"];
    self.img_BG.contentMode = UIViewContentModeScaleAspectFill;
    self.img_BG.clipsToBounds = YES;
    self.img_BG.frame = self.view.bounds;
    self.img_BG.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.img_BG.frame = self.view.bounds;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (self.scheduledMainScreen) return;
    self.scheduledMainScreen = YES;
    // Let the full-screen artwork draw before moving on. Sleeping in
    // viewWillAppear blocked the first frame and could leave a blank launch.
    __weak typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        typeof(self) self = weakSelf;
        if (!self) return;
        self.scheduledMainScreen = NO;
        if (self.navigationController.topViewController != self) return;
        NSString *identifier = IS_3_5_INCH ? @"LiveRadioView_480" : @"LiveRadioView";
        ViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:identifier];
        [self.navigationController pushViewController:controller animated:NO];
    });
}
@end
