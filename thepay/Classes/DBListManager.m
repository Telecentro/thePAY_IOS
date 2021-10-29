//
//  DataManager.m
//  thePAY
//
//  Created by Telecentro on 2015. 12. 4..
//  Copyright © 2015년 Telecentro. All rights reserved.
//

#import "DBManagerQueue.h"
#import "DBListManager.h"
#import "StringUtils.h"

//#import <APAddressBook/APAddressBook.h>
//#import <APAddressBook/APContact.h>

static NSString *DB_NAME = @"db_data.sqlite";

DBManagerQueue *_managerQueue;
@implementation DBListManager

+(BOOL)isTable:(NSString *)tableName
{
    DBManager *manager = [DBManager managerWithDocumentName:DB_NAME];
    BOOL returnValue = [manager isExistTable:tableName];
    
    if (manager !=nil) {
        [manager close];
        manager = nil;
    }
    
    return returnValue;
}
+(BOOL)deleteTable:(NSString *)tableName{
    DBManager *manager = [DBManager managerWithDocumentName:DB_NAME];
    BOOL returnValue = [manager dropTable:tableName];
    
    if (manager !=nil) {
        [manager close];
        manager = nil;
    }
    
    return returnValue;
}

/**
 * 국가리스트 DB생성 (최초 1회 생성)
 */
+(void)createNationTable{
    
    DBManager *manager= [DBManager managerWithDocumentName:DB_NAME];
    
    [manager createTable:[NationDBColumn TABLE_NAME] fields:@[
        [NationDBColumn COUNTRY_CODE],
        [NationDBColumn NAME_KR],
        [NationDBColumn NAME_US],
        [NationDBColumn NAME_CN],
        [NationDBColumn COUNTRY_NUMBER],
        [NationDBColumn GMT]]];
    
    
    NSString *csvString = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"country_list" ofType:@"csv"]
                                                    encoding:NSUTF8StringEncoding error:nil];
    NSArray *csvArray = [csvString componentsSeparatedByString:@"\n"];
    for (int i = 0; i < csvArray.count; i ++) {
        NSString *lineString = [csvArray objectAtIndex:i];
        
        if (lineString.length > 0){
            NSArray *itemArray = [lineString componentsSeparatedByString:@","];
            
            NSDictionary *lineDic = [NSDictionary dictionaryWithObjectsAndKeys:
                                     (NSString *)[itemArray objectAtIndex:0],[NationDBColumn COUNTRY_CODE],
                                     (NSString *)[itemArray objectAtIndex:1],[NationDBColumn NAME_KR],
                                     (NSString *)[itemArray objectAtIndex:2],[NationDBColumn NAME_US],
                                     (NSString *)[itemArray objectAtIndex:3],[NationDBColumn NAME_CN],
                                     (NSString *)[itemArray objectAtIndex:4],[NationDBColumn COUNTRY_NUMBER],
                                     (NSString *)[itemArray objectAtIndex:5],[NationDBColumn GMT],
                                     nil];
            
            
            [manager insert:[NationDBColumn TABLE_NAME] data:lineDic replace:YES];
        }
    }
    if (manager !=nil) {
        [manager close];
        manager = nil;
    }
}

+(NSMutableArray *)getNationList{
    NSMutableArray *retList = [[NSMutableArray alloc] init];
    DBManager *db = [DBManager managerWithDocumentName:DB_NAME];
    
    NSArray *arrList = [db select:[NationDBColumn TABLE_NAME] where:nil limit:nil];
    
    NationItem *item ;
    for (NSDictionary *dic in arrList) {
        item = [[NationItem alloc] init];
        [item setCountryCode:[dic valueForKey:[NationDBColumn COUNTRY_CODE]]];
        [item setNameKr:[dic valueForKey:[NationDBColumn NAME_KR]]];
        [item setNameUs:[dic valueForKey:[NationDBColumn NAME_US]]];
        [item setNameCn:[dic valueForKey:[NationDBColumn NAME_CN]]];
        [item setCountryNumber:[dic valueForKey:[NationDBColumn COUNTRY_NUMBER]]];
        [item setGmt:[dic valueForKey:[NationDBColumn GMT]]];
        
        [retList addObject:item];
    }
    
    if (db !=nil) {
        [db close];
        db = nil;
    }
    
    return retList;
}

/**
 * Alpha2Code로 국가 정보를 가져온다.
 */
