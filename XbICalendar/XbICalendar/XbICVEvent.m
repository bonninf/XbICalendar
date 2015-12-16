//
//  XbICVEvent.m
//

#import "XbICVEvent.h"
#import "XbICInvite.h"

@implementation XbICVEvent

-(instancetype) initWithIcalComponent:  (icalcomponent *) c {
  self = [super initWithIcalComponent: c];
  if (self) {

  }
  return self;
}

/**
 * Create an event
 *
 * @author fb
 * @version fb:gh#3
 */
+ (XbICVEvent *)eventEmpty
{
    icalcomponent *component = icalcomponent_new(ICAL_VEVENT_COMPONENT);
    XbICVEvent *event = [[XbICVEvent alloc] initWithIcalComponent:component];
    return event;
}

/**
 * Create an event with an ek event
 *
 * @author fb
 * @version fb:gh#3
 */
+ (XbICVEvent *)eventWithEKEvent:(EKEvent *)ekEvent
{
    XbICVEvent *event = [[XbICVEvent alloc] initWithEKEvent:ekEvent];
    return event;
}

/**
 * init an event with an ek event
 *
 * @author fb
 * @version fb:gh#3
 */
- (XbICVEvent *)initWithEKEvent:(EKEvent *)ekEvent
{
    icalcomponent *component = icalcomponent_new(ICAL_VEVENT_COMPONENT);
    
    //event identifier
    icalcomponent_add_property(component, icalproperty_new_uid([ekEvent.eventIdentifier cStringUsingEncoding:NSUTF8StringEncoding]));
    
    //Creation date
    NSDate *aDate = ekEvent.creationDate ? ekEvent.creationDate : [NSDate date];
    icalcomponent_add_property(component, icalproperty_new_dtstamp([XbICProperty icaltimetypeFromObject:aDate isDate:NO]));
    
    //Start date
    aDate = ekEvent.creationDate ? ekEvent.startDate : [NSDate date];
    icalcomponent_add_property(component, icalproperty_new_dtstart([XbICProperty icaltimetypeFromObject:aDate isDate:NO]));
    
    //End date
    aDate = ekEvent.creationDate ? ekEvent.endDate : [NSDate date];
    icalcomponent_add_property(component, icalproperty_new_dtend([XbICProperty icaltimetypeFromObject:aDate isDate:NO]));

    //Title - Summary
    icalcomponent_add_property(component, icalproperty_new_summary([ekEvent.title cStringUsingEncoding:NSUTF8StringEncoding]));
    
    //Location and coordinate
    icalcomponent_add_property(component, icalproperty_new_location([ekEvent.location cStringUsingEncoding:NSUTF8StringEncoding]));

    //Note
    if (ekEvent.hasNotes) {
        icalcomponent_add_property(component, icalproperty_new_description([ekEvent.notes cStringUsingEncoding:NSUTF8StringEncoding]));
    }

    //Recurrence - RRule
    if (ekEvent.hasRecurrenceRules) {
        XbICProperty *property = [[XbICProperty alloc] init];
        property.kind = ICAL_RRULE_PROPERTY;
        property.valueKind = ICAL_RECUR_VALUE;
        property.value = [self dictionaryFromRecurrenceRule:[ekEvent.recurrenceRules firstObject]];

        icalcomponent_add_property(component, [property icalBuildProperty]);
    }

    
    //Alarm - vAlarm
    if (ekEvent.hasAlarms) {
        EKAlarm *alarm = [ekEvent.alarms firstObject];
        struct icaltriggertype trigger = icaltriggertype_from_int(alarm.relativeOffset);
        icalcomponent *icalAlarm = icalcomponent_vanew(ICAL_VALARM_COMPONENT, icalproperty_new_trigger(trigger), 0);
        icalcomponent_add_component(component, icalAlarm);
        icalcomponent_free(icalAlarm);
    }
    
    XbICVEvent *event = (XbICVEvent *)[XbICComponent componentWithIcalComponent:component];
    
    if (component) {
        icalcomponent_free(component);
    }
    
    return event;
}

/**
 * Return the recipier vEvent updated with category, attendees and coordinate.
 * The attendee array is formatted with the main ATTENDEE value and the CN parameter value. Other ATTENDEE parameters are not supported at this time by this method.
 *
 * @author fb
 * @version fb:gh#3
 */
