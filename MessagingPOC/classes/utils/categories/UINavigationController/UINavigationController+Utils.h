//
//  Created by grizzly on 11/20/13.
//


#import <Foundation/Foundation.h>

@interface UINavigationController (Utils)

+(UIViewController*) topViewController:(UIViewController *)controller;
+(UIViewController*) topmostOfPresentedControllers;

@end