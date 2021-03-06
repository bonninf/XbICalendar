//
//  XbICVCalendar.h
//
#import "ical.h"
#import "XbICComponent.h"

@interface XbICVCalendar : XbICComponent

+(instancetype) vCalendarFromFile: (NSString *) pathname;
+(NSArray *) vCalendarsFromFile: (NSString *) pathname;
+(instancetype) vCalendarFromString: (NSString *) content;

-(NSString *) version;
-(NSString *) method;
-(void) setMethod: (NSString *) newMethod;
+ (XbICVCalendar *)calendarWithComponents:(NSArray *)components; //fb:gh#3


@end
