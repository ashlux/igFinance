
#import "CurrencyPickerViewController.h"


@implementation CurrencyPickerViewController

@synthesize allCurrencyCodes;
@synthesize selectedCurrency;

- (NSMutableArray *) getAllCurrencyCodes {
	if (allCurrencyCodes != nil) {
		return allCurrencyCodes;
	}
	
	allCurrencyCodes = [[NSMutableArray alloc] initWithObjects:
	@"AED",
	@"ANG",
	@"ARS",
	@"AUD",
	@"BGN",
	@"BHD",
	@"BND",
	@"BOB",
	@"BRL",
	@"BWP",
	@"CAD",
	@"CHF",
	@"CLP",
	@"CNY",
	@"COP",
	@"CSD",
	@"CZK",
	@"DKK",
	@"EEK",
	@"EGP",
	@"EUR",
	@"FJD",
	@"GBP",
	@"HKD",
	@"HNL",
	@"HRK",
	@"HUF",
	@"IDR",
	@"ILS",
	@"INR",
	@"ISK",
	@"JPY",
	@"KRW",
	@"KWD",
	@"KZT",
	@"LKR",
	@"LTL",
	@"MAD",
	@"MUR",
	@"MXN",
	@"MYR",
	@"NOK",
	@"NPR",
	@"NZD",
	@"OMR",
	@"PEN",
	@"PHP",
	@"PKR",
	@"PLN",
	@"QAR",
	@"RON",
	@"RUB",
	@"SAR",
	@"SEK",
	@"SGD",
	@"SIT",
	@"SKK",
	@"THB",
	@"TRY",
	@"TTD",
	@"TWD",
	@"UAH",
	@"USD",
	@"VEB",
	@"ZAR",
	nil];
	return allCurrencyCodes;
}

- (void) loadView {
	[super loadView];
	
	// disable main tableview from scrolling, want sub-tableview to scroll instead
	((UITableView*) self.view).scrollEnabled = NO;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
//}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {	
	return [[self getAllCurrencyCodes] count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *identifier = @"CurrencyCell";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier]; 
	if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero
									   reuseIdentifier:identifier] autorelease];
	}	

	[cell setText:[[self getAllCurrencyCodes] objectAtIndex:indexPath.row]];
	return cell;
}  

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	selectedCurrency = [[self getAllCurrencyCodes] objectAtIndex:indexPath.row];
	[self.navigationController popViewControllerAnimated:YES];
}
	
- (void)dealloc {
	[allCurrencyCodes release];
	 
    [super dealloc];
}


@end
