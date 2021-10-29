//
//  StringUtils.h
//  thepay
//
//  Created by xeozin on 2020/07/20.
//  Copyright © 2020 DuoLabs. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum{
    CARD_TYPE_NULL      =0,
    CARD_TYPE_VISA_SHORTER,
    CARD_TYPE_MASTERCARD_SHORTER,
    CARD_TYPE_AMERICAN_EXPRESS_SHORTER,
    CARD_TYPE_DISCOVER,
    CARD_TYPE_DISCOVER_SHORT,
    CARD_TYPE_JCB_SHORT,
    CARD_TYPE_DINERS_CLUB_SHORT,
    CARD_TYPE_UNION_PAY_SHORT,
    
    CARD_TYPE_HANA,
    CARD_TYPE_HANA_KEB,
    CARD_TYPE_KEB_HANA,
    CARD_TYPE_KOOKMIN,
    CARD_TYPE_HANA_CCHN,
    CARD_TYPE_KOOKMIN_CCKM,
    CARD_TYPE_BC,
    CARD_TYPE_KEB_HANA_CCKE,
    CARD_TYPE_BC_CCBC
}CARD_TYPE;


@interface CardTypeObject : NSObject
//[NSDictionary dictionaryWithObjectsAndKeys:DISCOVER_SHORT, @"value",@"DISCOVER_SHORT",@"name",@"ic_card_ds.png",@"img_path", nil],
@property (nonatomic, weak) NSString *cardFormat;
@property (nonatomic, weak) NSString *name;
@property (nonatomic, weak) NSString *img_path;
@property CARD_TYPE card_type;
@property NSInteger length;
-(CardTypeObject *)initWithCardData:(NSString *)format name:(NSString *)name cardType:(CARD_TYPE)cardType img_path:(NSString *)img_path;
@end

@interface StringUtils : NSObject
+(NSString *)removeDash:(NSString *)str;
+(NSString *)telFormat:(NSString *)telNum;
//카드 종류 파악
+(CardTypeObject *)cardFormatPattern:(NSString *)str;
//카드 종류 및 카드 길이
+(NSArray *)cardTypeArray;

+(NSInteger)str2int:(NSString *)str;
+(NSString *)int2str:(NSInteger)intValue;
+(NSString *)removeNotNumber:(NSString *)str;
+(BOOL)isEmpty:(NSString *)str;

+(NSString *)subString:(NSString *)str startIdx:(NSInteger)startIdx endIdx:(NSInteger)endIdx;

+(NSString *)removePrefixInterNumber:(NSString *)src;
+ (BOOL) isInternationalNumber:(NSString *)number;
+(NSString *)checkUSAorCanada:(NSString *)number;
+(NSString *)getCanadaPrefix:(NSString *)number;
+(NSString *)checkKzorRusia:(NSString *)number;

@end

NS_ASSUME_NONNULL_END
