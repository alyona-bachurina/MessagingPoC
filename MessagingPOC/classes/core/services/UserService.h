//
//  Created by grizzly on 1/4/14.
//


#import <Foundation/Foundation.h>

@class User;
@class UserContact;

typedef void (^LoginSuccessBlock)();
typedef void (^LoginFailBlock)(NSError* error);
typedef void (^SearchCompleteBlock)(NSArray* users, NSError *error);
typedef void (^UpdateContactsCompleteBlock)();

@protocol UserService <NSObject>
- (void)registerWithUserName:(NSString *)name password:(NSString *)password email:(NSString *)email successBlock:(LoginSuccessBlock)successBlock failBlock:(LoginFailBlock)failBlock;
- (void)loginWithUserName:(NSString *)name password:(NSString *)password successBlock:(LoginSuccessBlock)successBlock failBlock:(LoginFailBlock)failBlock;

- (NSArray *)getContactsOfCurrentUser;
- (NSArray *)getRecentChatContacts;

- (void)searchUsers:searchString withCompleteBlock:(SearchCompleteBlock)searchCompleteBlock;
- (void)updateContactsWithCompleteBlock:(UpdateContactsCompleteBlock) updateContactsCompleteBlock;
- (void)saveUserContacts:(NSArray *)userContacts;

- (void)logoutCurrentUser;

- (void)lockCurrentUser;

- (UserContact *)findContactByUserId:(NSInteger)userId;
@end