- (XbICVEvent *)eventUpdatedWithCategory:(NSString *)category attendees:(NSArray *)attendees coordinate:(CLLocationCoordinate2D)coordinate
{
    icalcomponent *component = [self icalBuildComponent];
    
    //Category
    icalcomponent_add_property(component, icalproperty_new_categories([category cStringUsingEncoding:NSUTF8StringEncoding]));
    
    //Attendees
    if ([attendees count]) {
        [attendees enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSDictionary *values = obj;
            NSString *attendeeValue = values[@"attendeeValue"];
            icalproperty *icalProp = icalproperty_new_attendee([attendeeValue cStringUsingEncoding:NSUTF8StringEncoding]);
            NSString *cnValue = values[@"cnValue"];
            icalproperty_add_parameter(icalProp, icalparameter_new_cn([cnValue cStringUsingEncoding:NSUTF8StringEncoding]));
            icalcomponent_add_property(component, icalProp);
            icalproperty_free(icalProp);
        }];
    }
    
    //Coordinate - GEO
    struct icalgeotype icalGeoType;
    icalGeoType.lat = coordinate.latitude;
    icalGeoType.lon = coordinate.longitude;
    icalcomponent_add_property(component, icalproperty_new_geo(icalGeoType));
    
    XbICVEvent *event = (XbICVEvent *)[XbICComponent componentWithIcalComponent:component];
    
    if (component) {
        icalcomponent_free(component);
    }

    return event;
}

/**
 * Return the recipier vEvent updated with uid. If the uid property already exists then it's replaced.
 * 
 * @author fb
 * @version fb:gh#4
 */
- (XbICVEvent *)eventByReplacingIdentifier:(NSString *)identifier
{
    icalcomponent *component = [self icalBuildComponent];
    
    if ([identifier length]) {
        //Remove the uid property if exist
        icalproperty *property;
        while ((property = icalcomponent_get_first_property(component, ICAL_UID_PROPERTY))) {
            icalcomponent_remove_property(component, property);
            icalproperty_free(property);
        }
        
        //Update the event with the new event identifier
        icalcomponent_add_property(component, icalproperty_new_uid([identifier cStringUsingEncoding:NSUTF8StringEncoding]));
    }
    
    XbICVEvent *event = (XbICVEvent *)[XbICComponent componentWithIcalComponent:component];
    
    if (component) {
        icalcomponent_free(component);
    }
    
    return event;
}

-(NSDate *) dateStart {
    return (NSDate *)[[self firstPropertyOfKind:ICAL_DTSTART_PROPERTY] value];
}

-(NSDate *) dateEnd {
    return (NSDate *)[[self firstPropertyOfKind:ICAL_DTEND_PROPERTY] value];
}

-(NSDate *) dateStamp {
    return (NSDate *)[[self firstPropertyOfKind:ICAL_DTSTAMP_PROPERTY] value];
}

-(NSDate *) dateCreated {
    return (NSDate *)[[self firstPropertyOfKind:ICAL_CREATED_PROPERTY] value];
}

-(NSDate *) dateLastModified {
    return (NSDate *)[[self firstPropertyOfKind:ICAL_LASTMODIFIED_PROPERTY] value];
}

-(NSArray *) sequences {
    NSArray * properties =  [self propertiesOfKind:ICAL_SEQUENCE_PROPERTY];
    NSMutableArray * sequences = [NSMutableArray array];
    
    for (XbICProperty * sequence in properties) {
        [sequences addObject:sequence.value];
    }
    
    return sequences;
}

-(NSString *) UID {
    return (NSString *)[[self firstPropertyOfKind:ICAL_UID_PROPERTY] value];
}

-(NSString *) location {

    return (NSString *)[[self firstPropertyOfKind:ICAL_LOCATION_PROPERTY] value];
}

-(NSString *) summary {
    return (NSString *)[[self firstPropertyOfKind:ICAL_SUMMARY_PROPERTY] value];
}

-(NSString *) status {
    return (NSString *)[[self firstPropertyOfKind:ICAL_STATUS_PROPERTY] value];
}

-(NSString *) description {
    return (NSString *)[[self firstPropertyOfKind:ICAL_DESCRIPTION_PROPERTY] value];
}

-(XbICPerson *) organizer {
    return (XbICPerson *)[self firstPropertyOfKind:ICAL_ORGANIZER_PROPERTY];
}


-(NSArray *) attendees {
    return [self propertiesOfKind:ICAL_ATTENDEE_PROPERTY];
}

