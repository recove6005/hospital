import { FORCEP, SNARE, INJECTOR } from '../constants.js';

const prodName = document.getElementById('prodName');
const forcepStandard = document.getElementById('forcep-standard');
const snareStandard = document.getElementById('snare-standard');
const injectorStandard = document.getElementById('injector-standard');
const quantity = document.getElementById('quantity');
var forcepPrice = FORCEP.FORCEP_STOMATCH_18;
var snarePrice = SNARE.SNARE_5M;
var injectorPrice = INJECTOR.INJECTOR_23G;
const price = document.getElementById('price');


// 초기화
document.addEventListener('DOMContentLoaded', () => {
    price.value = (forcepPrice + snarePrice + injectorPrice).toLocaleString('ko-KR');
});

// 장바구니 로직
function addCart(prodName, setStandard, quantity, price) {
    var cart = getCart();
    cart[prodName] = { 
        prodName: prodName, 
        standard: setStandard, 
        quantity: quantity, 
        price: price,
    };
    setCart(cart);
}

function getCart() {
    var cartCookie = document.cookie.replace(/(?:(?:^|.*;\s*)cart\s*\=\s*([^;]*).*$)|^.*$/, "$1");
    return cartCookie ? JSON.parse(cartCookie) : {};
}

function setCart(cart) {
    document.cookie = "cart="+JSON.stringify(cart) + ";max-age=3600;path=/";
}

// shoppingbag-btn
document.getElementById('shoppingbag-btn').addEventListener('click', (e) => {
    addToShoppingBag();
});

// shoppingbag form 로직
function addToShoppingBag() {
    if(quantity.value === '') {
        quantity.value = 1;
    }
    const setStandard = `포스니 세트 (포셉 ${forcepStandard.value} / 스네어 ${snareStandard.value} / 인젝터 ${injectorStandard.value})`;
    addCart(prodName.value, setStandard, quantity.value, price.value);
    alert('카트에 상품이 추가되었습니다.');
}

// order-btn
document.getElementById('order-btn').addEventListener('click', async (e) => {
    e.preventDefault();
    if(quantity.value === '') {
        quantity.value = 1;
    }
    order();
});

// order form 로직
async function order() {
    if(quantity.value === '') {
        quantity.value = 1;
    }

    const setStandard = `포스니 세트 (포셉 ${forcepStandard.value} / 스네어 ${snareStandard.value} / 인젝터 ${injectorStandard.value})`;
    const products = {
        prodName: prodName.value,
        standard: setStandard,
        quantity: quantity.value,
        price: price.value,
    }

    const encodedProducts = encodeURIComponent(JSON.stringify(products));
    const url = '/order/orderform.html?products='+encodedProducts;
    window.location.href = url;
}

// 수량 input 마이너스값 제한
document.getElementById('quantity').addEventListener('input', (e) => {
    var regex = /^\d+$/;
    if (!regex.test(e.target.value) || e.target.value <= 0) { 
        e.target.value = '';
    }
});

// 옵션 변경 시 가격 변경
forcepStandard.addEventListener('change', (e) => {
    var quantityValue = quantity.value;
    if(quantityValue === '') {
        quantityValue = 1;
    }

    switch(e.target.value) {
        case '위 1.8':
            forcepPrice = FORCEP.FORCEP_STOMATCH_18;
            break;
        case '위 2.3':
            forcepPrice = FORCEP.FORCEP_STOMATCH_23;
            break;
        case '대장 1.8':
            forcepPrice = FORCEP.FORCEP_COLON_18;
            break;
        case '대장 2.3':
            forcepPrice = FORCEP.FORCEP_COLON_23;
            break;
    }
    price.value = ((forcepPrice + snarePrice + injectorPrice) * quantityValue).toLocaleString('ko-KR');
});

snareStandard.addEventListener('change', (e) => {
    var quantityValue = quantity.value;
    if(quantityValue === '') {
        quantityValue = 1;
    }
   
    switch(e.target.value) {
        case '5m':
            snarePrice = SNARE.SNARE_5M;
            break;
        case '7m':
            snarePrice = SNARE.SNARE_7M;
            break;
        case '10m':
            snarePrice = SNARE.SNARE_10M;
            break;
        case '15m':
            snarePrice = SNARE.SNARE_15M;
            break;
    }       
    price.value = ((forcepPrice + snarePrice + injectorPrice) * quantityValue).toLocaleString('ko-KR');
});

injectorStandard.addEventListener('change', (e) => {
    var quantityValue = quantity.value;
    if(quantityValue === '') {
        quantityValue = 1;
    }
   
    switch(e.target.value) {
        case '23G':
            injectorPrice = INJECTOR.INJECTOR_23G;
            break;
        case '25G':
            injectorPrice = INJECTOR.INJECTOR_25G;
            break;
    }
    price.value = ((forcepPrice + snarePrice + injectorPrice) * quantityValue).toLocaleString('ko-KR');
});

// 수량 변경 시 가격 변경
quantity.addEventListener('input', (e) => {
    var quantityValue = quantity.value;
    if(quantityValue === '') {
        quantityValue = 1;
    }
    price.value = ((forcepPrice + snarePrice + injectorPrice) * quantityValue).toLocaleString('ko-KR');
});
