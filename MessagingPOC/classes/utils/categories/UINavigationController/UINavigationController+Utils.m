//
//  Created by grizzly on 11/20/13.
//


#import "UINavigationController+Utils.h"


@implementation UINavigationController (Utils)

+(UIViewController*) topViewController:(UIViewController *) root{
    UIViewController *result = nil;
    if([root isKindOfClass:[UINavigationController class]]){
        UINavigationController *navigationController = (UINavigationController *) root;

        result = [self topViewController: navigationController.topViewController];

    }else{
        if(root.presentedViewController!=nil){
            result = root.presentedViewController;
            if([result isKindOfClass:[UINavigationController class]]){
               result = [self topViewController: result];
            }
        }else{
            result = root;
        }
    }
    return result;
}

+(UIViewController*) topmostOfPresentedControllers{
    UIViewController *result = nil;
    UIWindow *window =  [[[UIApplication sharedApplication] delegate] window];
    UIViewController *topNavigationViewController = (UINavigationController *) window.rootViewController;
    result = [self topViewController: topNavigationViewController];
    return result;;
}


@end