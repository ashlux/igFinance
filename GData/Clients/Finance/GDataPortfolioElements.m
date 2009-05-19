/* Copyright (c) 2008 Google Inc.
*
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
*     http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*/

//
//  GDataPortfolioElements.m
//


#import "GDataPortfolioElements.h"
#import "GDataMoneyElements.h"
#import "GDataEntryFinancePortfolio.h" // for namespaces

static NSString *const kGainPercentageAttr = @"gainPercentage";
static NSString *const kReturn1wAttr = @"return1w";
static NSString *const kReturn1yAttr = @"return1y";
static NSString *const kReturn3mAttr = @"return3m";
static NSString *const kReturn3yAttr = @"return3y";
static NSString *const kReturn4wAttr = @"return4w";
static NSString *const kReturn5yAttr = @"return5y";
static NSString *const kReturnOverallAttr = @"returnOverall";
static NSString *const kReturnYTDAttr = @"returnYTD";

// portfolio-only
static NSString *const kCurrencyCodeAttr = @"currencyCode";

// position-only
static NSString *const kSharesAttr = @"shares";


//
// Portfolio subclass
//

@implementation GDataPortfolioData
+ (NSString *)extensionElementPrefix { return kGDataNamespaceFinancePrefix; }
+ (NSString *)extensionElementURI { return kGDataNamespaceFinance; }
+ (NSString *)extensionElementLocalName { return @"portfolioData"; }

+ (GDataPortfolioData *)portfolioData {
  return [[[self alloc] init] autorelease];
}

- (void)addParseDeclarations {
  
  [super addParseDeclarations];
  
  NSArray *attrs = [NSArray arrayWithObject:kCurrencyCodeAttr];
  
  [self addLocalAttributeDeclarations:attrs];
}

- (NSString *)currencyCode {
  return [self stringValueForAttribute:kCurrencyCodeAttr];  
}

- (void)setCurrencyCode:(NSString *)str {
  [self setStringValue:str forAttribute:kCurrencyCodeAttr]; 
}
@end

// 
// Position subclass
//

@implementation GDataPositionData
+ (NSString *)extensionElementPrefix { return kGDataNamespaceFinancePrefix; }
+ (NSString *)extensionElementURI { return kGDataNamespaceFinance; }
+ (NSString *)extensionElementLocalName { return @"positionData"; }

+ (GDataPositionData *)positionData {
  return [[[self alloc] init] autorelease];
}

- (void)addParseDeclarations {
    
  // add shares before adding the superclass's attributes so it shows
  // first in the description's list of attributes
  
  NSArray *attrs = [NSArray arrayWithObject:kSharesAttr];
  [self addLocalAttributeDeclarations:attrs];
  
  [super addParseDeclarations];
}

- (NSNumber *)shares {
  return [self doubleNumberForAttribute:kSharesAttr];  
}

- (void)setShares:(NSNumber *)num {
  [self setStringValue:[num stringValue] forAttribute:kSharesAttr]; 
}
@end

//
// common base
//
@implementation GDataPortfolioBase 

- (void)addExtensionDeclarations {

  [super addExtensionDeclarations];

  Class elementClass = [self class];
  [self addExtensionDeclarationForParentClass:elementClass
                                 childClasses:
   [GDataCostBasis class],
   [GDataDaysGain class],
   [GDataGain class],
   [GDataMarketValue class],
   nil];
}

- (void)addParseDeclarations {
  
  NSArray *attrs = [NSArray arrayWithObjects:
                    kGainPercentageAttr, kReturnOverallAttr, kReturnYTDAttr,
                    kReturn1wAttr, kReturn1yAttr, kReturn3mAttr, kReturn3yAttr,
                    kReturn4wAttr, kReturn5yAttr, nil];
                    
  [self addLocalAttributeDeclarations:attrs];
}

