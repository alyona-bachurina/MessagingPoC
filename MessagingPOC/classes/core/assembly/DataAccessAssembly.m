//
//  Created by grizzly on 1/4/14.
//


#import <Typhoon/TyphoonCollaboratingAssemblyProxy.h>
#import <Typhoon/TyphoonDefinition.h>
#import "DataAccessAssembly.h"
#import "CoreComponentsAssembly.h"
#import "ApplicationContextDaoImpl.h"
#import "UserDaoImpl.h"
#import "MessageDaoImpl.h"

#pragma GCC diagnostic ignored "-Wundeclared-selector"

@implementation DataAccessAssembly {

}

- (void)resolveCollaboratingAssemblies {
    _coreComponents = (id) [TyphoonCollaboratingAssemblyProxy proxy];
}

- (id)applicationContextDao{
    return [TyphoonDefinition withClass:[ApplicationContextDaoImpl class] configuration:^(TyphoonDefinition* definition){
         [definition injectProperty:@selector(store) with:[_coreComponents dataStore]];
         [definition setLazy:YES];
         [definition setScope:TyphoonScopeSingleton];
    }];
}

- (id)userDao{
    return [TyphoonDefinition withClass:[UserDaoImpl class] configuration:^(TyphoonDefinition* definition){
        [definition injectProperty:@selector(store) with:[_coreComponents dataStore]];
        [definition setLazy:YES];
        [definition setScope:TyphoonScopeSingleton];
    }];
}

- (id)messageDao{
    return [TyphoonDefinition withClass:[MessageDaoImpl class]  configuration:^(TyphoonDefinition* definition){
        [definition injectProperty:@selector(store) with:[_coreComponents dataStore]];
        [definition setLazy:YES];
        [definition setScope:TyphoonScopeSingleton];
    }];
}


@end