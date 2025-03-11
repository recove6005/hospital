import { prodNameExchange } from '../prodname-exchange.js';

const hospName = document.getElementById('hospName');
const call = document.getElementById('call');
const email = document.getElementById('email');
const address = document.getElementById('address');
let totalPrice = 0;

document.addEventListener('DOMContentLoaded', () => {
    displayProducts();
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
        totalPrice += parseInt(product.price);
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
                    <p>${product.price}</p>
                </div>
            <div>
        `;
    });

    document.getElementById('total-price').value = totalPrice;
}

// order form 로직
async function submitInquiry() {
    const urlParams = new URLSearchParams(window.location.search);
    const products = JSON.parse(decodeURIComponent(urlParams.get('products')));
    const productsArray = Array.isArray(products) ? products : [products];

    const orderResponse = await fetch('/api/order/order', {
        method:'POST',
        headers: {"Content-Type":"application/json"},
        body: JSON.stringify({
            products: productsArray, 
            hospName: hospName.value,
            call: call.value,
            email: email.value,
            address: address.value,
            price: totalPrice,
        }),
    });

    if(orderResponse.ok) {
        window.location.reload();
    } else {
        const orderResult = await orderResponse.json();
        console.log(`order error: ${orderResult.error}`);
    }
}

document.getElementById('order-form').addEventListener('submit', (e) => {
    e.preventDefault();
    submitInquiry();
});
