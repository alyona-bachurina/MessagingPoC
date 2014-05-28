//
//  Created by grizzly on 1/3/14.
//


#import <Foundation/Foundation.h>


@class ApplicationContext;
@class User;

@protocol ApplicationContextService
- (ApplicationContext *)getApplicationContext;

- (BOOL)isUserLoggedIn;

- (BOOL)isUserFirstStart;

- (void)updateCurrentUser:(User *)user password:(NSString *)password;

@end