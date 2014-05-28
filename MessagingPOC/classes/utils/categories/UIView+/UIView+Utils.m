//
//  Created by Alyona on 2/1/13.
//


#import "UIView+Utils.h"

@implementation UIView (Utils)

- (UIView *)findFirstResponder
{
    if (self.isFirstResponder) {
        return self;
    }
    for (UIView *subView in self.subviews) {
        if ([subView isFirstResponder]){
            return subView;
        }
        if ([subView findFirstResponder]){
            return [subView findFirstResponder];
        }
    }
    return nil;
}

-(CGRect)convertRectCountingAllSuperview:(CGRect)rect fromView:(UIView *)view {
    UIView *superView=view.superview;
    while (superView!=self){

        CGRect superViewRect = superView.frame;

        const CGFloat sx = superViewRect.origin.x;
        const CGFloat sy = superViewRect.origin.y;

        rect.origin = CGPointMake(rect.origin.x+ sx, rect.origin.y+ sy);
        superView = superView.superview;

        if (superView==nil){
            break;
        }
    }
    return rect;
}


+ (UIView *)loadFromNib:(NSString *) nibName class:(Class)clazz {

    UIView *result = nil;
    if([[NSBundle mainBundle] pathForResource:nibName ofType:@"nib"] != nil)
    {
        NSArray *nibContents = [[NSBundle mainBundle] loadNibNamed:nibName owner:clazz options:nil];

        for (UIView *view in nibContents) {
            if ([view isKindOfClass:[clazz class]]) {
                result = view;
                break;
            }
        }
    }

    if(!result){
        DLog(@"Failed to load view from nib %@", nibName);
    }
    return result;
}

+ (void)shakeView:(UIView *)viewToShake
{
    CGFloat t = 2.0;
    CGAffineTransform translateRight  = CGAffineTransformTranslate(CGAffineTransformIdentity, t, 0.0);
    CGAffineTransform translateLeft = CGAffineTransformTranslate(CGAffineTransformIdentity, -t, 0.0);

    viewToShake.transform = translateLeft;

    [UIView animateWithDuration:0.07 delay:0.0 options:UIViewAnimationOptionAutoreverse|UIViewAnimationOptionRepeat animations:^{
        [UIView setAnimationRepeatCount:2.0];
        viewToShake.transform = translateRight;
    } completion:^(BOOL finished) {
        if (finished) {
            [UIView animateWithDuration:0.05 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
                viewToShake.transform = CGAffineTransformIdentity;
            } completion:NULL];
        }
    }];
}

-(void)roundCorners:(CGFloat)radius{
   [self.layer setCornerRadius:radius];
   [self.layer setMasksToBounds:YES];
}

- (void)roundCornersWithRadius:(float)radius withBorderWidth:(float)width andColor:(UIColor *)color {
    [self.layer setBorderColor: color.CGColor];
    [self.layer setBorderWidth:width];
    [self.layer setCornerRadius:radius];
    [self.layer setMasksToBounds:YES];
}

- (UIImageView *)captureViewToImageView {
    UIImage *newImage= [self captureViewToImage];

    UIImageView *result = [[UIImageView alloc] initWithFrame:self.bounds];
    result.contentMode=UIViewContentModeTop;
    result.image=newImage;
    return result;
}

- (UIImage *)captureViewToImage {
    UIGraphicsBeginImageContext(self.bounds.size);

    CGContextRef ctx = UIGraphicsGetCurrentContext();
    [[UIColor clearColor] set];
    CGContextFillRect(ctx, self.frame);
    [self.layer renderInContext:ctx];

    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();

    UIGraphicsEndImageContext();
    return newImage;
}

-(void)moveOnDeltaX:(CGFloat) deltaX deltaY:(CGFloat)deltaY{
    CGRect frame = self.frame;
    frame.origin.x+=deltaX;
    frame.origin.y+=deltaY;
    self.frame=frame;
}

-(void)moveToPointX:(CGFloat) x y:(CGFloat)y{
    CGRect frame = self.frame;
    frame.origin.x=x;
    frame.origin.y=y;
    self.frame=frame;
}

-(void)setWidth:(CGFloat)width{
    CGRect frame = self.frame;
    frame.size.width+=width;
    self.frame=frame;
}

-(void)setHeight:(CGFloat)height{
    CGRect frame = self.frame;
    frame.size.height+=height;
    self.frame=frame;
}

@end