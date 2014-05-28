//
//  Created by grizzly on 1/3/14.
//


#import "LoginViewController.h"
#import "RegisterUserViewController+protected.h"
#import "NSString+Utils.h"
#import "UIView+Utils.h"
#import "Toast+UIView.h"
#import "ApplicationContextService.h"
#import "ApplicationContext.h"
#import "User.h"

@interface LoginViewController ()
@property(nonatomic, strong) NSObject<ApplicationContextService> *applicationContextService;
@end

@implementation LoginViewController {

}
- (id)init {
    self = [super init];
    if (self) {
        self.title = NSLocalizedString(@"login.screen.title", nil);
    }

    return self;
}

- (void)dealloc {

    _applicationContextService = nil;
}


- (void)loadView {
    [super loadView];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.lblConfirmPassword.hidden = YES;
    self.txtConfirmPassword.hidden = YES;
    self.lblEmail.hidden = YES;
    self.txtEmail.hidden = YES;
    self.title = NSLocalizedString(@"login.screen.title", nil);

    [self setupRecentLogin];
}

- (void)setupRecentLogin {
    ApplicationContext *applicationContext = [self.applicationContextService getApplicationContext];
    if(applicationContext.recentUser){
        self.txtUserName.text = applicationContext.recentUser.login;
    }
}

- (void)onJoinTapped:(id)sender {
    NSString *userName = [self.txtUserName.text stringByTrimmingWhitespaces];
    NSString *password = [self.txtPassword.text stringByTrimmingWhitespaces];

    [[self.view findFirstResponder] resignFirstResponder];
    if([NSString isBlankOrNil: userName]){
        [self.view makeToast:NSLocalizedString(@"login.validation.blank.username", nil) duration:3 position:@"center" withTapToHide:YES onDismissBlock:^{
        }];
    }else if([NSString isBlankOrNil: password]){
        [self.view makeToast:NSLocalizedString(@"login.validation.blank.password", nil) duration:3 position:@"center" withTapToHide:YES onDismissBlock:^{
        }];
    }else{
        [self doRegister:userName password:password];
    }
}

- (void)doRegister:(NSString *)userName password:(NSString *)password {
    [self.view makeToastActivity];

    __weak typeof (self) weakSelf = self;
    [self.userService loginWithUserName:userName password:password successBlock:^() {
        [weakSelf.view hideToastActivity];
        [weakSelf.controllerManager resolveAndPresentTopLevelViewController];

    }failBlock:^(NSError *error) {
        [weakSelf.view hideToastActivity];
        NSString *message = NSLocalizedErrorMessage(error);
        [weakSelf.view makeToast:message duration:3 position:@"center" withTapToHide:YES onDismissBlock:^{
        }];
    }];
}




@end