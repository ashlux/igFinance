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
//  GDataEntryYouTubeUserEvent.h
//

#import "GDataEntryBase.h"

@class GDataRating;

@interface GDataEntryYouTubeUserEvent : GDataEntryBase

+ (GDataEntryYouTubeUserEvent *)userEventEntry;

// event type category

- (NSString *)userEventType;
- (void)setUserEventType:(NSString *)typeStr;

// extensions

- (NSString *)videoID;
- (void)setVideoID:(NSString *)str;

- (NSString *)username;
- (void)setUsername:(NSString *)str;

- (GDataRating *)rating;
- (void)setRating:(GDataRating *)obj;

// convenience accessors

- (GDataLink *)videoLink;
- (GDataLink *)commentLink;

@end
