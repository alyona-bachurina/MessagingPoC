//
//  Created by grizzly on 1/3/14.
//


#import "RegisterUserViewController.h"
#import "PVVFL.h"
#import "PVLayout.h"
#import "PVGroup.h"
#import "NSString+Utils.h"
#import "Toast+UIView.h"
#import "UserService.h"
#import "TPKeyboardAvoidingScrollView.h"
#import "UIView+Utils.h"
#import "AuthenticationControllerManager.h"


@interface RegisterUserViewController () <UITextFieldDelegate>
@property(nonatomic, strong) UITextField *txtUserName;
@property(nonatomic, strong) UILabel *lblUserName;
@property(nonatomic, strong) TPKeyboardAvoidingScrollView *scrollContainer;
@property(nonatomic, strong) UILabel *lblPassword;
@property(nonatomic, strong) UITextField *txtPassword;
@property(nonatomic, strong) UILabel *lblConfirmPassword;
@property(nonatomic, strong) UITextField *txtConfirmPassword;
@property(nonatomic, strong) UILabel *lblEmail;
@property(nonatomic, strong) UITextField *txtEmail;
@property(nonatomic, strong) UIButton *btnJoinUs;
@property(nonatomic) BOOL shouldGoToNext;
@property(nonatomic, strong) UIToolbar *keyBoardToolBar;

@property(nonatomic, strong) NSObject<UserService>* userService;
@property(nonatomic, strong) NSObject<AuthenticationControllerManager>* controllerManager;
@end

@implementation RegisterUserViewController {

}

- (void)dealloc {
    _txtUserName = nil;
    _lblUserName = nil;
    _scrollContainer = nil;
    _lblPassword=nil;
    _txtPassword=nil;
    _lblConfirmPassword=nil;
    _txtConfirmPassword=nil;
    _lblEmail=nil;
    _txtEmail=nil;
    _btnJoinUs=nil;
    _keyBoardToolBar=nil;
    _userService=nil;
    _controllerManager=nil;
}

- (void)loadView {
    [super loadView];

    [self setupControls];

    [self setEdgesForExtendedLayout:UIRectEdgeNone];

    [self setupLayoutConstraints];

    [self localize];
    [self setupKeyboardToolBar];
    [self.view layoutSubviews];
}

- (void)setupControls {
    self.scrollContainer = [[TPKeyboardAvoidingScrollView alloc] initWithFrame: self.view.bounds];
    [self.scrollContainer setScrollEnabled: YES];
    [self.scrollContainer setBounces: YES];
    [self.scrollContainer setUserInteractionEnabled: YES];

    self.lblUserName = [[UILabel alloc] init];
    self.txtUserName = [[UITextField alloc] init];
    self.lblPassword = [[UILabel alloc] init];
    self.txtPassword = [[UITextField alloc] init];
    self.lblConfirmPassword = [[UILabel alloc] init];
    self.txtConfirmPassword = [[UITextField alloc] init];
    self.lblEmail = [[UILabel alloc] init];
    self.txtEmail = [[UITextField alloc] init];
    self.btnJoinUs = [UIButton buttonWithType: UIButtonTypeSystem];


    self.lblConfirmPassword.lineBreakMode = NSLineBreakByWordWrapping;
    self.txtPassword.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.txtPassword.secureTextEntry = YES;
    self.txtConfirmPassword.secureTextEntry = YES;
    self.txtConfirmPassword.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.txtEmail.keyboardType = UIKeyboardTypeEmailAddress;

    [@[self.lblUserName, self.lblPassword, self.lblConfirmPassword, self.lblEmail] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [obj setTextAlignment: NSTextAlignmentRight];
    }];

    [@[self.txtUserName, self.txtPassword, self.txtConfirmPassword, self.txtEmail] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [obj setBorderStyle: UITextBorderStyleRoundedRect];
        [obj setBackgroundColor: [UIColor whiteColor]];
        [obj setDelegate: self];
    }];

    self.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.scrollContainer.autoresizingMask = UIViewAutoresizingNone;
    self.scrollContainer.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview: self.scrollContainer];

    [@[self.txtUserName, self.txtPassword, self.txtConfirmPassword, self.txtEmail, self.lblUserName, self.lblPassword, self.lblConfirmPassword, self.lblEmail, self.btnJoinUs]
            enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [obj setTranslatesAutoresizingMaskIntoConstraints: NO];
            [_scrollContainer addSubview: obj];
    }];

    [self.btnJoinUs addTarget:self action:@selector(onJoinTapped:) forControlEvents: UIControlEventTouchUpInside];

}

