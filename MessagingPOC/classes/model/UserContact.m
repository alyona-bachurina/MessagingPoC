//
//  Created by grizzly on 1/6/14.
//


#import "UserContact.h"
#import "UIImage+Utils.h"


@implementation UserContact {

}

@dynamic user;
@dynamic contact;
@dynamic online;
@dynamic pending;


-(UIImage*)getStatusImage{
    UIImage *image = nil;
    if(self.pending.boolValue){
        image = [[UIImage imageNamed:@"pending"] imageBlendedWithColor: configUIColor(@"color.neutral.blue")];
    }else if(self.online.boolValue){
        image = [[UIImage imageNamed:@"online"] imageBlendedWithColor: configUIColor(@"color.online.green")];
    }else{
        image = [[UIImage imageNamed:@"online"] imageBlendedWithColor: [UIColor lightGrayColor]];
    } 
    return image;
}

@end