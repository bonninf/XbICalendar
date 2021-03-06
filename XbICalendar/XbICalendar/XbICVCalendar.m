//
//  XbICVCalendar.m
//

#import "XbICVCalendar.h"
#import "XbICFile.h"
#import "XbICProperty.h"

@interface XbICVCalendar ()

@end

@implementation XbICVCalendar


#pragma mark - Class Methods

+(instancetype) vCalendarFromFile: (NSString *) pathname  {
    
    XbICFile * file = [XbICFile fileWithPathname:pathname];
    
    XbICComponent *  component = (XbICVCalendar *) [file read];
    

    
    return [XbICVCalendar vCalendarfromCompnent:component];
}

/**
 * Return an array of the calendar items of the given kind retrieved in a ICS file.
 *
 * @author fb
 * @version gh#1
 */
+(NSArray *) vCalendarsFromFile: (NSString *) pathname  {
    
    XbICFile * file = [XbICFile fileWithPathname:pathname];
    
    XbICComponent *  component = (XbICVCalendar *) [file read];
    
    return [XbICVCalendar vCalendarsfromComponent:component];
}

+(instancetype) vCalendarFromString: (NSString *) content {
    
    XbICComponent *  component  = [  XbICComponent componentWithString:content];
    
    return [XbICVCalendar vCalendarfromCompnent:component];
    
}

+(instancetype) vCalendarfromCompnent: (XbICComponent *) component {
    if (component.kind ==ICAL_XROOT_COMPONENT) {
        component = [component firstComponentOfKind:ICAL_VCALENDAR_COMPONENT];
    }
    
    if (component.kind != ICAL_VCALENDAR_COMPONENT) {
        NSLog(@"Error: Unexpected Component in ICS File");
        return nil;
    }
    
    if (![[(XbICVCalendar *)component version] isEqualToString:@"2.0"] ) {
        NSLog(@"Error: Unexpected ICS File Version");
        return nil;
    }
    return (XbICVCalendar *) component;
}

/**
 * Return an array of the components of the given kind retrieved in the given component.
 *
 * @author fb
 * @version gh#1
 */
+(NSArray *) vCalendarsfromComponent: (XbICComponent *)component {

    NSArray *components;
    
    if (component.kind ==ICAL_XROOT_COMPONENT) {
        components = [component componentsOfKind:ICAL_VCALENDAR_COMPONENT];
    }
    else {
        NSLog(@"Error: Unexpected Component in ICS File: %u", component.kind);
    }
    
    return components;
}

/**
 * Create a calendar with an array of components such as events
 *
 * @author fb
 * @version fb:gh#3
 */
+ (XbICVCalendar *)calendarWithComponents:(NSArray *)components
{
    XbICVCalendar *calendar = [[XbICVCalendar alloc] initWithComponents:components];
    return calendar;
}

/**
 * init an icalendar with an array of components
 *
 * @author fb
 * @version fb:gh#3
 */
- (XbICVCalendar *)initWithComponents:(NSArray *)components
{
    icalcomponent *icalCal = icalcomponent_new(ICAL_VCALENDAR_COMPONENT);
    icalcomponent_add_property(icalCal, icalproperty_new_version("2.0"));
    
    [components enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        XbICComponent *component = obj;
        icalcomponent *icalComp = [component icalBuildComponent];
        icalcomponent_add_component(icalCal, icalComp);
        if (icalComp) {
            icalcomponent_free(icalComp);
        }
    }];
    
    XbICVCalendar *calendar = (XbICVCalendar *)[XbICComponent componentWithIcalComponent:icalCal];
    
    if (icalCal) {
        icalcomponent_free(icalCal);
    }
    
    return calendar;
}

#pragma mark - Object Lifecycle

-(instancetype) initWithIcalComponent:  (icalcomponent *) c {
  self = [super initWithIcalComponent: c];
  if (self) {

  }
  return self;
}

#pragma mark - Custom Accessors

-(NSString *) method {
    return (NSString *)[[self firstPropertyOfKind:ICAL_METHOD_PROPERTY] value];
}

-(void) setMethod: (NSString *) newMethod {
    XbICProperty * property = [self firstPropertyOfKind:ICAL_METHOD_PROPERTY];
    property.value = [newMethod copy];

}


-(NSString *) version {
    NSArray * properties = [self propertiesOfKind:ICAL_VERSION_PROPERTY];
    if (properties.count != 1 ) {
        NSLog(@"Error: Version Error");
        return nil;
    }
    return (NSString *)[((XbICProperty *)properties[0]) value];
}




#pragma mark - NSObject Overides
//- (NSString *)description {
//    return [NSString stringWithFormat:@"<%@: %p> Key: %@, Value: %@, Parameters: %@",
//            NSStringFromClass([self class]), self, self.key, self.value, self.parameters];
//}
//
//- (instancetype)copyWithZone:(NSZone *)zone {
//    XbICProperty *object = [[[self class] allocWithZone:zone] init];
//    
//    if (object) {
//        object.value = [self.key copyWithZone:zone];
//        
//        if ([self.value respondsToSelector:@selector(copyWithZone:)]) {
//            object.value = [(id) self.value copyWithZone:zone];
//        }
//        else {
//            object.value = self.value;
//        }
//        
//        object.parameters = [self.parameters copyWithZone:zone];
//    }
//    
//    return object;
//}
//


@end
