//
//  Created by Alyona on 7/11/13.
//


#import "ClassConfigurationManager.h"

@interface ClassConfigurationManager ()
@property(nonatomic, strong) NSCache *configCache;
@end


@implementation ClassConfigurationManager {



}

- (id)init {
    self = [super init];
    if (self) {
        self.configCache = [[NSCache alloc] init];
    }
    return self;
}

+ (ClassConfigurationManager *)sharedInstance {
    static dispatch_once_t onceToken;
    static ClassConfigurationManager * result;
    dispatch_once(&onceToken, ^{
        result = [[ClassConfigurationManager alloc] init];
    });
    return result;
}

-(void) releaseConfigFor:(NSString*)entityName{

    [self.configCache removeObjectForKey:entityName];
}

- (NSDictionary *)configForEntity:(NSString*) entityName {
    NSDictionary *result;
    @synchronized (self) {
        result = [self.configCache objectForKey:entityName];
        if(!result){
            result = [self getDictionary: entityName];
            if(result){
                [self.configCache setObject:result forKey: entityName];
            }else{
                DLog(@"Failed to load configurtion for entity: %@", entityName)
            }
        }
    }
    return result;
}

@end