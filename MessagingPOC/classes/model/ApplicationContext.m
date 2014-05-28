//
//  Created by grizzly on 1/3/14.
//


#import "ApplicationContext.h"
#import "User.h"


@implementation ApplicationContext {

}

@dynamic authState;
@dynamic currentUser;
@dynamic recentUser;


//TODO: save password to keystore for autologin
@dynamic password;

- (BOOL)isLocked {
    return [self.authState isEqualToNumber: @(AUTH_LOCKED)];

}

- (BOOL)isLoggedIn {
    return [self.authState isEqualToNumber: @(AUTH_LOGGED_IN)];

}

@end