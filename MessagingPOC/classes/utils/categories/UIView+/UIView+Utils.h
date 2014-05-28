//
//  Created by Alyona on 2/1/13.
//


#import <Foundation/Foundation.h>

@interface UIView (Utils)

- (UIView *)findFirstResponder;

- (CGRect)convertRectCountingAllSuperview:(CGRect)rect fromView:(UIView *)view ;

+ (UIView *)loadFromNib:(NSString *) nibName class:(Class)clazz;

+ (void)shakeView:(UIView *)viewToShake;

- (void)roundCorners:(CGFloat)radius;

- (void)roundCornersWithRadius:(float)radius withBorderWidth:(float)width andColor:(UIColor *)color;

- (UIImageView *)captureViewToImageView;

- (UIImage *)captureViewToImage;

- (void)moveOnDeltaX:(CGFloat) deltaX deltaY:(CGFloat)deltaY;

-(void)moveToPointX:(CGFloat) x y:(CGFloat)y;

- (void)setWidth:(CGFloat)width;

- (void)setHeight:(CGFloat)height;

@end