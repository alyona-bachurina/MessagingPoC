//
//  Created by grizzly on 10/28/13.
//


#import "UIImage+Utils.h"
#import <ImageIO/ImageIO.h>

@implementation UIImage (Utils)

-(UIImage *) imageBlendedWithColor:(UIColor *)color{

    // load the image

    // begin a new image context, to draw our colored image onto
    UIGraphicsBeginImageContextWithOptions(self.size, NO, 0);

    // get a reference to that context we created
    CGContextRef context = UIGraphicsGetCurrentContext();

    // set the fill color
    [color setFill];

    // translate/flip the graphics context (for transforming from CG* coords to UI* coords
    CGContextTranslateCTM(context, 0, self.size.height);
    CGContextScaleCTM(context, 1, -1);

    // set the blend mode to color burn, and the original image
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    CGRect rect = CGRectMake(0, 0, self.size.width, self.size.height);
    CGContextDrawImage(context, rect, self.CGImage);

    // set a mask that matches the shape of the image, then draw (color burn) a colored rectangle
    CGContextClipToMask(context, rect, self.CGImage);
    CGContextAddRect(context, rect);
    CGContextDrawPath(context,kCGPathFill);

    // generate a new UIImage from the graphics context we drew onto
    UIImage *coloredImg = UIGraphicsGetImageFromCurrentImageContext();

    UIGraphicsEndImageContext();

    //return the color-burned image
    return coloredImg;

}

+ (UIImage*)imageFromFileNamed:(NSString*) fileName{
    UIImage *result = [UIImage imageWithContentsOfFile: [[NSBundle mainBundle] pathForResource: [fileName stringByDeletingPathExtension] ofType:[fileName pathExtension]]];
    return result;
}

//+ (UIImage*)imageWithImage:(UIImage*)image
//               scaledToSize:(CGSize)newSize;
//{
//   UIGraphicsBeginImageContext( newSize );
//   [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
//   UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
//   UIGraphicsEndImageContext();
//
//   return newImage;
//}

- (UIImage *)imageByScalingProportionallyToSize:(CGSize)targetSize {

    UIImage *sourceImage = self;
    UIImage *newImage = nil;

    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;

    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;

    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;

    CGPoint thumbnailPoint = CGPointMake(0.0, 0.0);

    if (CGSizeEqualToSize(imageSize, targetSize) == NO) {

        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;

        if (widthFactor < heightFactor)
            scaleFactor = widthFactor;
        else
            scaleFactor = heightFactor;

        scaledWidth = width * scaleFactor;
        scaledHeight = height * scaleFactor;

        // center the image

        if (widthFactor < heightFactor) {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        } else if (widthFactor > heightFactor) {
            thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
        }
    }


// this is actually the interesting part:

    UIGraphicsBeginImageContext(targetSize);

    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width = scaledWidth;
    thumbnailRect.size.height = scaledHeight;

    [sourceImage drawInRect:thumbnailRect];

    newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    if (newImage == nil) NSLog(@"could not scale image");


    return newImage;
}

@end