static NSString * mailto = @"mailto";
-(NSString *) stringFixUpEmail: email {
    
    if ([email hasPrefix:mailto]) {
        return email;
    }
    return [NSString stringWithFormat:@"mailto:%@", email];
}

-(NSString *) stringInviteResponse: (XbICInviteResponse) response  {
    switch (response) {
        case XbICInviteResponseAccept:
            return @"ACCEPT";
            break;
        case XbICInviteResponseDecline:
            return @"DECLINE";
            break;
        case XbICInviteResponseTenative:
            return @"TENATIVE";
            break;
        case XbICInviteResponseUnknown:
        default:
            return @"UNKNOWN";
            break;
    }
}

-(XbICInviteResponse) responseInviteFromString: (NSString *) status {

  if ([status isEqualToString:@"ACCEPT"] || [status isEqualToString:@"ACCEPTED"] || [status isEqualToString:@"YES"]) {
    return XbICInviteResponseAccept;
  }
  if ([status isEqualToString:@"DECLINE"] || [status isEqualToString:@"DECLINED"] || [status isEqualToString:@"NO"]) {
    return XbICInviteResponseDecline;
  }
  if ([status isEqualToString:@"TENATIVE"] || [status isEqualToString:@"TENATIVED"] || [status isEqualToString:@"MAYBE"]) {
    return XbICInviteResponseTenative;
  }

    return XbICInviteResponseUnknown;
}

- (void) updateAttendeeWithEmail: (NSString *) email withResponse: (XbICInviteResponse) response {
    NSArray  * attendees = self.attendees;
    for (XbICProperty * attendee in  attendees) {
        
        if ([(NSString *)attendee.value isEqualToString:[self stringFixUpEmail:email]]) {
            NSMutableDictionary * parameters = [attendee.parameters mutableCopy];
            
            parameters[@"PARTSTAT"] = [self stringInviteResponse:response];
            
            attendee.parameters = [NSDictionary dictionaryWithDictionary:parameters];
        }
    }
}


- (XbICInviteResponse) lookupAttendeeStatusForEmail: (NSString *) email {
  NSArray  * attendees = self.attendees;
  for (XbICProperty * attendee in  attendees) {

    if ([(NSString *)attendee.value isEqualToString:[self stringFixUpEmail:email]]) {

      NSDictionary * parameters = attendee.parameters;

      return [self responseInviteFromString: parameters[@"PARTSTAT"]];
    }
  }
  return XbICInviteResponseUnknown;
}

/**
 * Return a dictionary with a EK Recurrence Rule.
 *
 * @author fb
 * @version fb:gh#3
 */
- (NSDictionary *)dictionaryFromRecurrenceRule:(EKRecurrenceRule *)rule
{
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    NSArray *weekDays;

    icalrecurrencetype_frequency icalFrequency;
    switch (rule.frequency) {
        case EKRecurrenceFrequencyDaily:
            icalFrequency = ICAL_DAILY_RECURRENCE;
            weekDays = @[@(ICAL_MONDAY_WEEKDAY), @(ICAL_TUESDAY_WEEKDAY), @(ICAL_WEDNESDAY_WEEKDAY), @(ICAL_THURSDAY_WEEKDAY),@(ICAL_FRIDAY_WEEKDAY)];
            //recurrenceType.by_day = "MO";
            break;
            
        case EKRecurrenceFrequencyWeekly:
            icalFrequency = ICAL_WEEKLY_RECURRENCE;
            break;
        case EKRecurrenceFrequencyMonthly:
            icalFrequency = ICAL_MONTHLY_RECURRENCE;
            break;
        case EKRecurrenceFrequencyYearly:
            icalFrequency = ICAL_YEARLY_RECURRENCE;
            break;
        default:
            icalFrequency = ICAL_NO_RECURRENCE;
            break;
    }
    [dictionary setObject:@(icalFrequency) forKey:@"freq"];
    if ([weekDays count]) {
        [dictionary setObject:weekDays forKey:@"by_day"];
    }
    [dictionary setObject:@(rule.interval) forKey:@"interval"];
    
    
    NSDate *endDate = rule.recurrenceEnd.endDate;
    if (endDate) {
        [dictionary setObject:endDate forKey:@"until"];
    }
    else {
        [dictionary setObject:@((int)rule.recurrenceEnd.occurrenceCount) forKey:@"count"];
    }
    
    return [dictionary copy];
}

@end
