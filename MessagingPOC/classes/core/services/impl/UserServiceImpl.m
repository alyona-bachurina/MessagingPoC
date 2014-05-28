//
//  Created by grizzly on 1/4/14.
//


#import "UserServiceImpl.h"
#import "QBSessionWrapper.h"
#import "UsersWrapper.h"
#import "User.h"
#import "ApplicationContextService.h"
#import "UserDao.h"
#import "ApplicationContext.h"
#import "ChatWrapper.h"
#import "UserContact.h"
#import "MessageDao.h"







@interface UserServiceImpl ()
@property(nonatomic, strong) NSObject<UserDao> *userDao;
@property(nonatomic, strong) NSObject<MessageDao> *messageDao;
@property(nonatomic, strong) NSObject<SessionWrapper> *sessionWrapper;
@property(nonatomic, strong) NSObject<UsersWrapper> *usersManager;
@property(nonatomic, strong) NSObject<ChatWrapper> *chatWrapper;
@property(nonatomic, strong) NSObject<ApplicationContextService> *applicationContextService;
@end

@implementation UserServiceImpl {

}

- (void)registerWithUserName:(NSString *)name password:(NSString *)password email:(NSString *)email successBlock:(LoginSuccessBlock)successBlock failBlock:(LoginFailBlock)failBlock {

    __weak typeof (self) weakSelf = self;
    [self.sessionWrapper startSessionWithCompleteBlock:^(NSError *error) {
        if(!error){
            [[weakSelf usersManager] signUpWithEmail:email login:name password:password completeBlock:^(User *detachedUser, NSError *signUpError) {
                 if(!signUpError){

                     [weakSelf.chatWrapper loginWithUser: detachedUser password:password completionBlock:^(NSError *chatLoginError) {
                         User* user = [weakSelf saveUser: detachedUser];
                         [weakSelf.applicationContextService updateCurrentUser: user password: password];
                         if(!chatLoginError){
                             successBlock();
                         }else{
                             failBlock(chatLoginError);
                         }
                     }];
                 }else{
                     failBlock(signUpError);
                 }
            }];
        }else{
            failBlock(error);
        }
    }];

}

- (User *)saveUser:(User *)user {

    return [self.userDao saveUser: user];
}

- (void)loginWithUserName:(NSString *)name password:(NSString *)password successBlock:(LoginSuccessBlock)successBlock failBlock:(LoginFailBlock)failBlock {
    __weak typeof (self) weakSelf = self;
    [self.sessionWrapper startSessionWithLogin:name password:password completeBlock:^(NSError *error) {
        if(!error){
            [[weakSelf usersManager] loginInWithName:name password:password completeBlock:^(User *detachedUser, NSError *userLoginError) {
                 if(!userLoginError){
                     [weakSelf.chatWrapper loginWithUser: detachedUser password:password completionBlock:^(NSError *chatLoginError) {
                         User* user = [weakSelf saveUser: detachedUser];
                         [weakSelf.applicationContextService updateCurrentUser:user password: password ];
                         if(!chatLoginError){
                             successBlock();
                         }else{
                             failBlock(chatLoginError);
                         }
                     }];
                 }else{
                     failBlock(userLoginError);
                 }
            }];
        }else{
            failBlock(error);
        }
    }];
}

- (NSArray *)getContactsOfCurrentUser {
    ApplicationContext *applicationContext = [self.applicationContextService getApplicationContext];
    return [self.userDao getContactsForUser:applicationContext.currentUser];

}

- (void)searchUsers:(id)searchString withCompleteBlock:(SearchCompleteBlock)searchCompleteBlock {
   [[self usersManager] searchUsersByLogin: searchString completeBlock: ^(NSArray *users,  NSError* searchByLoginError){
       searchCompleteBlock(users, searchByLoginError);
   }];
}

- (NSArray *)getRecentChatContacts {
    NSArray *contacts = [self getContactsOfCurrentUser];
    NSMutableArray *result = [NSMutableArray arrayWithCapacity: contacts.count];

    [contacts enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        UserContact *userContact = obj;
        NSArray *messages = [self.messageDao getMessagesHistoryForContact: userContact];
        if([messages count]){
            [result addObject: userContact];
        }
    }];

    return result;

}

- (void)updateContactsWithCompleteBlock:(UpdateContactsCompleteBlock) updateContactsCompleteBlock {

    [self.chatWrapper loadContactListWithCompletionBlock:^(NSArray *userContacts) {
        [self saveUserContacts:userContacts];
        updateContactsCompleteBlock();
    }];

}

- (void)saveUserContacts:(NSArray *)userContacts {
    ApplicationContext *applicationContext = [self.applicationContextService getApplicationContext];
    for(UserContact* contactDetached in userContacts){
        [self.userDao saveContact:contactDetached ofUser:applicationContext.currentUser];
    }
}

- (void)logoutCurrentUser {
    ApplicationContext *applicationContext = [self.applicationContextService getApplicationContext];
    applicationContext.authState = @(AUTH_LOGGED_OUT);
    applicationContext.password = nil;
    applicationContext.recentUser = applicationContext.currentUser;
    applicationContext.currentUser = nil;
    [self stopServices];

}

- (void)stopServices {
    [self.chatWrapper logoutCurrentUser];
}

- (void)lockCurrentUser {
    ApplicationContext *applicationContext = [self.applicationContextService getApplicationContext];
    applicationContext.authState = @(AUTH_LOCKED);
    [self stopServices];
}

- (UserContact *)findContactByUserId:(NSInteger)userId {
    ApplicationContext *applicationContext = [self.applicationContextService getApplicationContext];
    UserContact *result = [self.userDao getContactOfUser: applicationContext.currentUser withContactUserId: userId];
    return result;
}


@end