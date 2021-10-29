//
//  StringUtils.m
//  thepay
//
//  Created by xeozin on 2020/07/20.
//  Copyright © 2020 DuoLabs. All rights reserved.
//

#import "StringUtils.h"



@implementation CardTypeObject

-(id)init{
    self = [super init];
    self.cardFormat = @"";
    self.name = @"";
    self.card_type =CARD_TYPE_NULL;
    self.img_path = @"";
    self.length = 0;
    return self;
}
-(CardTypeObject *)initWithCardData:(NSString *)format name:(NSString *)name cardType:(CARD_TYPE)cardType img_path:(NSString *)img_path{
    self = [super init];
    if (self) {
        _cardFormat = format;
        _name = name;
        _card_type = cardType;
        _img_path = img_path;
    }
    return self;
}

@end


@implementation StringUtils

static NSString *VISA_SHORTER                              = @"4[0-9]{12}(?:[0-9]{3})?";                    //비자
static NSString *MASTERCARD_SHORTER                        = @"^5[1-5][0-9]{0,14}$";                        //마스터카드
static NSString *AMERICAN_EXPRESS_SHORTER                  = @"^3[47][0-9]{0,13}";                          //아메리칸 익스프레스
static NSString *DISCOVER                                  = @"^6(?:011|5[0-9]{1,2})[0-9]{0,12}";           //디스커버
static NSString *DISCOVER_SHORT                            = @"^6(011|5|[44-49])[0-9]{0,14}$";              //디스커버
static NSString *JCB_SHORT                                 = @"^(2131|1800|35)[0-9]{0,14}$";                //jcb
static NSString *DINERS_CLUB_SHORT                         = @"^3(0[0-5]|095|[689])[0-9]{0,12}";            //다이너스
static NSString *UNION_PAY_SHORT                           = @"62[0-9]{0,14}";                              //은련카드

static NSString *HANA                                      = @"^(408966)[0-9]{0,9}([0-9])?$";               //하나카드
static NSString *HANA_KEB                                  = @"^(455437)[0-9]{0,9}([0-9])?$";               //KEB하나카드
static NSString *KEB_HANA                                  = @"^(465583)[0-9]{0,9}([0-9])?$";               //하나KEB카드
static NSString *KOOKMIN                                   = @"^(467309)[0-9]{0,9}([0-9])?$";               //국민카드
static NSString *HANA_CCHN                                 = @"^(524242)[0-9]{0,9}([0-9])?$";               //하나카드
static NSString *KOOKMIN_CCKM                              = @"^(527289)[0-9]{0,9}([0-9])?$";               //국민카드
static NSString *BC                                        = @"^(636094)[0-9]{0,9}([0-9])?$";               //BC카드
static NSString *KEB_HANA_CCKE                             = @"^(941051)[0-9]{0,9}([0-9])?$";               //KEB하나카드
static NSString *BC_CCBC                                   = @"^(944003)[0-9]{0,9}([0-9])?$";               //BC카드


