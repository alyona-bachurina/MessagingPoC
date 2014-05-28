//
//  Created by grizzly on 1/3/14.
//


#import "TyphoonCollaboratingAssemblyProxy.h"

#import "ServicesAssembly.h"
#import "ApplicationContextServiceImpl.h"
#import "CoreComponentsAssembly.h"
#import "UserServiceImpl.h"
#import "DataAccessAssembly.h"
#import "ChatServiceImpl.h"


#pragma GCC diagnostic ignored "-Wundeclared-selector"

@implementation ServicesAssembly {

}

- (void)resolveCollaboratingAssemblies
{
    _coreComponents = (id) [TyphoonCollaboratingAssemblyProxy proxy];
    _dao = (id) [TyphoonCollaboratingAssemblyProxy proxy];
}


- (id)applicationContextService {

   return [TyphoonDefinition withClass:[ApplicationContextServiceImpl class] configuration:^(TyphoonDefinition* definition){
        [definition injectProperty:@selector(applicationContextDao) with:[_dao applicationContextDao]];
        [definition setLazy: YES];
        [definition setScope:TyphoonScopeSingleton];
   }];

}

- (id)userService {

    return [TyphoonDefinition withClass:[UserServiceImpl class] configuration:^(TyphoonDefinition* definition){
        [definition injectProperty:@selector(applicationContextService) with:[self applicationContextService]];
        [definition injectProperty:@selector(userDao) with:[_dao userDao]];
        [definition injectProperty:@selector(messageDao) with:[_dao messageDao]];
        [definition injectProperty:@selector(sessionWrapper) with:[_coreComponents sessionWrapper]];
        [definition injectProperty:@selector(usersManager) with:[_coreComponents usersWrapper]];
        [definition injectProperty:@selector(chatWrapper) with:[_coreComponents chatWrapper]];
        [definition setLazy: YES];
        [definition setScope:TyphoonScopeSingleton];
    }];
}

- (id)chatService {
    return [TyphoonDefinition withClass:[ChatServiceImpl class] configuration:^(TyphoonDefinition* definition){
        [definition injectProperty:@selector(applicationContextService) with:[self applicationContextService]];
        [definition injectProperty:@selector(userService) with:[self userService]];
        [definition injectProperty:@selector(chatWrapper) with:[_coreComponents chatWrapper]];
        [definition injectProperty:@selector(messageDao) with:[_dao messageDao]];
        [definition setLazy: YES];
        [definition setScope:TyphoonScopeSingleton];
        [definition setAfterInjections:@selector(subscribeForChatChanges)];
    }];
}


@end