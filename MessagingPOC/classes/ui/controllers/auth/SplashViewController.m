//
//  Created by grizzly on 1/8/14.
//


#import <Parus/PVGroup.h>
#import "PVLayout.h"
#import <Parus/PVLayout.h>
#import "PVVFL.h"
#import "SplashViewController.h"


@interface SplashViewController ()
@property(nonatomic, strong) UILabel *lblMessage;
@property(nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@property(nonatomic, strong) UIImageView *imgLogo;
@end

@implementation SplashViewController {

}

- (void)dealloc {
   _lblMessage=nil;
   _activityIndicator=nil;
   _imgLogo=nil;
}


- (void)loadView {
    [super loadView];

    [self setupControls];

    [self setupLayoutConstraints];

}

- (void)setupControls {
    UIImage *image = [UIImage imageNamed:@"wav-logo-sm"];
    self.imgLogo = [[UIImageView alloc] initWithImage: image];
    self.activityIndicator = [[UIActivityIndicatorView alloc] init];
    self.activityIndicator.tintColor= configUIColor(@"color.very.light.gray");
    [self.activityIndicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];


    self.lblMessage = [[UILabel alloc] init];
    self.lblMessage.textColor = configUIColor(@"color.very.light.gray");
    self.lblMessage.font=[UIFont boldSystemFontOfSize: 16];
    self.lblMessage.textAlignment = NSTextAlignmentCenter;

    if(image.size.height> self.view.frame.size.height || image.size.width> self.view.frame.size.width){
        self.imgLogo.contentMode = UIViewContentModeScaleAspectFit;
    }else{
        self.imgLogo.contentMode = UIViewContentModeCenter;
    }

    [@[self.imgLogo, self.activityIndicator, self.lblMessage]
            enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [obj setTranslatesAutoresizingMaskIntoConstraints: NO];
            [self.view addSubview:obj];
    }];
}

- (void)setupLayoutConstraints {
    [self.view addConstraints:PVVFL(@"H:|[_imgLogo]|").withViews(NSDictionaryOfVariableBindings(_imgLogo)).asArray];
    [self.view addConstraints:PVVFL(@"V:|[_imgLogo]|").withViews(NSDictionaryOfVariableBindings(_imgLogo)).asArray];

    [self.view addConstraints:PVGroup(@[
            PVCenterXOf(self.activityIndicator).equalTo.centerXOf(self.view),
            PVCenterXOf(self.lblMessage).equalTo.centerXOf(self.view),
            PVBottomOf(self.activityIndicator).equalTo.bottomOf(self.view).minus(60),
            PVBottomOf(self.lblMessage).equalTo.bottomOf(self.view).minus(30)
    ]).asArray];
}


- (void)startAnimatingWithMessage:(NSString *)message {
    [self.activityIndicator startAnimating];

    self.lblMessage.text = message;
    [self.lblMessage sizeToFit];
    [self.view layoutSubviews];
}

@end