+(NationItem *)getNationInfo:(NSString *)code{
    
    DBManager *db = [DBManager managerWithDocumentName:DB_NAME];
    NSArray *arrList = [db select:[NationDBColumn TABLE_NAME] where:nil limit:nil];
    
    NationItem *item = [[NationItem alloc] init];
    
    for (NSDictionary *dic in arrList) {
        
        if ([[dic valueForKey:[NationDBColumn COUNTRY_CODE]] isEqualToString:code]) {
            
            id key;
            for (key in dic) {
                if ([key isEqualToString:[NationDBColumn COUNTRY_CODE]]) {
                    [item setCountryCode:[dic valueForKey:key]];
                }
                else if ([key isEqualToString:[NationDBColumn COUNTRY_NUMBER]]) {
                    [item setCountryNumber:[dic valueForKey:key]];
                }
                else if ([key isEqualToString:[NationDBColumn NAME_KR]]) {
                    [item setNameKr:[dic valueForKey:key]];
                }
                else if ([key isEqualToString:[NationDBColumn NAME_US]]) {
                    [item setNameUs:[dic valueForKey:key]];
                }
                else if ([key isEqualToString:[NationDBColumn NAME_CN]]) {
                    [item setNameCn:[dic valueForKey:key]];
                }
                else if ([key isEqualToString:[NationDBColumn GMT]]) {
                    [item setGmt:[dic valueForKey:key]];
                }
            }
        }
    }
    if (db !=nil) {
        [db close];
        db = nil;
    }
    return item;
}
/**
 * 국가번호로 Alpha2Code 조회
 */
+(NSString *)getNationCode:(NSString *)nationNumber{
    NSString *returnValue =@"";
    DBManager *db = [DBManager managerWithDocumentName:DB_NAME];
    NSArray *arrList = [db select:[NationDBColumn TABLE_NAME] where:nil limit:nil];
    
    
    for (NSDictionary *dic in arrList) {
        
        if ([[dic valueForKey:[NationDBColumn COUNTRY_NUMBER]] isEqualToString:nationNumber]) {
            returnValue = [dic valueForKey:[NationDBColumn COUNTRY_CODE]];
            break;
        }
    }
    if (db !=nil) {
        [db close];
        db = nil;
    }
    return returnValue;
}
+(BOOL)getNationCorrect:(NSString *)nationNumber{
    BOOL retValue = NO;
    
    DBManager *db = [DBManager managerWithDocumentName:DB_NAME];
    NSArray *arrList = [db select:[NationDBColumn TABLE_NAME] where:nil limit:nil];
    
    for (NSDictionary* dic in arrList) {
        if ([[dic valueForKey:[NationDBColumn COUNTRY_NUMBER]] isEqualToString:nationNumber]) {
            retValue = YES;
        }
    }
    if (db !=nil) {
        [db close];
        db = nil;
    }
    return retValue;
}

/**
 * Call History 리스트
 */

+(void)addCallHistory:(CallHistoryItem *)item{
    DBManager *db = [DBManager managerWithDocumentName:DB_NAME];
    
    if(![self isTable:[CallHistoryDBColumn TABLE_NAME]]){
        [db createTable:[CallHistoryDBColumn TABLE_NAME] fields:@[[CallHistoryDBColumn DATE],
                                                                  [CallHistoryDBColumn COUNTRY_CODE],
                                                                  [CallHistoryDBColumn COUNTRY_NUMBER],
                                                                  [CallHistoryDBColumn INTER_NUMBER],
                                                                  [CallHistoryDBColumn CALL_NUMBER],
                                                                  [CallHistoryDBColumn NAME]]];
    }
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
                         [item date], [CallHistoryDBColumn DATE],
                         [item countryCode],[CallHistoryDBColumn COUNTRY_CODE],
                         [item countryNumber],[CallHistoryDBColumn COUNTRY_NUMBER],
                         [item interNumber], [CallHistoryDBColumn INTER_NUMBER],
                         [item callNumber], [CallHistoryDBColumn CALL_NUMBER],
                         [item name], [CallHistoryDBColumn NAME],
                         nil];
    
    [db insert:[CallHistoryDBColumn TABLE_NAME] data:dic replace:NO];
    if (db !=nil) {
        [db close];
        db = nil;
    }
}
+(NSMutableArray *)getCallHistoryList{
    
    NSMutableArray *arrData = [[NSMutableArray alloc] init];
    DBManager *db = [DBManager managerWithDocumentName:DB_NAME];
    
    NSArray *arrList = [db select:[CallHistoryDBColumn TABLE_NAME] where:nil limit:nil];
    
    CallHistoryItem *item ;
    for (NSDictionary *dic in arrList) {
        item = [[CallHistoryItem alloc] init];
        
        [item setDate:[dic valueForKey:[CallHistoryDBColumn DATE]]];
        [item setCountryCode:[dic valueForKey:[CallHistoryDBColumn COUNTRY_CODE]]];
        [item setCountryNumber:[dic valueForKey:[CallHistoryDBColumn COUNTRY_NUMBER]]];
        [item setInterNumber:[dic valueForKey:[CallHistoryDBColumn INTER_NUMBER]]];
        [item setCallNumber:[dic valueForKey:[CallHistoryDBColumn CALL_NUMBER]]];
        [item setName:[dic valueForKey:[CallHistoryDBColumn NAME]]];
        [arrData addObject:item];
    }
    if (db !=nil) {
        [db close];
        db = nil;
    }
    return arrData;
}