- (void)setupLayoutConstraints {
    [self.view addConstraints:PVVFL(@"H:|[_scrollContainer]|").withViews(NSDictionaryOfVariableBindings(_scrollContainer)).asArray];
    [self.view addConstraints:PVVFL(@"V:|[_scrollContainer]|").withViews(NSDictionaryOfVariableBindings(_scrollContainer)).asArray];

    [self.scrollContainer addConstraints:(PVVFL(@"V:|-(i)-[v]").withViews(@{@"v" : self.lblUserName,}).metrics(@{@"i" : @(40)}).asArray)];
    [self.scrollContainer addConstraints:(PVVFL(@"V:|-(i)-[v]").withViews(@{@"v" : self.txtUserName,}).metrics(@{@"i" : @(40)}).asArray)];

    const float padding = 10.0;
    const float field_min_width = 180;
    const float labelPartMulti = IS_IPAD ? 0.45 : 0.33;
    const float editPartMulti = IS_IPAD ? 0.5 : 0.66;

    [self.scrollContainer addConstraints:PVGroup(@[
            PVWidthOf(self.lblUserName).equalTo.widthOf(self.scrollContainer).multipliedTo(labelPartMulti).minus(padding),
            PVLeftOf(self.lblUserName).equalTo.leftOf(self.scrollContainer).plus(padding),

            PVLeftOf(self.txtUserName).equalTo.rightOf(self.lblUserName).plus(padding),
            PVWidthOf(self.txtUserName).lessThan.widthOf(self.scrollContainer).multipliedTo(editPartMulti).minus(padding),
            PVWidthOf(self.txtUserName).moreThan.constant(field_min_width),

            PVCenterYOf(self.lblPassword).equalTo.centerYOf(self.txtPassword),
            PVRightOf(self.lblPassword).equalTo.rightOf(self.lblUserName),

            PVLeftOf(self.txtPassword).equalTo.leftOf(self.txtUserName),
            PVTopOf(self.txtPassword).equalTo.bottomOf(self.txtUserName).plus(padding),
            PVWidthOf(self.txtPassword).moreThan.constant(field_min_width),

            PVCenterYOf(self.lblConfirmPassword).equalTo.centerYOf(self.txtConfirmPassword),
            PVRightOf(self.lblConfirmPassword).equalTo.rightOf(self.lblUserName),

            PVLeftOf(self.txtConfirmPassword).equalTo.leftOf(self.txtPassword),
            PVTopOf(self.txtConfirmPassword).equalTo.bottomOf(self.txtPassword).plus(padding),
            PVWidthOf(self.txtConfirmPassword).moreThan.constant(field_min_width),

            PVCenterYOf(self.lblEmail).equalTo.centerYOf(self.txtEmail),
            PVRightOf(self.lblEmail).equalTo.rightOf(self.lblUserName),

            PVLeftOf(self.txtEmail).equalTo.leftOf(self.txtConfirmPassword),
            PVTopOf(self.txtEmail).equalTo.bottomOf(self.txtConfirmPassword).plus(padding),
            PVWidthOf(self.txtEmail).moreThan.constant(field_min_width),

            PVTopOf(self.btnJoinUs).equalTo.bottomOf(self.txtEmail).plus(padding * 2),
            PVCenterXOf(self.btnJoinUs).equalTo.centerXOf(self.scrollContainer),


    ]).asArray];

    [self.scrollContainer addConstraints:(PVVFL(@"V:[v]-(i)-|").withViews(@{@"v" : self.btnJoinUs}).metrics(@{@"i" : @(padding)}).asArray)];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.scrollContainer.contentSize=self.scrollContainer.bounds.size;

}

