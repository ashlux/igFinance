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
//  GDataYouTubeElements.m
//

// http://code.google.com/apis/youtube/reference.html#Elements

#import "GDataYouTubeElements.h"
#import "GDataEntryYouTubeVideo.h"


// user info, like <yt:aboutMe>I am hot</yt:about me>
@implementation GDataYouTubeAboutMe
+ (NSString *)extensionElementURI       { return kGDataNamespaceYouTube; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceYouTubePrefix; }
+ (NSString *)extensionElementLocalName { return @"aboutMe"; }
@end

// user's age, an integer, like <yt:age>32</yt:age>
@implementation GDataYouTubeAge
// user's age, an integer, like <yt:age>32</yt:age>
+ (NSString *)extensionElementURI       { return kGDataNamespaceYouTube; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceYouTubePrefix; }
+ (NSString *)extensionElementLocalName { return @"age"; }
@end

// user's books, like <yt:books>Pride and Prejudice</yt:books>
@implementation GDataYouTubeBooks 
+ (NSString *)extensionElementURI       { return kGDataNamespaceYouTube; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceYouTubePrefix; }
+ (NSString *)extensionElementLocalName { return @"books"; }
@end

// rating of comment, like <yt:commentRating>1</yt:commentRating>
@implementation GDataYouTubeCommentRating
+ (NSString *)extensionElementURI       { return kGDataNamespaceYouTube; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceYouTubePrefix; }
+ (NSString *)extensionElementLocalName { return @"commentRating"; }
@end

// user's company, like <yt:company>Self employed</yt:company>
@implementation GDataYouTubeCompany
+ (NSString *)extensionElementURI       { return kGDataNamespaceYouTube; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceYouTubePrefix; }
+ (NSString *)extensionElementLocalName { return @"company"; }
@end

// count hint for entry content, like <yt:countHint>10</yt:countHint>
@implementation GDataYouTubeCountHint
+ (NSString *)extensionElementURI       { return kGDataNamespaceYouTube; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceYouTubePrefix; }
+ (NSString *)extensionElementLocalName { return @"countHint"; }
@end

// user's hobbies, like <yt:hobbies>Reading, skiing</yt:hobbies>
@implementation GDataYouTubeHobbies
+ (NSString *)extensionElementURI       { return kGDataNamespaceYouTube; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceYouTubePrefix; }
+ (NSString *)extensionElementLocalName { return @"hobbies"; }
@end

// user's hometown, like <yt:hometown>Seattle</yt:hometown>
@implementation GDataYouTubeHometown
+ (NSString *)extensionElementURI       { return kGDataNamespaceYouTube; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceYouTubePrefix; }
+ (NSString *)extensionElementLocalName { return @"hometown"; }
@end

// user's location, like <yt:location>Longbourn in Hertfordshire, Pemberley in Derbyshire</yt:location>
@implementation GDataYouTubeLocation
+ (NSString *)extensionElementURI       { return kGDataNamespaceYouTube; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceYouTubePrefix; }
+ (NSString *)extensionElementLocalName { return @"location"; }
@end

// user's movies, like <yt:movies>Pride and Prejudice, 2005</yt:movies>
@implementation GDataYouTubeMovies
+ (NSString *)extensionElementURI       { return kGDataNamespaceYouTube; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceYouTubePrefix; }
+ (NSString *)extensionElementLocalName { return @"movies"; }
@end

// user's music, like <yt:music>Pink Floyd</yt:music>
@implementation GDataYouTubeMusic
+ (NSString *)extensionElementURI       { return kGDataNamespaceYouTube; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceYouTubePrefix; }
+ (NSString *)extensionElementLocalName { return @"music"; }
@end

// user's occupation, like <yt:occupation>Doctor of quackery</yt:occupation>
@implementation GDataYouTubeOccupation
+ (NSString *)extensionElementURI       { return kGDataNamespaceYouTube; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceYouTubePrefix; }
+ (NSString *)extensionElementLocalName { return @"occupation"; }
@end

// user's school, like <yt:school>Rocky Mountain High</yt:school>
@implementation GDataYouTubeSchool
+ (NSString *)extensionElementURI       { return kGDataNamespaceYouTube; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceYouTubePrefix; }
+ (NSString *)extensionElementLocalName { return @"school"; }
@end

// user's gender, like <yt:gender>f</yt:gender>
@implementation GDataYouTubeGender
+ (NSString *)extensionElementURI       { return kGDataNamespaceYouTube; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceYouTubePrefix; }
+ (NSString *)extensionElementLocalName { return @"gender"; }
@end

