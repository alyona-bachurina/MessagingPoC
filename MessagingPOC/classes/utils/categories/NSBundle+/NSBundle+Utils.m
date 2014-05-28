//
//  Created by Alyona on 10/2/13.
//


#import "NSBundle+Utils.h"


@implementation NSBundle (Utils)

+ (NSString *)appNameAndVersionNumberDisplayString {
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *majorVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    NSString *minorVersion = [infoDictionary objectForKey:@"CFBundleVersion"];

    return [NSString stringWithFormat:@"%@ (%@)" ,majorVersion, minorVersion];
}

+ (NSString *)shortVersionNumberDisplayString {
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *minorVersion = [infoDictionary objectForKey:@"CFBundleVersion"];

    return [NSString stringWithFormat:@"%@" , minorVersion];
}

@end