+(void)addColumn:(NSString *)column {
    DBManager *db = [DBManager managerWithDocumentName:DB_NAME];
    
    if([self isTable:[AutoCompleteDBColumn TABLE_NAME]]){
        [db alterAutoTable:[AutoCompleteDBColumn TABLE_NAME] newColumn:column type:@"TEXT"];
    }
}

+(void)addAutoComplete:(AutoCompleteItem *)item {
    DBManager *db = [DBManager managerWithDocumentName:DB_NAME];
    
    if(![self isTable:[AutoCompleteDBColumn TABLE_NAME]]){
        [db createAutoTable:[AutoCompleteDBColumn TABLE_NAME] fields:@[
            [AutoCompleteDBColumn ID],
            [AutoCompleteDBColumn TEXT],
            [AutoCompleteDBColumn COUNTRY_CODE],
            [AutoCompleteDBColumn COUNTRY_NUMBER],
            [AutoCompleteDBColumn TYPE],
            [AutoCompleteDBColumn CATE],
            [AutoCompleteDBColumn DATE],
            [AutoCompleteDBColumn NAME],
            [AutoCompleteDBColumn INTER_NUMBER],
            [AutoCompleteDBColumn SAVE_TYPE]
        ]];
    }
    
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
                         [item date], [AutoCompleteDBColumn DATE],
                         [item code],[AutoCompleteDBColumn COUNTRY_CODE],
                         [item mvno],[AutoCompleteDBColumn COUNTRY_NUMBER],
                         [item type], [AutoCompleteDBColumn TYPE],
                         [item cate], [AutoCompleteDBColumn CATE],
                         [item text], [AutoCompleteDBColumn TEXT],
                         [item name], [AutoCompleteDBColumn NAME],
                         [item inter], [AutoCompleteDBColumn INTER_NUMBER],
                         [item save], [AutoCompleteDBColumn SAVE_TYPE],
                         nil];
    
    [db insert:[AutoCompleteDBColumn TABLE_NAME] data:dic replace:NO];
    if (db !=nil) {
        [db close];
        db = nil;
    }
}

+(void)updateAutoCompleteList:(AutoCompleteItem *)item andWhere:(NSDictionary *)where {
    DBManager *db = [DBManager managerWithDocumentName:DB_NAME];
    
    if(![self isTable:[AutoCompleteDBColumn TABLE_NAME]]){
        [db createAutoTable:[AutoCompleteDBColumn TABLE_NAME] fields:@[
            [AutoCompleteDBColumn ID],
            [AutoCompleteDBColumn TEXT],
            [AutoCompleteDBColumn COUNTRY_CODE],
            [AutoCompleteDBColumn COUNTRY_NUMBER],
            [AutoCompleteDBColumn TYPE],
            [AutoCompleteDBColumn CATE],
            [AutoCompleteDBColumn DATE],
            [AutoCompleteDBColumn NAME],
            [AutoCompleteDBColumn INTER_NUMBER],
            [AutoCompleteDBColumn SAVE_TYPE]
        ]];
    }
    
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
                         [item date], [AutoCompleteDBColumn DATE],
                         [item code],[AutoCompleteDBColumn COUNTRY_CODE],
                         [item mvno],[AutoCompleteDBColumn COUNTRY_NUMBER],
                         [item type], [AutoCompleteDBColumn TYPE],
                         [item cate], [AutoCompleteDBColumn CATE],
                         [item text], [AutoCompleteDBColumn TEXT],
                         [item name], [AutoCompleteDBColumn NAME],
                         [item inter], [AutoCompleteDBColumn INTER_NUMBER],
                         [item save], [AutoCompleteDBColumn SAVE_TYPE],
                         nil];
    
    [db update:[AutoCompleteDBColumn TABLE_NAME] data:dic where:where];
    if (db !=nil) {
        [db close];
        db = nil;
    }
}