+(NSArray *)cardTypeArray{
    NSArray *arr = [NSArray arrayWithObjects:
                    
//                    [[CardTypeObject alloc] initWithCardData:HANA name:@"HANA" cardType:CARD_TYPE_HANA img_path:@"ic_card_keb.png"],
//                    [[CardTypeObject alloc] initWithCardData:HANA_KEB name:@"HANA_KEB" cardType:CARD_TYPE_HANA_KEB img_path:@"ic_card_keb.png"],
//                    [[CardTypeObject alloc] initWithCardData:KEB_HANA name:@"KEB_HANA" cardType:CARD_TYPE_KEB_HANA img_path:@"ic_card_keb.png"],
//                    [[CardTypeObject alloc] initWithCardData:KOOKMIN name:@"KOOKMIN" cardType:CARD_TYPE_KOOKMIN img_path:@"ic_card_kb.png"],
//                    [[CardTypeObject alloc] initWithCardData:HANA_CCHN name:@"HANA_CCHN" cardType:CARD_TYPE_HANA_CCHN img_path:@"ic_card_keb.png"],
//                    [[CardTypeObject alloc] initWithCardData:KOOKMIN_CCKM name:@"KOOKMIN_CCKM" cardType:CARD_TYPE_KOOKMIN_CCKM img_path:@"ic_card_kb.png"],
//                    [[CardTypeObject alloc] initWithCardData:BC name:@"BC" cardType:CARD_TYPE_BC img_path:@"ic_card_bc.png"],
//                    [[CardTypeObject alloc] initWithCardData:KEB_HANA_CCKE name:@"KEB_HANA_CCKE" cardType:CARD_TYPE_KEB_HANA_CCKE img_path:@"ic_card_keb.png"],
//                    [[CardTypeObject alloc] initWithCardData:BC_CCBC name:@"BC_CCBC" cardType:CARD_TYPE_BC_CCBC img_path:@"ic_card_bc.png"],

                    [[CardTypeObject alloc] initWithCardData:VISA_SHORTER name:@"VISA_SHORTER" cardType:CARD_TYPE_VISA_SHORTER img_path:@"ic_card_vi.png"],
                    [[CardTypeObject alloc] initWithCardData:MASTERCARD_SHORTER name:@"MASTERCARD_SHORTER" cardType:CARD_TYPE_MASTERCARD_SHORTER img_path:@"ic_card_mc.png"],
                    [[CardTypeObject alloc] initWithCardData:AMERICAN_EXPRESS_SHORTER name:@"AMERICAN_EXPRESS_SHORTER" cardType:CARD_TYPE_AMERICAN_EXPRESS_SHORTER img_path:@"ic_card_am.png"],
                    [[CardTypeObject alloc] initWithCardData:DISCOVER name:@"DISCOVER" cardType:CARD_TYPE_DISCOVER img_path:@"ic_card_ds.png"],
                    [[CardTypeObject alloc] initWithCardData:DISCOVER_SHORT name:@"DISCOVER_SHORT" cardType:CARD_TYPE_DISCOVER_SHORT img_path:@"ic_card_ds.png"],
                    [[CardTypeObject alloc] initWithCardData:JCB_SHORT name:@"JCB_SHORT" cardType:CARD_TYPE_JCB_SHORT img_path:@"ic_card_jcb.png"],
                    [[CardTypeObject alloc] initWithCardData:DINERS_CLUB_SHORT name:@"DINERS_CLUB_SHORT" cardType:CARD_TYPE_DINERS_CLUB_SHORT img_path:@"ic_card_dc.png"],
                    [[CardTypeObject alloc] initWithCardData:UNION_PAY_SHORT name:@"UNION_PAY_SHORT" cardType:CARD_TYPE_UNION_PAY_SHORT img_path:@"ic_card_un.png"],
                    
                    nil];
    
    return arr;
}

+(CardTypeObject *)cardFormatPattern:(NSString *)str{
    
    NSString *cardNum =[self removeDash:str];

    NSArray *arr = [self cardTypeArray];

    for (CardTypeObject *data in arr) {
        NSRange range = [cardNum rangeOfString:data.cardFormat options:NSRegularExpressionSearch];
        if (range.length && range.location == 0) {

            data.length = range.length;
            return data;
        }
    }
    return nil;
}

+(NSInteger)str2int:(NSString *)str{
    return [str intValue];
}
+(NSString *)int2str:(NSInteger)intValue{
    
    return [NSString stringWithFormat:@"%ld",(long)intValue];
}

+(NSString *)removeDash:(NSString *)str{
    if (str == nil || [str length] == 0) {
        return str;
    }
    return [str stringByReplacingOccurrencesOfString:@"-" withString:@""];
}

+(NSString *)subString:(NSString *)str startIdx:(NSInteger)startIdx endIdx:(NSInteger)endIdx{
    
    if (startIdx + endIdx > [str length]) {
        return @"";
    }
    NSRange range = {startIdx, endIdx};
    NSString *strTmp = [str substringWithRange:range];
    
    return strTmp;
}

+(NSString *)removeNotNumber:(NSString *)str{
    if (str == nil || [str length] == 0) {
        return str;
    }
    return [[str componentsSeparatedByCharactersInSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]]componentsJoinedByString:@""];
}

+(BOOL)isEmpty:(NSString *)str{
    if (str == nil) {
        return YES;
    }
    if ([str isEqualToString:@""]) {
        return YES;
    }
    return NO;
}

