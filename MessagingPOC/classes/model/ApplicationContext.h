//
//  Created by grizzly on 1/3/14.
//


#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class User;

typedef NS_ENUM(NSUInteger, AuthState) {
        AUTH_FIRST_START,
        AUTH_LOGGED_OUT,
        AUTH_LOGGED_IN,
        AUTH_LOCKED
    };

@interface ApplicationContext : NSManagedObject
@property (nonatomic, retain) NSNumber * authState;
@property (nonatomic, retain) User * currentUser;
@property (nonatomic, retain) User * recentUser;
@property (nonatomic, retain) NSString* password;


- (BOOL)isLocked;

- (BOOL)isLoggedIn;

@end