// user's relationship, like <yt:relationship>available</yt:relationship>
@implementation GDataYouTubeRelationship
+ (NSString *)extensionElementURI       { return kGDataNamespaceYouTube; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceYouTubePrefix; }
+ (NSString *)extensionElementLocalName { return @"relationship"; }
@end

// video duration in seconds, like <yt:duration seconds="2462" />
@implementation GDataYouTubeDuration
+ (NSString *)extensionElementURI       { return kGDataNamespaceYouTube; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceYouTubePrefix; }
+ (NSString *)extensionElementLocalName { return @"duration"; }

- (NSString *)attributeName {
  return @"seconds";
}
@end

// element indicating non-embeddable video, <yt:noembed/>
@implementation GDataYouTubeNonEmbeddable
+ (NSString *)extensionElementURI       { return kGDataNamespaceYouTube; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceYouTubePrefix; }
+ (NSString *)extensionElementLocalName { return @"noembed"; }
@end

// position in a playlist, an integer, like <yt:position>1</yt:position>
@implementation GDataYouTubePosition
+ (NSString *)extensionElementURI       { return kGDataNamespaceYouTube; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceYouTubePrefix; }
+ (NSString *)extensionElementLocalName { return @"position"; }
@end

@implementation GDataYouTubePrivate
+ (NSString *)extensionElementURI       { return kGDataNamespaceYouTube; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceYouTubePrefix; }
+ (NSString *)extensionElementLocalName { return @"private"; }
@end

@implementation GDataYouTubeFirstName
+ (NSString *)extensionElementURI       { return kGDataNamespaceYouTube; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceYouTubePrefix; }
+ (NSString *)extensionElementLocalName { return @"firstName"; }
@end

@implementation GDataYouTubeLastName
+ (NSString *)extensionElementURI       { return kGDataNamespaceYouTube; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceYouTubePrefix; }
+ (NSString *)extensionElementLocalName { return @"lastName"; }
@end

@implementation GDataYouTubePlaylistID
+ (NSString *)extensionElementURI       { return kGDataNamespaceYouTube; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceYouTubePrefix; }
+ (NSString *)extensionElementLocalName { return @"playlistId"; }
@end

@implementation GDataYouTubePlaylistTitle
+ (NSString *)extensionElementURI       { return kGDataNamespaceYouTube; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceYouTubePrefix; }
+ (NSString *)extensionElementLocalName { return @"playlistTitle"; }
@end

@implementation GDataYouTubeQueryString
+ (NSString *)extensionElementURI       { return kGDataNamespaceYouTube; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceYouTubePrefix; }
+ (NSString *)extensionElementLocalName { return @"queryString"; }
@end

// spam hint, like <yt:spamHint/>
@implementation GDataYouTubeSpamHint
+ (NSString *)extensionElementURI       { return kGDataNamespaceYouTube; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceYouTubePrefix; }
+ (NSString *)extensionElementLocalName { return @"spamHint"; }
@end

// status, like <yt:status>accepted</yt:status>
@implementation GDataYouTubeStatus
+ (NSString *)extensionElementURI       { return kGDataNamespaceYouTube; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceYouTubePrefix; }
+ (NSString *)extensionElementLocalName { return @"status"; }
@end

// user's name, like <yt:username>liz</yt:username>
@implementation GDataYouTubeUsername
+ (NSString *)extensionElementURI       { return kGDataNamespaceYouTube; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceYouTubePrefix; }
+ (NSString *)extensionElementLocalName { return @"username"; }
@end

// token extension to edit-media links, like <yt:token>LongForm</yt:token>
@implementation GDataYouTubeToken
+ (NSString *)extensionElementURI       { return kGDataNamespaceYouTube; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceYouTubePrefix; }
+ (NSString *)extensionElementLocalName { return @"token"; }
@end

// date video was recorded <yt:recorded>1998-12-1</yt:recorded>
@implementation GDataYouTubeRecordedDate
+ (NSString *)extensionElementURI       { return kGDataNamespaceYouTube; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceYouTubePrefix; }
+ (NSString *)extensionElementLocalName { return @"recorded"; }
@end

// elements deprecated for GData v2

// user or playlist description, like <yt:description>User's description goes here.</yt:description>
@implementation GDataYouTubeDescription
+ (NSString *)extensionElementURI       { return kGDataNamespaceYouTube; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceYouTubePrefix; }
+ (NSString *)extensionElementLocalName { return @"description"; }
@end

// element indicating adult-oriented video, <yt:racy/>
@implementation GDataYouTubeRacy
+ (NSString *)extensionElementURI       { return kGDataNamespaceYouTube; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceYouTubePrefix; }
+ (NSString *)extensionElementLocalName { return @"racy"; }
@end
