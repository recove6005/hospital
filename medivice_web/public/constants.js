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

export const CLEANING = { // 내시경 세척액
    "CLEANING_01": 88000, // 에이크린
    "CLEANING_02": 116000, // 오피에이
    "CLEANING_03": 114000, // 울트라
    "CLEANING_04": 144000 // 페라플루
}

export const SET = 55000;
export const MOUTHPIECE = 43500; // 마우스피스 50ea
export const NASAL = 189000; // 나잘케뉼라 200ea
export const BRUSH = 1600; // 내시경 세척 브러시
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
        return CLEANING.CLEANING_04;
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
    if(prodName === 'brush') return '내시경 세척 브러쉬'; //
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

export function getProdThnImagePath(prodName) {
    if(prodName === 'forcep') return '/images/thn/thn-forcep.png';
    else if(prodName === 'snare') return '/images/thn/thn-snare.png';
    else if(prodName === 'injector') return '/images/thn/thn-injector.png';
    else if(prodName === 'set') return '/images/thn/thn-set.png';
    else if(prodName === 'mouthpiece') return '/images/thn/thn-mouthpiece.png';
    else if(prodName === 'pad') return '/images/thn/thn-pad.png'
    else if(prodName === 'brush') return '/images/thn/thn-brush.png';
    else if(prodName === 'cleaning') return '/images/thn/thn-cleaning.png';
    else if(prodName === 'sponge') return '/images/thn/thn-sponge.png';
    else if(prodName === 'nasal') return '/images/thn/thn-nasal.png';
    else if(prodName === 'gown-top') return '/images/thn/thn-gown-top.png'; //
    else if(prodName === 'gown-set') return '/images/thn/thn-gown-set.png'; //
    else if(prodName === 'gown-pants') return '/images/thn/thn-gown-pants.png';
    else if(prodName === 'gown-skirt') return '/images/thn/thn-gown-skirt.png';
    else if(prodName === 'gown-inner') return '/images/thn/thn-gown-inner.png'; //
    else if(prodName === 'gown-breast') return '/images/thn/thn-gown-breast.png'; //
    else if(prodName === 'bed-cover') return '/images/thn/thn-bed-cover.png'; //
    else if(prodName === 'pillow-cover') return '/images/thn/thn-pillow-cover.png';
    else if(prodName === 'pillow-cover-bag') return '/images/thn/thn-pillow-cover-bag.png';
    else if(prodName === 'hospital-gown') return '/images/thn/thn-hospital-gown.png';
    else return '';
}

export function getProdSpecImagePath(prodName) {
    if(prodName === 'mouthpiece') return '/images/spec/spec-mouthpiece.jpg';
    else if(prodName === 'pad') return '/images/spec/spec-pad.jpg';
    else if(prodName === 'brush') return '/images/spec/spec-brush.jpg';
    else if(prodName === 'sponge') return '/images/spec/spec-sponge.png';
    else if(prodName === 'nasal') return '/images/spec/spec-nasal.jpg';
    else if(prodName === 'gown-top') return '/images/spec/spec-gown-top.png'; //
    else if(prodName === 'gown-set') return '/images/spec/spec-gown-set.png'; //
    else if(prodName === 'gown-pants') return '/images/spec/spec-gown-pants.jpg';
    else if(prodName === 'gown-skirt') return '/images/spec/spec-gown-skirt.jpg';
    else if(prodName === 'gown-inner') return '/images/spec/spec-gown-inner.jpg'; //
    else if(prodName === 'gown-breast') return '/images/spec/spec-gown-breast.png'; //
    else if(prodName === 'bed-cover') return '/images/spec/spec-bed-cover.jpg'; //
    else if(prodName === 'pillow-cover') return '/images/spec/spec-pillow-cover.jpg';
    else if(prodName === 'pillow-cover-bag') return '/images/spec/spec-pillow-cover-bag.jpg';
    else if(prodName === 'hospital-gown') return '/images/spec/spec-hospital-gown.png';
    else if(prodName === 'cleaning-01') return '/images/spec/spec-cleaning-01.jpg';
    else if(prodName === 'cleaning-02') return '/images/spec/spec-cleaning-02.jpg';
    else return '(ea)';
}

export function prodNameSubTitle(prodName) {
    if(prodName === 'mouthpiece') return '(50ea/box)';
    else if(prodName === 'cleaning') return '(4L/box)';
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
        prodName === 'hospital-gown' ||
        prodName === 'cleaning'
    ) {
        return 'box';
    } else {
        return 'ea';
    }
}