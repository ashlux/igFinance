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
//  GDataQueryGoogleHealth.h
//

#import "GDataQuery.h"

@interface GDataQueryGoogleHealth : GDataQuery

+ (GDataQueryGoogleHealth *)healthQueryWithFeedURL:(NSURL *)feedURL;

- (void)setIsDigest:(BOOL)flag;
- (BOOL)isDigest;

- (void)setIsGrouped:(BOOL)flag;
- (BOOL)isGrouped;

- (void)setMaxResultsGroup:(int)val;
- (int)maxResultsGroup;

- (void)setMaxResultsInGroup:(int)val;
- (int)maxResultsInGroup;

- (void)setStartIndexGroup:(int)val;
- (int)startIndexGroup;

- (void)setStartIndexInGroup:(int)va;
- (int)startIndexInGroup;

@end
