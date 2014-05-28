//
//  Created by grizzly on 1/3/14.
//


#import <Foundation/Foundation.h>
#import <Typhoon/TyphoonAssembly.h>

@class CoreComponentsAssembly;
@class DataAccessAssembly;


@interface ServicesAssembly : TyphoonAssembly

@property(nonatomic, strong) CoreComponentsAssembly *coreComponents;
@property(nonatomic, strong) DataAccessAssembly *dao;

- (id)applicationContextService;
- (id)userService;
- (id)chatService;

@end