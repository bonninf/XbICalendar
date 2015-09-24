//
//  XbICEventsTableViewController.m
//  XbICalendar
//
//  Created by François Bonnin on 24/09/2015.
//  Copyright (c) 2015 GaltSoft. All rights reserved.
//

#import "XbICEventsTableViewController.h"
#import "XBICalendar.h"

@interface XbICEventsTableViewController ()

@property (nonatomic, strong) NSDictionary *calendars;
//@property (nonatomic, strong) NSString * selectedFile;

@end

static NSString * kCellReuseIdentifier = @"Cell";

@implementation XbICEventsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;

    self.calendars = [self eventsFromFile:self.fileName];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kCellReuseIdentifier];
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellReuseIdentifier forIndexPath:indexPath];
    if(cell == nil ) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:kCellReuseIdentifier];
    }
    
    // Configure the cell...
    XbICVEvent * event;
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
    

    if (event) {
        if ([event respondsToSelector:@selector(summary)]) {
            cell.textLabel.text = [event summary];
            NSDateFormatter * df = [[NSDateFormatter alloc] init];
            cell.detailTextLabel.text = [NSString stringWithFormat:@"From %@ to %@", [df stringFromDate:[event dateStart]], [df stringFromDate:[event dateEnd]]];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        else {
            NSLog(@"Debug: this event does not respond to the summary selector: %@", [event description]);
        }
    }
    
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma  mark - Table view utils

- (NSArray *)sectionTitles
{
    NSArray *keys = [self.calendars allKeys];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"description" ascending:YES];
    keys = [keys sortedArrayUsingDescriptors:@[sortDescriptor]];

    return keys;
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
