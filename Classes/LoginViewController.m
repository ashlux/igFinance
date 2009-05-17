
#import "LoginViewController.h"
#import "LoginDao.h"

@implementation LoginViewController

@synthesize usernameTextField;
@synthesize passwordTextField;
@synthesize alertLabel;
@synthesize loginButton;
@synthesize resetButton;
@synthesize portfoliosViewController;

CGFloat animatedDistance;
static const CGFloat KEYBOARD_ANIMATION_DURATION = 0.3;
static const CGFloat MINIMUM_SCROLL_FRACTION = 0.2;
static const CGFloat MAXIMUM_SCROLL_FRACTION = 0.8;
static const CGFloat PORTRAIT_KEYBOARD_HEIGHT = 216;
static const CGFloat LANDSCAPE_KEYBOARD_HEIGHT = 162;

- (void) toggleViewElements:(BOOL)enabled {
	usernameTextField.enabled = enabled;
	passwordTextField.enabled = enabled;
	loginButton.enabled = enabled;
	resetButton.enabled = enabled;
}	

- (IBAction)login:(id)sender {
	// disable text fields, etc. on login view
	alertLabel.text = @"Logging in, please wait.";
	[self toggleViewElements:NO];

	LoginDao *loginDao = [[LoginDao alloc] init];
	GoogleClientLogin *googleClientLogin = [loginDao loginUser:usernameTextField.text :passwordTextField.text];
	[loginDao release];
		
	if (googleClientLogin == nil) {
		alertLabel.text = @"Login failed. Perhaps wrong username/password or no connection?";
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Login Failed"
															message:@"Login failed: Perhaps wrong username/password combination or no internet connection?" 
															delegate:nil 
															cancelButtonTitle:@"Okay" otherButtonTitles:nil];
		[alertView show];
		[alertView release];
	} else {
		alertLabel.text = @"Login successful.";
		PortfoliosViewController *aView = [[PortfoliosViewController alloc] initWithNibName:@"PortfoliosViewController" bundle:[NSBundle mainBundle]];
		aView.googleClientLogin = googleClientLogin;
		self.portfoliosViewController = aView;
		[aView release];
		[self.navigationController pushViewController:portfoliosViewController animated:YES];
	}
	
	// re-enable text fields, etc. on login view
	[self toggleViewElements:YES];
}

- (IBAction)resetForm:(id)sender {
	alertLabel.text = @"";
	
	usernameTextField.text = @"";
	passwordTextField.text = @"";
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	self.title = @"Login";
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

// Animate to make sure the text field that is being edited is viewed 
// and not covered up by the keyboard
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    CGRect textFieldRect =
	[self.view.window convertRect:textField.bounds fromView:textField];
    CGRect viewRect =
	[self.view.window convertRect:self.view.bounds fromView:self.view];

	CGFloat midline = textFieldRect.origin.y + 0.5 * textFieldRect.size.height;
    CGFloat numerator =
	midline - viewRect.origin.y
	- MINIMUM_SCROLL_FRACTION * viewRect.size.height;
    CGFloat denominator =
	(MAXIMUM_SCROLL_FRACTION - MINIMUM_SCROLL_FRACTION)
	* viewRect.size.height;
    CGFloat heightFraction = numerator / denominator;
	
	if (heightFraction < 0.0)
    {
        heightFraction = 0.0;
    }
    else if (heightFraction > 1.0)
    {
        heightFraction = 1.0;
    }
	
	UIInterfaceOrientation orientation =
	[[UIApplication sharedApplication] statusBarOrientation];
    if (orientation == UIInterfaceOrientationPortrait ||
        orientation == UIInterfaceOrientationPortraitUpsideDown)
    {
        animatedDistance = floor(PORTRAIT_KEYBOARD_HEIGHT * heightFraction);
    }
    else
    {
        animatedDistance = floor(LANDSCAPE_KEYBOARD_HEIGHT * heightFraction);
    }
	
	CGRect viewFrame = self.view.frame;
    viewFrame.origin.y -= animatedDistance;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
    
    [self.view setFrame:viewFrame];
    
    [UIView commitAnimations];
}

// Change view back to how it was after moving the textfield being edited 
// so that the keyboard is not in the way.
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    CGRect viewFrame = self.view.frame;
    viewFrame.origin.y += animatedDistance;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
    
    [self.view setFrame:viewFrame];
    
    [UIView commitAnimations];
}

- (void)dealloc {
	[usernameTextField release];
	[passwordTextField release];
	[alertLabel release];
	[loginButton release];
	[resetButton release];
	[portfoliosViewController release];
	
    [super dealloc];
}


@end
