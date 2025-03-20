import { getProdName, getProdSpecImagePath, getProdThnImagePath, prodNameExchange, prodNameSubTitle, prodQuantityType, CLEANING } from '../constants.js';

let prodName;
let PRODNAME;
let quantity;
let standard;

const price = document.getElementById('price');
const details = document.getElementById('details');
const cartCnt = document.getElementById('cart-cnt');
const cntNumber = document.getElementById('cnt-number');
let cartItemCnt = 0;


// 초기화
document.addEventListener('DOMContentLoaded', () => {
    //
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
    })

    cartCnt.style.display = 'none';
    var cart = getCart();
    
    for(var item in cart) {
        if(cart[item].prodName === 'delete') continue;
        else cartItemCnt++;
    }

    if(cartItemCnt > 0) cartCnt.style.display = 'flex';
    cntNumber.innerText = cartItemCnt;

    // 규격 설정
    console.log(`prod name : ${prodName}`);
    if(
        prodName === 'brush' ||
        prodName === 'cleaning' ||
        prodName === 'gown-top' ||
        prodName === 'gown-set' ||
        prodName === 'gown-inner' ||
        prodName === 'gown-breast' ||
        prodName === 'hospital-gown'
    ) {
        document.getElementById(`standard-container-${prodName}`).style.display = 'flex';
        standard = document.querySelector(`#standard-container-${prodName} #standard`);

        // 옵션 가격 변경 - cleaning
        if(prodName === 'cleaning') {
            document.querySelector(`#standard-container-${prodName} #standard`).addEventListener('input', (e) => {
                console.log(e.target.value);
                if(e.target.value === '디터점스 에이크린액') PRODNAME = CLEANING.CLEANING_01;
                else if(e.target.value === '디터점스 오피에이액') PRODNAME = CLEANING.CLEANING_02;
                else if(e.target.value === '디터점스 울트라') PRODNAME = CLEANING.CLEANING_03;
                else if(e.target.value === '페라플루디액') PRODNAME = CLEANING.CLEANING_04;

                var quantityValue = quantity.value;
                if(quantityValue === '') {
                    quantityValue = 1;
                }
                price.value = (PRODNAME*quantityValue).toLocaleString('ko-KR');
            });
        }
    }
    else {
        standard = document.querySelector('#standard');
        standard.value = document.getElementById('product-subtitle').innerText;
    }

    // 이미지 처리
    const displayImage = document.getElementById('display-img');
    const specImage = document.getElementById('spec-01');
    const specImagePlus = document.getElementById('spec-02');

    displayImage.src = getProdThnImagePath(prodName);
    if(prodName === 'cleaning') {
        specImage.src = getProdSpecImagePath(prodName+'-01');
        specImagePlus.style.display = 'block';
        specImagePlus.src = getProdSpecImagePath(prodName+'-02');
        
    } else {
        specImage.src = getProdSpecImagePath(prodName);
        specImagePlus.style.display = 'none';
    }
});    

// 장바구니 로직
function addCart(prodName, standard, quantity, price, details) {
    var cart = getCart();   
    cart[prodName+standard+quantity] = { 
        prodName: prodName, 
        standard: standard, 
        quantity: quantity, 
        price: price,
        details: details
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

    addCart(prodName, standard.value, quantity.value + prodQuantityType(prodName), price.value, details.value);
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
        standard: standard.value,
        quantity: quantity.value + prodQuantityType(prodName),
        price: price.value,
        details: details.value
    }
    
    const encodedProducts = encodeURIComponent(JSON.stringify(products));
    const url = '/order/orderform.html?products='+encodedProducts;
    window.location.href = url;
}