import { getProdName, prodNameExchange, prodNameSubTitle, prodQuantityType } from '../constants.js';

let prodName;
let PRODNAME;
let quantity;

const price = document.getElementById('price');

// 초기화
document.addEventListener('DOMContentLoaded', () => {
    const urlParams = new URLSearchParams(window.location.search);
    prodName = urlParams.get('prodName');
    PRODNAME = getProdName(prodName);

    const nameTitle = document.getElementById('product-name');
    nameTitle.innerText = prodNameExchange(prodName);
    const subTitle = document.getElementById('product-subtitle')
    subTitle.innerText = prodNameSubTitle(prodName);
    
    price.value = PRODNAME.toLocaleString('ko-KR');

    if(prodQuantityType(prodName) === 'box') {        
        document.getElementById('quantity-ea').style.display = 'none';
        document.getElementById('quantity-box').style.display = 'flex';
        quantity = document.getElementById('quantity-input-box');
    } else {
        document.getElementById('quantity-ea').style.display = 'flex';
        document.getElementById('quantity-box').style.display = 'none';
        quantity = document.getElementById('quantity-input-ea');
    }

    

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
    addCart(prodName, document.getElementById('product-subtitle').innerText, quantity.value + prodQuantityType(prodName), price.value);
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

// 수량 input 마이너스값 제한, 문자열 처리
quantity.addEventListener('input', (e) => {
    var regex = /^\d+$/;
    if (!regex.test(e.target.value) || e.target.value <= 0) { 
        e.target.value = '';
    }

    var quantityValue = e.target.value;
    if(quantityValue === '') {
        quantityValue = 1;
    }

    price.value = (PRODNAME*quantityValue).toLocaleString('ko-KR');
    });
});

// order form 로직
async function order() {
    if(quantity.value === '') {
        quantity.value = 1;
    }
    
    const products = {
        prodName: prodName,
        standard: document.getElementById('product-subtitle').innerText,
        quantity: quantity.value + prodQuantityType(prodName),
        price: price.value,
    }
    
    const encodedProducts = encodeURIComponent(JSON.stringify(products));
    const url = '/order/orderform.html?products='+encodedProducts;
    window.location.href = url;
}