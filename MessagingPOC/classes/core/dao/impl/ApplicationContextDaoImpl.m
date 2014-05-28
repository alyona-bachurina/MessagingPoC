//
//  Created by grizzly on 1/4/14.
//


#import "ApplicationContextDaoImpl.h"
#import "ApplicationContext.h"
#import "DataStore.h"
#import "NSManagedObject+SJODataKitAdditions.h"
#import "User.h"


@interface ApplicationContextDaoImpl ()
@property(nonatomic, strong) NSObject<DataStore> *store;
@end


@implementation ApplicationContextDaoImpl {

}

- (ApplicationContext *)getApplicationContextCreateIfNeed {

    NSManagedObjectContext *context = self.store.mainContext;

    ApplicationContext *result = [ApplicationContext firstRecordInContext:context];
    if(!result){
      result = [ApplicationContext insertInContext: context];
      result.authState = @(AUTH_FIRST_START);
    }
    return result;
}

- (void)updateCurrentUser:(User *)user andPassword:(NSString *)password {
    ApplicationContext *context = [self getApplicationContextCreateIfNeed];
    context.authState = @(AUTH_LOGGED_IN);
    context.currentUser = user;
    context.password = password;
    [self.store save];
}


@end