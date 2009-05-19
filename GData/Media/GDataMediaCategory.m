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
//  GDataMediaCategory.m
//

#import "GDataMediaCategory.h"
#import "GDataMediaGroup.h"

static NSString* const kSchemeAttr = @"scheme";
static NSString* const kLabelAttr = @"label";

@implementation GDataMediaCategory
// like <media:category scheme="http://search.yahoo.com/mrss/category_schema" label="foo">
//             music/artist/album/song</media:category>
// http://search.yahoo.com/mrss

+ (NSString *)extensionElementURI       { return kGDataNamespaceMedia; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceMediaPrefix; }
+ (NSString *)extensionElementLocalName { return @"category"; }

+ (GDataMediaCategory *)mediaCategoryWithString:(NSString *)str {
  GDataMediaCategory* obj = [[[GDataMediaCategory alloc] init] autorelease];
  [obj setStringValue:str];
  return obj;
}

- (void)addParseDeclarations {
  
  NSArray *attrs = [NSArray arrayWithObjects: 
                    kLabelAttr, kSchemeAttr, nil];
  
  [self addLocalAttributeDeclarations:attrs];
  
  [self addContentValueDeclaration];
}

- (NSString *)label {
  return [self stringValueForAttribute:kLabelAttr];
}

- (void)setLabel:(NSString *)str {
  [self setStringValue:str forAttribute:kLabelAttr];
}

- (NSString *)scheme {
  return [self stringValueForAttribute:kSchemeAttr];
}

- (void)setScheme:(NSString *)str {
  [self setStringValue:str forAttribute:kSchemeAttr];
}

- (NSString *)stringValue {
  return [self contentStringValue];
}

- (void)setStringValue:(NSString *)str {
  [self setContentStringValue:str];
}

@end


