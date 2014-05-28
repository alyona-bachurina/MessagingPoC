//
//  Created by grizzly on 1/4/14.
//


#import <Foundation/Foundation.h>
#import "UserService.h"


@class User;

@interface UserServiceImpl : NSObject<UserService, QBActionStatusDelegate>
- (User *)saveUser:(User *)user;
@end