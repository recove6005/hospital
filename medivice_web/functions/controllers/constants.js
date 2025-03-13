export const FORCEP = {
    "FORCEP_STOMATCH_18": 10010,
    "FORCEP_STOMATCH_23": 10020,
    "FORCEP_COLON_18": 10030,
    "FORCEP_COLON_23": 10040
}

export const SNARE = {
    "SNARE_5M": 10100,
    "SNARE_7M": 10200,
    "SNARE_10M": 10300,
    "SNARE_15M": 10400
}

export const INJECTOR = {
    "INJECTOR_23G": 11000,
    "INJECTOR_25G": 12000
}

export const MOUTHPIECE = 12500; // 마우스피스
export const NASAL = 13000; // 나잘케뉼라
export const BRUSH = 14000; // 내시경 세척 브러시
export const CLEANING = 15000; // 내시경 세척액
export const PAD = 16000; // 내시경 패드
export const SPONGE = 17000; // 내시경 세척스펀지
export const GOWN_TOP = 18001; // 일회용 검진복 상의
export const GOWN_SET = 18000; // 1회용 검진복 상하의 세트
export const GOWN_PANTS = 19000; // 1회용 대장 바지
export const GOWN_SKIRT = 20000;  // 1회용 검진 치마
export const GOWN_INNER = 21000; // 1회용 내시경 가운
export const GOWN_BREAST = 22000;  // 유방검사용 가운
export const BED_COVER = 23000;  // 베드 커버
export const PILLOW_COVER = 24000; // 베개 커버
export const PILLOW_COVER_BAG = 25000; // 베개 커버 파우치형
export const HOSPITAL_GOWN = 26000; // 1회용 입원복


export function getProdName(prodName) {
    if(prodName === 'mouthpiece') {
        return MOUTHPIECE;
    } else if(prodName === 'nasal') {
        return NASAL;
    } else if(prodName === 'brush') {
        return BRUSH;
    } else if(prodName === 'cleaning') {
        return CLEANING;
    } else if(prodName === 'pad') {
        return PAD;
    } else if(prodName === 'sponge') {
        return SPONGE;
    } else if(prodName === 'gown-top') {
        return GOWN_TOP;
    } else if(prodName === 'gown-set') {
        return GOWN_SET;
    } else if(prodName === 'gown-pants') {
        return GOWN_PANTS;
    } else if(prodName === 'gown-skirt') {
        return GOWN_SKIRT;
    } else if(prodName === 'gown-inner') {
        return GOWN_INNER;
    } else if(prodName === 'gown-breast') {
        return GOWN_BREAST;
    } else if(prodName === 'bed-cover') {
        return BED_COVER;
    } else if(prodName === 'pillow-cover') {
        return PILLOW_COVER;
    } else if(prodName === 'pillow-cover-bag') {
        return PILLOW_COVER_BAG;
    } else if(prodName === 'hospital-gown') {
        return HOSPITAL_GOWN;
    }       
}

export function prodNameExchange(prodName) {
    if(prodName === 'forcep') return '포셉';
    if(prodName === 'snare') return '스네어';
    if(prodName === 'injector') return '인젝터';
    if(prodName === 'set') return '포스니 세트';
    if(prodName === 'mouthpiece') return '마우스피스';
    if(prodName === 'nasal') return '나잘케뉼라';
    if(prodName === 'brush') return '내시경 세척 브러시';
    if(prodName === 'cleaning') return '내시경 세척액';
    if(prodName === 'pad') return '내시경 패드';
    if(prodName === 'sponge') return '내시경 세척스펀지';
    if(prodName === 'gown-top') return '일회용 검진복 상의';
    if(prodName === 'gown-set') return '일회용 검진복 상하의 세트';
    if(prodName === 'gown-pants') return '일회용 대장 바지';
    if(prodName === 'gown-skirt') return '일회용 검진 치마';
    if(prodName === 'gown-inner') return '일회용 내시경 가운';
    if(prodName === 'gown-breast') return '유방검사용 가운';
    if(prodName === 'bed-cover') return '베드 커버';
    if(prodName === 'pillow-cover') return '베개 커버';
    if(prodName === 'pillow-cover-bag') return '베개 커버 파우치형';
    if(prodName === 'hospital-gown') return '일회용 입원복';
}