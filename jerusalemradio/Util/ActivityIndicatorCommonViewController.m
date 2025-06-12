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
    if ([UIView instancesRespondToSelector:@selector(animateWithDuration:animations:completion:)]) {
        
        [UIView animateWithDuration:0.2
                         animations:^{ self.view.alpha = 0.0; }
                         completion:^(BOOL finished){
                             
                             [self.view removeFromSuperview];
                         }];
        
    } else {
        [UIView beginAnimations:@"FadeIn" context:nil];
        [UIView setAnimationDuration:0.3];
        [UIView setAnimationDidStopSelector:@selector(removeFromSuperview)];
        
        // Make the animatable changes.
        self.view.alpha = 0.0;
        
        // Commit the changes and perform the animation.
        [UIView commitAnimations];
        
    }
    
    [self.view removeFromSuperview];
}

-(BOOL)shouldAutorotate
{
    return NO;
}

@end
