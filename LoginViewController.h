
#import <UIKit/UIKit.h>


@interface LoginViewController : UITableViewController {
	IBOutlet UILabel *alertLabel;
	IBOutlet UITextField *usernameTextField;
	IBOutlet UITextField *passwordTextField;
	IBOutlet UIButton *loginButton;
	IBOutlet UIButton *resetButton;
}

@property (nonatomic, retain) IBOutlet UILabel *alertLabel;
@property (nonatomic, retain) IBOutlet UITextField *usernameTextField;
@property (nonatomic, retain) IBOutlet UITextField *passwordTextField;
@property (nonatomic, retain) IBOutlet UIButton *loginButton;
@property (nonatomic, retain) IBOutlet UIButton *resetButton;

- (IBAction)login:(id)sender;
- (IBAction)resetForm:(id)sender;

- (IBAction)changeStatusToLoggingIn:(id)sender;

@end
