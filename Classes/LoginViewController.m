
#import "LoginViewController.h"
#import "GoogleClientLogin.h"

@implementation LoginViewController

@synthesize portfoliosViewController;
@synthesize usernameTextField;
@synthesize passwordTextField;
@synthesize autoLoginSwitch;

- (void)viewDidLoad {
    [super viewDidLoad];
	self.title = @"Account Details";
}

- (IBAction)useAccount {
	GoogleClientLogin *googleClientLogin = [[GoogleClientLogin alloc] autorelease];
	googleClientLogin.username = usernameTextField.text;
	googleClientLogin.password = passwordTextField.text;
	
	[portfoliosViewController release];
	PortfoliosViewController *aView = [[PortfoliosViewController alloc] 
									   initWithNibName:@"PortfoliosViewController" bundle:[NSBundle mainBundle]];
	[aView setGoogleClientLogin:googleClientLogin];
	portfoliosViewController = aView;
	
	[self.navigationController pushViewController:portfoliosViewController animated:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {	
    if (theTextField == usernameTextField) {
        [usernameTextField resignFirstResponder];
    }
	
	if (theTextField == passwordTextField) {
		[passwordTextField resignFirstResponder];
	}
	
    return YES;
}

- (void)dealloc {
	[portfoliosViewController release];
	
	[usernameTextField release];
	[passwordTextField release];
	[autoLoginSwitch release];
	
    [super dealloc];
}


@end
