import { FORCEP } from '../constants.js';

const prodName = document.getElementById('prodName');
const standard = document.getElementById('standard');
const quantity = document.getElementById('quantity');
const price = document.getElementById('price');

// 초기화
document.addEventListener('DOMContentLoaded', () => {
    price.value = FORCEP.FORCEP_STOMATCH_18;
});

// 장바구니 로직
function addCart(prodName, standard, quantity, price) {
    var cart = getCart();
    cart[prodName] = { 
        prodName: prodName, 
        standard: standard, 
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
    addCart(prodName.value, standard.value, quantity.value, price.value);
}

// 수량 input 마이너스값 제한
document.getElementById('quantity').addEventListener('input', (e) => {
    var regex = /^\d+$/;
    if (!regex.test(e.target.value) || e.target.value <= 0) { 
        e.target.value = '';
    }
});

// 옵션 변경 시 가격 변경 
standard.addEventListener('change', (e) => {    
    var quantityValue = quantity.value;
    if(quantityValue == '') {
        quantityValue = 1;
    }

    switch(e.target.value) {
        case '위 1.8':
            price.value = FORCEP.FORCEP_STOMATCH_18*quantityValue;
            break;
        case '위 1.3':
            price.value = FORCEP.FORCEP_STOMATCH_13*quantityValue;
            break;
        case '대장 1.8':
            price.value = FORCEP.FORCEP_COLON_18*quantityValue;
            break;
        case '대장 1.3':
            price.value = FORCEP.FORCEP_COLON_13*quantityValue;
            break;  
    }
});

// 수량 변경 시 가격 변경
quantity.addEventListener('input', (e) => {
    var quantityValue = quantity.value;
    if(quantityValue == '') {
        quantityValue = 1;
    }

    switch(standard.value) {
        case '위 1.8':
            price.value = FORCEP.FORCEP_STOMATCH_18;
            break;
        case '위 1.3':
            price.value = FORCEP.FORCEP_STOMATCH_13;
            break;
        case '대장 1.8':
            price.value = FORCEP.FORCEP_COLON_18;
            break;
        case '대장 1.3':
            price.value = FORCEP.FORCEP_COLON_13;
            break;
    }

    price.value = price.value * quantityValue;
});

// order-btn
document.getElementById('order-btn').addEventListener('click', async (e) => {
    e.preventDefault();
    if(quantity.value === '') {
        quantity.value = 1;
    }
    order();
});

async function order() {
    if(quantity.value === '') {
        quantity.value = 1;
    }
    
    const products = {
        prodName: prodName.value,
        standard: standard.value,
        quantity: quantity.value,
        price: price.value,
    }

    const encodedProducts = encodeURIComponent(JSON.stringify(products));
    const url = '../order/orderform.html?products='+encodedProducts;
    window.location.href = url;
}
