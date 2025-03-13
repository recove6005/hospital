import { prodNameExchange } from '../prodname-exchange.js';

function getCart() {
    var cartCookie = document.cookie.replace(/(?:(?:^|.*;\s*)cart\s*\=\s*([^;]*).*$)|^.*$/, "$1");
    return cartCookie ? JSON.parse(cartCookie) : {};
}

function setCart(cart) {
    document.cookie = "cart="+JSON.stringify(cart) + ";max-age=3600;path=/";
}

function displayCart() {
    var cart = getCart();
    var cartList = document.getElementById('shoppingbag-list');
    cartList.innerHTML = '';
    
    for(var product in cart) {
        var prodName = '-';
        if(cart[product].prodName === 'delete') continue;
        else prodName = prodNameExchange(cart[product].prodName);
        
        const div = document.createElement('div');
        div.id = 'product-container';
        div.innerHTML = `
            <div id="product-select">
                <input class="checkbox" id="${product}" type="checkbox" name="product" value="${product}">
            </div>
            <div id="product-image">
                <img id="product-image" src="../images/main-${prodName}.png" alt="제품 이미지 준비 중">
            </div>
            <div id="product-name">${prodName}</div>
            <div id="product-standard">${cart[product].standard}</div>
            <div id="product-quantity">${cart[product].quantity}</div>
            <div id="product-price">${cart[product].price}</div>
        `;
        cartList.appendChild(div);
    }
}
displayCart();

// order
document.getElementById('order-btn').addEventListener('click', async (e) => {
    var cart = getCart();
    const selectedProducts = [];

    Object.keys(cart).forEach(product => {
        const target = document.getElementById(product);
        if(target?.checked && cart[product].prodName !== 'delete') {
            selectedProducts.push({
                prodName: cart[product].prodName,
                standard: cart[product].standard,
                quantity: cart[product].quantity,
                price: cart[product].price || 0
            });
        }
    });

    if(selectedProducts.length === 0) {
        alert('주문할 상품을 선택해주세요.');
        return;
    }

    const encodedProducts = encodeURIComponent(JSON.stringify(selectedProducts));
    const url = '/order/orderform.html?products='+encodedProducts;
    window.location.href = url;
});

// delete
document.getElementById('delete-btn').addEventListener('click', (e) => {
    var cart = getCart();
    Object.keys(cart).forEach(product => {
        const target = document.getElementById(product);
        if(target?.checked) {
            delete cart[product];
        }
    });
    setCart(cart);
    window.location.reload();
});

// select all
document.getElementById('select-all').addEventListener('click', (e) => {
    var cart = getCart();
    const selectAllCheckbox = e.target;

    Object.keys(cart).forEach(product => {
        const target = document.getElementById(product);
        if(target) {
            target.checked = selectAllCheckbox.checked;
        }
    });
});