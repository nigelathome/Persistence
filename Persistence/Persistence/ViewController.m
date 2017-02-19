//
//  ViewController.m
//  Persistence
//
//  Created by Nigel Lee on 01/01/2017.
//  Copyright © 2017 Apress. All rights reserved.
//

#import "ViewController.h"
#import <sqlite3.h>

@interface ViewController ()
@property (strong, nonatomic) IBOutletCollection(UITextField) NSArray *lineFields;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    sqlite3 *database;
    if (sqlite3_open([[self dataFildPath] UTF8String], &database) != SQLITE_OK) {
        sqlite3_close(database);
        NSAssert(0, @"Failed to open database");
    }
    
    NSString *createSQL = @"CREATE TABLE IF NOT EXISTS FIELDS" "(ROW INTEGER PRIMARY KEY, FIELD_DATA TEXT);";
    
    char *errorMsg = NULL;
    if (sqlite3_exec(database, [createSQL UTF8String], NULL, NULL, &errorMsg) != SQLITE_OK) {
        sqlite3_close(database);
        NSAssert(0, @"Error creating table: %s", errorMsg);
    }
    
    NSString *query = @"SELECT ROW, FIELD_DATA FROM FIELDS ORDER BY ROW";
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, nil) == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            int row = sqlite3_column_int(statement, 0);
            char *rowData = (char*)sqlite3_column_text(statement, 1);
            NSString *fieldValue = [[NSString alloc] initWithUTF8String:rowData];
            UITextField *field = self.lineFields[row];
            field.text = fieldValue;
        }
        sqlite3_finalize(statement);
    }
    sqlite3_close(database);
    
    UIApplication *app = [UIApplication sharedApplication];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                              selector:@selector(applicationWillResignActive:)
                                                  name:UIApplicationWillResignActiveNotification
                                                object:app];
}

     
- (void)applicationWillResignActive:(NSNotification *)notification {
    sqlite3 *database;
    if (sqlite3_open([[self dataFildPath] UTF8String], &database) != SQLITE_OK) {
        sqlite3_close(database);
        NSAssert(0, @"Failed to open database");
    }
    
    for (int i=0; i<4; ++i) {
        UITextField *field = self.lineFields[i];
        char *update = "INSERT OR REPLACE FIELDS (ROW FIELD_DATA TEXT)" "VALUES(?, ?);";
        char *errorMsg = NULL;
        sqlite3_stmt *stmt;
        
        if (sqlite3_prepare_v2(database, update, -1, &stmt, nil) == SQLITE_OK) {
            sqlite3_bind_int(stmt, 1, i);
            sqlite3_bind_text(stmt, 2, [field.text UTF8String], -1, NULL);
        }
        
        if (sqlite3_step(stmt) == SQLITE_DONE) {
            NSAssert(0, @"Error updating table: %s", errorMsg);
        }
        sqlite3_close(database);
        
        
    }
}

//- (void)didReceiveMemoryWarning {
//    [super didReceiveMemoryWarning];
//    // Dispose of any resources that can be recreated.
//}

#pragma mark define the path of sqlite file
- (NSString *)dataFildPath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    return [documentsDirectory stringByAppendingString:@"data.sqlite"];
    
}


@end
