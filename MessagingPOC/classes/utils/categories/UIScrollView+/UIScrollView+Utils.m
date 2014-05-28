//
//  Created by Alyona on 6/18/12.
//


#import <CoreGraphics/CoreGraphics.h>
#import "UIScrollView+Utils.h"
#import "UIView+Utils.h"


@implementation UIScrollView (Utils)




- (BOOL)isViewVisible:(UIView *)view {

    CGRect viewRect = [self convertRectCountingAllSuperview:view.frame fromView:view];

    CGRect visibleRect;
    visibleRect.origin = self.contentOffset;
    visibleRect.size = self.frame.size;

    BOOL result = NO;
    const CGPoint viewBottomPoint =CGPointMake(viewRect.origin.x, viewRect.origin.y + viewRect.size.height);
    if (CGRectContainsPoint(visibleRect, viewRect.origin) &&
            CGRectContainsPoint(visibleRect, viewBottomPoint) )
    {
        result = YES;
    }
    return result;
}

- (void)scrollToFocusedControl {
    UIView *currentResponder = [self findFirstResponder];
    if (![self isViewVisible:currentResponder]){
        CGFloat scrollViewBottom = self.contentSize.height - self.bounds.size.height;

        CGRect responderFrame = [self convertRectCountingAllSuperview:currentResponder.frame fromView:currentResponder];

        CGPoint pointToScroll = CGPointMake(0, MIN(scrollViewBottom, responderFrame.origin.y));
        [self setContentOffset:pointToScroll animated:NO];
    }
}


-(void)contentSizeToFitSubviews{
    float maxHeight = self.frame.size.height;
    for(UIView* subview in self.subviews){
        maxHeight=MAX(maxHeight, subview.frame.size.height+subview.frame.origin.y);
    }
    CGSize size = self.frame.size;
    [self setContentSize:size];
}

@end