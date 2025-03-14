export const FORCEP = {
    "FORCEP_STOMATCH_18": 7000,
    "FORCEP_STOMATCH_23": 7000,
    "FORCEP_COLON_18": 7000,
    "FORCEP_COLON_23": 7000
}

export const SNARE = {
    "SNARE_5M": 22000,
    "SNARE_7M": 22000,
    "SNARE_10M": 22000,
    "SNARE_15M": 22000
}

export const INJECTOR = {
    "INJECTOR_23G": 43860,
    "INJECTOR_25G": 43860
}

export const SET = 55000;
export const MOUTHPIECE = 43500; // 마우스피스 50ea
export const NASAL = 189000; // 나잘케뉼라 200ea
export const BRUSH = 1600; // 내시경 세척 브러시
export const CLEANING = 15000; // 내시경 세척액
export const PAD = 0; // 내시경 패드
export const SPONGE = 4900; // 내시경 세척스펀지
export const GOWN_TOP = 200000; // 일회용 검진복 상의 100ea
export const GOWN_SET = 150000; // 1회용 검진복 상하의 세트 50ea
export const GOWN_PANTS = 240000; // 1회용 대장 바지 100ea
export const GOWN_SKIRT = 200000;  // 1회용 검진 치마 100ea
export const GOWN_INNER = 125000; // 1회용 내시경 가운 50ea
export const GOWN_BREAST = 200000;  // 유방검사용 가운 100ea
export const BED_COVER = 20000;  // 베드 커버 10ea
export const PILLOW_COVER = 3000; // 베개 커버 10ea
export const PILLOW_COVER_BAG = 6500; // 베개 커버 파우치형 10ea
export const HOSPITAL_GOWN = 150000; // 1회용 입원복 50ea


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
    if(prodName === 'brush') return '내시경 세척 브러시'; //
    if(prodName === 'cleaning') return '내시경 세척액';
    if(prodName === 'pad') return '내시경 패드'; //
    if(prodName === 'sponge') return '내시경 세척스펀지';
    if(prodName === 'gown-top') return '일회용 검진복 상의'; //
    if(prodName === 'gown-set') return '일회용 검진복 상하의 세트'; //
    if(prodName === 'gown-pants') return '일회용 대장 바지';
    if(prodName === 'gown-skirt') return '일회용 검진 치마';
    if(prodName === 'gown-inner') return '일회용 내시경 가운'; //
    if(prodName === 'gown-breast') return '유방검사용 가운'; //
    if(prodName === 'bed-cover') return '베드 커버'; //
    if(prodName === 'pillow-cover') return '베개 커버';
    if(prodName === 'pillow-cover-bag') return '베개 커버 파우치형';
    if(prodName === 'hospital-gown') return '일회용 입원복';
}


export function prodNameSubTitle(prodName) {
    if(prodName === 'mouthpiece') return '(50ea/box)';
    else if(prodName === 'nasal') return '(200ea/box)';
    else if(prodName === 'gown-top') return '(100ea/box)'; //
    else if(prodName === 'gown-set') return '(50ea/box)'; //
    else if(prodName === 'gown-pants') return '(100ea/box)';
    else if(prodName === 'gown-skirt') return '(100ea/box)';
    else if(prodName === 'gown-inner') return '(50ea/box)'; //
    else if(prodName === 'gown-breast') return '(100ea/box)'; //
    else if(prodName === 'bed-cover') return '(10ea/pack)'; //
    else if(prodName === 'pillow-cover') return '(10ea/pack)';
    else if(prodName === 'pillow-cover-bag') return '(10ea/pack)';
    else if(prodName === 'hospital-gown') return '(50ea/box)';
    else return '(ea)';
}

export function prodQuantityType(prodName) {
    if(
        prodName === 'mouthpiece' ||
        prodName === 'nasal' ||
        prodName === 'gown-top' ||
        prodName === 'gown-set' ||
        prodName === 'gown-pants' ||
        prodName === 'gown-skirt' ||
        prodName === 'gown-inner' ||
        prodName === 'gown-breast' ||
        prodName === 'bed-cover' ||
        prodName === 'pillow-cover' ||
        prodName === 'pillow-cover-bag' ||
        prodName === 'hospital-gown'
    ) {
        return 'box';
    } else {
        return 'ea';
    }
}