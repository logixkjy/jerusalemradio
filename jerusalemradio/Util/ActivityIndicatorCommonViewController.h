//
//  ActivityIndicatorCommonViewController.h
//  trueFriend
// 
//

#import <UIKit/UIKit.h>

@interface ActivityIndicatorCommonViewController : UIViewController

@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *indicator;
- (void)removeFromSuperViewFadeout;
@end
