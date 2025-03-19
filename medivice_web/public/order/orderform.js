import { prodNameExchange } from '../constants.js';

const hospName = document.getElementById('hospName');
const call = document.getElementById('call');
const email = document.getElementById('email');
const addressMain = document.getElementById('address');
const addressDetail = document.getElementById('address-detail');
let totalPrice = 0;

const cartCnt = document.getElementById('cart-cnt');
const cntNumber = document.getElementById('cnt-number');
let cartItemCnt = 0;

document.addEventListener('DOMContentLoaded', () => {
    displayProducts();

    cartCnt.style.display = 'none';
    var cart = getCart();
    
    for(var item in cart) {
        if(cart[item].prodName === 'delete') continue;
        else cartItemCnt++;
    }

    if(cartItemCnt > 0) cartCnt.style.display = 'flex';
    cntNumber.innerText = cartItemCnt;
});

function getCart() {
    var cartCookie = document.cookie.replace(/(?:(?:^|.*;\s*)cart\s*\=\s*([^;]*).*$)|^.*$/, "$1");
    return cartCookie ? JSON.parse(cartCookie) : {};
}

// 연락처 input 문자열 처리
call.addEventListener('input', (e) => {
    let input = e.target.value;

    input = input.replace(/[^0-9]/g, "");

    if(input.length > 11) {
        input = input.substring(0, 11);
    }

    if (input.length <= 3) {
        e.target.value = input; 
    } else if (input.length <= 7) {
        e.target.value = input.slice(0, 3) + "-" + input.slice(3); // 3-4 형식
    }
    else if(input.length <= 10) { 
        e.target.value = input.slice(0, 3) + "-" + input.slice(3, 6) + "-" + input.slice(6);
    }
    else if(input.length > 10) { 
        e.target.value = input.slice(0, 3) + "-" + input.slice(3, 7) + "-" + input.slice(7);
    }
});

// order list 표시
async function displayProducts() {
    const urlParams = new URLSearchParams(window.location.search);
    const products = JSON.parse(decodeURIComponent(urlParams.get('products')));
    const productsArray = Array.isArray(products) ? products : [products];

    totalPrice = 0;

    const formElement = document.getElementById('form-body');
    formElement.innerHTML = '';
    productsArray.map((product) =>{
        totalPrice += parseInt(product.price.replace(/,/g, ''));
        formElement.innerHTML += `
            <div class="form-body-item">
                <div class="order-item" id="product-name">
                    <p>${prodNameExchange(product.prodName)}</p>
                </div>
                <div class="order-item" id="product-standard">
                    <p>${product.standard}</p>
                </div>
                <div class="order-item" id="product-quantity">
                    <p>${product.quantity}</p>
                </div>
                <div class="order-item" id="product-price">
                    <p>${product.price} 원</p>
                </div>
                <div class="order-item" id="product-details">
                    <p>${product.details}</p>
                </div>
            <div>
        `;
    });
    document.getElementById('total-price').value = totalPrice.toLocaleString('ko-KR') + '원';
}

// order form 로직
async function submitInquiry() {
    const urlParams = new URLSearchParams(window.location.search);
    const products = JSON.parse(decodeURIComponent(urlParams.get('products')));
    const productsArray = Array.isArray(products) ? products : [products];

    if(!email.value.includes('@') || !email.value.includes('.')) {
        alert('이메일 형식이 올바르지 않습니다.');
        return;
    }

    if(addressMain.value === '' || addressDetail.value === '') {
        alert('주소를 모두 입력해 주세요.');
        return;
    }

    const orderResponse = await fetch('/api/order/order', {
        method:'POST',
        headers: {"Content-Type":"application/json"},
        body: JSON.stringify({
            products: productsArray, 
            hospName: hospName.value,
            call: call.value,
            email: email.value,
            address: `${addressMain.value} ${addressDetail.value}`,
            price: totalPrice.toLocaleString('ko-KR'),
        }),
    });

    if(orderResponse.redirected) {
        document.cookie = "cart=;max-age=0;path=/";
        window.location.href = orderResponse.url;
    } else {
        const orderResult = await orderResponse.json();
        console.log(`order error: ${orderResult.error}`);
    }
}

document.getElementById('order-form').addEventListener('submit', (e) => {
    e.preventDefault();
    submitInquiry();
});


// 배송지 주소 검색
document.getElementById('search-address-btn').addEventListener('click', (e) => {
    searchAddress();
});

async function searchAddress() {
    new daum.Postcode({
        oncomplete: function(data) {
            document.getElementById('address').value = data.address;
        }
    }).open();
}