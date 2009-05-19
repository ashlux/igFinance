/* Copyright (c) 2009 Google Inc.
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
//  GDataEntryHealthRegister.m
//

#import "GDataEntryHealthRegister.h"
#import "GDataEntryHealthProfile.h"

@implementation GDataEntryHealthRegister

+ (id)registerEntry {

  GDataEntryHealthRegister *obj = [[[self alloc] init] autorelease];

  [obj setNamespaces:[GDataEntryHealthProfile healthNamespaces]];

  return obj;
}

#pragma mark -

+ (NSString *)standardEntryKind {
  return kGDataCategoryH9Register;
}

+ (void)load {
  [self registerEntryClass];
}

+ (NSString *)defaultServiceVersion {
  return kGDataHealthDefaultServiceVersion;
}

#pragma mark -

// convenience accessor method
- (GDataLink *)completeLink {
  return [self linkWithRelAttributeValue:kGDataHealthRelComplete];
}

@end
