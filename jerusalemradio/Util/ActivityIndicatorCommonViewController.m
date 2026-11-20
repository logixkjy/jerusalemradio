//
//  ActivityIndicatorCommonViewController.m 
// 
//

#import "ActivityIndicatorCommonViewController.h"
@implementation ActivityIndicatorCommonViewController
 
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [_indicator startAnimating];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
    [_indicator stopAnimating];
}

- (void)removeFromSuperViewFadeout
{
    [UIView animateWithDuration:0.2 animations:^{ self.view.alpha = 0; } completion:^(BOOL finished) {
        [self.view removeFromSuperview];
    }];
}

-(BOOL)shouldAutorotate
{
    return NO;
}

@end
