import { INJECTOR } from '../constants.js';

const prodName = document.getElementById('prodName');
const standard = document.getElementById('standard');
const quantity = document.getElementById('quantity');
const price = document.getElementById('price');
const details = document.getElementById('details');

const cartCnt = document.getElementById('cart-cnt');
const cntNumber = document.getElementById('cnt-number');
let cartItemCnt = 0;

// 초기화
document.addEventListener('DOMContentLoaded', () => {
    price.value = (INJECTOR.INJECTOR_23G).toLocaleString('ko-KR');

    cartCnt.style.display = 'none';
    var cart = getCart();
    
    for(var item in cart) {
        if(cart[item].prodName === 'delete') continue;
        else cartItemCnt++;
    }

    if(cartItemCnt > 0) cartCnt.style.display = 'flex';
    cntNumber.innerText = cartItemCnt;
});

// 장바구니 로직
function addCart(prodName, standard, quantity, price, details) {
    var cart = getCart();
    cart[prodName+standard+quantity] = { 
        prodName: prodName, 
        standard: standard, 
        quantity: quantity, 
        price: price,
        details: details,
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
        quantity.value  = 1;
    }
    addCart(prodName.value, standard.value, quantity.value+'ea', price.value, details.value);
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

async function order() {
    if(quantity.value === '') {
        quantity.value = 1;
    }
    
    const products = {
        prodName: prodName.value,
        standard: standard.value,
        quantity: quantity.value + 'ea',
        price: price.value,
        details: details.value
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
standard.addEventListener('change', (e) => {
    var quantityValue = quantity.value;
    if(quantityValue == '') {
        quantityValue = 1;
    }

    switch(e.target.value) {
        case '23G':
            price.value = (INJECTOR.INJECTOR_23G*quantityValue).toLocaleString('ko-KR');
            break;
        case '25G':
            price.value = (INJECTOR.INJECTOR_25G*quantityValue).toLocaleString('ko-KR');
            break;
    }
});

// 수량 변경 시 가격 변경
quantity.addEventListener('input', (e) => {
    var quantityValue = quantity.value;
    if(quantityValue === '') {
        quantityValue = 1;
    }

    switch(standard.value) {
        case '23G':
            price.value = INJECTOR.INJECTOR_23G;
            break;
        case '25G':
            price.value = INJECTOR.INJECTOR_25G;
            break;
    }

    price.value = (price.value * quantityValue).toLocaleString('ko-KR');
});

