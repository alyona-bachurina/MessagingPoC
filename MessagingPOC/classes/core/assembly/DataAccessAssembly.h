//
//  Created by grizzly on 1/4/14.
//


#import <Foundation/Foundation.h>
#import <Typhoon/TyphoonAssembly.h>

@class CoreComponentsAssembly;


@interface DataAccessAssembly : TyphoonAssembly

@property(nonatomic, strong) CoreComponentsAssembly *coreComponents;

- (id)applicationContextDao;

- (id)userDao;

- (id)messageDao;

@end