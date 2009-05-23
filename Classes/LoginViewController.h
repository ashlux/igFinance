
#import <UIKit/UIKit.h>
#import "AbstractTextEditingUITableViewController.h"
#import "PortfoliosViewController.h"

@interface LoginViewController : AbstractTextEditingUITableViewController {
	PortfoliosViewController *portfoliosViewController;
	
	IBOutlet UITableView *uiTableView;
	IBOutlet UITextField *usernameTextField;
	IBOutlet UITextField *passwordTextField;
	IBOutlet UISwitch *rememberPasswordSwitch;
}

@property (nonatomic, retain) IBOutlet PortfoliosViewController *portfoliosViewController;

@property (nonatomic, retain) IBOutlet UITableView *uiTableView;
@property (nonatomic, retain) IBOutlet UITextField *usernameTextField;
@property (nonatomic, retain) IBOutlet UITextField *passwordTextField;
@property (nonatomic, retain) IBOutlet UISwitch *rememberPasswordSwitch;

- (IBAction)useAccount;

@end
