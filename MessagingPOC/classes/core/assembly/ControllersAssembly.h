//
//  Created by grizzly on 1/3/14.
//


#import <Foundation/Foundation.h>
#import "TyphoonAssembly.h"
#import "ControllerProvider.h"


@class ServicesAssembly;


@interface ControllersAssembly : TyphoonAssembly <ControllerProvider>

@property(nonatomic, strong) ServicesAssembly *serviceComponents;


@end