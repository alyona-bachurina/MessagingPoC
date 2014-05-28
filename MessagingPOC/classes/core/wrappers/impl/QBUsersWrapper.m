//
//  Created by grizzly on 1/6/14.
//


#import "QBUsersWrapper.h"
#import "EntityAdapter.h"
#import "QBBaseWrapper+protected.h"
#import "User.h"

@interface QBUsersWrapper ()
@property(nonatomic, strong) EntityAdapter *entityAdapter;
@end

@implementation QBUsersWrapper {

}

- (void)signUpWithEmail:(NSString *)email login:(NSString *)login password:(NSString *)password completeBlock:(SingleUserActionCompleteBlock)completeBlock {

    NSString *blockId = [[NSProcessInfo processInfo] globallyUniqueString];

    [self.completeBlocks setObject: completeBlock forKey: blockId];

    QBUUser *const user = [QBUUser user];
    user.email = email;
    user.login = login;
    user.password = password;

    NSObject<Cancelable>* cancellable = [QBUsers signUp: user delegate: self context:(__bridge void *) (blockId)];
    
    
    [self.cancelableOperations setObject: cancellable forKey: blockId];
}

- (void)completedWithResult:(Result *)result context:(void *)contextInfo {

    NSString* blockId = (__bridge NSString *)(contextInfo);

    if([result isKindOfClass: [QBUUserResult class]]){
        QBUUserResult* userResult = (QBUUserResult *) result;
        [self handleQBUUserResult: userResult blockId: blockId];
    }else if([result isKindOfClass: [QBUUserPagedResult class]]){
        QBUUserPagedResult* userPagedResult = (QBUUserPagedResult *) result;
        [self handleQBUUserPagedResult: userPagedResult blockId: blockId];
    } if([result isKindOfClass: [QBUUserLogOutResult class]]){
        QBUUserLogOutResult* userLogOutResult = (QBUUserLogOutResult *) result;
        [self handleQBUUserLogOutResultResult: userLogOutResult blockId: blockId];
    }


    [self.completeBlocks removeObjectForKey: blockId];
    [self.cancelableOperations removeObjectForKey: blockId];
}

- (void)handleQBUUserLogOutResultResult:(QBUUserLogOutResult *)result blockId:(NSString *)blockId {
    NSError *error = nil;
    if(!result.success){
       logErrorList(result.errors);
       error = [NSError errorWithDomain:ERROR_DOMAIN_SERVER_API code:ERROR_CODE_API_ERROR userInfo: @{NSLocalizedDescriptionKey: result.errors.lastObject} ];
    }
    SingleUserActionCompleteBlock block = [self.completeBlocks objectForKey: blockId];
    block(nil, error);
}

- (void)handleQBUUserPagedResult:(QBUUserPagedResult *)result blockId:(NSString *)blockId {
    NSError *error = nil;
    NSMutableArray* users = [NSMutableArray array];
    if(result.success){
        NSArray *qbUsers = result.users;

        [qbUsers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
             User *user = [self.entityAdapter userWithQBUser: obj];
             [users addObject: user];
        }];
    }else{
       logErrorList(result.errors);
       error = [NSError errorWithDomain:ERROR_DOMAIN_SERVER_API code:ERROR_CODE_API_ERROR userInfo: @{NSLocalizedDescriptionKey: result.errors.lastObject} ];
    }
    SearchUsersCompleteBlock block = [self.completeBlocks objectForKey: blockId];
    block(users, error);
}

- (void)handleQBUUserResult:(QBUUserResult *)result blockId:(NSString *)blockId {
    NSError *error = nil;
    User* user = nil;
    if(result.success){
        user = [self.entityAdapter  userWithQBUser: result.user ];

        // TODO: find more suitable place for login to chat
        [[QBChat instance] loginWithUser: result.user];
    }else{
       logErrorList(result.errors);
       // TODO: present localized error message
       error = [NSError errorWithDomain:ERROR_DOMAIN_SERVER_API code:ERROR_CODE_API_ERROR userInfo: @{NSLocalizedDescriptionKey: result.errors.lastObject} ];
    }
    SingleUserActionCompleteBlock block = [self.completeBlocks objectForKey: blockId];
    block(user, error);
}

- (void)loginInWithName:(NSString *)login password:(NSString *)password completeBlock:(SingleUserActionCompleteBlock)completeBlock {

    NSString *blockId = [[NSProcessInfo processInfo] globallyUniqueString];

    [self.completeBlocks setObject: completeBlock forKey: blockId];

    NSObject<Cancelable>* cancellable = [QBUsers logInWithUserLogin:login password:password delegate: self context:(__bridge void *) (blockId)];

    [self.cancelableOperations setObject: cancellable forKey: blockId];
}

- (void)searchUsersByLogin:(id)searchString completeBlock:(SearchUsersCompleteBlock)searchUsersCompleteBlock {
    
    NSString *blockId = [[NSProcessInfo processInfo] globallyUniqueString];

    [self.completeBlocks setObject: searchUsersCompleteBlock forKey: blockId];

    PagedRequest *request = [PagedRequest request];
    request.page=0;
    request.perPage=20;

    NSObject<Cancelable>* cancellable = [QBUsers usersWithLogins: @[searchString]
                                                    pagedRequest: request
                                                        delegate: self
                                                         context: (__bridge void *) (blockId)];

    [self.cancelableOperations setObject: cancellable forKey: blockId];    

}

- (void) loadUsersByIDs:(NSArray *) ids withCompleteBlock:(SearchUsersCompleteBlock)completeBlock{
    
    NSString *blockId = [[NSProcessInfo processInfo] globallyUniqueString];

    [self.completeBlocks setObject: completeBlock forKey: blockId];

    PagedRequest *request = [PagedRequest request];
    request.page=0;
    request.perPage=ids.count;

    NSString *idsAsString = [ids componentsJoinedByString: @","];
    NSObject<Cancelable>* cancellable = [QBUsers usersWithIDs:idsAsString pagedRequest: request delegate:self context: (__bridge void *) (blockId)];

    [self.cancelableOperations setObject: cancellable forKey: blockId];                
}

- (void)logoutCurrentUserWithCompleteBlock:(SingleUserActionCompleteBlock)completeBlock{
    NSString *blockId = [[NSProcessInfo processInfo] globallyUniqueString];
    [self.completeBlocks setObject:completeBlock forKey:blockId];
    NSObject<Cancelable>* cancellable = [QBUsers logOutWithDelegate:self context:(__bridge void *) (blockId)];
    [self.cancelableOperations setObject: cancellable forKey: blockId];

}


@end