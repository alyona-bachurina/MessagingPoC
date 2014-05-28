//
//  Created by grizzly on 10/28/13.
//


#import <Foundation/Foundation.h>

@interface UIImage (Utils)
-(UIImage *) imageBlendedWithColor:(UIColor *)color;
+ (UIImage*)imageFromFileNamed:(NSString*) fileName;
//+ (UIImage*)imageWithImage:(UIImage*)image
//               scaledToSize:(CGSize)newSize;
- (UIImage *)imageByScalingProportionallyToSize:(CGSize)targetSize;
@end