+(NSMutableArray *)getAutoCompleteList {
    NSMutableArray *arrData = [[NSMutableArray alloc] init];
    DBManager *db = [DBManager managerWithDocumentName:DB_NAME];
    
    NSArray *arrList = [db select:[AutoCompleteDBColumn TABLE_NAME] where:nil limit:nil];
    
    AutoCompleteItem *item ;
    for (NSDictionary *dic in arrList) {
        item = [[AutoCompleteItem alloc] init];
        [item setDate:[dic valueForKey:[AutoCompleteDBColumn DATE]]];
        [item setCode:[dic valueForKey:[AutoCompleteDBColumn COUNTRY_CODE]]];
        [item setMvno:[dic valueForKey:[AutoCompleteDBColumn COUNTRY_NUMBER]]];
        [item setType:[dic valueForKey:[AutoCompleteDBColumn TYPE]]];
        [item setText:[dic valueForKey:[AutoCompleteDBColumn TEXT]]];
        [item setName:[dic valueForKey:[AutoCompleteDBColumn NAME]]];
        [item setCate:[dic valueForKey:[AutoCompleteDBColumn CATE]]];
        [item setInter:[dic valueForKey:[AutoCompleteDBColumn INTER_NUMBER]]];
        [item setSave:[dic valueForKey:[AutoCompleteDBColumn SAVE_TYPE]]];
        [arrData addObject:item];
    }
    if (db !=nil) {
        [db close];
        db = nil;
    }
    return arrData;
}

+(NSMutableArray *)getAutoCompleteList:(NSDictionary *)where {
    NSMutableArray *arrData = [[NSMutableArray alloc] init];
    DBManager *db = [DBManager managerWithDocumentName:DB_NAME];
    
    NSArray *arrList = [db select:[AutoCompleteDBColumn TABLE_NAME] where:where limit:nil];
    
    AutoCompleteItem *item;
    for (NSDictionary *dic in arrList) {
        item = [[AutoCompleteItem alloc] init];
        [item setDate:[dic valueForKey:[AutoCompleteDBColumn DATE]]];
        [item setDate:[dic valueForKey:[AutoCompleteDBColumn DATE]]];
        [item setCode:[dic valueForKey:[AutoCompleteDBColumn COUNTRY_CODE]]];
        [item setMvno:[dic valueForKey:[AutoCompleteDBColumn COUNTRY_NUMBER]]];
        [item setType:[dic valueForKey:[AutoCompleteDBColumn TYPE]]];
        [item setText:[dic valueForKey:[AutoCompleteDBColumn TEXT]]];
        [item setName:[dic valueForKey:[AutoCompleteDBColumn NAME]]];
        [item setCate:[dic valueForKey:[AutoCompleteDBColumn CATE]]];
        [item setInter:[dic valueForKey:[AutoCompleteDBColumn INTER_NUMBER]]];
        [item setSave:[dic valueForKey:[AutoCompleteDBColumn SAVE_TYPE]]];
        [arrData addObject:item];
    }
    if (db !=nil) {
        [db close];
        db = nil;
    }
    return arrData;
}



/**
 * 충전 번호 리스트
 */

+(void)addRechargeHistory:(CallHistoryItem *)item{
    DBManager *db = [DBManager managerWithDocumentName:DB_NAME];
    
    if(![self isTable:[RechargeDBColumn TABLE_NAME]]){
        [db createTable:[RechargeDBColumn TABLE_NAME] fields:@[[RechargeDBColumn DATE],
                                                               [RechargeDBColumn COUNTRY_CODE],
                                                               [RechargeDBColumn COUNTRY_NUMBER],
                                                               [RechargeDBColumn CALL_NUMBER]]];
    }
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
                         [item date], [CallHistoryDBColumn DATE],
                         [item countryCode],[RechargeDBColumn COUNTRY_CODE],
                         [item countryNumber],[CallHistoryDBColumn COUNTRY_NUMBER],
                         [item callNumber], [RechargeDBColumn CALL_NUMBER],
                         nil];
    
    if ([db insert:[RechargeDBColumn TABLE_NAME] data:dic replace:NO]){
        [db close];
    }
    else{
        [db close];
    }
    
}
+(NSMutableArray *)getRechargeHistoryList{
    
    NSMutableArray *arrData = [[NSMutableArray alloc] init];
    DBManager *db = [DBManager managerWithDocumentName:DB_NAME];
    
    NSArray *arrList = [db select:[RechargeDBColumn TABLE_NAME] where:nil limit:nil];
    
    CallHistoryItem *item ;
    for (NSDictionary *dic in arrList) {
        item = [[CallHistoryItem alloc] init];
        
        [item setCountryCode:[dic valueForKey:[RechargeDBColumn COUNTRY_CODE]]];
        [item setCountryNumber:[dic valueForKey:[RechargeDBColumn COUNTRY_NUMBER]]];
        [item setCallNumber:[dic valueForKey:[RechargeDBColumn CALL_NUMBER]]];
        [item setDate:[dic valueForKey:[RechargeDBColumn DATE]]];
        [arrData addObject:item];
    }
    if (db !=nil) {
        [db close];
        db = nil;
    }
    return arrData;
}

@end

