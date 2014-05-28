//
//  Created by grizzly on 1/3/14.
//


#import <Foundation/Foundation.h>
#import <Typhoon/TyphoonAssembly.h>


@interface CoreComponentsAssembly : TyphoonAssembly

- (id)dataStore;

- (id)sessionWrapper;

- (id)usersWrapper;

- (id)chatWrapper;

@end