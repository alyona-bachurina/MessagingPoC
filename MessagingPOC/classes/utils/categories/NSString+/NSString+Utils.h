//
//  Created by Alyona on 4/5/12.
//


#import <Foundation/Foundation.h>

@interface NSString (Utils)

+ (BOOL)compareString:(NSString *)left withOtherString:(NSString *)right;

+ (BOOL)compareStringBlankAsNil:(NSString *)left withOtherString:(NSString *)right;

+ (BOOL)isBlankOrNil:(NSString *)string;

- (BOOL)containsInteger;

+ (CGSize)text:(NSString *)text sizeWithFont:(UIFont *)font constrainedToSize:(CGSize)size;

-(BOOL)isValidEmail;

-(NSString*)stringByTrimmingWhitespaces;

- (BOOL) containsString: (NSString*) substring;

@end