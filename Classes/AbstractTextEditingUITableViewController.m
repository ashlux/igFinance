// Class adopted mostly from http://iphoneincubator.com/blog/windows-views/how-to-create-a-data-entry-screen

#import "AbstractTextEditingUITableViewController.h"

@implementation AbstractTextEditingUITableViewController

CGRect keyboardBounds;

- (void)scrollViewToCenterOfScreen:(UIView *)theView {
	CGFloat viewCenterY = theView.center.y;
	CGRect applicationFrame = [[UIScreen mainScreen] applicationFrame];
	
	CGFloat availableHeight = applicationFrame.size.height - keyboardBounds.size.height;	// Remove area covered by keyboard
	
	CGFloat y = viewCenterY - availableHeight / 2.0;
	if (y < 0) {
		y = 0;
	}
	UIScrollView *scrollView = (UIScrollView*) self.view;
	scrollView.contentSize = CGSizeMake(applicationFrame.size.width, applicationFrame.size.height + keyboardBounds.size.height);
	[scrollView setContentOffset:CGPointMake(0, y) animated:YES];
}

- (void)scrollViewBackToNormal {
	UIScrollView *scrollView = (UIScrollView*) self.view;
	CGRect applicationFrame = [[UIScreen mainScreen] applicationFrame];
	scrollView.contentSize = CGSizeMake(applicationFrame.size.width, applicationFrame.size.height);
	[scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {  
	[self scrollViewToCenterOfScreen:textField];  
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[self scrollViewBackToNormal];
	[textField resignFirstResponder];
	return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView {  
	[self scrollViewToCenterOfScreen:textView];  
}

- (BOOL)textVieShouldReturn:(UITextField *)textView {
	[self scrollViewBackToNormal];
	[textView resignFirstResponder];
	return YES;
}

- (void)keyboardNotification:(NSNotification*)notification {
	NSDictionary *userInfo = [notification userInfo];
	NSValue *keyboardBoundsValue = [userInfo objectForKey:UIKeyboardBoundsUserInfoKey];
	[keyboardBoundsValue getValue:&keyboardBounds];
}

- (void)registerForKeyboardNotifications {
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(keyboardNotification:)  
												 name:UIKeyboardWillShowNotification  
											   object:nil];
}

- (void) loadView {
	[super loadView];
	[self registerForKeyboardNotifications];
}

- (void)dealloc {
    [super dealloc];
}

@end
