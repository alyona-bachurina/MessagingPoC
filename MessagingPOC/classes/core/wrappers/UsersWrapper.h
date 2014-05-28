//
//  Created by grizzly on 1/6/14.
//


#import <Foundation/Foundation.h>

@class User;

typedef void (^SingleUserActionCompleteBlock)(User* user, NSError* error);
typedef void (^SearchUsersCompleteBlock)(NSArray * users, NSError * error);


@protocol UsersWrapper <NSObject>
- (void) signUpWithEmail:(NSString *)email login:(NSString *)login password:(NSString *)password completeBlock:(SingleUserActionCompleteBlock)completeBlock;
- (void) loginInWithName:(NSString *)login password:(NSString *)password completeBlock:(SingleUserActionCompleteBlock)completeBlock;
- (void) searchUsersByLogin:(id)searchString completeBlock:(SearchUsersCompleteBlock)searchUsersCompleteBlock;
- (void) loadUsersByIDs:(NSArray *) ids withCompleteBlock:(SearchUsersCompleteBlock)completeBlock;
- (void)logoutCurrentUserWithCompleteBlock:(SingleUserActionCompleteBlock)completeBlock;
@end