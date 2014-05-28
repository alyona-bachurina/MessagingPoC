//
//  Created by grizzly on 1/8/14.
//


#import "SettingsViewController.h"
#import "PVGroup.h"
#import "PVLayout.h"
#import "UserService.h"
#import "AuthenticationControllerManager.h"
#import "UIView+Utils.h"
#import "ApplicationContextService.h"
#import "ApplicationContext.h"
#import "User.h"


@interface SettingsViewController ()
@property(nonatomic, strong) UIButton *btnLogout;
@property(nonatomic, strong) UILabel *lblApplicationDescription;

@property(nonatomic, strong) NSObject<UserService> *userService;
@property(nonatomic, strong) NSObject<ApplicationContextService> *applicationContextService;
@property(nonatomic, strong) NSObject<AuthenticationControllerManager>* controllerManager;
@property(nonatomic, strong) UILabel *lblYouAreLoggedAs;
@end

@implementation SettingsViewController {

}

- (id)init {
    self = [super init];
    if (self) {
        self.title = NSLocalizedString(@"settings.screen.title", nil);
    }
    return self;
}

- (void)dealloc {
    _btnLogout=nil;
    _lblApplicationDescription=nil;
    _userService=nil;
    _applicationContextService=nil;
    _controllerManager=nil;
    _lblYouAreLoggedAs=nil;
}


- (void)loadView {
    [super loadView];

    [self setupControls];

    [self localize];

    [self setupLayoutConstraints];

}

- (void)setupControls {

    self.lblApplicationDescription = [[UILabel alloc] init];
    self.lblYouAreLoggedAs = [[UILabel alloc] init];

    self.lblApplicationDescription.textAlignment = NSTextAlignmentCenter;
    self.lblApplicationDescription.lineBreakMode = NSLineBreakByWordWrapping;
    self.lblApplicationDescription.numberOfLines=0;
    self.lblApplicationDescription.textColor=configUIColor(@"color.very.light.gray");
    self.lblYouAreLoggedAs.textColor=configUIColor(@"color.neutral.blue");
    self.lblYouAreLoggedAs.font=[UIFont boldSystemFontOfSize: 16];

    self.lblYouAreLoggedAs.textAlignment = NSTextAlignmentCenter;
    self.lblYouAreLoggedAs.numberOfLines=0;
    self.lblYouAreLoggedAs.lineBreakMode = NSLineBreakByWordWrapping;

    self.btnLogout = [UIButton buttonWithType: UIButtonTypeRoundedRect];
    [self.btnLogout setBackgroundColor: configUIColor(@"color.neutral.blue")];
    [self.btnLogout setTintColor: [UIColor whiteColor]];
    [self.btnLogout setTitle:NSLocalizedString(@"button.title.logout", nil) forState:UIControlStateNormal];

    [@[self.lblApplicationDescription, self.lblYouAreLoggedAs, self.btnLogout]
            enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [obj setTranslatesAutoresizingMaskIntoConstraints: NO];
            [self.view addSubview:obj];
    }];

    [self.btnLogout roundCornersWithRadius: 8.0 withBorderWidth:2 andColor: [UIColor lightGrayColor]];
    [self.btnLogout addTarget:self action:@selector(onLogoutTapped:) forControlEvents:UIControlEventTouchUpInside];

}

- (void)setupLayoutConstraints {

    [self setEdgesForExtendedLayout:UIRectEdgeNone];

    [self.view addConstraints:PVGroup(@[
            PVHeightOf(self.btnLogout).moreThan.constant(42),
            PVWidthOf(self.btnLogout).moreThan.constant(160),
            PVWidthOf(self.lblApplicationDescription).lessThan.widthOf(self.view),
            PVWidthOf(self.lblYouAreLoggedAs).lessThan.widthOf(self.view),

            PVCenterXOf(self.btnLogout).equalTo.centerXOf(self.view),
            PVCenterYOf(self.btnLogout).equalTo.centerYOf(self.view),

            PVBottomOf(self.lblApplicationDescription).equalTo.bottomOf(self.view).minus(5),
            PVCenterXOf(self.lblApplicationDescription).equalTo.centerXOf(self.view),
            PVBottomOf(self.lblYouAreLoggedAs).equalTo.topOf(self.btnLogout).minus(10),
            PVCenterXOf(self.lblYouAreLoggedAs).equalTo.centerXOf(self.view)
    ]).asArray];
}


-(void)localize{
    self.lblApplicationDescription.text = NSLocalizedString(@"application.description", nil);
    [self.lblApplicationDescription sizeToFit];

    ApplicationContext *applicationContext = [self.applicationContextService getApplicationContext];

    User* currentUser = [applicationContext currentUser];
    self.lblYouAreLoggedAs.text = [NSString stringWithFormat:NSLocalizedString(@"you.are.logged.in.as", nil), [currentUser login], [currentUser email]];
    [self.lblYouAreLoggedAs sizeToFit];
}

- (void)onLogoutTapped:(id)sender {
    [self.userService logoutCurrentUser];
    [self.controllerManager resolveAndPresentTopLevelViewController];

}


@end