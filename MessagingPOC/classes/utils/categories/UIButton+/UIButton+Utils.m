//
//  Created by grizzly on 10/28/13.
//


#import "UIButton+Utils.h"
#import "NSString+Utils.h"


@implementation UIButton (Utils)

- (void)centerImageAndTitle:(float)spacing
{
    CGSize imageSize = self.imageView.frame.size;
    CGSize titleSize = [NSString text:self.titleLabel.text sizeWithFont:self.titleLabel.font constrainedToSize:CGSizeMake(self.frame.size.width, MAXFLOAT)];
    CGFloat totalHeight = (imageSize.height + titleSize.height + spacing);
    self.imageEdgeInsets = UIEdgeInsetsMake(- (totalHeight - imageSize.height), 0.0, 0.0, - titleSize.width);
    self.titleEdgeInsets = UIEdgeInsetsMake(0.0, - imageSize.width, - (totalHeight - titleSize.height),0.0);
}

- (void)centerImageAndTitle
{
    float DEFAULT_SPACING = 6.0f;
    [self centerImageAndTitle:DEFAULT_SPACING];
}

@end