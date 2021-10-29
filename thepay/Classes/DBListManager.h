//
//  DataManager.h
//  thePAY
//
//  Created by Telecentro on 2015. 12. 4..
//  Copyright © 2015년 Telecentro. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DBManager.h"
#import "DBManagerQueue.h"
#import "BankDBColumn.h"
#import "CallHistoryDBColumn.h"
#import "CardDBColumn.h"
#import "DataGoodsDBColumn.h"
#import "KtPosGoodsDBColumn.h"
#import "NationDBColumn.h"
#import "VoiceGoodsDBColumn.h"
#import "MonthRateGoodsDBColumn.h"

#import "NationItem.h"
#import "CallHistoryItem.h"
#import "RechargeDBColumn.h"
#import "AutoCompleteItem.h"
#import "AutoCompleteDBColumn.h"

@interface DBListManager : NSObject
{
    DBManagerQueue *_managerQueue;
}

+(BOOL)isTable:(NSString *)tableName;
+(BOOL)deleteTable:(NSString *)tableName;

+(void)createNationTable;
+(NSMutableArray *)getNationList;

+(BOOL)getNationCorrect:(NSString *)nationNumber;
+(NationItem *)getNationInfo:(NSString *)code;
+(NSString *)getNationCode:(NSString *)nationNumber;

+(void)addCallHistory:(CallHistoryItem *)item;
+(NSMutableArray *)getCallHistoryList;

+(void)addRechargeHistory:(CallHistoryItem *)item;
+(NSMutableArray *)getRechargeHistoryList;

+(void)addColumn:(NSString *)column;
+(void)addAutoComplete:(AutoCompleteItem *)item;
+(void)updateAutoCompleteList:(AutoCompleteItem *)item andWhere:(NSDictionary *)where;
+(NSMutableArray *)getAutoCompleteList;
+(NSMutableArray *)getAutoCompleteList:(NSDictionary *)where;

@end
