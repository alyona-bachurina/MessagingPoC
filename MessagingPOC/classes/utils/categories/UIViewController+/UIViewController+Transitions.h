//
//  Created by grizzly on 1/9/14.
//


#import <Foundation/Foundation.h>
#import "TransitionDelegate.h"

@interface UIViewController (Transitions)

- (void)presentFromController:(UIViewController *)controller transitionAnimationType:(TransitionType)transitionAnimationType;

@end