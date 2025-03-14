import { prodNameExchange } from '../constants.js';

document.addEventListener('DOMContentLoaded', async () => {
    const urlParams = new URLSearchParams(window.location.search);
    const order_id = urlParams.get('order_id');
    const email = urlParams.get('email');
    const products = JSON.parse(urlParams.get('products'));
    const hospName = urlParams.get('hospName');
    const call = urlParams.get('call');
    const address = urlParams.get('address');

    document.getElementById('order-id').textContent = order_id;
    document.getElementById('email').textContent = email;
    document.getElementById('hosp-name').textContent = hospName;
    document.getElementById('call').textContent = call;
    document.getElementById('address').textContent = address;

    let totalPrice = 0;
    products.forEach(product => {
        const total = parseInt(product.price.replace(/,/g, ''));
        totalPrice += total;
    });

    document.getElementById('price').textContent = totalPrice.toLocaleString('ko-KR') + '원';

    products.forEach(product => {
        const li = document.createElement('li');
        const prodNameDiv = document.createElement('p');
        const quantityDiv = document.createElement('p');
        const standardDiv = document.createElement('p');
        const priceDiv = document.createElement('p');

        prodNameDiv.textContent = `상품명: ${prodNameExchange(product.prodName)}`;
        quantityDiv.textContent = `수량: ${product.quantity}`;
        standardDiv.textContent = `규격: ${product.standard}`;
        priceDiv.textContent = `가격: ${product.price}원`;

        li.appendChild(prodNameDiv);
        li.appendChild(standardDiv);
        li.appendChild(quantityDiv);
        li.appendChild(priceDiv);
        
        document.getElementById('products-list').appendChild(li);
    });
});
