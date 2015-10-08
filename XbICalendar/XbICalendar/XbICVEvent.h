//
//  XbICVEvent.h
//

#import "ical.h"
#import "XbICComponent.h"
#import "XbICPerson.h"
#import "XbICInvite.h"
#import <EventKit/EventKit.h> //fb:gh#3


@interface XbICVEvent : XbICComponent

-(NSDate *) dateStart;
-(NSDate *) dateEnd;
-(NSDate *) dateStamp;
-(NSDate *) dateCreated;
-(NSDate *) dateLastModified;
-(XbICPerson *) organizer;
-(NSString *) UID;
-(NSArray *) attendees;
-(NSString *) location;
-(NSString *) description;
-(NSArray *) sequences;
-(NSString *) status;
-(NSString *) summary;

- (void) updateAttendeeWithEmail: (NSString *) email withResponse: (XbICInviteResponse) response;
- (XbICInviteResponse) lookupAttendeeStatusForEmail: (NSString *) email;

+ (XbICVEvent *)eventEmpty; //fb:gh#3
+ (XbICVEvent *)eventWithEKEvent:(EKEvent *)ekEvent; //fb:gh#3
- (XbICVEvent *)eventUpdatedWithCategory:(NSString *)category attendees:(NSArray *)attendees coordinate:(CLLocationCoordinate2D)coordinate; //fb:gh#3

@end
