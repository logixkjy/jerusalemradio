//
//  DBStorage.m
//  jerusalemradio
//
//  Created by james on 04/08/2019.
//  Copyright © 2019 JooYoung Kim. All rights reserved.
//

#import "DBStorage.h"

@implementation DBStorage
static DBStorage* g_DBStorage = nil;

+ (DBStorage*)shared{
    if ( g_DBStorage == nil) {
        @synchronized(self)
        {
            if (g_DBStorage == nil) {
                g_DBStorage = [[self alloc] init];
            }
        }
    }
    
    return g_DBStorage;
}

- (id) init
{
    self = [super init];
    if (self != nil) {
        self.database = nil;
        self.databasePath = @"";
    }
    return self;
}

- (void)initDB
{
    NSString *DirectoryPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSString *databasePath = [DirectoryPath stringByAppendingPathComponent:@"jerusalem.db"];
    
    self.databasePath = databasePath;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:databasePath]) {
        _database = [FMDatabase databaseWithPath:databasePath];
        [_database setLogsErrors:YES];
        [_database setTraceExecution:NO];
        NSLog(@"database created");
    } else {
        NSLog(@"Didnt need to create database");
    }
    
    [self createTable];
}

- (void)createTable
{
    // 재생된 시간
    NSString *sql = @"CREATE TABLE TBL_PLAY_LIST (\
    _id INTEGER PRIMARY KEY AUTOINCREMENT,\
    CT_NO TEXT NOT NULL,\
    PR_PROGRESS INTEGER)";
    
    _database = [FMDatabase databaseWithPath:self.databasePath];
    [_database open];
    
    if(![_database tableExists:@"TBL_PLAY_LIST"]){
        if (![_database executeUpdate:sql]) {
            NSLog(@"Error!!");
        }
    }
    [_database close];
}

#pragma mark --------------------------------------------
#pragma mark SQL Query - INSERT
- (void)insertPlayList:(NSString*)CT_NO
{
    FMDatabaseQueue *queue = [FMDatabaseQueue databaseQueueWithPath:self.databasePath];
    [queue inDatabase:^(FMDatabase *db) {
        NSString *sql = @"INSERT INTO TBL_PLAY_LIST (CT_NO, PR_PROGRESS) VALUES(?,?)";
        [_database executeUpdate:sql, CT_NO, @(0)];
    }];
}

#pragma mark --------------------------------------------
#pragma mark SQL Query - UPDATE
- (void)updatePlayList:(NSString*)CT_NO playTime:(NSInteger)playTime
{
    FMDatabaseQueue *queue = [FMDatabaseQueue databaseQueueWithPath:self.databasePath];
    [queue inDatabase:^(FMDatabase *db) {
        NSString *sql = @"UPDATE TBL_PLAY_LIST set CT_NO=?, PR_PROGRESS=? WHERE CT_NO=?";
        [self.database executeUpdate:sql, CT_NO, @(playTime), CT_NO];
    }];
}

#pragma mark --------------------------------------------
#pragma mark SQL Query - SELECT

- (void)selectPlayList:(NSString*)CT_NO block:(void(^)(NSDictionary *result))block
{
    FMDatabaseQueue *queue = [FMDatabaseQueue databaseQueueWithPath:self.databasePath];
    [queue inDatabase:^(FMDatabase *db) {
        NSString *sql  = @"SELECT _id, PR_ID, PR_PROGRESS FROM TBL_PLAY_LIST\
        WHERE PR_ID = ?";
        FMResultSet *results = [self.database executeQuery:sql, CT_NO];
        NSDictionary *dic = nil;
        while ([results next]) {
            dic = @{@"_ID":@([results intForColumnIndex:0]),
                                  @"ctNo":[results stringForColumnIndex:1],
                                  @"PrProgress":@([results intForColumnIndex:2])};
            
        }
        if (block) {
            block(dic);
        }
    }];
}

@end
