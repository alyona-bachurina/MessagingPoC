//
//  Created by Alyona on 4/5/12.
//

#import "NSString+Utils.h"


@implementation NSString (Utils)

+(BOOL)compareString:(NSString *)left withOtherString:(NSString *)right{

    BOOL result = NO;

    if (left==nil){
        result = right==nil;
    }else{
        result = right != nil && [left isEqualToString:right];
    }
    return result;
}

+(BOOL)compareStringBlankAsNil:(NSString *)left withOtherString:(NSString *)right{

    NSString *lStr = left!=nil ?[NSString stringWithString:left]:nil;
    NSString *rStr = right!=nil ?[NSString stringWithString:right]:nil;

    if ([@"" isEqualToString:left]){
        lStr = nil;
    }
    if ([@"" isEqualToString:right]){
        rStr = nil;
    }
    const BOOL result = [NSString compareString:lStr withOtherString:rStr];
    return result;
}

+(BOOL)isBlankOrNil:(NSString *)string{
    const BOOL result = string==nil || string.length==0;
    return result;
}

-(BOOL) containsInteger
{
   NSScanner *sc = [NSScanner scannerWithString: self];
   if ( [sc scanInteger:NULL] )
   {
      return [sc isAtEnd];
   }
   return NO;
}


+ (CGSize)text:(NSString *)text sizeWithFont:(UIFont *)font constrainedToSize:(CGSize)size
{

        CGRect frame = [text boundingRectWithSize:size
                                          options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading)
                                       attributes:@{NSFontAttributeName:font}
                                          context:nil];
        return frame.size;

}

-(BOOL)isValidEmail
{
   BOOL stricterFilter = YES; // Discussion http://blog.logichigh.com/2010/09/02/validating-an-e-mail-address/
   NSString *stricterFilterString = @"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}";
   NSString *laxString = @".+@([A-Za-z0-9]+\\.)+[A-Za-z]{2}[A-Za-z]*";
   NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
   NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
   return [emailTest evaluateWithObject:self];
}

-(NSString*)stringByTrimmingWhitespaces{
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

- (BOOL) containsString: (NSString*) substring
{
    NSRange range = [self rangeOfString : substring];
    BOOL found = ( range.location != NSNotFound );
    return found;
}


@end