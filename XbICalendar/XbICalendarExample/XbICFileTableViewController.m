//
//  XbICFileTableViewController.m
//

#import "XbICFileTableViewController.h"
#import "XbICViewController.h"

#import "XbICEventsTableViewController.h" //fb:gh#1

@interface XbICFileTableViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSArray * files;
@property (nonatomic, strong) NSString * selectedFile;

@end

@implementation XbICFileTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

static NSString * kCellReuseIdentifier = @"Cell";

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"XbICalender Example";
    
    self.files = [self arrayOfICSFiles];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kCellReuseIdentifier];

}



#pragma mark - UITableViewDataSource, UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    return [self.files count];
    
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:kCellReuseIdentifier];
    
    cell.textLabel.text = self.files[indexPath.row];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedFile = self.files[indexPath.row];

    //fb:gh#1: show the events list instead of the detail of the first event
    //[self performSegueWithIdentifier:@"detailSegue" sender:self];
    XbICEventsTableViewController *controller = [[XbICEventsTableViewController alloc] init];
    controller.fileName = self.selectedFile;
    [self.navigationController pushViewController:controller animated:YES];
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSLog(@"prepareForSegue: %@", segue.identifier  );
    if ([segue.identifier isEqualToString:@"detailSegue"])
    {
        XbICViewController * viewController = segue.destinationViewController;
        viewController.fileName = self.selectedFile;

    }
}

#pragma mark - File Access
-(NSArray *) arrayOfICSFiles {
    NSString *bundleRoot = [[NSBundle mainBundle] bundlePath];
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray *dirContents = [fm contentsOfDirectoryAtPath:bundleRoot error:nil];
    NSPredicate *fltr = [NSPredicate predicateWithFormat:@"self ENDSWITH '.ics'"];
    NSArray *files = [dirContents filteredArrayUsingPredicate:fltr];

    return files;
}

@end
