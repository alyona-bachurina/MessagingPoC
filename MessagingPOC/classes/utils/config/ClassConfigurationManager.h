//
//  Created by Alyona on 7/11/13.
//


#import <Foundation/Foundation.h>
#import "ConfigManager.h"


@interface ClassConfigurationManager : ConfigManager

- (void)releaseConfigFor:(NSString *)entityName;

- (NSDictionary *)configForEntity:(NSString *)entityName;

+ (ClassConfigurationManager *)sharedInstance;

@end
