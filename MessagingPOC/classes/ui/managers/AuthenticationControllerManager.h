//
//  Created by grizzly on 1/3/14.
//


#import <Foundation/Foundation.h>

@protocol AuthenticationControllerManager <NSObject>
- (void)resolveAndPresentTopLevelViewController;
- (void)doAutoLogin;
- (void)presentSplashScreen;
@end