#if !GDATA_SIMPLE_DESCRIPTIONS
- (NSMutableArray *)itemsForDescription {
  
  NSMutableArray *items = [super itemsForDescription];
  
  // extensions
  [self addToArray:items objectDescriptionIfNonNil:[self costBasis] withName:@"costBasis"];
  [self addToArray:items objectDescriptionIfNonNil:[self daysGain] withName:@"daysGain"];
  [self addToArray:items objectDescriptionIfNonNil:[self gain] withName:@"gain"];
  [self addToArray:items objectDescriptionIfNonNil:[self marketValue] withName:@"marketValue"];

  return items;
}
#endif

// common attributes

- (NSNumber *)gainPercentage {
  return [self doubleNumberForAttribute:kGainPercentageAttr];  
}

- (void)setGainPercentage:(NSNumber *)num {
  [self setStringValue:[num stringValue] forAttribute:kGainPercentageAttr]; 
}

- (NSNumber *)return1w {
  return [self doubleNumberForAttribute:kReturn1wAttr];  
}

- (void)setReturn1w:(NSNumber *)num {
  [self setStringValue:[num stringValue] forAttribute:kReturn1wAttr]; 
}

- (NSNumber *)return1y {
  return [self doubleNumberForAttribute:kReturn1yAttr];  
}

- (void)setReturn1y:(NSNumber *)num {
  [self setStringValue:[num stringValue] forAttribute:kReturn1yAttr]; 
}

- (NSNumber *)return3m {
  return [self doubleNumberForAttribute:kReturn3mAttr];  
}

- (void)setReturn3m:(NSNumber *)num {
  [self setStringValue:[num stringValue] forAttribute:kReturn3mAttr]; 
}

- (NSNumber *)return3y {
  return [self doubleNumberForAttribute:kReturn3yAttr];  
}

- (void)setReturn3y:(NSNumber *)num {
  [self setStringValue:[num stringValue] forAttribute:kReturn3yAttr]; 
}

- (NSNumber *)return4w {
  return [self doubleNumberForAttribute:kReturn4wAttr];  
}

- (void)setReturn4w:(NSNumber *)num {
  [self setStringValue:[num stringValue] forAttribute:kReturn4wAttr]; 
}

- (NSNumber *)return5y {
  return [self doubleNumberForAttribute:kReturn5yAttr];  
}

- (void)setReturn5y:(NSNumber *)num {
  [self setStringValue:[num stringValue] forAttribute:kReturn5yAttr]; 
}

- (NSNumber *)returnOverall {
  return [self doubleNumberForAttribute:kReturnOverallAttr];  
}

- (void)setReturnOverall:(NSNumber *)num {
  [self setStringValue:[num stringValue] forAttribute:kReturnOverallAttr]; 
}

- (NSNumber *)returnYTD {
  return [self doubleNumberForAttribute:kReturnYTDAttr];  
}

- (void)setReturnYTD:(NSNumber *)num {
  [self setStringValue:[num stringValue] forAttribute:kReturnYTDAttr]; 
}

// extensions

- (GDataCostBasis *)costBasis {
  return [self objectForExtensionClass:[GDataCostBasis class]];
}

 - (void)setCostBasis:(GDataCostBasis *)obj {
   [self setObject:obj forExtensionClass:[GDataCostBasis class]];
 }

- (GDataGain *)gain {
  return [self objectForExtensionClass:[GDataGain class]];
}

- (void)setGain:(GDataGain *)obj {
  [self setObject:obj forExtensionClass:[GDataGain class]];
}

- (GDataDaysGain *)daysGain {
  return [self objectForExtensionClass:[GDataDaysGain class]];
}

- (void)setDaysGain:(GDataDaysGain *)obj {
  [self setObject:obj forExtensionClass:[GDataDaysGain class]];
}

- (GDataMarketValue *)marketValue {
  return [self objectForExtensionClass:[GDataMarketValue class]];  
}

- (void)setMarketValue:(GDataMarketValue *)obj {
  [self setObject:obj forExtensionClass:[GDataMarketValue class]];
}

@end
