//
//  Created by Alyona on 6/18/12.
//


#import <Foundation/Foundation.h>

@interface UIScrollView (Utils)
- (BOOL)isViewVisible:(UIView *)view;
- (void)scrollToFocusedControl;
- (void)contentSizeToFitSubviews;
@end