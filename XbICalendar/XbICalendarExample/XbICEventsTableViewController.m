//
//  XbICEventsTableViewController.m
//  XbICalendar
//
//  Created by François Bonnin on 24/09/2015.
//  Copyright (c) 2015 GaltSoft. All rights reserved.
//

#import "XbICEventsTableViewController.h"
#import "XBICalendar.h"
#import "XbICPropertiesTableViewController.h"

@interface XbICEventsTableViewController ()

@property (nonatomic, strong) NSDictionary *calendars;
//@property (nonatomic, strong) NSString * selectedFile;

@end

static NSString * kCellReuseIdentifier = @"XbICEventsTableViewControllerCell";

@implementation XbICEventsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;

    self.calendars = [self eventsFromFile:self.fileName];
    
    self.tableView.rowHeight = 40;
    //[self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kCellReuseIdentifier];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    NSLog(@"Debug: number of sections: %ld",[[self.calendars allKeys] count]);
    return [[self.calendars allKeys] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    NSArray *keys = [self.calendars allKeys];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"description" ascending:YES];
    keys = [keys sortedArrayUsingDescriptors:@[sortDescriptor]];

    NSInteger result;
    if (section < [[self.calendars allKeys] count]) {
        NSString *key = [[self sectionTitles] objectAtIndex:section];
        NSArray *values = [self.calendars objectForKey:key];
        NSLog(@"Debug: number of events for the %@th section: %ld", key, [values count]);
        result = [values count];
    }
    else {
        NSLog(@"Debug, issue with this section %ld by %ld", section, [[self.calendars allKeys] count]);
        result = 0;
    }
    return result;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *title;
    if (section < [[self.calendars allKeys] count]) {
        title = [[self sectionTitles] objectAtIndex:section];
    }
    else {
        NSLog(@"Debug, issue with this section %ld by %ld", section, [[self.calendars allKeys] count]);
    }
    
    return title;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellReuseIdentifier];
    if(cell == nil ) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:kCellReuseIdentifier];
    }
    
    // Configure the cell...
    XbICVEvent * event = [self eventFromIndexPath:indexPath];

    if (event) {
        if ([event respondsToSelector:@selector(summary)]) {
            cell.textLabel.text = [event summary];
            NSDateFormatter * df = [[NSDateFormatter alloc] init];
            [df setDateStyle: NSDateFormatterMediumStyle];
            [df setTimeStyle:NSDateFormatterShortStyle];
            cell.detailTextLabel.text = [NSString stringWithFormat:@"From %@ to %@", [df stringFromDate:[event dateStart]], [df stringFromDate:[event dateEnd]]];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        else {
            NSLog(@"Debug: this event does not respond to the summary selector: %@", [event description]);
        }
    }
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //self.selectedFile = self.files[indexPath.row];
    
    XbICPropertiesTableViewController *controller = [[XbICPropertiesTableViewController alloc] init];
    controller.event = [self eventFromIndexPath:indexPath];
    [self.navigationController pushViewController:controller animated:YES];
    
}

#pragma  mark - Table view utils

- (NSArray *)sectionTitles
{
    NSArray *keys = [self.calendars allKeys];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"description" ascending:YES];
    keys = [keys sortedArrayUsingDescriptors:@[sortDescriptor]];

    return keys;
}

- (XbICVEvent *)eventFromIndexPath:(NSIndexPath *)indexPath
{
    XbICVEvent *event;
    if (indexPath.section < [[self.calendars allKeys] count]) {
        NSString *sectionTitle = [[self sectionTitles] objectAtIndex:indexPath.section];
        NSArray *events = [self.calendars objectForKey:sectionTitle];
        if (indexPath.row < [events count]) {
            event = [events objectAtIndex:indexPath.row];
        }
        else {
            NSLog(@"Debug, issue with this row %ld/%ld of the section %ld", indexPath.row, [events count], indexPath.section);
        }
    }
    else {
        NSLog(@"Debug, issue with this section %ld by %ld", indexPath.section, [[self.calendars allKeys] count]);
    }

    return event;
}

#pragma mark - Calendar utils

- (NSDictionary *)eventsFromFile:(NSString *)aFileName
{
    NSString *path = [[NSBundle mainBundle] resourcePath];
    NSString *pathname = [NSString stringWithFormat:@"%@/%@", path, aFileName];
    
    NSArray *vCalendars = [XbICVCalendar vCalendarsFromFile:pathname];

    NSMutableDictionary __block *mutableCalendars = [NSMutableDictionary dictionaryWithCapacity:[vCalendars count]];
    [vCalendars enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        XbICVCalendar * vCalendar = obj;
        
        NSArray *events = [vCalendar subcomponents];
        NSMutableArray __block *mutableEvents = [NSMutableArray arrayWithCapacity:[events count]];
        [events enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if ([obj isKindOfClass:[XbICVEvent class]]) {
                [mutableEvents addObject:(XbICVEvent *)obj];
            }
        }];
        
        if ([mutableEvents count]) {
            NSString *prefix = [[mutableCalendars allKeys] count] < 10 ? @"0" : @"";
            [mutableCalendars setObject:mutableEvents forKey:[NSString stringWithFormat:@"%@%d", prefix, (int)[[mutableCalendars allKeys] count]]];
        }
    }];
    
    return [mutableCalendars copy];
}


@end
