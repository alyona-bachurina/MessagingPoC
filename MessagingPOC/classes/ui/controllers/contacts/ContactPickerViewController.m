//
//  Created by grizzly on 1/8/14.
//


#import "ContactPickerViewController.h"
#import "ContactViewController+protected.h"
#import "UserContact.h"

@implementation ContactPickerViewController {

}


@synthesize cancelBlock = _cancelBlock;
@synthesize doneBlock = _doneBlock;

- (void)dealloc {
    _cancelBlock=nil;
    _doneBlock=nil;
}


- (void)loadView {
    [super loadView];
    [self setupNavigationBar];
    self.title = NSLocalizedString(@"chose.contact", nil);
}

- (void)setupNavigationBar {
    [self.navigationController setNavigationBarHidden: NO];
    UIBarButtonItem *btnCancel = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(onCancelTapped)];
    [self.navigationItem setLeftBarButtonItems:[NSArray arrayWithObjects:btnCancel, nil]];
}


- (void)onCancelTapped {
    __weak typeof (self) weakSelf = self;
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        if(weakSelf.cancelBlock){
            weakSelf.cancelBlock();
        }
    }];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if ([self.model count]) {
        UserContact *userContact = [self.model objectAtIndex:(NSUInteger) indexPath.row];
        __weak typeof (self) weakSelf = self;
        if(weakSelf.doneBlock){
            weakSelf.doneBlock(userContact);
        }
    }
}

@end