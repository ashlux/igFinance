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
//  GDataEntryACL.h
//

#import "GDataEntryBase.h"

#undef _EXTERN
#undef _INITIALIZE_AS
#ifdef GDATAENTRYACL_DEFINE_GLOBALS
#define _EXTERN 
#define _INITIALIZE_AS(x) =x
#else
#define _EXTERN extern
#define _INITIALIZE_AS(x)
#endif

_EXTERN NSString* const kGDataCategoryACL _INITIALIZE_AS(@"http://schemas.google.com/acl/2007#accessRule");

_EXTERN NSString* const kGDataNamespaceACL _INITIALIZE_AS(@"http://schemas.google.com/acl/2007");
_EXTERN NSString* const kGDataNamespaceACLPrefix _INITIALIZE_AS(@"gAcl");

_EXTERN NSString* const kGDataLinkRelACL _INITIALIZE_AS(@"http://schemas.google.com/acl/2007#accessControlList");
_EXTERN NSString* const kGDataLinkRelControlledObject _INITIALIZE_AS(@"http://schemas.google.com/acl/2007#controlledObject");

@class GDataACLRole;
@class GDataACLScope;

#import "GDataCategory.h"

@interface GDataEntryACL : GDataEntryBase

+ (NSDictionary *)ACLNamespaces;

+ (id)ACLEntryWithScope:(GDataACLScope *)scope
                   role:(GDataACLRole *)role;

- (void)setRole:(GDataACLRole *)obj;
- (GDataACLRole *)role;

- (void)setScope:(GDataACLScope *)obj;
- (GDataACLScope *)scope;

// convenience accessors

- (GDataLink *)controlledObjectLink;
@end

@interface GDataEntryBase (GDataACLLinks)
- (GDataLink *)ACLLink;
@end
