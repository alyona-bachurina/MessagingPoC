

#import "ConfigManager.h"
#import "SynthesizeSingleton.h"


@implementation ConfigManager


@synthesize config=_config;


SYNTHESIZE_SINGLETON_FOR_CLASS(ConfigManager, sharedInstance);

- (id)init {
    self = [super init];
    if (self) {
#ifdef DEBUG
        _config = [self getDictionary:@"config-local"];
#else
         _config = [self getDictionary:@"config-prod"];
#endif
    }

    return self;
}

- (id)readPlist:(NSString *)fileName {
   NSData *plistData;
   NSString *error;
   NSPropertyListFormat format;
   id plist;

   NSString *localizedPath = [[NSBundle mainBundle] pathForResource:fileName ofType:@"plist"];
   plistData = [NSData dataWithContentsOfFile:localizedPath];

   plist = [NSPropertyListSerialization propertyListFromData:plistData mutabilityOption:NSPropertyListImmutable format:&format errorDescription:&error];
   if (!plist) {
      NSLog(@"Error reading plist from file '%s', error = '%s'", [localizedPath UTF8String], [error UTF8String]);
   }

   return plist;
}

- (NSDictionary *)getDictionary:(NSString *)fileName {
   return (NSDictionary *)[self readPlist:fileName];
}

@end