/* Copyright (c) 2007 Google Inc.
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
//  GDataACLScope.m
//

#define GDATAACLSCOPE_DEFINE_GLOBALS 1
#import "GDataACLScope.h"

#import "GDataEntryACL.h"

static NSString* const kTypeAttr = @"type";
static NSString* const kValueAttr = @"value";

@implementation GDataACLScope
// an element with type and value attributes, as in
//  <gAcl:scope type='user' value='user@gmail.com'></gAcl:scope>
//
//  http://code.google.com/apis/calendar/reference.html#gacl_reference

+ (NSString *)extensionElementURI       { return kGDataNamespaceACL; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceACLPrefix; }
+ (NSString *)extensionElementLocalName { return @"scope"; }

+ (GDataACLScope *)scopeWithType:(NSString *)type value:(NSString *)value {
  GDataACLScope *obj = [[[self alloc] init] autorelease];
  [obj setType:type];
  [obj setValue:value];
  return obj;
}

- (void)addParseDeclarations {
    
  NSArray *attrs = [NSArray arrayWithObjects:
                    kTypeAttr, kValueAttr, nil];
  [self addLocalAttributeDeclarations:attrs];
}

- (NSString *)value {
  return [self stringValueForAttribute:kValueAttr];
}

- (void)setValue:(NSString *)str {
  [self setStringValue:str forAttribute:kValueAttr];
}

- (NSString *)type {
  return [self stringValueForAttribute:kTypeAttr];
}

- (void)setType:(NSString *)str {
  [self setStringValue:str forAttribute:kTypeAttr];
}

@end
