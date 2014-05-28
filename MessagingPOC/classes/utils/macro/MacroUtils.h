
#ifdef DEBUG
#define DLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#   define DLog(...)
#endif

#import "ConfigManager.h"
#import "ErrorConstants.h"

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#define configValueNSInteger(key) ((NSNumber*)[[[ConfigManager sharedInstance] config] valueForKey:key]).integerValue
#define configValueNSUInteger(key) ((NSNumber*)[[[ConfigManager sharedInstance] config] valueForKey:key]).unsignedIntValue

#define configValueFloat(key) ((NSNumber*)[[[ConfigManager sharedInstance] config] valueForKey:key]).floatValue

#define configUIColor(key)  UIColorFromRGB(((NSNumber*)[[[ConfigManager sharedInstance] config] valueForKey:key]).integerValue)

#define configObject(key) [[[ConfigManager sharedInstance] config] objectForKey:key]

#define configClassValueNSInteger(key, entityName) ((NSNumber*)[[[ClassConfigurationManager sharedInstance] configForEntity:entityName] valueForKey:key]).integerValue

#define configClassValueFloat(key, entityName) ((NSNumber*)[[[ClassConfigurationManager sharedInstance] configForEntity:entityName] valueForKey:key]).floatValue

#define configClassUIColor(key, entityName)  UIColorFromRGB(((NSNumber*)[[[ClassConfigurationManager sharedInstance] configForEntity:entityName] valueForKey:key]).integerValue)

#define configClassObject(key, entityName) [[[ClassConfigurationManager sharedInstance] configForEntity:entityName] objectForKey:key]

//#define deviceSpecificNibName(str) ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)? [NSString stringWithFormat:@"%@_iPhone", str]:[NSString stringWithFormat:@"%@_iPad", str]
#define deviceSpecificNibName(str) ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)? [NSString stringWithFormat:@"%@_iPhone", str]:[NSString stringWithFormat:@"%@_iPhone", str]

#define IS_IPAD ([[UIDevice currentDevice] userInterfaceIdiom] != UIUserInterfaceIdiomPhone)

#define logErrorList(errorList)[errorList enumerateObjectsUsingBlock:^(NSError *obj, NSUInteger idx, BOOL *stop) { DLog(@"%@", obj);}]


#define must_override @throw [NSException exceptionWithName:NSInternalInconsistencyException\
                                          reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]\
                                        userInfo:nil]



#define SuppressPerformSelectorLeakWarning(Stuff) \
    do { \
        _Pragma("clang diagnostic push") \
        _Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"") \
        Stuff; \
        _Pragma("clang diagnostic pop") \
    } while (0)


#ifndef NSLocalizedErrorMessage
#define NSLocalizedErrorMessage(error) \
    NSLocalizedStringFromTable([error.userInfo objectForKey:NSLocalizedDescriptionKey], @"ErrorMessages", nil)
#endif

#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)


