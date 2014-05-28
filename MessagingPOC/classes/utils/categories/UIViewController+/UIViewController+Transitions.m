//
//  Created by grizzly on 1/9/14.
//


#import "UIViewController+Transitions.h"
#import "TransitionDelegate.h"


@implementation UIViewController (Transitions)


- (void)presentFromController:(UIViewController *)controller transitionAnimationType:(TransitionType)transitionAnimationType {

    [self setTransitioningDelegate:[[TransitionDelegate alloc] initWithTransitionType: transitionAnimationType]];
    self.modalPresentationStyle= UIModalPresentationCustom;
    [controller presentViewController:self animated:YES completion:nil];

}

@end