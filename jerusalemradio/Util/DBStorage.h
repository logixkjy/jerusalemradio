//
//  DBStorage.h
//  jerusalemradio
//
//  Created by james on 04/08/2019.
//  Copyright © 2019 JooYoung Kim. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <fmdb/FMDB.h>

@interface DBStorage : NSObject

@property (nonatomic, strong) FMDatabase *database;
@property (nonatomic, strong) NSString *databasePath;

+ (DBStorage*)shared;
- (void)initDB;
- (void)createTable;
- (void)insertPlayList:(NSString*)CT_NO;
- (void)updatePlayList:(NSString*)CT_NO playTime:(NSInteger)playTime;
- (void)selectPlayList:(NSString*)CT_NO block:(void(^)(NSDictionary *result))block;

@end
