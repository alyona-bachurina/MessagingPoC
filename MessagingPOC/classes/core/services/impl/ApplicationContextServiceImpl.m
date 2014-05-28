//
//  Created by grizzly on 1/3/14.
//


#import "ApplicationContextServiceImpl.h"
#import "ApplicationContext.h"
#import "NSManagedObject+SJODataKitAdditions.h"
#import "TyphoonAutowire.h"
#import "TyphoonIntrospectionUtils.h"
#import "ApplicationContextDao.h"
#import "User.h"


@interface ApplicationContextServiceImpl ()
@property(nonatomic, strong) NSObject<ApplicationContextDao> *applicationContextDao;
@end

@implementation ApplicationContextServiceImpl {

}

- (ApplicationContext *)getApplicationContext {

    return [self.applicationContextDao getApplicationContextCreateIfNeed];
}

- (BOOL)isUserLoggedIn {
    return NO;
}

- (BOOL)isUserFirstStart {
    return NO;
}

- (void)updateCurrentUser:(User *)user password:(NSString *)password {
    [self.applicationContextDao updateCurrentUser: user andPassword: password];
}


@end