- (void)localize {
    self.lblUserName.text= NSLocalizedString(@"login.label.user.name", nil);
    self.lblPassword.text= NSLocalizedString(@"login.label.password", nil);
    self.lblConfirmPassword.text= NSLocalizedString(@"login.label.confirm.password", nil);
    self.lblEmail.text= NSLocalizedString(@"login.label.email", nil);
    self.txtUserName.placeholder= NSLocalizedString(@"login.placeholder.user.name", nil);
    self.txtPassword.placeholder= NSLocalizedString(@"login.placeholder.password", nil);
    self.txtConfirmPassword.placeholder= NSLocalizedString(@"login.placeholder.confirm.password", nil);
    self.txtEmail.placeholder= NSLocalizedString(@"login.placeholder.email", nil);
    [self.btnJoinUs setTitle:NSLocalizedString(@"login.button.join.us", nil) forState:UIControlStateNormal];
    self.title = NSLocalizedString(@"register.screen.title", nil);
}

- (BOOL)validateInput:(NSString *)userName password:(NSString *)password passwordConfirm:(NSString *)passwordConfirm email:(NSString *)email {
    UITextField *failedField =nil;
    NSString* message;
    if([NSString isBlankOrNil:userName]){
       failedField = self.txtUserName;
        message = NSLocalizedString(@"login.validation.blank.username", nil);
    }else if([NSString isBlankOrNil: password]){
        failedField = self.txtPassword;
        message = NSLocalizedString(@"login.validation.blank.password", nil);
    }else if(![password isEqualToString:passwordConfirm]){
        failedField = self.txtConfirmPassword;
        message = NSLocalizedString(@"login.validation.password.confirmation.mismatch", nil);
    }else if ([NSString isBlankOrNil:email]||![email isValidEmail]){
        failedField = self.txtEmail;
        message = NSLocalizedString(@"login.validation.wrong.email", nil);
    }

    BOOL success = failedField==nil;
    if(!success){
        [self.view makeToast:message duration:3 position:@"center" withTapToHide:YES onDismissBlock:^{
        }];
        failedField.backgroundColor= configUIColor(@"field.validation.warning.background");
    }

    return success;
}


- (void)setupKeyboardToolBar {
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(hideKeyboard)];
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    toolbar.items = [NSArray arrayWithObject:barButton];
    self.keyBoardToolBar = toolbar;

    [self.txtEmail setInputAccessoryView: self.keyBoardToolBar];
    [self.txtPassword setInputAccessoryView: self.keyBoardToolBar];
    [self.txtConfirmPassword setInputAccessoryView: self.keyBoardToolBar];
    [self.txtUserName setInputAccessoryView: self.keyBoardToolBar];
}

- (void)hideKeyboard {
    self.shouldGoToNext=NO;
    [[[self scrollContainer] findFirstResponder] resignFirstResponder];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    textField.backgroundColor=[UIColor whiteColor];
    self.shouldGoToNext=YES;
}


- (void)processNextField:(UITextField *)textField {
    if(textField!= self.txtEmail){
        [self goToNextField:textField];
    }else{
        [textField resignFirstResponder];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    self.shouldGoToNext=YES;
    [self processNextField:textField];
    return YES;
}


- (void)goToNextField:(UITextField *)textField {
    if(self.shouldGoToNext){
        [self.scrollContainer focusNextTextField];
        [self.scrollContainer scrollToActiveTextField];
    }
}

- (void)onJoinTapped:(id)sender {
    NSString *userName = [self.txtUserName.text stringByTrimmingWhitespaces];
    NSString *password = [self.txtPassword.text stringByTrimmingWhitespaces];
    NSString *passwordConfirm = [self.txtConfirmPassword.text stringByTrimmingWhitespaces];
    NSString *email = [self.txtEmail.text stringByTrimmingWhitespaces];

    [[self.view findFirstResponder] resignFirstResponder];

    if([self validateInput:userName password:password passwordConfirm:passwordConfirm email:email ]){
        [self doRegister:userName password:password passwordConfirm:passwordConfirm email:email];
    }
}

- (void)doRegister:(NSString *)userName password:(NSString *)password passwordConfirm:(NSString *)passwordConfirm email:(NSString *)email {
    [self.view makeToastActivity];

    __weak typeof (self) weakSelf = self;
    [self.userService registerWithUserName:userName password:password email:email successBlock:^() {
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