+(NSString *)telFormat:(NSString *)telNum{
    if (telNum == nil) {
        return @"";
    }
    
    if ([telNum length] <1) {
        return @"";
    }
    NSString *str =[self removeDash:telNum];
    
    NSString *first =@"";
    NSString *mid = @"";
    NSString *last = @"";
    
    if ([str length] ==4) {
        first = [str substringWithRange:NSMakeRange(0, 3)];
        mid = [str substringWithRange:NSMakeRange(3, 1)];
        return [NSString stringWithFormat:@"%@-%@",first,mid];
    }
    else if ([str length] ==5) {
        first = [str substringWithRange:NSMakeRange(0, 3)];
        mid = [str substringWithRange:NSMakeRange(3, 2)];
        return [NSString stringWithFormat:@"%@-%@",first,mid];
    }
    else if ([str length] ==6) {
        first = [str substringWithRange:NSMakeRange(0, 3)];
        mid = [str substringWithRange:NSMakeRange(3, 3)];
        return [NSString stringWithFormat:@"%@-%@",first,mid];
    }
    else if ([str length] ==7) {
        first = [str substringWithRange:NSMakeRange(0, 3)];
        mid = [str substringWithRange:NSMakeRange(3, 3)];
        last = [str substringWithRange:NSMakeRange(6, 1)];
        return [NSString stringWithFormat:@"%@-%@-%@",first,mid,last];
    }
    else if ([str length] ==8) {
        first = [str substringWithRange:NSMakeRange(0, 3)];
        mid = [str substringWithRange:NSMakeRange(3, 3)];
        last = [str substringWithRange:NSMakeRange(6, 2)];
        return [NSString stringWithFormat:@"%@-%@-%@",first,mid,last];
    }
    else if ([str length] ==9) {
        first = [str substringWithRange:NSMakeRange(0, 3)];
        mid = [str substringWithRange:NSMakeRange(3, 3)];
        last = [str substringWithRange:NSMakeRange(6, 3)];
        return [NSString stringWithFormat:@"%@-%@-%@",first,mid,last];
    }
    else if([str length] ==10)
    {
        first = [str substringWithRange:NSMakeRange(0, 3)];
        mid = [str substringWithRange:NSMakeRange(3, 3)];
        last = [str substringWithRange:NSMakeRange(6, 4)];
        return [NSString stringWithFormat:@"%@-%@-%@",first,mid,last];
    }
    else if ([str length] == 11) {
        first = [str substringWithRange:NSMakeRange(0, 3)];
        mid = [str substringWithRange:NSMakeRange(3, 4)];
        last = [str substringWithRange:NSMakeRange(7, 4)];
        return [NSString stringWithFormat:@"%@-%@-%@",first,mid,last];
    }
    else if([str length] == 12)
    {
        first = [str substringWithRange:NSMakeRange(0, 4)];
        mid = [str substringWithRange:NSMakeRange(4, 4)];
        last = [str substringWithRange:NSMakeRange(8, 4)];
        return [NSString stringWithFormat:@"%@-%@-%@",first,mid,last];
    }
    
    return str;
}



+(NSString *)removePrefixInterNumber:(NSString *)src
{
    if (src == nil || [src length] <= 0)
    {
        return @"";
    }
    if ([src hasPrefix:@"00"]) {
        if ([src hasPrefix:@"003"] && [src length] >=5) {
            return [src substringFromIndex:5];
        }
        else if([src hasPrefix:@"007"] && [src length] >=5)
        {
            return [src substringFromIndex:5];
        }
        else if([src length]>=3)
        {
            return [src substringFromIndex:3];
        }
    }
    else if([src hasPrefix:@"+"])
    {
        return [src substringFromIndex:1];
    }
    
    return src;
}

+ (BOOL) isInternationalNumber:(NSString *)number
{
    if (number == nil || [number length] < 10) return NO;
    
    if ([number hasPrefix:@"00"])
    {
        if ([number hasPrefix:@"003"] && [number length] >=5)
        {
            return YES;
        }
        else if([number hasPrefix:@"007"] && [number length] >=5)
        {
            return YES;
        }
        else if([number length] >= 3)
        {
            return YES;
        }
    }
    else if([number hasPrefix:@"+"])
    {
        if (![number hasPrefix:@"+82"]) return YES;
    }
    
    return NO;
}

+(NSString *)checkUSAorCanada:(NSString *)number {
    
    NSArray *canadaList =@[@"1204",@"1226",@"1236",@"1249",@"1250",@"1289",@"1306",@"1343",@"1365",@"1403",@"1416",@"1418",@"1431",@"1437",@"1438",@"1450",@"1506",@"1514",@"1519",@"1548",@"1579",@"1581",@"1587",@"1600",@"1604",@"1613",@"1639",@"1647",@"1705",@"1709",@"1778",@"1780",@"1782",@"1807",@"1819",@"1825",@"1867",@"1873",@"1902",@"1905"];
    
    
    for (NSString *phoneCode in canadaList) {
        if([number hasPrefix:phoneCode]){
            return @"ca";
        }
    }
    return @"us";
}

+(NSString *)getCanadaPrefix:(NSString *)number {
    
    NSArray *canadaList =@[@"1204",@"1226",@"1236",@"1249",@"1250",@"1289",@"1306",@"1343",@"1365",@"1403",@"1416",@"1418",@"1431",@"1437",@"1438",@"1450",@"1506",@"1514",@"1519",@"1548",@"1579",@"1581",@"1587",@"1600",@"1604",@"1613",@"1639",@"1647",@"1705",@"1709",@"1778",@"1780",@"1782",@"1807",@"1819",@"1825",@"1867",@"1873",@"1902",@"1905"];
    
    
    for (NSString *phoneCode in canadaList) {
        if([number hasPrefix:phoneCode]){
            return phoneCode;
        }
    }
    return @"1";
}

+(NSString *)checkKzorRusia:(NSString *)number {
    
    if([number hasPrefix:@"77"]){
        return @"kz";
    }
    return @"ru";
}


@end
