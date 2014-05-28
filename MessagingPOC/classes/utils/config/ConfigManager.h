

#import <Foundation/Foundation.h>


@interface ConfigManager : NSObject {

    NSDictionary *config;
}


@property(nonatomic, retain, readonly) NSDictionary *config;

+(ConfigManager *)sharedInstance;

- (NSDictionary *)getDictionary:(NSString *)fileName;
@end