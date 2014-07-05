#import <XCTest/XCTest.h>

#define HC_SHORTHAND
#import <OCHamcrestIOS/OCHamcrestIOS.h>

#define MOCKITO_SHORTHAND
#import <OCMockitoIOS/OCMockitoIOS.h>

#import "LWArrayDataSource.h"

@interface LWArrayDataSourceTests : XCTestCase

@end

@implementation LWArrayDataSourceTests {
    LWArrayDataSource *dataSource;
}

- (void)setUp
{
    [super setUp];
    dataSource = [[LWArrayDataSource alloc] initWithItems:@[@"a", @"b"] cellIdentifier:@"foo" configureCellBlock:nil];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testIsInstantiable {
    XCTAssertNil([[LWArrayDataSource alloc] init], @"Default initializer should not be possible");
    id obj1 = [[LWArrayDataSource alloc] initWithItems:@[] cellIdentifier:@"foo" configureCellBlock:^(UITableViewCell *a, id b) {
    }];
    XCTAssertNotNil(obj1, @"Initializing should work");
}

//Somehow the mocking framework crashes
/*- (void)testUsesCellConfigureBlock {
    __block UITableViewCell *configuredCell = nil;
    __block id configuredObject = nil;
    TableViewCellConfigureBlock block = ^(UITableViewCell *a, id b) {
        configuredCell = a;
        configuredObject = b;
    };
    
    dataSource = [[LWArrayDataSource alloc] initWithItems:@[@"a", @"b"] cellIdentifier:@"foo" configureCellBlock:block];
    
    UITableView *mockTableView = mock([UITableView class]);
    
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [given([mockTableView dequeueReusableCellWithIdentifier:@"foo" forIndexPath:indexPath]) willReturn:cell];
    
    id result = [dataSource tableView:mockTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    XCTAssertEqual(result, cell, @"Result should be the same cell");
    XCTAssertEqual(configuredCell, cell, @"ConfiguredCell should be the same cell");
    XCTAssertEqual(configuredObject, @"a", @"Object should be a");
}*/

- (void)testAmountOfRows {
    id mockTableView = mock([UITableView class]);
    dataSource = [[LWArrayDataSource alloc] initWithItems:@[@"a", @"b"] cellIdentifier:@"foo" configureCellBlock:nil];
    XCTAssertEqual([dataSource tableView:mockTableView numberOfRowsInSection:0], 2, @"Should contain two rows");
}

- (void)testDataSourceShouldConformsToUITableViewDataSourceProtocol
{
    assertThatBool([dataSource conformsToProtocol:@protocol(UITableViewDataSource)], equalToBool(YES));
}

- (void)testDataSourceShouldRespondToTableViewNumberOfRowsInSection
{
    assertThatBool([dataSource respondsToSelector:@selector(tableView:numberOfRowsInSection:)], equalToBool(YES));
}

- (void)testdataSourceShouldRespondToTableViewCellForRowAtIndexPath
{
    assertThatBool([dataSource respondsToSelector:@selector(tableView:cellForRowAtIndexPath:)], equalToBool(YES));
}
@end
