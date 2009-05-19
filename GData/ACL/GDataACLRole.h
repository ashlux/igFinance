/* Copyright (c) 2007-2008 Google Inc.
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
//  GDataRole.h
//

#import "GDataObject.h"

#undef _EXTERN
#undef _INITIALIZE_AS
#ifdef GDATAACLROLE_DEFINE_GLOBALS
#define _EXTERN 
#define _INITIALIZE_AS(x) =x
#else
#define _EXTERN extern
#define _INITIALIZE_AS(x)
#endif

_EXTERN NSString* const kGDataRoleNone      _INITIALIZE_AS(@"none");
_EXTERN NSString* const kGDataRolePeeker    _INITIALIZE_AS(@"peeker");
_EXTERN NSString* const kGDataRoleReader    _INITIALIZE_AS(@"reader");
_EXTERN NSString* const kGDataRoleWriter    _INITIALIZE_AS(@"writer");
_EXTERN NSString* const kGDataRoleOwner     _INITIALIZE_AS(@"owner");

// an element with a value attribute, as in
//  <gAcl:role value='owner'></gAcl:role>
//
//  http://code.google.com/apis/calendar/reference.html#gacl_reference


@interface GDataACLRole : GDataObject <GDataExtension> {
}

+ (GDataACLRole *)roleWithValue:(NSString *)value;

- (NSString *)value;
- (void)setValue:(NSString *)str; 

@end

