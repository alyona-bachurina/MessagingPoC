//
//  Created by grizzly on 1/6/14.
//


#import <Foundation/Foundation.h>

@class User;
@class UserContact;

@protocol UserDao <NSObject>
- (User *)saveUser:(User*) user;

- (NSArray *)getContactsForUser:(User *)user;

- (void)saveContact:(UserContact *)contact ofUser:(User *)user;

- (UserContact *)getContactOfUser:(User *)user withContactUserId:(NSInteger)contactUserId;
@end