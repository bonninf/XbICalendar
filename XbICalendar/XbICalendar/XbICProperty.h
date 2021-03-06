//
//  XbICProperty.h
//
#import "ical.h"

@interface XbICProperty : NSObject


@property (nonatomic, copy) NSObject * value;
@property (nonatomic, copy) NSDictionary * parameters;
@property (nonatomic, assign) icalproperty_kind kind;
@property (nonatomic, assign) icalvalue_kind valueKind;


//-(instancetype) initWithKey: (NSString *) key value: (NSObject *) value parameters: (NSDictionary *) parameters;
//+(instancetype) propertyWithKey: (NSString *) key value: (NSObject *) value parameters: (NSDictionary *) parameters;
+(instancetype) propertyWithIcalProperty: (icalproperty *) p;
-(icalproperty *) icalBuildProperty ;
- (NSString *)stringWithICalPropertyKind; //fb:gh#2
+ (icaltimetype )icaltimetypeFromObject:(id)date isDate:(BOOL)isDate; //fb:gh#3

@end
