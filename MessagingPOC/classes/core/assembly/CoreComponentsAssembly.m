//
//  Created by grizzly on 1/3/14.
//

#import "CoreComponentsAssembly.h"
#import "DataStore.h"

#import "SJODataStore.h"
#import "QBSessionWrapper.h"
#import "QBUsersWrapper.h"
#import "EntityAdapter.h"
#import "QBChatWrapper.h"

#pragma GCC diagnostic ignored "-Wundeclared-selector"

@implementation CoreComponentsAssembly {
}

- (id)dataStore {

    return [TyphoonDefinition withClass:[SJODataStore class] configuration:^(TyphoonDefinition* definition){
        [definition setScope:TyphoonScopeSingleton];
    }];
}

- (id)sessionWrapper {

    return [TyphoonDefinition withClass:[QBSessionWrapper class] configuration:^(TyphoonDefinition* definition){
        [definition setLazy:YES];
        [definition setScope:TyphoonScopeSingleton];
    }];
}

- (id)entityAdapter{
    return [TyphoonDefinition withClass:[EntityAdapter class] configuration:^(TyphoonDefinition* definition){
        [definition injectProperty:@selector(store) with:[self dataStore]];
        [definition setLazy:YES];
        [definition setScope:TyphoonScopeSingleton];
    }];
}

- (id)usersWrapper {

    return [TyphoonDefinition withClass:[QBUsersWrapper class] configuration:^(TyphoonDefinition* definition){
        [definition injectProperty:@selector(entityAdapter) with:[self entityAdapter]];
        [definition setLazy:YES];
        [definition setScope:TyphoonScopeSingleton];
    }];
}

- (id)chatWrapper {
    return [TyphoonDefinition withClass:[QBChatWrapper class] configuration:^(TyphoonDefinition* definition){
        [definition injectProperty:@selector(entityAdapter) with:[self entityAdapter]];
        [definition injectProperty:@selector(usersManager) with:[self usersWrapper]];
        [definition setLazy: YES];
        [definition setScope:TyphoonScopeSingleton];
    }];
}

@end
