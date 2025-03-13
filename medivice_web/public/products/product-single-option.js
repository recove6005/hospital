import { getProdName, prodNameExchange } from '../constants.js';

let prodName;
let PRODNAME;
const quantity = document.getElementById('quantity');
const price = document.getElementById('price');

// 초기화
document.addEventListener('DOMContentLoaded', () => {
    const urlParams = new URLSearchParams(window.location.search);
    prodName = urlParams.get('prodName');
    PRODNAME = getProdName(prodName);

    const nameTitle = document.getElementById('product-name');
    nameTitle.innerText = prodNameExchange(prodName);
    
    price.value = PRODNAME.toLocaleString('ko-KR');
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
    e.preventDefault();
    addToShoppingBag();
    window.location.reload();
});

// shoppingbag form 로직
function addToShoppingBag() {
    if(quantity.value === '') {
        quantity.value = 1;
    }
    addCart(prodName, '', quantity.value, price.value);
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
    
    const products = {
        prodName: prodName,
        standard: '',
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

// 수량 변경 시 가격 변경
quantity.addEventListener('input', (e) => {
    var quantityValue = quantity.value;
    if(quantityValue === '') {
        quantityValue = 1;
    }

    price.value = (PRODNAME*quantityValue).toLocaleString('ko-KR');
});

