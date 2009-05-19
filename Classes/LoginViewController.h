
#import <UIKit/UIKit.h>
#import "AbstractTextEditingUITableViewController.h"
#import "PortfoliosViewController.h"

@interface LoginViewController : AbstractTextEditingUITableViewController {
	PortfoliosViewController *portfoliosViewController;
	
	IBOutlet UITextField *usernameTextField;
	IBOutlet UITextField *passwordTextField;
	IBOutlet UISwitch *autoLoginSwitch;
}

@property (nonatomic, retain) IBOutlet PortfoliosViewController *portfoliosViewController;

@property (nonatomic, retain) IBOutlet UITextField *usernameTextField;
@property (nonatomic, retain) IBOutlet UITextField *passwordTextField;
@property (nonatomic, retain) IBOutlet UISwitch *autoLoginSwitch;

- (IBAction)useAccount;

@end
